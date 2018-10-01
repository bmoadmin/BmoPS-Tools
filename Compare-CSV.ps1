<#
#  Author  : BMO
#  Purpose : To Compare two different CSV files and export the unique values to an output file
#  Created : 10/1/2018
#  Status  : Functional
#>

Param
(
    [parameter(
	    Mandatory=$true
    )]
	[string]$FileOne,
	[string]$FileTwo,
	[string]$OutCSV
)

If($FileOne -eq $null){
    throw "The FileOne value must be specified, please rerun script and specify the FileOne value"
}
ElseIf($FileTwo -eq $null){
    throw "The FileTwo value must be specified, please rerun script and specify the FileTwo value"
} 
ElseIf($OutCSV -eq $null) {
    throw "The OutCSV value must be specified, please rerun script and specify the OutCSV value"
}
Else{
}

$compare_files = Compare-Object -ReferenceObject $(Import-CSV -Path $FileOne) -DifferenceObject $(Import-CSV -Path $FileTwo)

$compare_files_sort = $compare_files | Select @{
    Name='Alias';
	Expression={
        $_.InputObject.Alias
	}
    },
    @{
    Name='PrimarySmtpAddress';
    Expression={
        $_.InputObject.PrimarySmtpAddress
	}
    } 
	
$compare_files_sort | Sort Alias | Export-CSV $OutCSV
