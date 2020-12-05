# Advent of Code 2020 Day 1
[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
$DayN = 'Day1'

# Input file must be created as a file named 'Day<n>_input.txt' in the directory of this script
$input_file = Join-Path $PSScriptRoot "$DayN_input.txt"

# Load the input as an array of [int]
$input_list = [System.Collections.ArrayList]@()
Get-Content $input_file | Foreach-Object { $input_list.Add([int]$_) | Out-Null }
Write-Verbose "$($last_i +1) lines loaded from $input_file"

# Part 1
foreach ( $num in $input_list ) {
	$searched_2020_complement = 2020 - $num
	if ( $searched_2020_complement -in $input_list ) {
		$result = $num * $searched_2020_complement
		break
	}
}
Write-Output ''
Write-Output ("2020 $DayN part 1:")
Write-Output "result = $result"

# Part 2
$input_list.Sort()

$last_i = $input_list.Count -1

:main_loop for ($i=0; $i -le $last_i; $i++ ) {
	for ($j=$i; $j -le $last_i; $j++ ) {
		$ij_sum = $input_list[$i] + $input_list[$j]
		if ( $ij_sum -gt 2020 ) {
			break;
		}
		$searched_2020_complement = 2020 - $ij_sum
		if ( $searched_2020_complement -in $input_list ) {
			Write-Output ( "$($input_list[$i]) + $($input_list[$j]) + $searched_2020_complement = 2020 => $($input_list[$i]) * $($input_list[$j]) * $searched_2020_complement = $($($input_list[$i]) * $($input_list[$j]) * $searched_2020_complement))" )
			break main_loop
		}
	
	}
}
Write-Output ''
Write-Output ("2020 $DayN part 2:")
Write-Output "result = $result"

