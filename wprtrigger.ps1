<#
.SYNOPSIS
    Start performance monitor counters as triggers to begin WPR tracing
.DESCRIPTION
    This utility is designed to allow an IT admin or troubleshooting technician the ability to setup a powershell job, monitoring a specific indicator counter implicent of error behavior, and use that as a trigger to start/stop WPR tracing for later analysis.

    -counter: Defines the specific performance monitor to observe (i.e. "/Process(lsass)/Process Time %")
    -overunder: Define if you want to trigger above or below a threshold
    -runtime: How long to run WPR once tracing begins
    -sampleinterval: How often to query the performance counter for threshold violations
    -profile: Profile to use for WPR (i.e. "CPU", "NETWORK")*

    * Adheres to WPR command line documentation
.NOTES
    File Name: wprtrigger.ps1
    File Author: Ryan Creecy, McAfee Technical Support Team - Dynamic Endpoint

.LINK
    https://docs.microsoft.com/en-us/windows-hardware/test/wpt/wpr-command-line-options
#>

param(
    [string]$counter = "",
    [string]$overunder = "",
    [int]$runtime = "",
    [int]$sampleinterval = "",
    [string]$profile = ""
)

Function Threshold-Value {
    try:
        if($overunder -eq "over"){
            $threshold = ">="
        }elseif($overunder -eq "under"){
            $threshold = "<"
        }
    else:
        Write-Host "No parameter for -overunder set!" -ForegroundColor Red
}

$counterWatch = {
    Get-Counter -Counter $counter -Continuous -SampleInterval $sampleinterval
}

Start-Job $counterWatch | foreach 