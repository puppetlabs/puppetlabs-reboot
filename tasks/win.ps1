[CmdletBinding()]
Param(
  [String]$message = "",
  [Int]$timeout = 3
)
# If an error is encountered, the script will stop instead of the default of "Continue"
$ErrorActionPreference = "Stop"

If (Test-Path -Path $env:SYSTEMROOT\sysnative\shutdown.exe) {
  $executable = "$env:SYSTEMROOT\sysnative\shutdown.exe"
}
ElseIf (Test-Path -Path $env:SYSTEMROOT\system32\shutdown.exe) {
  $executable = "$env:SYSTEMROOT\system32\shutdown.exe"
}
Else {
  $executable = "shutdown.exe"
}

cmd /c start $executable /r /t $timeout /d p:4:1 $message

Write-Output "{""status"":""queued"",""timeout"":${timeout}}"

