<#
.SYNOPSIS
	Script which deploys the structure for the SPA web part to be able to persists daily journals as diary
.DESCRIPTION
    Author: Sebastian Mueller aka SBM (sbm@covis.de)
	Change Log:
		28/06/22	0.1	SBM  Initial Release
#>




#region References 
. $PSScriptRoot\logging.service.ps1
#endregion 

#region GLOBALCONFIG
$ErrorActionPreference = "Stop"
#endregion



#region Generic
#endregion

#region Authentication
<#
    .PARAMETER url 
    Parameter to set the SPO url to connect to 
#>
function Connect-SPO {
    [CmdletBinding()]
    param (
        [string]
        $url = "https://smu92.sharepoint.com/sites/SPOL",
        [PSCredential]
        $credentials = (Get-CredentialsOfPersonallSettings)
    )
    process {
        try {
            Add-Log -message "Login to PnP using credentials";
            Connect-PnPOnline -Url $url -Credentials $credentials;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}
#endregion

#region Content Types
function Get-CtsByName {
    [CmdletBinding()]
    param (
        [string]
        $name = "Item"
    )
    process {
        try {
            Add-Log -message "Get Content Type $name";
            $Ct = Get-PnPContentType -Identity $name;
            Add-Log -message "$($Ct.Id) $($Ct.Name)";
            return $Ct;
        }
        catch {
            Add-Log -message "$($_.ScriptStackTrace)" -logLevel "ERROR";
            Add-Log -message "$($_.Exception.Message)" -logLevel "ERROR";
        }
    }
}
function Add-Ct {
    [CmdletBinding()]
    param (
        $parentContentType,
        [string]
        $name = "SPOL",
        [string]
        $description = "BAMUs PnP CT",
        [string]
        $groupName = "SPOL - CTs"
    )
    process {
        try {
            
            Add-PnPContentType -Name $name -Description $description -Group $groupName -ParentContentType $parentContentType;
        }
        catch {
            Add-Log -message "$($_.ScriptStackTrace)" -logLevel "ERROR";
            Add-Log -message "$($_.Exception.Message)" -logLevel "ERROR";
        }
    }
}

function Add-SiteField {
    [CmdletBinding()]
    param (
        [string]
        $displayName = "Kids Diary Field",
        [string]
        $internalName = "kdryTxtField",
        [string]
        $description = "Kids Diary Field xyz",
        [string]
        $groupName = "Kids Diary - Fields",
        [Microsoft.SharePOint.Client.FieldType]
        $type = [Microsoft.SharePoint.Client.FieldType]::Text,
        [string]
        $id
    )
    process {
        try {
            
            Add-PnPField -DisplayName $displayName -InternalName $internalName -Type $type -Id $id -Group $groupName;
        }
        catch {
            Add-Log -message "$($_.ScriptStackTrace)" -logLevel "ERROR";
            Add-Log -message "$($_.Exception.Message)" -logLevel "ERROR";
        }
    }
}

function Add-SiteFieldfromXML {
    [CmdletBinding()]
    param (
        [string]
        $xml
    )
    process {
        try {
            
            Add-PnPFieldFromXml -FieldXml $xml
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Remove-SiteFieldByName {
    [CmdletBinding()]
    param (
        [string]
        $identity
    )
    process {
        try {
            
            Remove-PnPField -Identity $identity -Force;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}
function Add-List {
    [CmdletBinding()]
    param (
        [string]
        $title = "Kids Diary",
        [bool]
        $enableContentTypes = $true,
        [string]
        $url = "",
        [Microsoft.SharePoint.Client.ListTemplateType]
        $template = [Microsoft.SharePoint.Client.ListTemplateType]::GenericList
    )
    process {
        try {
            $whatToDo = "";
            $result = "";
            if ($enableContentTypes) { 
                $whatToDo += "1";
            }
            else {
                $whatToDo += "0"
            }
            if ($url -ne "") {
                $whatToDo += "1";
            }
            else {
                $whatToDo += "0";
            }

            switch ($whatToDo) {
                "00" { $result = New-PnPList -Title $title -Template $template; }
                "01" {
                    $result = New-PnPList -Title $title -Template $template -Url $url;
                }
                "10" {
                    $result = New-PnPList -Title $title -Template $template -EnableContentTypes;
                }
                "11" {
                    $result = New-PnPList -Title $title -Template $template -EnableContentTypes -Url $url;
                }
            }
            return $result;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Remove-List {
    [CmdletBinding()]
    param (
        [string]
        $title,
        [bool]
        $force 
    )
    process {
        
        try {
            if ($force) {
                Remove-PnPList -Identity $title -Force
            }
            else {
                Remove-PnPList -Identity $title;
            }

        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Add-FieldToCtype {
    [CmdletBinding()]
    param (
        [string]
        $internalName,
        [string]
        $ctypeName,
        [bool]
        $required
    )
    process {
        try {
            $result = $null;
            if ($required) {
                $result = Add-PnPFieldToContentType -Field $internalName -ContentType $ctypeName -Required;
            }
            else {
                $result = Add-PnPFieldToContentType -Field $internalName -ContentType $ctypeName;
            }
            return $result;            
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Add-CtypeToList {
    [CmdletBinding()]
    param (
        [string]
        $listName = "SPOL",
        [string]
        $ctypeName = "BAMUs PnP CT",
        [bool]
        $defaultCtype = $true
    )
    process {
        try {
            if ($defaultCtype) {
                $result = Add-PnPContentTypeToList -List $listName -ContentType $ctypeName -DefaultContentType;
                return $result;
            }
            
            $result = Add-PnPContentTypeToList -List $listName -ContentType $ctypeName;
            return $result;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Get-ListItems {
    [CmdletBinding()]
    param (
        [string]
        $listTitle,
        [string[]]
        $fields = @("ID", "Title")
    )
    process {
        Add-Log -message "Get list items for list $listTitle";
        (Get-PnPListItem -List $listTitle  -Fields $fields).FieldValues      
    }
}

function Add-ListItem {
    [CmdletBinding()]
    param (
        [string]
        $listTitle,
        [hashtable]
        $values
    )
    process {
        Add-Log -message "Add item to list $listTitle";
        Add-PnPListItem -List $listTitle -Values $values;    
    }
}

function Remove-ListItem {
    [CmdletBinding()]
    param (
        [string]
        $listTitle,
        [string]
        $id
    )
    process {
        Add-Log -message "Remove item from list $listTitle";
        Remove-PnPListItem -List $listTitle -Identity $id -Force;    
    }
}

function Add-SiteScopedAppCatalog {
    [CmdletBinding()]
    param(
        [string]
        $adminSite,
        [string]
        $targetSite
    )
    begin {
        Connect-SPO -url $adminSite;
    }
    process {
        #TODO: CMDLet requires to connect to admin site before;
        Add-PnPSiteCollectionAppCatalog -Site $targetSite;
    }
    end {
        Disconnect-PnPOnline;
        Connect-SPO;
    }
}
function Remove-SiteScopedAppCatalog {
    [CmdletBinding()]
    param(
        [string]
        $adminSite,
        [string]
        $targetSite
    )
    begin {
        Connect-SPO -url $adminSite;
    }
    process {
        #TODO: CMDLet requires to connect to admin site before;
        Remove-PnPSiteCollectionAppCatalog -Site $targetSite;
    }
    end {
        Disconnect-PnPOnline;
        Connect-SPO;
    }
}
#endregion 



