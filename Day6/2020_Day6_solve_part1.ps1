[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day6'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


# count the number of different letters (questions) 
function count_distinct_letters ( [string]$ans ) {
	$distinct_letters = [System.Collections.ArrayList]@()
	for( $i=0; $i -lt ($ans.Length); $i++ ) {
		$letter = $ans[$i]
		if ( $letter -notin $distinct_letters ) {
			$distinct_letters.Add( $letter ) | Out-Null
		}
	}
	return ( ($distinct_letters.Count) )
}


$result = -1
$line_number = 0

$q_cpt_tot = 0
$ans_grp = ''	# concatened answers of the same group
$q_cpt_grp = 0

$ans_list = Get-Content $input_file
$last_line = $ans_list.Count

foreach ( $ans in $ans_list ) {
	$line_number += 1
	
	if ( $ans -ne '' ) {
		# answers of another person of the same group
		$ans_grp += $ans	# concatened answers of the same group
	}

	if ( ($ans -eq '' ) -or ($line_number -eq $last_line) ) {
		# end of group: empty line or last line
		$q_cpt_grp = count_distinct_letters $ans_grp
		write-verbose ( "line ${line_number}: $q_cpt_grp for the group" )
		$q_cpt_tot += $q_cpt_grp
		$ans_grp = ''	# concatened answers of the next group
	}

}

$result = $q_cpt_tot
Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "result = $result"


