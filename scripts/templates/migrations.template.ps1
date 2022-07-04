<#
.SYNOPSIS
	migration summary
.DESCRIPTION
.PARAMETER url
	url of the target SharePoint site collection
.PARAMETER command
	- up - to apply the migration
    - down - to rollback the migration
#>


[CmdletBinding()]
param (
    [string]
    $url = "https://smu92.sharepoint.com/sites/SPOL",
    [ValidateSet('up', 'down')]
    [string]
    $command = "up"
)


#region References 
. $PSScriptRoot\..\..\services\logging.service.ps1
. $PSScriptRoot\..\..\services\spo.service.ps1
. $PSScriptRoot\..\..\services\utility.service.ps1
#endregion 

#region GLOBALCONFIG
$ErrorActionPreference = "Stop"
#endregion


#region migrationscope 
$script:migrationName = "<MIGRATION_NAME>";
$script:configName = "<MIGRATION_NAME>.json";
#endregion 


#endregion 

function Up {
    begin {
        Add-Log -message "Apply migration $($script:migrationName)" 
    }
    process {
        try {
            # .. do whatever is needed
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished appliying migration $($script:migrationName)" 
    }
}

function Down {
    begin {
        Add-Log -message "Rollback migration $($script:migrationName)" 
    }
    process {
        try {
            # .. do whatever is needed
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Rolling back migration $($script:migrationName)" 
    }
}

function Main {
    begin {
        Add-Log -message "Start migration $($script:migrationName)" 
    }
    process {
        try {
            switch ($command) {
                "up" {
                    Add-Log -message "Running up script for migration $($script:migrationName)";
                    Up;
                }
                "down" {
                    Add-Log -message "Running down script for migration $($script:migrationName)";
                    Down;
                }
                Default {
                    Add-Log -message "No script to run for command: $command  in migration $($script:migrationName)";
                }
            }
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished migration $($script:migrationName)" 
    }
}


Main;