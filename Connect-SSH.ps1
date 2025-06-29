$target = $Env:SSH_TARGET
if (-not $target) { Write-Error 'SSH_TARGET is not defined'; exit 1 }

Start-Process wt.exe `
-ArgumentList @(
  '--profile', 'PowerShell',
  'pwsh', '-NoExit', '-Command', "ssh $target"
)
