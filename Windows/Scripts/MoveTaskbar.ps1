$Positions = New-Object 'system.collections.generic.dictionary[int,int]'
$Positions[0] = 3 # Left to Bottom
$Positions[3] = 0 # Bottom to Left

$Path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\StuckRects3"
$Name = "Settings"
$Settings = (Get-ItemProperty -Path $Path -Name $Name).Settings
$Settings[12] = $Positions[$Settings[12]]
Set-ItemProperty -Path $Path -Name $Name -Value $Settings

Stop-Process -Name "explorer" # Restart explorer