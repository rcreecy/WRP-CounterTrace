<#
.SYNOPSIS
    Start performance monitor counters as triggers to begin WPR tracing
.DESCRIPTION
    This utility is designed to allow an IT admin or troubleshooting technician the ability to setup a powershell job, monitoring a specific indicator counter implicent of error behavior, and use that as a trigger to start/stop WPR tracing for later analysis.

    -counter: Defines the specific performance monitor to observe (i.e. "/Process(lsass)/Process Time %", respective of Powershells Get-Counter cmdlet parameters)
    -overunder: Define if you want to trigger above or below a threshold (Accepts over/under)
    -maxsamples: Define how many samples to gather before escaping script (Defaults to 5, multiply this by your sample interval to determine true sample collection timewindow)
    -runtime: How long to run WPR once tracing begins
    -sampleinterval: How often to query the performance counter for threshold violations
    -profile: Profile to use for WPR (i.e. "CPU", "NETWORK")*

    * Adheres to WPR command line documentation
.NOTES
    File Name: wprtrigger.ps1
    File Author: Ryan Creecy

.LINK
    https://docs.microsoft.com/en-us/windows-hardware/test/wpt/wpr-command-line-options
#>

param( # Start parameters for script execution and job setup
    [Parameter(Mandatory=$true)]
    [string]$counter = "",
    [Parameter(Mandatory=$true)]
    [string]$overunder = "",
    [Parameter(Mandatory=$true)]
    [int]$maxsamples = 5,
    [Parameter(Mandatory=$true)]
    [int]$runtime = "",
    [Parameter(Mandatory=$true)]
    [int]$sampleinterval = "",
    [Parameter(Mandatory=$true)]
    [string]$profile = ""
) # End Parameters

Function Threshold-Value(){ # Validates -overunder parameter
    Try{
        if($overunder -eq "over"){
            $threshold = "-gt"
        }elseif($overunder -eq "under"){
            $threshold = "-lt"
        }else{
            Write-Host "Invalid parameter for -overunder (over/under)"
        }
    }
    Catch{
        return # There may be a better way to do this moving forward
    }
}

Function Counter-Watch(){ # Uses CLI parameters -counter and -sample interval
    Try{
        [array]$counterstack = Get-Counter -Counter $counter -SampleInterval $sampleinterval -MaxSamples $maxsamples
        $counterarray = ForEach-Object {$_.CounterSamples[0].CookedValue} 
        Write-Host $counterarray
    }
    Catch{
        Write-Host "Establishing counter values failed - It's possible the Counter used is invalid" -ForegroundColor Red
    }
}

& Counter-Watch