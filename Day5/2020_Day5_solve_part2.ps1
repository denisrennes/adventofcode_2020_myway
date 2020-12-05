[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'


$Dayx = 'Day5'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


# FBFBBFFRLR to Id, Row, Col
function convert_FBLR_to_IdRowCol ( [string]$fblr ) {
	if ( $fblr -notmatch '^(F|B){7}(L|R){3}$' ) { throw 'Invalid fblr code' }
	
	# row
	$row_bin = ($fblr.SubString(0,7) -Replace 'F','0') -replace 'B','1'
	$Row = [convert]::ToInt32($row_bin,2)
	
	# column
	$col_bin = ($fblr.SubString(7,3) -Replace 'L','0') -replace 'R','1'
	$Col = [convert]::ToInt32($col_bin,2)
	
	# Id
	$Id = ($Row * 8) + $Col
	
	return ($Id, $Row, $Col)
}


function convert_Id_to_RowCol ( [int]$Id ) {
	if ( ($Id -lt 0) -or ($Id -gt 1027) ) { throw 'Invalid Id (must be 0 to 1027)' }
	
	# column
	[int]$Col = $Id % 8

	# row
	[int]$Row = ($Id - $Col) / 8
	
	return ( $Row, $Col )
}
#>


[int]$Id = -1
[int]$Row = -1
[int]$Col = -1

# array of existing boarding pass (input): hash table with key = Id and value = Row
$boarding_pass_list = @{}
Get-Content $input_file | Foreach-Object {
	$Id, $Row, $Col = convert_FBLR_to_IdRowCol $_
	$boarding_pass_list.Add( $Id, $Row ) | Out-Null
}
write-verbose "$($boarding_pass_list.Count) entries in $input_file"

# array of missing boarding pass: Id's from 0 to 1023 missing in $boarding_pass_list.keys (Id's): hash table with key = Id and value = Row
$missing_boarding_pass_list = @{}
for ( $Id = 0; $Id -le 1023; $Id++ ) {
	try { 
		$Col = $boarding_pass_list.$Id
		Write-Verbose "$Id is not missing"
	}
	catch {
		Write-Verbose "$Id is missing"
		$Row, $Col = convert_Id_to_RowCol $Id
		$missing_boarding_pass_list.Add( $Id, $Row ) | Out-Null
	}
}
write-verbose "$($missing_boarding_pass_list.Count) missing Id"

# array of missing boarding pass with neighbours, i.e. with ID-1 and ID+1 not missing : hash table with key = Id and value = Row
$missing_boarding_pass_with_neighbours_list = @{}
$missing_id_list = $missing_boarding_pass_list.keys
foreach ( $Id in $missing_id_list ) {
	try { 
		$null = $boarding_pass_list.$($Id - 1)
		$null = $boarding_pass_list.$($Id + 1)
		$has_neighbours = $true
	}
	catch {
		write-verbose "nope: $Id is missing but $($Id-1) and/or $($Id+1) are/is missing too."
		$has_neighbours = $false
	}
	if ( $has_neighbours ) {
		Write-Verbose "$Id is missing and has neighbours"
		$missing_boarding_pass_with_neighbours_list.Add( $Id, ($missing_boarding_pass_list.$Id) ) | Out-Null
	}
}
write-verbose "$($missing_boarding_pass_with_neighbours_list.Count) missing Id with neighbours"

if ( $missing_boarding_pass_with_neighbours_list.Count -ne 1 ) {
	$missing_boarding_pass_with_neighbours_list
	throw "ERROR: more than 1 missing Id with neighbours:"
}
else {
	$result = $missing_boarding_pass_with_neighbours_list.keys[0]
}
Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"


