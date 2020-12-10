[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day9'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"
if ( -not (Test-Path -LiteralPath $input_file) ) { throw ("ERROR: $input_file does not exist.") }


# check num: is it sum of 2 numbers of the previous numbers list?
function is_num_sum_previous ( $num, $i_prev_start, $i_prev_end ) {
	for ( $i=$i_prev_start; $i -lt $i_prev_end; $i++ ) {
		for ( $j=$i+1; $j -le $i_prev_end; $j++ ) {
			if ( ($number_list[$i] + $number_list[$j]) -eq $num ) {
				return $true
			}
		}		
	}
	return $false	
}

# load the input 
$number_list = [System.Collections.ArrayList]@()
Get-Content $input_file | Foreach-Object { $number_list.Add( [uint64]$_ ) | Out-Null }
$last_i = $number_list.count - 1


##########################  Part 1
$result = $null

$prev_count = 25
$i_prev_start = 0	# start index of the $prev_count previous numbers 
$i_prev_end = $i_prev_start + $prev_count - 1		
for ( 	$i = $i_prev_end+1;		# start after the preamble
		$i -le $last_i;			# stop at the last number
		$i++ 	) 
{

	# check the number: break if not a sum of two numbers among the 25 previous
	if ( is_num_sum_previous $number_list[$i] $i_prev_start $i_prev_end ) {
		Write-Verbose ("line #${i} number is $($number_list[$i]): ok sum of two from the $prev_count previous")
	}
	else {
		$result = $number_list[$i]
		Write-Verbose ("FOUND! line #${i} number is $($number_list[$i])")
		break
	}

	# Inc the start and end of the previous number list 
	$i_prev_start++ 
	$i_prev_end++		
}

if ( -not ($result) ) {
		throw ("ERROR: not found")
}

Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "result = $result"


##########################  Part 2
$sum_to_reach = $result
Write-Verbose "SUM to reach = ${sum_to_reach}"

$result = $null


for ( 	$i_sum_start = 0;	
		$i_sum_start -lt $last_i;	# stop at the penultimate because there must be at leats 2 numbers
		$i_sum_start++ 	) 
{

	if ( $number_list[$i_sum_start] -ge $sum_to_reach ) {
		continue
	}
	
	$i_sum_end = $i_sum_start
	$current_sum = $number_list[$i_sum_start]
	do {
		$i_sum_end++
		$current_sum += $number_list[$i_sum_end]
	} while ( $current_sum -lt $sum_to_reach )
 	
	if ( $current_sum -eq $sum_to_reach ) {
		Write-Verbose ("FOUND! line range from #${i_sum_start}=$($number_list[$i_sum_start]) to #${i_sum_end}=$($number_list[$i_sum_end])")
		break
	}
	
	Write-Verbose "No for start line #${i_sum_start}"
}

if ( -not ($current_sum -eq $sum_to_reach) ) {
	throw ("ERROR: not found")
}

# add the mn and the max value of the list from $i_sum_start to $i_sum_end
$list = $number_list[$i_sum_start..$i_sum_end]
$min = ($list | Measure-Object -Minimum).Minimum
$max = ($list | Measure-Object -Maximum).Maximum
$result = $min + $max
Write-verbose ("Min = ${min},   Max = ${max},   Min+Max = ${result}")

Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"

