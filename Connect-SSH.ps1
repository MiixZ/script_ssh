$target = $env:SSH_TARGET

Start-Process pwsh @(
  '-NoExit',
  '-Command',
  "ssh $target"
)