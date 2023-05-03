Import-Module -Name 'NetSecurity'

# Setup windows update service to manual
$wuauserv = Get-WmiObject Win32_Service -Filter "Name = 'wuauserv'"
$wuauserv_starttype = $wuauserv.StartMode
Set-Service wuauserv -StartupType Manual

# Install OenSSH
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Set service to automatic and start
Set-Service sshd -StartupType Automatic
Start-Service sshd

# Setup windows update service to original
Set-Service wuauserv -StartupType $wuauserv_starttype

# Configure PowerShell as the default shell
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "$Env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# Restart the service
Restart-Service sshd

# Configure SSH public key
$content = @"
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDYHFAAZF+raMTCr7aM54AGTRpzlPBVEeKlgoyK1Tpol5xfEAWgrJG/D2ilsCCdiLduqFF1zsJhZmpCvu0D8RfBHji/nUnY7VAWvHLdM/YXK6NqnNEeVV6MlBySe1puTCuGbcfu7o0h71r+9BR4eLm7psWONq8+cE1tY2l9oj8zyRptBZSALr6Rmm+NCobh2q9TPGTuCNCLmHdIRzrKuHJG46aV/QFxozUIkFxIeEeaPbnRaLX1/IGN7GFHTYoipsx90yQIGINhIdoBy7MC1c+vIuLoBys0Siu3OkhwX9Ha19VSyLc+jVah/sPbVWYZldolItjNpnEgf+P0b/jhdf7XXNc3WZGDjIcqzmJ1CwzisKRANBlA7VlocwuISkpw9hWP6Us8e2iFuKXemphC7XITlPBHPQjXIP79Ugu36EW8gfb6L5ijGKNPx4qDs5ginWtoI3pXIrORUrPxeQSG6hZGHEe2rqS9336iPeejf1bMKqqZrOfrx7Iw2VckGATVuw+y6r9swQqeHzoKjBRZ049TNKjyEsH2jfxCLOfEs2Tw+YoXdpw47bo2ihS+y4Etn2gBs6pGe6Vb7hdYeRYmvxbeabLdFqlnUOEsL9uHLjFNXTLBr5CBVy4UwtTQz6RMKlOnae1t0k1/X+On9HlcXPdYxqY39lZdPvJ9jzNWhdLLOw== jnelson@LTCF99.local
"@

# Write public key to file
$content | Set-Content -Path "$Env:ProgramData\ssh\administrators_authorized_keys"

# set acl on administrators_authorized_keys
$admins = ([System.Security.Principal.SecurityIdentifier]'S-1-5-32-544').Translate( [System.Security.Principal.NTAccount]).Value
$acl = Get-Acl $Env:ProgramData\ssh\administrators_authorized_keys
$acl.SetAccessRuleProtection($true, $false)
$administratorsRule = New-Object system.security.accesscontrol.filesystemaccessrule($admins,"FullControl","Allow")
$systemRule = New-Object system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow")
$acl.SetAccessRule($administratorsRule)
$acl.SetAccessRule($systemRule)
$acl | Set-Acl

# Open firewall port 22
$FirewallParams = @{ 
  "DisplayName"       = 'OpenSSH SSH Server (sshd)' 
  "Direction"         = 'Inbound' 
  "Action"            = 'Allow' 
  "Protocol"          = 'TCP'
  "LocalPort"         = '22' 
  "Program"           = '%SystemRoot%\system32\OpenSSH\sshd.exe'
}
New-NetFirewallRule @FirewallParams
