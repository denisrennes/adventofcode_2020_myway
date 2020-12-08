[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Year = 2020
$Day = 5
$Part = 2

$input_file = Join-Path $PSScriptRoot "alternate_${Year}_Day${Day}_input.txt"

# FBFBBFFRLR to ID
function convert_FBLR_to_ID ( [string]$fblr ) {
	return ( [convert]::ToInt32( (($fblr -Replace 'F|L','0') -replace 'B|R','1'), 2 ) )
}

# ID to Row,Col
function convert_ID_to_RowCol ( [int]$ID ) {
	[int]$Col = $ID % 8
	[int]$Row = ($ID - $Col) / 8
	return ($Row, $Col)
}

# Row,Col to FBFBBFFRLR
function convert_RowCol_to_FBLR ( [int]$Row, [int]$Col ) {
	$bin = [convert]::ToString( ($Row*8+$Col), 2 ).PadLeft(10,'0')
	$FBLR = (($bin.substring(0,7) -replace '0','F') -replace '1','B') + (($bin.substring(7,3) -replace '0','L') -replace '1','R') 
	return ( $FBLR )
}

# Boarding passes loaded from input and converted to ID's
$boarding_pass_list = @( Get-Content $input_file | Foreach-Object { convert_FBLR_to_ID $_ } )
write-verbose "$($boarding_pass_list.Count) boarding passes loaded from $input_file"

# Draw the seats
0..1023 | % {
	[int]$ID = $_
	$Row, $Col = convert_ID_to_RowCol $ID
	if ( $Col -eq 0 ) { Write-Host '' }
	if ( $ID -in $boarding_pass_list ) { 
		Write-Host '.' -NoNewLine
	} else {
		Write-Host 'X' -NoNewLine
	}
}
