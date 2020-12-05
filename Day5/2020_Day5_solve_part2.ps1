[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Year = 2020
$Day = 5
$Part = 2

$input_file = Join-Path $PSScriptRoot "${Year}_Day${Day}_input.txt"

# FBFBBFFRLR to ID
function convert_FBLR_to_ID ( [string]$fblr ) {
	$Row = [convert]::ToInt32( (($fblr.SubString(0,7) -Replace 'F','0') -replace 'B','1'), 2 )
	$Col = [convert]::ToInt32( (($fblr.SubString(7,3) -Replace 'L','0') -replace 'R','1'), 2 )
	$ID = ($Row * 8) + $Col
	return $ID
}

# Boarding passes loaded from input and converted to ID's
$boarding_pass_list = @( Get-Content $input_file | Foreach-Object { convert_FBLR_to_ID $_ } )
write-verbose "$($boarding_pass_list.Count) boarding passes loaded from $input_file"

# ID's missing: ID's from 0 to 1023 missing in $boarding_pass_list
$missing_boarding_pass_list = @( for ( $ID = 0; $ID -le 1023; $ID++ ) { if ( $ID -notin $boarding_pass_list ) { $ID } } )
write-verbose "$($missing_boarding_pass_list.Count) missing ID's"

# ID's missing with ID-1 and ID+1 not missing
$missing_boarding_pass_with_PrevAndNextID = @( foreach ( $ID in $missing_boarding_pass_list ) { 
	if ( (($ID-1) -notin $missing_boarding_pass_list) -and (($ID+1) -notin $missing_boarding_pass_list) ) { $ID }
} )
write-verbose "$($missing_boarding_pass_with_PrevAndNextID.Count) missing ID with ID-1 and ID+1 not missing."

if ( $missing_boarding_pass_with_PrevAndNextID.Count -ne 1 ) {
	throw "ERROR: more than 1 missing ID with with ID-1 and ID+1 not missing"
}
else {
	$result = $missing_boarding_pass_with_PrevAndNextID[0]
}
Write-Output ( "${Year} Day ${Day} Part ${Part} result = ${result}")


