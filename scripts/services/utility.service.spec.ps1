<#
    .SYNOPSIS 
    Test script for testing the SPO.SERVICE
#>

#region References
. $PSScriptRoot\logging.service.ps1
. $PSScriptRoot\utility.service.ps1
#endregion

#region globals
$logFile = "$PSScriptRoot\..\log\tests\$($MyInvocation.MyCommand.Name.Split('.ps1')[0])-$((Get-Date).toString("yyyy-MM-dd")).log"
#endregion

Describe 'Convert tests' {
    BeforeAll {
        # connect to SPO
        Add-Log -message "Start utility service tests" -filePath $logFile;
    }
    It "convert json file to object" {
        $result = Get-JsonObjectFromFile -filePath "$PSScriptRoot\cli.artifacts.json";
        $result | Should -Not -Be $null;
        $result.lists | Should -Not -Be $null; 
    }
}