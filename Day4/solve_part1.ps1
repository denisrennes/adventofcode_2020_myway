[CmdletBinding()]
param()

# Get 'Day1, 'Day2'... from the name of the directory containing this script
$Dayx = [io.path]::GetFileNameWithoutExtension($PSScriptRoot)

# Input file
$input_file = Join-Path $PSScriptRoot 'input.txt'


# passport record
$pass = [ordered]@{ 'byr'=''; 'iyr'=''; 'eyr'=''; 'hgt'=''; 'hcl'=''; 'ecl'=''; 'pid'=''; 'cid'='' }


# Only the fields in $allowed_missing_fields are allowed to be '' or missing
$allowed_missing_fields = @( 'cid' )

function is_pass_valid ( $pass, [ref]$invalid_reason ) {
	try {
		$invalid_reason.value = ''
		foreach ( $field in $pass.keys ) {
			if ( ($pass.$field -eq '') -and ($field -notin $allowed_missing_fields) ) {
				throw "missing field $field (not allowed)"
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
Write-Output ($Dayx + ' part 1:')
if ( $nb_error -ne 0 ) {
	Write-Error "ERROR number: $nb_error!"
}
Write-Output "$result valid passports."


