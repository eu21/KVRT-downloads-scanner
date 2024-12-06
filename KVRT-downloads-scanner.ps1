<#
 .SYNOPSIS
  Scan for viruses with Kaspersky Virus Removal Tool

 .DESCRIPTION


 .EXAMPLE
  KVRT-downloads-scanner.ps1

 .LINK
  https://s3.by/

 .NOTES
  Version:        0.2
  Author:         Kuzniatsou Yuheni
  Email:          phpsql.net@gmail.com
  Creation Date:  23.11.2024
  Purpose/Change: PowerShell Script to scan downloaded files. Supports integration with Download Managers like IDM

#>

#This will show you the current setting (e.g., Restricted, AllSigned, RemoteSigned, Unrestricted).
#Set-ExecutionPolicy Unrestricted


    param(
    [switch]$UpdateBases = $false,
    [string]$customPath = "%appdata%"
)

#Uncomment(Uncommon) to always download new tools(but make sure that the links $KVRTurl and $UUurl are correct)
#Remove-Item  -Recurse -Path "$KVRTPath" -Force -ErrorAction SilentlyContinue

$KVRTurl = "https://devbuilds.s.kaspersky-labs.com/devbuilds/KVRT/latest/full/KVRT.exe"
$UUurl = "http://products.s.kaspersky-labs.com/special/kasp_updater3.0/4.1.0.517/english-4.1.0.517/3839303233357c44454c7c31/kuu4.1.0.517_en.zip"

#EXAMPLES how to call from cmd.exe EXAMPLES
#"C:\Program Files\PowerShell\7\pwsh.exe" d:\portable\KVRTScriptDev\KVRT-downloads-scanner.ps1 -UpdateBases:$false -customPath "d:\Downloads\Compressed\Ex_Files_NLP_Python_ML_EssT.zip"
#"%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe" d:\portable\KVRTScriptDev\KVRT-downloads-scanner.ps1 -UpdateBases:$false -customPath d:\KVRTcopyfiles_here\
#"C:\Program Files\PowerShell\7\pwsh.exe" d:\portable\KVRTScriptDev\KVRT-downloads-scanner.ps1 -UpdateBases:$false -customPath "d:\Downloads\"


#"C:\Program Files\PowerShell\7\pwsh.exe" d:\portable\KVRTScriptDev\KVRT-downloads-scanner.ps1 -UpdateBases:$false -customPath "d:\Downloads\"

# Set the console encoding to UTF-8
$OutputEncoding = [System.Text.Encoding]::UTF8

$returnStateOK = 0
$returnStateWarning = 1
$returnStateCritical = 2
$returnStateUnknown = 3

#$ErrorActionPreference = "SilentlyContinue"

$errorstr = ""
$KVRTPath = "d:\portable\KVRTScriptWorkingDir111"

############################# updater.ini #############################

$updaterini = @"
[ConnectionSettings]
TimeoutConnection=60
UsePassiveFtpMode=true
UseProxyServer=false
AutomaticallyDetectProxyServerSettings=true
UseSpecifiedProxyServerSettings=false
AddressProxyServer=
PortProxyServer=8080
UseAuthenticationProxyServer=false
UserNameProxyServer=
PasswordProxyServer=
ByPassProxyServer=true
DownloadPatches=false

[AdditionalSettings]
CreateCrashDumpFile=true
TurnTrace=false
AddIconToTray=true
MinimizeProgramUponTermination=true
AnimateIcon=true
ReturnCodeDesc=All_files_are_up-to-date

[ReportSettings]
DisplayReportsOnScreen=false
SaveReportsToFile=true
AppendToPreviousFile=true
SizeLogFileValue=104852
ReportFileName=d:\\portable\\KVRTScriptWorkingDir\\UU\\Update-Report.log
DeleteIfSize=true
DeleteIfNumDay=false
NoChangeLogFile=false
NumDayLifeLOgFileValue=7

[DirectoriesSettings]
MoveToCurrentFolder=false
MoveToCustomFolder=true
UpdatesFolder=d:\\portable\\KVRTScriptWorkingDir\\UU\\Updates
TempFolder=d:\\portable\\KVRTScriptWorkingDir\\UU\\Temp
ClearTempFolder=false

[UpdatesSourceSettings]
SourceCustomPath=
SourceCustom=false
SourceKlabServer=true

[DownloadingSettings]
DownloadDataBasesAndModules=true

[ComponentSettings]
DownloadAllDatabases=false
DownloadSelectedComponents=true
ApplicationsOs=1
KasperskyFreeAntivirus_19_0=true


[ShedulerSettings]
LastUpdate=@Variant(\0\0\0\x10\0%\x82\x9d\x3\xcd\xda\x32\xff)
ShedulerType=0
PeriodValue=1
UseTime=true
Time=@Variant(\0\0\0\xf\0\0\0\0)
Monday=true
Tuesday=true
Wednesday=true
Thursday=true
Friday=true
Saturday=true
Sunday=true

[SdkSettings]
PrimaryIndexFileName=u0607g.xml
PrimaryIndexRelativeUrlPath=index
LicensePath=
SimpleModeLicensing=true
"@

############################# updater.ini #############################

#Script Timer
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start() #Start Timer


$exeFileName = "KVRT.exe"
$fullEXEfileName = Join-Path $KVRTPath $exeFileName

#If there is no folder, then create and fill it our tools KVRT.exe and Kaspersky Updater Utility
if (!(Test-Path -Path $fullEXEfileName -PathType Leaf)) {
  Try {
    Write-Verbose "Создаем директории"
    New-Item -ErrorAction Ignore -ItemType directory -Path $KVRTPath
    New-Item -ErrorAction Ignore -ItemType directory -Path "$KVRTPath\UU"

    Write-Verbose "Загружаем Kaspersky Virus Removal Tool из: $KVRTurl"
    Invoke-WebRequest -URI $KVRTurl -UseBasicParsing -OutFile "$KVRTPath\KVRT.exe"

  } catch [System.Exception] {
    $errorstr = $_.Exception.toString()
    Write-Host $errorstr
    [System.Environment]::Exit($returnStateCritical)
  }

}

$zipFileName = "kuu4.1.0.517_en.zip"
$fullZipPath = Join-Path $KVRTPath $zipFileName

#If there is no folder, then create and fill it our tools KVRT.exe and Kaspersky Updater Utility
if (!(Test-Path -Path $fullZipPath -PathType Leaf)) {
    Try {
      Write-Verbose "Создаем директории"
      New-Item -ErrorAction Ignore -ItemType directory -Path $KVRTPath
      New-Item -ErrorAction Ignore -ItemType directory -Path "$KVRTPath\UU"

      Write-Verbose "Загружаем Kaspersky Update Utility из: $UUurl"
      Invoke-WebRequest -URI $UUurl -UseBasicParsing -OutFile "$KVRTPath\kuu4.1.0.517_en.zip"
      Write-Verbose "Распаковываем архив c Kaspersky Update Utility в $KVRTPath\UU"
      Expand-Archive -Path "$KVRTPath\kuu4.1.0.517_en.zip"  -DestinationPath "$KVRTPath\UU" -Force
  
      Remove-Item -Path "$KVRTPath\kuu4.1.0.517_en.zip" -Force -ErrorAction SilentlyContinue
  
  
    } catch [System.Exception] {
      $errorstr = $_.Exception.toString()
      Write-Host $errorstr
      [System.Environment]::Exit($returnStateCritical)
    }
  
  }


if ($UpdateBases) {
    Write-Verbose "New config file Kaspersky Update Utility 3.0"
    $updaterini -replace '\n', "`r`n" | Out-File -FilePath "$KVRTPath\UU\updater.ini" -Force -Encoding ascii

    Write-Verbose "Updating virus bases..." 

    try {
        $process = Start-Process -FilePath "$KVRTPath\UU\UpdateUtility-Console.exe" -ArgumentList "-u -s -r -o ""$KVRTPath\UU\updater.ini""" -Wait -PassThru -RedirectStandardOutput "update_output.log" -RedirectStandardError "update_error.log"
    
        if ($process.ExitCode -eq 0) {
            Write-Verbose "UpdateUtility completed successfully."
        } else {
            Write-Warning "UpdateUtility returned error code $($process.ExitCode). Check update_output.log and update_error.log for details."
        }
    }
    catch {
        Write-Error "Error running UpdateUtility: $($_.Exception.Message)"
    }

}


$scannowDate = Get-Date -Format "yyyyMMdd"

if (!(Test-Path "$KVRTPath\$scannowDate")) {
    New-Item -ErrorAction Ignore -ItemType directory -Path "$KVRTPath\$scannowDate"
}


Write-Verbose "Starting scanning ..."
#$resultScan = & "$KVRTPath\KVRT.exe" -d "$KVRTPath\$scannowDate" -accepteula -silent -processlevel 0 -dontencrypt -moddirpath "$KVRTPath\UU\Updates" -custom "d:\portable\KVRTScriptWorkingDir\lab\" -details -noads -tracelevel DBG -trace -d "d:\portable\KVRTScriptWorkingDir\"
$resultScan = & "$KVRTPath\KVRT.exe" -custom "$customPath" -d "$KVRTPath\$scannowDate" -accepteula -silent -processlevel 0 -dontencrypt -moddirpath "$KVRTPath\UU\Updates" -details -noads -fixednames

#Good idea to run with -fixednames parameter so it would be more easily found in task manager as KVRT.exe

# try {
#   $resultScan = Start-Process -FilePath "$KVRTPath\KVRT.exe" -ArgumentList "-custom ""$customPath"" -d ""$KVRTPath\$scannowDate"" -accepteula -silent -fixednames -dontencrypt -processlevel 1" `
#                                 -RedirectStandardOutput "kvrt_output.log" `
#                                 -RedirectStandardError "kvrt_error.log" `
#                                 -Wait `
#                                 -PassThru

#   if ($resultScan.ExitCode -eq 0) {
#       Write-Host "KVRT scan completed successfully. See kvrt_output.log for details."
#   } else {
#       Write-Warning "KVRT scan returned error code $($resultScan.ExitCode). Check kvrt_error.log for details."
#   }
# }
# catch {
#   Write-Error "Error running KVRT: $($_.Exception.Message)"
# }


Write-Host "OK - AV scan started"

$watch.Stop() #Stop timer
Write-Host $watch.Elapsed #Execution time
Write-Host (Get-Date)

Write-Host "Check log files to inspect the results of scanning $KVRTPath\$scannowDate\Reports"




#[System.Environment]::Exit($returnStateOK)

# KVRT.exe parameters
# -trace — turn on collecting traces.
# -freboot — enable Advanced mode. Reboot and scan.
# -d <folder_path> — specify the folder for reports, Quarantine and trace files.
# -accepteula — automatically accept the License Agreement, Privacy Policy and KSN agreement.
# -silent — run without graphic interface.
# -adinsilent — active disinfection without displaying graphical user interface.
# -processlevel <level> — set threat levels for objects to be neutralized in the console mode:
# 0 - only scan
# 1 — neutralize objects with high threat level
# 2 — neutralize objects with high and medium threat levels
# 3 — neutralize objects with high, medium and low threat levels
# -fixednames — disable file name randomization.
# -en — run the tool with the English interface.
# -moddirpath — specify the folder with antivirus databases.
# -dontcryptsupportinfo — disable encryption of trace files, reports and dump files.
# -fupdate — enable notifications in case tool’s bases are outdated.
# -allvolumes — add a scan of all logical drives.
# -custom <folder_path> — add a scan of a selected folder. You can only select one folder. To scan several folders at a time, use the -customlist parameter.
# -customlist <file_path> — add a scan of folders specified in the text file.


# Задать уровень трассировок.
# - `ERR` – только события с ошибками.
# - `WRN` – события с предупреждениями и ошибками.
# - `INF` – информационные события, события с предупреждениями и ошибками (по умолчанию).
# - `DBG` – все события.
# `./kvrt.run -- -trace -tracelevel ERR`

