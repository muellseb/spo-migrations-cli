
#region References 
. $PSScriptRoot\services\logging.service.ps1
#endregion 

#region globals
$logFilePath = "$PSScriptRoot\log\tests\$((Get-Date).toString("yyyy-MM-dd")).log"
#endregion

try {
    $testFiles = Get-ChildItem -Path $PSScriptRoot -Filter *.spec.ps1 -Recurse -ErrorAction Stop -Force;
    foreach ($testFile in $testFiles) {
        Add-Log -message $testFile.FullName -filePath $logFilePath;
        # todo: invoke tests with Invoke-Pester command
    }
}
catch {
    Add-ErrorLog -errorRecord $_ -filePath $logFilePath;
}