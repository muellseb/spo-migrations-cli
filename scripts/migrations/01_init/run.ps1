<#
.SYNOPSIS
	migration script for initial setup of SPO structure
    - Adds site collection scoped app catalog (site admin connection required!)
    - Adds a site collection term store
.DESCRIPTION
    Author: Sebastian Mueller aka SBM (sbm@covis.de)
	Change Log:
		28/06/22	0.1	SBM  Initial Release
.PARAMETER url
	url of the target SharePoint site collection
#>


[CmdletBinding()]
param (
    [string]
    $url = "https://smu92.sharepoint.com/sites/SPOL",
    [ValidateSet('up', 'down')]
    [string]
    $command
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
$script:migrationName = "01_Init";
#endregion 


#endregion 

<#
.SYNOPSIS 
    The Up method for tis migration script adds a site collection scoped app catalog
#>
function Up {
    begin {
        Add-Log -message "Apply migration $($script:migrationName)" 
    }
    process {
        try {
            Add-Log -message "Add sitecollection scoped app catalog to $url";
            Add-SiteScopedAppCatalog -adminSite "https://smu92-admin.sharepoint.com" -targetSite $url;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished appliying migration $($script:migrationName)" 
    }
}

<#
.SYNOPSIS 
    The Down method for tis migration script removes a site collection scoped app catalog
#>
function Down {
    begin {
        Add-Log -message "Rollback migration $($script:migrationName)" 
    }
    process {
        try {
            Remove-SiteScopedAppCatalog -adminSite "https://smu92-admin.sharepoint.com" -targetSite $url;
            # Add-Log -message "Remove also app catalog list from site";
            # Remove-List -title "Apps for SharePoint" -force $true;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Rolling back migration $($script:migrationName) finished" 
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