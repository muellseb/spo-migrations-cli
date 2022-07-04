
<#
.SYNOPSIS
	Seed script to seed groups, roles and permissions
.DESCRIPTION
    Author: Sebastian Mueller aka SBM (sbm@covis.de)
	Change Log:
		28/06/22	0.1	SBM  Initial Release
.PARAMETER url
	url of the target SharePoint site collection
#>


[CmdletBinding()]
param (
)

#region References 
. $PSScriptRoot\..\services\logging.service.ps1

#region Script scope vars
$script:name = "test.seed.ps1"
$script:config = "test.seed.config.json"
#endregion

function Main {
	begin { Add-Log -message "Seed script $script:name is running"; }
	process {

		if ($script:config) {
			Add-Log -message "Load config from $script:config";
		}

		#... proceed
	}
	end { Add-Log -message "Seed script $script:name finished"; }
}
Main;


