function Add-Log {
    [CmdletBinding()]
    param (
        [bool]
        $toFile = $true,
        [string]
        $filePath = "$PSScriptRoot\..\log\$((Get-Date).toString("yyyy-MM-dd")).log",
        [bool]
        $toConsole = $true,
        [Parameter(Mandatory = $true)]
        [string]
        $message,
        [ValidateSet('INFO', 'WARNING', 'ERROR', 'NOTES')]
        [string]
        $logLevel = "INFO",
        [System.ConsoleColor]
        $consoleColor = [System.ConsoleColor]::White
    )
    process {
        $dt = (Get-Date).toString("yyyy-MM-dd HH:mm:ss");
        if ($toFile -eq $true) {
            Add-Content -Path $filePath -Value "$dt `t $logLevel `t $message `r`n";
        }        
        if ($toConsole -eq $true) {
            switch ($logLevel) {
                "INFO" { Write-Host "$dt `t $logLevel `t $message" -ForegroundColor Cyan }
                "WARNING" { Write-Host "$dt `t $logLevel `t $message" -ForegroundColor Yellow }
                "ERROR" { Write-Host "$dt `t $logLevel `t $message" -ForegroundColor Red }
                Default { Write-Host "$dt `t $logLevel `t $message" -ForegroundColor $consoleColor }
            }
        }    
    }
}

function Add-ErrorLog {
    [CmdletBinding()]
    param (
        [bool]
        $toFile = $true,
        [string]
        $filePath = "$PSScriptRoot\..\log\$((Get-Date).toString("yyyy-MM-dd")).log",
        [bool]
        $toConsole = $true,
        [System.Management.Automation.ErrorRecord]
        $errorRecord
    )
    process {
        Add-Log -message "$($errorRecord.ScriptStackTrace)" -logLevel "ERROR" -toFile $toFile -toConsole $toConsole -filePath $filePath;
        Add-Log -message "$($errorRecord.Exception.Message)" -logLevel "ERROR" -toFile $toFile -toConsole $toConsole -filePath $filePath;
        Add-Log -message "$($errorRecord.Exception.StackTrace)" -logLevel "ERROR" -toFile $toFile -toConsole $toConsole -filePath $filePath;
    }
}

function Add-Console {
    [CmdletBinding()]
    param (
        [ValidateSet('INFO', 'WARNING', 'ERROR')]
        [string]
        $logLevel = "INFO",
        [string]
        $message
    )
    process {
        Add-Log -message $message -toConsole $true -toFile $false -logLevel $logLevel;
    }
}


function Add-Notes {
    [CmdletBinding()]
    param (
        [string]
        $message
    )
    process {
        Add-Log -message $message -toConsole $true -toFile $false -logLevel "NOTES" -consoleColor White;
    }
}
