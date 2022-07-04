<#
.SYNOPSIS
	migration script for initial setup of SPO structure
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
$script:migrationName = "02_lists";
#endregion 


#endregion 

function Up {
    begin {
        Add-Log -message "Apply migration $($script:migrationName)" 
    }
    process {
        try {
            Add-Log -message "Get list definitions from json file"
            $lists = Get-JsonObjectFromFile -filePath "$PSScriptRoot\lists.json";
            Add-Log -message "Foreach listdefinition, add the list to SPO";
            foreach ($list in $lists) {
                Add-Log -message "Add list $($list.title) at url $($list.url)";
                Add-List -title $list.title -url $list.url;
            }
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
            Add-Log -message "Remove list instances from json file"
            $lists = Get-JsonObjectFromFile -filePath "$PSScriptRoot\lists.json";
            Add-Log -message "Foreach listdefinition, remove the list from SPO";
            foreach ($list in $lists) {
                Add-Log -message "Remove list $($list.title) at url $($list.url)";
                Remove-List -title $list.title -force $true;
            }
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