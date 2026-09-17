param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $FlutterArgs
)

$setupScript = Join-Path $PSScriptRoot "setup.ps1"
if (-not (Test-Path -LiteralPath $setupScript)) {
  Write-Error "Flutter setup script was not found at '$setupScript'."
  exit 1
}

$flutter = & $setupScript -PrintFlutterExecutable
$setupSucceeded = $?
if (-not $setupSucceeded -or [string]::IsNullOrWhiteSpace($flutter)) {
  exit 1
}

& $flutter @FlutterArgs
exit $LASTEXITCODE
