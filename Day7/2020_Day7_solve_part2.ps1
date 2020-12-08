[CmdletBinding()]
param()
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'

$Dayx = 'Day7'

# Input file
$input_file = Join-Path $PSScriptRoot "2020_${Dayx}_input.txt"


$result = -1
$line_number = 0

$mybag = 'shiny gold'

# ex: 'light red bags contain 5 mirrored magenta bags, 1 mirrored lime bag, 4 dotted teal bags.'
$reg_ex_lev1 = '^(?<container_bag>[a-z ]+) bags contain (?<contained_list>.+)+\.$'
$reg_ex_lev2 = '^(?<nb_contained>\d+) (?<contained>[a-z ]+) bags?$'
$rule_list = Get-Content $input_file | Foreach-Object { 
	$line_number += 1
	$line = $_

	if ( $line -notmatch $reg_ex_lev1 ) {
		throw "ERROR line ${line_number} does not match reg ex level 1"
	}

	$container_bag = $matches.container_bag
	$matches.contained_list -split ', ' | Foreach-Object { 
		if ( $_ -eq 'no other bags' ) {
		   [PSCustomObject]@{ Container = $container_bag; Contained = $null; Nb_contained = 0 }
		}
		else {
			if ( $_ -notmatch $reg_ex_lev2 ) {
				throw "ERROR line ${line_number} does not match reg ex level 2"
			}
		   [PSCustomObject]@{ Container = $container_bag; Contained = $matches.contained; Nb_contained = $matches.nb_contained }
		}
	}
}

$all_contained = [System.Collections.ArrayList]@()

$bag_list = @( $mybag )
$level = 0
$all_ope = '<' + $mybag + '>'

do {
	Write-Verbose ("Level ${level}:")
	Write-Verbose ($bag_list -join '/')
	
	$new_bag_list = @()
	foreach ( $container in $bag_list ) {
		$ope = @()
		$contained_rules = @( $rule_list | Where-object { $_.Container -eq $container } )
		foreach ( $contained_rule in $contained_rules ) {
			if ( $contained_rule.Nb_contained -gt 0 ) {
				$ope += $contained_rule.Nb_contained + ' + ' + $contained_rule.Nb_contained + '*(<' + $contained_rule.Contained + '>)'
				$new_bag_list += $contained_rule.Contained
			}
			else {
				$ope = '0'
			}
		}
		$ope = $ope -join ' + '
		$all_ope = $all_ope -replace ([Regex]::Escape('<'+$container+'>')),$ope
	}
	Write-Verbose $all_ope

	$bag_list = @( $new_bag_list | select -Unique )
	$level += 1
} while( $bag_list.count -gt 0 )


$result = Invoke-Expression $all_ope
Write-Output ''
Write-Output ($Dayx + ' part 2:')
Write-Output "result = $result"


