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
    [Parameter(Mandatory)]
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
$script:migrationName = "03_person_fields";
$script:migrationConfig = "$PSScriptRoot\fields.json";
#endregion 


#endregion 

function Up {
    begin {
        Add-Log -message "Apply migration $($script:migrationName)" 
    }
    process {
        try {
            Add-Log -message "load field config"
            $fieldsConfig = Get-JsonObjectFromFile -filePath $script:migrationConfig;

            foreach ($fieldConfig in $fieldsConfig) {
                # TODO: apply different configs based on the field XML config
                try {
                    if ($fieldConfig.xml) {
                        Add-Log -message "Add field from XML";
                        Add-SiteFieldfromXML -xml $fieldConfig.xml;
                    }
                    else {
                        Add-Log -message "Add field from JSON config";
                        Add-Log -message "Get field type as enum value for $($fieldConfig.type)"
                        $fieldType = Get-SPFieldTypeFromText -type $fieldConfig.type;
                        Add-Log -message "Type-> $fieldType"
                        $fieldParams = @{
                            displayName  = $fieldConfig.displayName
                            internalName = $fieldConfig.internalName
                            description  = $fieldConfig.description
                            groupName    = $fieldConfig.groupName
                            type         = $fieldType
                            id           = $fieldConfig.id
                        }
    
                        Add-Log -message "Params-> $fieldParams"
                        Add-SiteField @fieldParams;
                    }
                }
                catch {
                    Add-Log -message "Failed to add field with config $fieldConfig" -logLevel WARNING;
                    Add-ErrorLog -errorRecord $_;
                }
               
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
            Add-Log -message "Delete Fields"
            $fieldsConfig = Get-JsonObjectFromFile -filePath $script:migrationConfig;

            foreach ($fieldConfig in $fieldsConfig) {
                Add-Log -message "Removing field $fieldConfig from site"             
                Remove-SiteFieldByName -identity $fieldConfig.internalName;
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