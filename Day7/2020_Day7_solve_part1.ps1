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
		   [PSCustomObject]@{ Container = $container_bag; Contained = $null; nb_contained = 0 }
		}
		else {
			if ( $_ -notmatch $reg_ex_lev2 ) {
				throw "ERROR line ${line_number} does not match reg ex level 2"
			}
		   [PSCustomObject]@{ Container = $container_bag; Contained = $matches.contained; nb_contained = $matches.nb_contained }
		}
	}
}

$all_containers = [System.Collections.ArrayList]@()

$bag_list = @( $mybag )
$level = 0

do {
Write-Verbose ("Level ${level}:")
	Write-Verbose ($bag_list -join '/')
	$container_rules = @( $rule_list | Where-object { $_.Contained -in $bag_list } )
	if ( $container_rules.count -gt 0 ) {
		$bag_list = @( $container_rules.Container | Select-Object -Unique )
	}
	else {
		$bag_list = @()
	}
	foreach ( $bag in $bag_list ) {
		if ( $bag -notin $all_containers) {
			$all_containers.add($bag) | Out-Null
		}
	}
	$level +=1
} while( $bag_list.count -gt 0 )


$result = $all_containers.count
Write-Output ''
Write-Output ($Dayx + ' part 1:')
Write-Output "result = $result"


