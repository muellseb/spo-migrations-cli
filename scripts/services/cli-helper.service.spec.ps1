<#
    .SYNOPSIS 
    Test script for testing the SPO.SERVICE
#>

#region References
. $PSScriptRoot\logging.service.ps1
. $PSScriptRoot\spo.service.ps1
. $PSScriptRoot\utility.service.ps1
#endregion


BeforeAll {
    # connect to SPO
}


Describe 'Deploy ctype, list and add ctype to list' {
    It "Should create a content type based on a parents content type" {

    }

    It "should add a list" {

    }

    It "should add the content type to the list"
}
function TEST {
    [CmdletBinding()]
    param (
    )
    begin {
        $startTime = Get-Date;   
        Add-Log -message "Start script deploy-spo-assets" 
       
    }
    process {
        try {
            # Connect-SPO;
            $ct = Get-CtsByName;
            Add-Log -message "Add content type SPOL (base = item ct)"
            Add-Ct -parentContentType $ct;
            Add-List -title "TEST 01"

        }
        catch {
            Add-Log -message "$($_.ScriptStackTrace)" -logLevel "ERROR";
            Add-Log -message "$($_.Exception.Message)" -logLevel "ERROR";
        }
    }
    end {
    }
}

TEST;