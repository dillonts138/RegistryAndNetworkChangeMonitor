#Dillon Shaver
#CSCI 5742
#Homework 3
#Power Shell Scripting: Startup Checker
#Description: Checks Multiple registry keys and determines how many properties the key has. If the count of the properties has changed, the key has been altered, and logs change to log file.

# Log and count log paths
$countLog = $PSScriptRoot + '\countLog.json'
$changeLog = $PSScriptRoot + '\changeLog.txt'

# Monitored Registry paths

# Shell Registry Keys

#Current user shell keys
$curUserShell = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
$curUserUserShell = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'
#Local machine shell keys
$localMachShell = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders'
$localMachUserShell = 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders'

# Run Registry Key Definitions

#Current user keys
$curUserRun = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$curUserRunOnce = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
$curUserRunServ = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\RunServices'
#local machine keys
$localMachRun = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Run'
$localMachRunOnce = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunOnce'
$localMachRunServ= 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServices'
$localMachRunServOnce = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\RunServicesOnce'

# Count Variables

#Current user property counts
$curUserRunCount = 0
$curUserRunOnceCount = 0
$curUserRunServ = 0
#Local machin property counts
$localMachRunCount = 0
$localMachRunOnceCount = 0
$localMachRunServCount = 0
$localMachRunServOnceCount = 0


#Recieves a registry key path, and returns the number of properties inside that key
Function Get-PropertyCount {
    Param(
        [Parameter(Mandatory=$True)]
        [string]$KeyPath
    )
    $count = 0
    Get-Item  $KeyPath | Select-Object -ExpandProperty property |
    ForEach-Object {
        $count = $count + 1
    }
    return $count
}

#Recieves a registry key path, checks if the path exists and if so, returns the number of properties,
#otherwise, returns 0. (Note, a path may exist and still contain 0 properties.)
Function Get-Count{
    Param(
        [Parameter(Mandatory=$True)]
        [string]$keyPath
    )
    $countVar = 0
    if(Test-Path $keyPath){
    $countVar = Get-PropertyCount -KeyPath $keyPath
    }
    return $countVar
}

#Recieves a registry path and two values: Current count and former count. 
#If the two values do not match, log key change to changelog with number of added properties.
Function Checkfor-Change{
    Param(
        [Parameter(Mandatory=$True)]
        [string]$keyPath,
        [Parameter(Mandatory=$True)]
        [int]$CurrentCount,
        [Parameter(Mandatory=$True)]
        [int]$FormerCount
    )
    if($CurrentCount -ne $FormerCount){
       $Date = Get-Date
       $logMsg = "$Date | Change to registry detected at $keyPath, Former prop count:$FormerCount | Current Prop count:$CurrentCount"
       $logMsg | Add-Content -Path $changeLog
    }

}

#Test Registry key paths, and if exists, Get Property count for each registry key

#Get Counts for Current User
$curUserRunCount = Get-Count -KeyPath $curUserRun 
$curUserRunOnceCount = Get-Count -KeyPath $curUserRunOnce
$curUserRunServ = Get-Count -KeyPath $curUserRunServ

#Get counts for local machine
$localMachRunCount = Get-Count -KeyPath $localMachRun
$localMachRunOnceCount = Get-Count -KeyPath $localMachRunOnce
$localMachRunServCount = Get-Count -KeyPath $localMachRunServ
$localMachRunServOnceCount = Get-Count -KeyPath $localMachRunServOnce

#Store recieved counts in JSON object to store for later.
$counts = @{
    curUserRunCount = $curUserRunCount
    curUserRunOnceCount = $curUserRunOnceCount
    curUserRunServ = $curUserRunServ
    localMachRunCount = $localMachRunCount
    localMachRunOnceCount = $localMachRunOnceCount
    localMachRunServCount = $localMachRunServCount
    localMachRunServOnceCount = $localMachRunServOnceCount
}

#check for count log file, if exists, continue, otherwise, create file in current directory.
if( Test-Path -Path $countLog)
{
    
}
else{
    New-Item -Path $countLog -ItemType File
}

#Get old counts from count log
$oldCounts = (Get-Content $countLog -Raw) | ConvertFrom-Json
#update count log with new counts
$counts | ConvertTo-Json | Set-Content -Path $countLog

#Test Read and Write
#echo "Old Counts:"
#echo $oldCounts
#echo "New Counts:"
#echo $counts
#echo $oldCounts.curUserRunCount

#Check for change log, if exists, continue,
#Otherwise, create changelog
if (Test-Path -Path $changeLog){

}
else{
    New-Item -Path $changeLog -ItemType File
}


#Compare old counts to new counts, and log changes.

#Check changes for Current User
Checkfor-Change -KeyPath $curUserRun -CurrentCount $curUserRunCount -FormerCount $oldCounts.curUserRunCount
Checkfor-Change -KeyPath $curUserRunOnce -CurrentCount $curUserRunOnceCount -FormerCount $oldCounts.curUserRunOnceCount
Checkfor-Change -KeyPath $curUserRunServ -CurrentCount $curUserRunServCount -FormerCount $oldCounts.curUserRunServCount

#Check changes for local machine
Checkfor-Change -KeyPath $localMachRun -CurrentCount $localMachRunCount -FormerCount $oldCounts.localMachRunCount
Checkfor-Change -KeyPath $localMachRunOnce -CurrentCount $localMachRunOnceCount -FormerCount $oldCounts.localMachRunOnceCount
Checkfor-Change -KeyPath $localMachRunServ -CurrentCount $localMachRunServCount -FormerCount $oldCounts.localMachRunServCount
Checkfor-Change -KeyPath $localMachRunServOnce -CurrentCount $localMachRunServOnceCount -FormerCount $oldCounts.localMachRunServOnceCount

#Test CheckFor-Change function
#Checkfor-Change -keyPath $curUserRun -CurrentCount 0 -FormerCount 1