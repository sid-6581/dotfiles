Function Set-DwordRegistryKey ($path, $key, $value) {
  if ((Get-ItemProperty -Path $path | Select-Object -ExpandProperty $key) -ne $value) {
    New-ItemProperty -Path $path -Name $key -PropertyType DWORD -Value $value -Force | Out-Null
  }
}

# Enable developer mode
Set-DwordRegistryKey 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' 'AllowDevelopmentWithoutDevLicense' 1

# Disable web search in the Start menu
Set-DwordRegistryKey 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' 'BingSearchEnabled' 0

# Keyboard repeat rate
$keyboardResponsePath = 'HKCU:\Control Panel\Accessibility\Keyboard Response'
Set-DwordRegistryKey $keyboardResponsePath 'BounceTime' 0
Set-DwordRegistryKey $keyboardResponsePath 'AutoRepeatDelay' 264
Set-DwordRegistryKey $keyboardResponsePath 'AutoRepeatRate' 10
Set-DwordRegistryKey $keyboardResponsePath 'DelayBeforeAcceptance' 0
Set-DwordRegistryKey $keyboardResponsePath 'Flags' 27

# Disable StickyKeys
Set-DwordRegistryKey 'HKCU:\Control Panel\Accessibility\StickyKeys' 'Flags' 26

# Underline access keys even when not holding Alt
Set-DwordRegistryKey 'HKCU:\Control Panel\Accessibility\Keyboard Preference' 'On' 1
