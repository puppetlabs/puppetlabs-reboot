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

# Force a minimum timeout of 3 second to allow the response to be returned.
If ($timeout -lt 3) {
  $timeout = 3
}

If ($message -ne "") {
  & $executable /r /t $timeout /d p:4:1 /c $message
}
Else {
  & $executable /r /t $timeout /d p:4:1
}


Write-Output "{""status"":""queued"",""timeout"":${timeout}}"

