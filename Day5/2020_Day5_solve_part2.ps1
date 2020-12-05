[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'


$Dayx = 'Day5'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


# FBFBBFFRLR to Id
function convert_FBLR_to_Id ( [string]$fblr ) {
	$Row = [convert]::ToInt32((($fblr.SubString(0,7) -Replace 'F','0') -replace 'B','1'),2)
	$Col = [convert]::ToInt32((($fblr.SubString(7,3) -Replace 'L','0') -replace 'R','1'),2)
	$Id = ($Row * 8) + $Col
	return $Id
}

function convert_Id_to_RowCol ( [int]$Id ) {
	[int]$Col = $Id % 8
	[int]$Row = ($Id - $Col) / 8
	return ( $Row, $Col )
}

# array of existing boarding pass (input) converted to Id
$boarding_pass_list = @( Get-Content $input_file | Foreach-Object { convert_FBLR_to_Id $_ } )
write-verbose "$($boarding_pass_list.Count) entries in $input_file"

# array of missing boarding pass: Id's from 0 to 1023 missing in $boarding_pass_list
$missing_boarding_pass_list = @( for ( $Id = 0; $Id -le 1023; $Id++ ) { if ( $Id -notin $boarding_pass_list ) { $Id } } )
write-verbose "$($missing_boarding_pass_list.Count) missing Id's"

# array of missing boarding pass with ID-1 and ID+1 not missing
$missing_boarding_pass_with_PrevAndNextId = @( foreach ( $Id in $missing_boarding_pass_list ) { 
	if ( (($Id-1) -notin $missing_boarding_pass_list) -and (($Id+1) -notin $missing_boarding_pass_list) ) { $Id }
} )
write-verbose "$($missing_boarding_pass_with_PrevAndNextId.Count) missing Id with ID-1 and ID+1 not missing."

if ( $missing_boarding_pass_with_PrevAndNextId.Count -ne 1 ) {
	$missing_boarding_pass_with_PrevAndNextId
	throw "ERROR: more than 1 missing Id with with ID-1 and ID+1 not missing"
}
else {
	$result = $missing_boarding_pass_with_PrevAndNextId[0]
}
Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"


