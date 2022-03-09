#Dillon Shaver
#CSCI 5742
#Homework 3
#Power Shell Scripting: Schedule Startup Checker
#Description: Creates Scheduled task for Startup Checker script

$path = $PSScriptRoot + '\StartupCheck.ps1'
$taskName = "StartupCheck"
$description = "Checks registry files for changes to registry keys that run applications on startup."
$Date = Get-Date

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument "-File $path"
$trigger = New-ScheduledTaskTrigger -Once -At $Date -RepetitionInterval (New-TimeSpan -Minutes 5)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description $description
