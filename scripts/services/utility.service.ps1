#region References
. $PSScriptRoot\logging.service.ps1
#endregion

function Get-JsonObjectFromFile {
    [CmdletBinding()]
    param (
        [string]
        $filePath
    )
    process {
        try {
            $jsonContent = Get-Content -Path $filePath;
            Add-Log -message "$jsonContent";
            $jsonObj = $jsonContent | Out-String | ConvertFrom-Json;
            return $jsonObj;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Get-SPFieldTypeFromText {
    [CmdletBinding()]
    param (
        [string]
        $type
    )
    process {
        try {
            switch ($type) {
                "Text" { return [Microsoft.SharePoint.Client.FieldType]::Text }
                "Boolean" { return [Microsoft.SharePoint.Client.FieldType]::Boolean }
                "DateTime" { return [Microsoft.SharePoint.Client.FieldType]::DateTime }
                "Number" { return [Microsoft.SharePoint.Client.FieldType]::Number }
                "Lookup" { return [Microsoft.SharePoint.Client.FieldType]::Lookup }
                "User" { return [Microsoft.SharePoint.Client.FieldType]::User }
                "Note" { return [Microsoft.SharePoint.Client.FieldType]::Note }
                Default {}
            }
        }
        catch {
        
        }
    }
}

function Get-CredentialsOfPersonallSettings {
    [CmdletBinding()]
    param(
        [string]
        $fileToPersonalSettings = "$PSScriptRoot\..\..\personal_settings.json"
    )
    process {
        $personalSettings = Get-JsonObjectFromFile -filePath $fileToPersonalSettings;
        # Define Credentials
        [string]$userName = $personalSettings.userName;
        [string]$userPassword = $personalSettings.password;

        # Crete credential Object
        [SecureString]$secureString = $userPassword | ConvertTo-SecureString -AsPlainText -Force 
        [PSCredential]$credentialObejct = New-Object System.Management.Automation.PSCredential -ArgumentList $userName, $secureString

        return $credentialObejct;
    }
}
function Get-SPOListsFromJsonFile {
    [CmdletBinding()]
    param (
        [string]
        $filePath
    )
    process {
        try {
        
        }
        catch {
        
        }
    }
}
function Get-SPOFieldsFromJsonFile {
    [CmdletBinding()]
    param (
        [string]
        $filePath
    )
    process {
        try {
        
        }
        catch {
        
        }
    }
}

function Get-SPOContentTypesFromJsonFile {
    [CmdletBinding()]
    param (
        [string]
        $filePath
    )
    process {
        try {
        
        }
        catch {
        
        }
    }
}

