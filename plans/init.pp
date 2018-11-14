# Reboots targets and waits for them to be available again.
#
# @param nodes Targets to reboot.
# @param message Message to log with the reboot (for platforms that support it).
# @param reboot_delay How long (in seconds) to wait before rebooting. Defaults to 1.
# @param disconnect_wait How long (in seconds) to wait before checking whether the server has rebooted. Defaults to 10.
# @param reconnect_timeout How long (in seconds) to attempt to reconnect before giving up. Defaults to 180.
# @param retry_interval How long (in seconds) to wait between retries. Defaults to 1.
plan reboot (
  TargetSpec $nodes,
  Optional[String] $message = undef,
  Integer[1] $reboot_delay = 1,
  Integer[0] $disconnect_wait = 10,
  Integer[0] $reconnect_timeout = 180,
  Integer[0] $retry_interval = 1,
) {
  $targets = get_targets($nodes)

  # Get last boot time
  $begin_boot_time_results = without_default_logging() || {
    run_task('reboot::last_boot_time', $targets)
  }

  # Reboot; catch errors here because the connection may get cut out from underneath
  $reboot_result = run_task('reboot', $nodes, timeout => $reboot_delay, message => $message)

  # Wait long enough for all targets to trigger reboot, plus disconnect_wait to allow for shutdown time.
  $timeouts = $reboot_result.map |$result| { $result['timeout'] }
  $wait = max($timeouts)
  reboot::sleep($wait+$disconnect_wait)

  $start_time = Timestamp()
  # Wait for reboot in a loop
  ## Check if we can connect; if we can retrieve last boot time.
  ## Mark finished for targets with a new last boot time.
  ## If we still have targets check for timeout, sleep if not done.
  $failed = without_default_logging() || {
    $reconnect_timeout.reduce($targets) |$down, $_| {
      if $down.empty() {
        break()
      }

      $plural = if $down.size() > 1 { 's' }
      notice("Waiting: ${$down.size()} target${plural} rebooting")
      $current_boot_time_results = run_task('reboot::last_boot_time', $down, _catch_errors => true)

      # Compare boot times
      $failed_results = $current_boot_time_results.filter |$current_boot_time_res| {
        # If this one errored, need to check it again
        if !$current_boot_time_res.ok() {
          true
        }
        else {
          # If this succeeded, then we have a boot time, compare it against the begin_boot_time
          $target_name = $current_boot_time_res.target().name()
          $begin_boot_time_res = $begin_boot_time_results.find($target_name)

          # If the boot times are the same, then we need to check it again
          $current_boot_time_res.value() == $begin_boot_time_res.value()
        }
      }

      # $failed_results is an array of results, turn it into a ResultSet so we can
      # extract the targets from it
      $failed_targets = ResultSet($failed_results).targets()

      # Check for timeout if we still have failed targets
      if !$failed_targets.empty() {
        $elapsed_time_sec = Integer(Timestamp() - $start_time)
        if $elapsed_time_sec >= $reconnect_timeout {
          fail_plan(
            "Hosts failed to come up after reboot within ${reconnect_timeout} seconds: ${failed_targets}",
            'bolt/reboot-timeout',
            {
              'failed_targets' => $failed_targets,
            }
          )
        }

        # sleep for a small time before trying again
        reboot::sleep($retry_interval)

        # wait for all targets to be available again
        $remaining_time = $reconnect_timeout - $elapsed_time_sec
        wait_until_available($failed_targets, wait_time => $remaining_time, retry_interval => $retry_interval)
      }

      $failed_targets
    }
  }

  if !$failed.empty() {
    fail_plan(
      "Failed to reboot ${failed}",
      'bolt/reboot-failed',
      {
        'failed_targets' => $failed,
      },
    )
  }
}
