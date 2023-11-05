$location = $(Invoke-Command {Get-Location}).ToString()
$drive = $($location)[0..1] -join ''
$user = $env:USERPROFILE
$username = $env:USERNAME

mv ./module/remotenv.psm1 .
mv ./remotenv.ps1 ./module
cd "C:\Windows\System32\WindowsPowerShell\v1.0\Modules"
mkdir remotenv
cd $location
cp -R ./* "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\remotenv"