# Import the input
#$input_list = [System.Collections.ArrayList]@()
$input_file = Join-Path $PSScriptRoot 'Day2_input.txt'

function check_nb_char_min_max ( [string]$string_to_check, [char]$char_to_check, [int]$min, [int]$max ) {
	$nb_char_to_check = 0
	$string_length = $string_to_check.length
	for ( $i = 0; $i -lt $string_length; $i++ ) {
		if ( $string_to_check[$i] -ceq $char_to_check ) {
			$nb_char_to_check += 1
			if ( $nb_char_to_check -gt $max ) {
				return $false
			}
		}
	}
	if ( $nb_char_to_check -lt $min ) {
		return $false
	}
	return $true
}


function check_1char_pos1_pos2 ( [string]$string_to_check, [char]$char_to_check, [int]$pos1, [int]$pos2 ) {
	$nb_char_to_check = 0
	$string_length = $string_to_check.length
	if ( $pos1 -le $string_length ) {
		if ( $string_to_check[$pos1 - 1] -ceq $char_to_check ) {
			$nb_char_to_check += 1
		}
	}
	if ( $pos2 -le $string_length ) {
		if ( $string_to_check[$pos2 - 1] -ceq $char_to_check ) {
			$nb_char_to_check += 1
		}
	}
	if ( $nb_char_to_check -eq 1 ) {
		return $true
	}

	return $false
}


$line_reg_ex = '^(?<Min>\d+)-(?<Max>\d+) (?<Letter>\w): (?<Password>\w+)$'
$line_number = 0
$nb_valid_passwords = 0
Get-Content $input_file | Foreach-Object {
	$line_number += 1

	if ( $_ -match $line_reg_ex ) {

		if ( check_nb_char_min_max $matches.Password $matches.Letter $matches.Min $matches.Max ) { 
			$nb_valid_passwords += 1
			Write-Output "Valid password line #${line_number}: $_"
		}
	}
	else {
		Write-Output "ERROR line #$line_number does not match the regular expression."
		Exit
	}
}

Write-Output ''
Write-Output 'Day2 part 1:'
Write-Output "$nb_valid_passwords valid passwords out of $line_number lines from $from $input_file"


$line_reg_ex = '^(?<Pos1>\d+)-(?<Pos2>\d+) (?<Letter>\w): (?<Password>\w+)$'
$line_number = 0
$nb_valid_passwords = 0
Get-Content $input_file | Foreach-Object {
	$line_number += 1

	if ( $_ -match $line_reg_ex ) {

		if ( check_1char_pos1_pos2 $matches.Password $matches.Letter $matches.Pos1 $matches.Pos2 ) { 
			$nb_valid_passwords += 1
			Write-Output "Valid password line #${line_number}: $_"
		}
		else {
			Write-Output "INvalid password line #${line_number}: $_"
		}
	}
	else {
		Write-Output "ERROR line #$line_number does not match the regular expression."
		Exit
	}
}

Write-Output ''
Write-Output 'Day2 part 2:'
Write-Output "$nb_valid_passwords valid passwords out of $line_number lines from $from $input_file"
