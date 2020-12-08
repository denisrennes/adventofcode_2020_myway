[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day6'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


# return the common letters (questions) between two strings (answers of two passengers). A letter can be only once in a string (only 1 answer per question)
function get_common_letters ( [string]$ans1, [string]$ans2 ) {
	$common_letters = ''
	for( $i=0; $i -lt ($ans1.Length); $i++ ) {
		$letter = $ans1[$i]
		if ( $ans2.IndexOf($letter) -ne -1 ) {
			$common_letters += $letter
		}
	}
	return ( $common_letters )
}


$result = -1
$line_number = 0

$q_cpt_tot = 0
$common_letters_grp = ''	# common letters of a group
$q_cpt_grp = 0
$new_group = $true

$ans_list = Get-Content $input_file
$last_line = $ans_list.Count

foreach ( $ans in $ans_list ) {
	$line_number += 1
	
	if ( $ans -ne '' ) {
		if ( $new_group ) {
			# first person of this group
			$common_letters_grp = $ans
			$new_group = $false
		}
		else {
			# answers of another person of the same group
			if ( $common_letters_grp -ne '' ) {
				$common_letters_grp = get_common_letters $common_letters_grp $ans
			}
		}
	}

	if ( ($ans -eq '' ) -or ($line_number -eq $last_line) ) {
		# end of group: empty line or last line
		$q_cpt_grp = $common_letters_grp.Length
		write-verbose ( "line ${line_number}: $q_cpt_grp common for the group" )
		$q_cpt_tot += $q_cpt_grp
		$common_letters_grp = ''	# common letters of the next group
		$new_group = $true
	}

}

$result = $q_cpt_tot
Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"


