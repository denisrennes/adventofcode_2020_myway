[CmdletBinding()]
param()

# Get 'Day1, 'Day2'... from the name of the directory containing this script
$Dayx = [io.path]::GetFileNameWithoutExtension($PSScriptRoot)

# Input file
$input_file = Join-Path $PSScriptRoot 'input.txt'


$pass = [ordered]@{ 'byr'=''; 'iyr'=''; 'eyr'=''; 'hgt'=''; 'hcl'=''; 'ecl'=''; 'pid'=''; 'cid'='' }

# Only the fields in $allowed_missing_fields are allowed to be '' or missing
$allowed_missing_fields = @( 'cid' )
# byr (Birth Year) - four digits; at least 1920 and at most 2002
# iyr (Issue Year) - four digits; at least 2010 and at most 2020.
# eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
# hgt (Height) - a number followed by either cm or in:
#     If cm, the number must be at least 150 and at most 193.
#     If in, the number must be at least 59 and at most 76.
# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
# ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
# pid (Passport ID) - a nine-digit number, including leading zeroes.
# cid (Country ID) - ignored, missing or not.
function is_pass_valid ( $pass, [ref]$invalid_reason ) {
	try {
		$invalid_reason.value = ''
		foreach ( $field in $pass.keys ) {
			$value = $pass.$field
			if ( ($value -eq '') -and ($field -notin $allowed_missing_fields) ) {
				throw "missing field $field (not allowed)"
			}
			switch ($field) {
				
				# byr (Birth Year) - four digits; at least 1920 and at most 2002
				'byr' {
					if ( $value -notmatch '\d\d\d\d' ) { throw "field $field has not four digits" }
					[int]$year = $value
					if ( ($year -lt 1920) -or ($year -gt 2002) ) { throw "field $field not at least 1920 and at most 2002" }
				}
				
				# iyr (Issue Year) - four digits; at least 2010 and at most 2020.
				'iyr' {
					if ( $value -notmatch '\d\d\d\d' ) { throw "field $field has not four digits" }
					[int]$year = $value
					if ( ($year -lt 2010) -or ($year -gt 2020) ) { throw "field $field not at least 2010 and at most 2020" }
				}

				# eyr (Expiration Year) - four digits; at least 2020 and at most 2030.
				'eyr' {
					if ( $value -notmatch '\d\d\d\d' ) { throw "field $field has not four digits" }
					[int]$year = $value
					if ( ($year -lt 2020) -or ($year -gt 2030) ) { throw "field $field not at least 2020 and at most 2030" }
				}
				
				# hgt (Height) - a number followed by either cm or in:
				#     If cm, the number must be at least 150 and at most 193.
				#     If in, the number must be at least 59 and at most 76.
				'hgt' {
					if ( $value -notmatch '^(?<height>\d{2,3})(?<unit>(cm|in))$' ) { throw "field $field has not two or three digits and/or does not end with 'cm' or 'in'" }
					[int]$height = $matches.height
					[string]$unit = $matches.unit
					if ( ($unit -eq 'cm' ) -and (($height -lt 150) -or ($height -gt 193)) ) { throw "field $field not at least 150 and at most 193 cm" }
					if ( ($unit -eq 'in' ) -and (($height -lt 59) -or ($height -gt 76)) ) { throw "field $field not at least 59 and at most 76 in" }
				}

				# hcl (Hair Color) - a # followed by exactly six characters 0-9 or a-f.
				'hcl' {
					if ( $value -cnotmatch '^#(?<color>[0-9a-f]{6})$' ) { throw "field $field is not a # followed by exactly six characters 0-9 or a-f" }
				}
				
				# ecl (Eye Color) - exactly one of: amb blu brn gry grn hzl oth.
				'ecl' {
					if ( $value -cnotin @('amb', 'blu', 'brn', 'gry', 'grn', 'hzl', 'oth') ) { throw "field $field is not exactly one of: amb blu brn gry grn hzl oth" }
				}
				
				# pid (Passport ID) - a nine-digit number, including leading zeroes.				
				'pid' {
					if ( $value -cnotmatch '^\d{9}$' ) { throw "field $field is not a nine-digit number, including leading zeroes" }
				}

				# cid (Country ID) - ignored, missing or not.
				'cid' {
				}
				
				default {
					Write-Error "ERROR: Unprocessed field $field in function is_pass_valid. Exit"
					Exit
				}
			}
		}
		# all fields validated (no thow), so the passport record is validated
		$return_value = $true
	}
	catch {
		# a field is not validated, so the passport record is not validated
		$invalid_reason.value = $_
		$return_value = $false
	}
	
	return $return_value
}


$result = 0					# nb valid passports
$line_number = 0			# y pos where the toboggan is (1st line is line 0)
# for records detected as ill-formed (multiple fields with same name)
$nb_error = 0
$ill_formed_rec = $false

[string]$invalid_reason = ''

Get-Content $input_file | Foreach-Object {

	if ( $_ -eq '' ) {

		# empty line means end of passport record

		# check the passport if not already detected as invalid
		if ( -not $ill_formed_rec ) {
			if ( (is_pass_valid $pass ([ref]$invalid_reason)) ) {
				$result += 1		# nb valid passports
				Write-Verbose "VALID passport ends at line #${line_number}"
			}
			else {
				Write-Verbose "Invalid passport ends at line #${line_number}: $invalid_reason."
			}

		}
		# next passport to check: empty all fields
		$pass.byr=''; $pass.iyr=''; $pass.eyr=''; $pass.hgt=''; $pass.hcl=''; $pass.ecl=''; $pass.pid=''; $pass.cid=''
		$ill_formed_rec = $false

	}
	else {
		
		# non empty line: set the fields of the $pass record contained in this line
		
		$key_value_list = $_ -split '\s'
		foreach ( $key_value in $key_value_list ) {
			$key, $value = $key_value -split ':'
			if ( $key -notin $pass.keys ) {
				$ill_formed_rec = $true	
				$nb_error += 1
				write-host "Invalid passport at line #${line_number}: unknown '$key' field."
			}
			else {
				if ( $pass.$key -eq '' ) {
					$pass.$key = $value
				}
				else {
					if ( $pass.$key -ne $value ) {
						$ill_formed_rec = $true	
						$nb_error += 1
						write-host "Invalid passport at line #${line_number}: multiple $key fields with different values."
					}
				}
			}
		}
		
	}


	$line_number += 1
}

# last record

# check the passport if not already detected as invalid
if ( -not $ill_formed_rec ) {
	if ( (is_pass_valid $pass ([ref]$invalid_reason)) ) {
		$result += 1		# nb valid passports
		Write-Verbose "VALID passport ends at line #${line_number}"
	}
	else {
		Write-Verbose "Invalid passport ends at line #${line_number}: $invalid_reason."
	}

}


Write-Output ''
Write-Output ($Dayx + ' part 2:')
if ( $nb_error -ne 0 ) {
	Write-Error "ERROR number: $nb_error!"
}
Write-Output "$result valid passports."


