# Add a fact to find local user sessions
Facter.add(:consolesession) do
  confine :kernel =~ /Darwin/i
  confine :kernel =~ /Windows/i
  confine :kernel =~ /Linux/i

  setcode do
    kernel = Facter.value(:kernel)
    has_session = false
    case kernel
      when /Darwin|Linux/i
        who = Facter::Core::Execution.exec('which who') rescue Facter.debug('Cannot find who exec')
        Facter.debug("Found who exec: #{who}") if who
        sessions = Facter::Core::Execution.exec(who) if File.executable?(who) rescue ''
        has_session = true if sessions.to_s.match(/console|tty[0-9]/i)
      when /Windows/i
        sessions = Facter::Core::Execution.exec("#{ENV['SYSTEMROOT']}\\system32\\cmd.exe /c query session console") rescue ''
        has_session = true if sessions.to_s.match(/Active/i)
      else
        Facter.debug('Unsupported kernel')
    end
    Facter.debug("Found console sessions: #{sessions}") if sessions != ''
    has_session
  end
end
