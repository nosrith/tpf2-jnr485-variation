$yourNameHolder = "Your Name"
$yourNameIdHolder = "yourname"
$varNameHolder = "Variation Name"
$varNameIdHolder = "varname"

$yourName = Read-Host "Your name [a-zA-Z0-9]+"
$varName = Read-Host "Variation name [a-zA-Z0-9]+"
Read-Host "Press Enter to continue"

$yourNameId = ($yourName -replace ' ', '').ToLower()
$varNameId = ($varName -replace ' ', '_').ToLower()

Push-Location $PSScriptRoot

function visitFolder($dir) {
    # Change contents
    Get-ChildItem $dir | ? { $_.Extension -in ".lua", ".mtl", ".mdl" } | % {
        Write-Host (Resolve-Path $_.FullName -Relative)
        $content = Get-Content $_.FullName -Encoding UTF8
        $content | 
            % { 
                $_ -replace $varNameHolder, $varName `
                    -replace $varNameIdHolder, $varNameId `
                    -replace $yourNameHolder, $yourName `
                    -replace $yourNameIdHolder, $yourNameId
            } |
            Out-File $_.FullName -Encoding UTF8
    }

    # Change file names
    Get-ChildItem $dir |
        ? { $_.Name.Contains($varNameIdHolder) } |
        % { 
            Write-Host (Resolve-Path $_.FullName -Relative)
            $name = $_.Name -replace $varNameIdHolder, $varNameId `
                -replace $yourNameIdHolder, $yourNameId
            Rename-Item $_.FullName $name
        }

    # Visit subfolder
    Get-ChildItem $dir -Directory |
        % { visitFolder $_.FullName }
}
visitFolder $PSScriptRoot

Pop-Location
