    $seats = Get-Content .\alternate_2020_Day5_input.txt | ForEach-Object {
        [convert]::ToInt32(($_-replace 'B|R',1 -replace 'F|L',0), 2)
    } | Sort-Object
    
    # Part 1
    $seats[-1]
    
    # Part 2
    $seats[0]..$seats[-1] | where { ($_ -notin $seats) -and (($_-1) -in $seats) -and (($_+1) -in $seats) }
