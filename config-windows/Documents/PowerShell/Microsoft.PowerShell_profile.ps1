Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-Alias -Name lg -Value lazygit

Function vsvars() { Import-VisualStudioVars -Architecture x64 }
Function bg() { Start-Process -NoNewWindow @args }
Function l { lsd.exe -lah --color=always $args }
Function lt { lsd.exe -lah --tree --color=always $args }
Function ltl { lsd.exe -lah --tree --color=always | less }
Function j { just --command-color blue $args }
Function jl { just --list $args }
Function gj { just --justfile $env:USERPROFILE\.justfile --working-directory . --command-color blue $args }

Remove-Alias -Name cat
Remove-Alias -Name cp
Remove-Alias -Name dir
Remove-Alias -Name echo
Remove-Alias -Name ls
Remove-Alias -Name mv
Remove-Alias -Name ps
Remove-Alias -Name pwd
Remove-Alias -Name rm

#[Console]::InputEncoding = [Console]::OutputEncoding = [Text.UTF8Encoding]::new()

$env:STARSHIP_CONFIG = "$env:USERPROFILE/.config/starship/starship.toml"
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
