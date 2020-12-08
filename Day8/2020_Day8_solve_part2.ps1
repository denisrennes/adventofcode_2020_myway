[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day8'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"
if ( -not (Test-Path -LiteralPath $input_file) ) { throw ("ERROR: $input_file does not exist.") }

$result = -1


$inst_regex = '^(?<ope>[a-z]{3}) (?<arg>[+-]\d{1,3})$'
$known_ope_list = @( 'acc', 'jmp', 'nop' )

# Load the instruction list (the boot code): record is an array
$inst_list = [System.Collections.ArrayList]@()

Get-Content $input_file | Foreach-Object {
	switch -regex -casesensitive ($_)
	{
		$inst_regex {
			$ope = $matches.ope
			if ( $ope -cnotin $known_ope_list ) { throw ("ERROR: Line '$_' does not have a known ope") }
			$inst_list.Add( @($ope, [int]($matches.arg)) ) | Out-Null
			continue
		}
		default {
			throw ( "Line '$_' does not match the reg ex" )
		}
	}
}
$last_address = ($inst_list.Count) - 1
$end_ok_address = $inst_list.Count   # the program ends normally by attempting to run the instruction below the last instruction
Write-Verbose ("Program loaded: from address #0 to #${last_address}. Success End address: #${end_ok_address}")


# Will run the program $inst_list
# return the value of $Accumulator
# $stop_reason will contain: 
# - 'ok' when the program ended normally by attempting to run the instruction below the last instruction
# - 'loop' when an infinit loop was detected: the instruction about to be executed was already executed before
# - 'out_of_prog': the instruction about to be executed in not in the program (and not the one below the last instruction)
function run_prog ( [ref]$stop_reason ) { 

	# Execute the program while the instruction address to execute was not already executed before
	[int]$Accumulator = 0
	[int]$i_add = 0		# "address" of the current instruction to execute, i.e. the index in $inst_list
	$already_run_inst_list = [System.Collections.ArrayList]@()		# addresses of instructions already executed
	
	# run
	while ($i_add -notin $already_run_inst_list) {
		$stop_reason.value = 'error'
		
		# End of program? the program ends normally by attempting to run the instruction below the last instruction
		if ( $i_add -eq $end_ok_address ) {
			$stop_reason.value = 'ok'
			return $Accumulator 
		}

		# Out of program? The address must be within the memory containing the program
		if ( ($i_add -lt 0) -or ($i_add -gt $last_address) ) { 
			$stop_reason.value = 'out_of_prog'
			return $Accumulator 
		}
	
		# Add this instruction address to the list of addresses of instructions already executed
		$already_run_inst_list.Add($i_add) | Out-Null
	
		# Execute this instruction
		[string]$ope = $inst_list[$i_add][0]
		[int]$arg = $inst_list[$i_add][1]
		$verbose_msg = ("#${i_add}: ${ope} ${arg} Accumulator=${Accumulator}  =>  ")
	
		switch ($ope)
		{
			'nop' {
				$i_add++	# next instruction
				continue
			}
			'acc' {
				$Accumulator += $arg	# change the accumulator
				$i_add++		# next instruction
				continue
			}
			'jmp' {
				$i_add += $arg	# next instruction
				continue
			}
			default { 
				throw ("ERROR: Unknown ope ${ope} at address #${i_add}")
			}
		}
		# Write-Verbose ( $verbose_msg + ("#${i_add} / Accumulator=${Accumulator}") )
	}
	# Here the while condition is false:
	$stop_reason.value = 'loop'
	return $Accumulator 
}

# Brut force: we will change 1 'nop' or 1 'jmp' instruction from the first instruction to the last, tryin to launch it after each change
# We will stop the first time the result will be ok: program ended normally
[string]$stop_reason = ''
for ( $i_address=0; $i_address -le $last_address; $i_address++ ) {
	$ope = $inst_list[$i_address][0]
	
	if ( ($ope -eq 'nop') -or ($ope -eq 'jmp') ) {

		# save the original ope
		$saved_ope = $inst_list[$i_address][0]
		
		# change the ope: 'nop' to 'jmp' or 'jmp' to 'nop'
		if ( $ope -eq 'nop' ) {
			$inst_list[$i_address][0] = 'jmp'
		} else {
			$inst_list[$i_address][0] = 'nop'
		}
		
		# run the modified program
		$Accumulator = run_prog ([ref]$stop_reason)
		write-verbose ("#${i_address}: ${saved_ope} changed to $($inst_list[$i_address][0]): stop reason = ${stop_reason}")

		if ( $stop_reason -eq 'ok' ) {
			break
		}
		
		# restore the original ope
		$inst_list[$i_address][0] = $saved_ope
	}
	else {
		# 'acc' ope so nothing to change and try
	}
}
if ( $stop_reason -ne 'ok' ) {
	throw ( 'Damn! Nothing worked!' )
}

$result = $Accumulator
Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"


