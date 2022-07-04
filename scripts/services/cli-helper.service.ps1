<#
.SYNOPSIS
	service provides helper functions for the main cli. It also ensures that the migrations list is available. 
.DESCRIPTION
    Author: Sebastian Mueller aka SBM (sbm@covis.de)
	Change Log:
		28/06/22	0.1	SBM  Initial Release
#>


#region References 
. $PSScriptRoot\logging.service.ps1
. $PSScriptRoot\spo.service.ps1
. $PSScriptRoot\utility.service.ps1
#end region 

function Set-CLIEnvironment {
    [CmdletBinding()]
    param (
        [string]
        $url
    )
    begin {
        Add-Log -message "Setup CLI Environment"
    }
    process {
        try {
            Add-Log -message "Read cli artifacts which needs to be deployed"
            $migrationsListInformation = Get-JsonObjectFromFile -filePath "$PSScriptRoot\cli.artifacts.json";
            Add-Log -message "$migrationsListInformation";
            Add-Log -message "Add migrations list";
            $list = Add-List -title $migrationsListInformation.lists[0].title;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
    }
}

function Main {
    [CmdletBinding()]
    param (
    )
    begin {
        $startTime = Get-Date;   
        Add-Log -message "Start script deploy-spo-assets" 
    }
    process {
        try {
        }
        catch {
        }
    }
    end {
    }
}

