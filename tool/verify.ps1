[CmdletBinding()]
param(
	[string] $FlutterPath = $env:NOTIST_FLUTTER,
	[switch] $AllowNonFatalInfos,

	[switch] $BuildWindowsRelease
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

function Resolve-FlutterPath {
	param([string] $RequestedPath)

	$candidates = @()
	if ($RequestedPath) {
		$candidates += $RequestedPath
	}
	if ($env:FLUTTER_ROOT) {
		$candidates += (Join-Path $env:FLUTTER_ROOT 'bin\flutter.bat')
	}
	$fromPath = Get-Command flutter -ErrorAction SilentlyContinue
	if ($fromPath) {
		$candidates += $fromPath.Source
	}

	foreach ($candidate in $candidates) {
		if (Test-Path -LiteralPath $candidate -PathType Leaf) {
			return (Resolve-Path -LiteralPath $candidate).Path
		}
	}

	throw '找不到 Flutter。請設定 NOTIST_FLUTTER、FLUTTER_ROOT，或將 flutter 加入 PATH。'
}

$flutterExe = Resolve-FlutterPath -RequestedPath $FlutterPath
$flutterBin = Split-Path -Parent $flutterExe
$dartExe = Join-Path $flutterBin 'cache\dart-sdk\bin\dart.exe'
$krepisNativeDir = Join-Path $projectRoot 'build\windows\x64\runner\Debug'

if (!(Test-Path -LiteralPath $dartExe -PathType Leaf)) {
	throw "Flutter SDK 缺少 Dart executable：$dartExe"
}

function Invoke-VerifyStep {
	param(
		[Parameter(Mandatory = $true)]
		[string] $Name,

		[Parameter(Mandatory = $true)]
		[string] $Executable,

		[Parameter(Mandatory = $true)]
		[string[]] $Arguments,

		[string] $WorkingDirectory = $projectRoot
	)

	Write-Host "`n== $Name =="
	Push-Location -LiteralPath $WorkingDirectory

	try {
		& $Executable @Arguments
		$stepExitCode = $LASTEXITCODE
	}
	finally {
		Pop-Location
	}

	if ($stepExitCode -ne 0) {
		Write-Error "$Name 失敗，結束碼：$stepExitCode" -ErrorAction Continue
		exit $stepExitCode
	}
}

Invoke-VerifyStep -Name '發行 metadata 檢查' -Executable 'pwsh.exe' -Arguments @(
	'-NoProfile',
	'-ExecutionPolicy',
	'Bypass',
	'-File',
	(Join-Path $PSScriptRoot 'check_release_metadata.ps1')
)
Invoke-VerifyStep -Name 'Provider pin 檢查' -Executable 'pwsh.exe' -Arguments @(
	'-NoProfile',
	'-ExecutionPolicy',
	'Bypass',
	'-File',
	(Join-Path $PSScriptRoot 'check_provider_pins.ps1')
)
Invoke-VerifyStep -Name '鎖定相依解析' -Executable $flutterExe -Arguments @(
	'pub',
	'get',
	'--enforce-lockfile'
)
Invoke-VerifyStep -Name '格式檢查' -Executable $dartExe -Arguments @(
	'format',
	'--output=none',
	'--set-exit-if-changed',
	'lib',
	'test'
)
	$analyzeArguments = @('analyze', 'lib', 'test')
	if ($AllowNonFatalInfos) {
		$analyzeArguments = @('analyze', '--no-fatal-infos', 'lib', 'test')
	} else {
		$analyzeArguments = @('analyze', '--fatal-infos', 'lib', 'test')
	}

Invoke-VerifyStep -Name '靜態分析' -Executable $flutterExe -Arguments $analyzeArguments
Invoke-VerifyStep -Name 'Windows Debug 與 Krepis ABI 建置' -Executable $flutterExe -Arguments @(
	'build',
	'windows',
	'--debug'
)

$krepisDll = Join-Path $krepisNativeDir 'krepis_c.dll'
if (!(Test-Path -LiteralPath $krepisDll -PathType Leaf)) {
	throw "Windows Debug 建置未產生 Krepis runtime：$krepisDll"
}

$env:NOTIST_KREPIS_NATIVE_TEST = '1'
$env:Path = "$krepisNativeDir;$env:Path"
Invoke-VerifyStep -Name '測試' -Executable $flutterExe -Arguments @(
	'test'
)

if ($BuildWindowsRelease) {
	Invoke-VerifyStep -Name 'Windows Release 建置' -Executable $flutterExe -Arguments @(
		'build',
		'windows',
		'--release'
	)
}
