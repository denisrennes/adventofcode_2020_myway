[CmdletBinding()]
param()

# 'Day1, 'Day2'...
$Dayx = [io.path]::GetFileNameWithoutExtension($MyInvocation.MyCommand)

# Input file
$input_file = Join-Path $PSScriptRoot ($Dayx + '_input.txt')


function tree_count ( $right_move, $down_move ) {
	$nb_trees = 0
	$x_pos = 0			# x pos where the toboggan is (first pos is 0)
	$line_number = 0	# y pos where the toboggan is (1st line is line 0)
	
	Get-Content $input_file | Foreach-Object {

		if ( ($line_number -ne 0) -and ($line_number % $down_move) -eq 0 ) {  # assuming here that at the 1st line the start pos is alway free, no tree
			$pattern_length = $_.length		# lines of the input could have different length 
			$x_pos += $right_move  			# right move
			
			# the same pattern repeats to the right: It's like going back to the beginning of the pattern, hence the use of the modulo operator
			$x_pos_pattern = $x_pos % $pattern_length
			
			if ( $_[$x_pos_pattern] -eq '#' ) {
				$nb_trees += 1
				# Write-Verbose "Tree #$nb_trees at pos. $x_pos_pattern ($x_pos) line #$line_number"
			}
		}

		$line_number += 1
	}
	
	Write-Verbose "#$nb_trees trees for slope right $right_move, down $down_move."
	return $nb_trees
}

$result = tree_count 3 1
Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "$result trees for slope right 3, down 1."


$res1 = tree_count 1 1
$res2 = tree_count 3 1
$res3 = tree_count 5 1
$res4 = tree_count 7 1
$res5 = tree_count 1 2
$result = $res1 * $res2 * $res3 * $res4 * $res5

Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "$res1 * $res2 * $res3 * $res4 * $res5 = $result"
