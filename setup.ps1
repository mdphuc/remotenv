$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE
$username = $env:USERNAME
$python_version =$(Invoke-Command {python --version})
$python_version = $python_version.SubString(7,$python_version.Length - 7).Split(".")
$python_version = $python_version[0] + $python_version[1]


Invoke-Command {powershell -f ./module.ps1}


