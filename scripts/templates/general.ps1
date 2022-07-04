<#
.SYNOPSIS
	
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
    $url = "https://smu92.sharepoint.com/sites/SPOL"
)


#region References 
. $PSScriptRoot\..\logging.service.ps1
. $PSScriptRoot\..\spo.service.ps1