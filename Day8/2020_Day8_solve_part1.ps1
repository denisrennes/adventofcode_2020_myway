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
Write-Verbose ("Program loaded: from address #0 to #${last_address}")



# Execute the program while the instruction address to execute was not already executed before
[int]$Accumulator = 0
[int]$i_add = 0		# "address" of the current instruction to execute, i.e. the index in $inst_list
$already_run_inst_list = [System.Collections.ArrayList]@()		# addresses of instructions already executed

# run
while ($i_add -notin $already_run_inst_list) {

	# The address must be within the memory containing the program
	if ( ($i_add -lt 0) -or ($i_add -gt $last_address) ) { throw ("Next instruction address is out of the program: #${i_add}") }

	# add this instruction address to the list of addresses of instructions already executed
	$already_run_inst_list.Add($i_add) | Out-Null

	# execute this instruction
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
	Write-Verbose ( $verbose_msg + ("#${i_add} / Accumulator=${Accumulator}") )
}
Write-Verbose ( "STOP! #${i_add} was about to be re-executed." )


$result = $Accumulator
Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "result = $result"


