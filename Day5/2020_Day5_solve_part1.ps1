[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day5'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


# FBFBBFFRLR to 357
function convert_FBLR_to_Id ( [string]$fblr ) {
	if ( $fblr -notmatch '^(F|B){7}(L|R){3}$' ) { throw 'Invalid fblr code' }
	
	# row
	$row_bin = ($fblr.SubString(0,7) -Replace 'F','0') -replace 'B','1'
	$row = [convert]::ToInt32($row_bin,2)
	
	# column
	$col_bin = ($fblr.SubString(7,3) -Replace 'L','0') -replace 'R','1'
	$col = [convert]::ToInt32($col_bin,2)
	
	
	return ( [int](($row * 8) + $col) )
}


$result = -1
$line_number = 1

Get-Content $input_file | Foreach-Object {

	$Id = convert_FBLR_to_Id $_
	if ( $Id -gt $result ) {
		write-verbose ( "line #${line_number} had a greater Id: $_ => $Id" )
		$result = $Id
	}
	
	$line_number += 1
}

Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "result = $result"


