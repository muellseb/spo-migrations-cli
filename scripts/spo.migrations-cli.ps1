<#
.SYNOPSIS
	Script which acts as an migration CLI for structuring SharePoint Online environments (Fields, Ctypes, Lists, Permissions, Groups, Users, Add-Ins, SPFx solutions ...)
.DESCRIPTION
    Author: Sebastian Mueller aka SBM (sbm@covis.de)
	Change Log:
		28/06/22	0.1	SBM  Initial Release
.PARAMETER url
	url of the target SharePoint site collection
.PARAMETER command
	command to execute. 
    - "list" will list all applied migrations, if there is already a migration list
    - "apply" will execute all migrations
    - "rollback" will rollback each migration starting with the latest
    - "seed" will seed the data of the current environment
    - "apply-template" to apply a pnp template on the target site (url parameter). File needs to be added as template.pnp in the same directory as the PowerShell Script ($PSScriptRoot)
    - "export-template" to exporta a pnp template on the target site (url parameter)
    - "add-migration" adds a new migration
.PARAMETER spEnv
    Environment, can be controlled by spo.migration.config.json
.PARAMETER version
    version of the SPO Migrations CLI
.EXAMPLE
    C:\PS> .\spo.migrations-cli.ps1 -command init
.NOTES
    Author: Keith Hill
    Date:   June 28, 2010  
#>
param (
    [string]$url = "https://smu92.sharepoint.com/sites/SPOL",
    [ValidateSet('list', 'apply', 'rollback', 'seed', 'init', 'export-template', 'apply-template', 'add-migration')]
    [string]$command = "list",
    [ValidateSet('DEV', 'CI', 'QA', 'PRD')]
    [string]$spEnv = "DEV",
    [Alias("v")]
    [bool]$version = $false
)


#region References 
. $PSScriptRoot\services\logging.service.ps1
. $PSScriptRoot\services\cli-helper.service.ps1
. $PSScriptRoot\services\spo.service.ps1
. $PSScriptRoot\services\utility.service.ps1

#endregion 
$ErrorActionPreference = "Stop"
#region script Scope
$script:cliArtifacts = $null;
$script:clientId = "813d0910-e2af-445c-9e51-a6ca3b82f295";
$script:secret = "jh_7Q~cSJKRLQCufDE-sckLdspDsZ7fkoz3Vx";
#endregion

#region Command functions


function Init {
    [CmdletBinding()]
    param() 
    begin {
        Connect-SPO;
        Add-Log -message "Start initialization of environment for $url";
    }
    process {
        try {
           
            Set-CLIEnvironment;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finisehd initialization of enviroment for $url";
        Disconnect-PnPOnline;
    }
}

function List {
    [CmdletBinding()]
    param (
    )
    begin {
        Connect-SPO;
        Add-Log -message "list migrations for $url";
         
    }
    process {
        Add-Log -message "Get list of migrations"
        try {
           
            $migrations = Get-SPOMigrationItems;
            foreach ($migration in $migrations) {
                Add-Log -message "$($migration.Title) - $($migration.ID)";
            }
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished listing migrations for $url";
        Disconnect-PnPOnline;
    }
}
function Apply {
    [CmdletBinding()]
    param (
    )
    begin {
        Connect-SPO;
        Add-Log -message "Apply migrations for $url" 
    }
    process {
        try {
            Add-Log -message "get migrations to apply for $url";
            $migrationInformation = Pre-Action;
            if ($migrationInformation.actionMigrations.Count -gt 0) {
                Add-Log -message "$($migrationInformation.actionMigrations.Count) migrations to apply"
                foreach ($migrationToApply in $migrationInformation.actionMigrations) {
                    $migrationTitle = $migrationToApply.Directory.Name;
                    $migrationFullName = $migrationToApply.FullName;
                    Apply-Migration -migrationFullName $migrationFullName -migrationTitle $migrationTitle;
                }
            }
            else {
                Add-Log -message "No migration to apply!";
            }
            
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished applying migrations for $url";
        Disconnect-PnPOnline;
    }
   
}

function Apply-Migration {
    [CmdletBinding()]
    param (
        [string]
        $migrationFullName, 
        [string]
        $migrationTitle
    )
    begin {
        Add-Log -message "apply migration $migrationTitle on path $migrationFullName"; 
    }
    process {
        $migrationFailed = $false;
        try {
            & $migrationFullName -url $url -command up;
        }
        catch {
            $migrationFailed = $true;
            Add-ErrorLog -errorRecord $_;
        }
        finally {
            if ($migrationFailed -eq $false) {
                Add-Log -message "Add migration to SPO list";
                Add-ListItem -listTitle $script:cliArtifacts.lists[0].title -values @{ "Title" = "$migrationTitle" };
            }
        }
    }
}
function Rollback {
    [CmdletBinding()]
    param (
    )
    begin {
        Connect-SPO;
        Add-Log -message "Rollback migrations for $url" 
    }
    process {
        try {
            Add-Log -message "get migrations to rollback for $url";
            $migrationInformation = Pre-Action;
            if ($migrationInformation.actionMigrations.Count -gt 0) {
                Add-Log -message "$($migrationInformation.actionMigrations.Count) migrations to rollback"
                foreach ($migrationToRollback in $migrationInformation.actionMigrations) {
                    $migrationTitle = $migrationToRollback.migration.BaseName;
                    $migrationFullName = $migrationToRollback.migration.FullName;
                    $spMigId = $migrationToRollback.spoid;
                    Rollback-Migration -migrationFullName $migrationFullName -migrationTitle $migrationTitle -spMigId $spMigId;
                }
            }
            else {
                Add-Log -message "No migration to rollback!";
            }
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished rollback migrations for $url";
        Disconnect-PnPOnline;
    }
   
}

function Rollback-Migration {
    [CmdletBinding()]
    param (
        [string]
        $migrationFullName, 
        [string]
        $migrationTitle,
        [string]
        $spMigId
    )
    begin {
        Add-Log -message "Rollback migration $migrationTitle on path $migrationFullName"; 
    }
    process {
        $migrationFailed = $false;
        try {
            & $migrationFullName -url $url -command down;
        }
        catch {
            $migrationFailed = $true;
            Add-ErrorLog -errorRecord $_;
        }
        finally {
            if ($migrationFailed -eq $false) {
                Add-Log -message "Remove migration from SPO list";
                # TODO: remove list item form migration list
                Remove-ListItem -listTitle $script:cliArtifacts.lists[0].title -id $spMigId;
            }
        }
    }
}

function Pre-Action {
    [CmdletBinding()]
    param (
    )
    begin {
        Add-Log -message "Get list of migrations for action $command" 
    }
    process {
        try {

            $appliedMigrations = Get-SPOMigrationItems
            $migrations = Get-ChildItem -Path "$PSScriptRoot\migrations\" -Filter *.ps1  -Recurse | Sort-Object -Property { $_.Directory };
            $migsforAction = @();

            foreach ($migration in $migrations) {
                $migrationTitle = $migration.Directory.Name;
                Add-Log -toFile $false -toConsole $true -message $migrationTitle;
                $migrationApplied = $appliedMigrations | ? {
                    $_.Title -eq $migrationTitle
                };

                switch ($command) {
                    "rollback" { 
                        if ($migrationApplied) {
                            Add-Log -message "migration $migrationTitle already applied. Add as mig for action to rollback mig"
                            $migsforAction += @{migration = $migration; spoid = $migrationApplied.ID }
                        }
                        else {
                            Add-Log -message "migration $migrationTitle not applied yet. No need to roll it back."
                        }
                    }
                    "apply" {
                        if ($migrationApplied) {
                            Add-Log -message "migration $migrationTitle already applied. No need to apply it again."
                        }
                        else {
                            Add-Log -message "migration $migrationTitle not applied yet. Add as mig for action to apply mig."
                            $migsforAction += $migration;
                        }
                    }
                    Default {}
                }
                
            }

            $preActionInfos = [PSCustomObject]@{
                appliedMigrations = $appliedMigrations
                migrations        = $migrations
                actionMigrations  = $migsforAction
            }
            return $preActionInfos;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
    }
}
function Seed {
    [CmdletBinding()]
    param (
    )
    begin {
        $seedDir = "$PSScriptRoot\seed\";
        Add-Log -message "Seeding.." 
        Connect-SPO;
    }
    process {
        try {
            $seedScripts = Get-ChildItem -Path $seedDir -Filter *.seed.ps1;
            foreach ($seedScript in $seedScripts) {
                Add-Log -message "Found seed script $($seedScript.BaseName) - FullName: $($seedScript.FullName)";
                Seed-Script -seedScriptPath $seedScript.FullName;
            }
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Seeds planted!";
        Disconnect-PnPOnline;
    }
}

function Seed-Script {
    [CmdletBinding()]
    param (
        [string]
        $seedScriptPath
    )
    begin {
        Add-Log -message "Run seed script $seedScriptPath" 
    }
    process {
        try {
            & $seedScriptPath;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}

function Add-Migration {
    [CmdletBinding()]
    param (
    )
    begin {
        Add-Log -message "Add new migration" 
        $rollback = 0;
       
    }
    process {
        try {
            # ask for name only allow alphas, nums and underscore
            # add folder with incremented prefix
            # add script & config
            $migrationName = Get-MigrationName;
            $migrationDir = Add-MigrationFolder -migrationName $migrationName;
            $rollback++;
            Copy-MigrationTemplates -migrationName $migrationDir.Name -migrationDirectoryPath $migrationDir.FullName;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
            #TODO: rollback 
            # delete folder if created...
        }
    }
}

function Get-MigrationName {
    [CmdletBinding()]
    param (
    )
    process {
        try {
            # ask for name only allow alphas, nums and underscore
            $isValid = $false;
            $migName = "";
            while ($isValid -eq $false) {
                $migName = Read-Host "Enter your migration name (Allowed charachters: word character - alphanumeric & underscore)";
                $isValid = $migName -match "^\w+$"
            }
            
            return $migName;
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
}
function Add-MigrationFolder {
    [CmdletBinding()]
    param (
        [string]
        $migrationName
    )
    process {
        # add folder with incremented prefix
        $migDirs = Get-ChildItem -Directory -Path "$PSScriptRoot\migrations" -Recurse  | Sort-Object -Property { $_.Name } -Descending
        $lastMigDir = $migDirs[0];
        $lastMigNum = $lastMigDir.Name.Split('_')[0] -as [int];
        $newMigNum = $lastMigNum + 1;
        $newMigDirPrefix = "$($newMigNum)_"
        if ($newMigNum -lt 10) {
            $newMigDirPrefix = "0" + $newMigDirPrefix;
        }
        Add-Log -message "New mig dir prefix: $newMigDirPrefix"
        Add-Log -message "New mig dir name: $($newMigDirPrefix)$($migrationName)";
        Add-Log -message "Create mig dir: $($PSScriptRoot)\migrations\$($newMigDirPrefix)$($migrationName)";
        $migDir = New-Item -Path "$PSScriptRoot\migrations" -Name "$($newMigDirPrefix)$($migrationName)" -ItemType "directory";
        return $migDir;
    }
}
function Copy-MigrationTemplates {
    [CmdletBinding()]
    param (
        [string]
        $migrationDirectoryPath,
        [string]
        $migrationName
    )
    process {
        Copy-Item -Path "$PSScriptRoot\templates\migrations.template.ps1" -Destination "$migrationDirectoryPath\run.ps1";
        Copy-Item -Path "$PSScriptRoot\templates\migrations.config.json" -Destination "$migrationDirectoryPath\config.json";
        $templateContent = (Get-Content -Path "$PSScriptRoot\templates\migrations.template.ps1").Replace('<MIGRATION_NAME>', $migrationName);
        Set-Content -Path "$migrationDirectoryPath\run.ps1" -Value $templateContent;
    }
}

#endregion 

#region helper functions 
function Get-SPOMigrationItems {
    [CmdletBinding()]
    param()
    begin {}
    process {
        try {
            if ($script:cliArtifacts -eq $null) {
                $script:cliArtifacts = Get-JsonObjectFromFile -filePath "$PSScriptRoot\services\cli.artifacts.json";
            }

            $migrations = Get-ListItems -listTitle $script:cliArtifacts.lists[0].title;
            return $migrations;
        }
        catch {
            return null;
        }
    }
}

function Get-SPOMigrationCLIVersion {
    [CmdletBinding()]
    param()
    begin {}
    process {
        try {
            $versionInformation = Get-JsonObjectFromFile -filePath "$PSScriptRoot\spo.migrations-cli.json";
            $carRet = "`r`n";
            $tab = "`t";
            $carTab = "$($carRet)$($tab)";
            $message = "$($carTab)CLI VERSION NOTES$($carTab)Version:$($tab)$($versionInformation.version)$($carTab)Author:$($tab)$($versionInformation.author)$($carTab)Author Homepage:$($tab)$($versionInformation.authorHomePage)";
            Add-Notes -message $message;
        }
        catch {
            return null;
        }
    }
}
#endregion

#endregion 

function Main {
    [CmdletBinding()]
    param (
    )
    begin {
        Add-Log -message "CLI started" 
    }
    process {
        try {
            Add-Log -message "Running $command on $url environment";
            if ($version) {
                Get-SPOMigrationCLIVersion;
                return;
            }
            switch ($command) {
                "list" {
                    List;
                }
                "init" {
                    Init;
                }
                "apply" {
                    Apply;
                }
                "rollback" {
                    Rollback;
                }
                "seed" {
                    Seed;
                }
                "export-template" {
                    Add-Log -message "Command: '$command' not implemented yet!"
                }
                "apply-template" {
                    Add-Log -message "Command: '$command' not implemented yet!"
                }
                "add-migration" {
                    Add-Migration;
                }
                Default {
                    Add-Log -message "No valid command: '$command' executed!";
                }
            }
        }
        catch {
            Add-ErrorLog -errorRecord $_;
        }
    }
    end {
        Add-Log -message "Finished operation $command";
    }
}



Main;

