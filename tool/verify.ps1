$ErrorActionPreference = 'Stop'

$flutterBin = 'C:\development\flutter\bin'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$krepisRoot = (Resolve-Path -LiteralPath (Join-Path $projectRoot '..\Krepis')).Path
$dartExe = Join-Path $flutterBin 'cache\dart-sdk\bin\dart.exe'
$flutterTool = Join-Path $flutterBin 'cache\flutter_tools.snapshot'
$cmakeExe = 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\CMake\CMake\bin\cmake.exe'
$krepisNativeDir = Join-Path $krepisRoot 'build\msvc-x64\Debug'

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
Invoke-VerifyStep -Name '格式檢查' -Executable $dartExe -Arguments @(
	'format',
	'--output=none',
	'--set-exit-if-changed',
	'lib',
	'test'
)
Invoke-VerifyStep -Name '靜態分析' -Executable $dartExe -Arguments @(
	$flutterTool,
	'analyze',
	'--fatal-infos'
)
Invoke-VerifyStep -Name 'Krepis ABI 設定' -Executable $cmakeExe -Arguments @(
	'--preset',
	'msvc-x64'
) -WorkingDirectory $krepisRoot
Invoke-VerifyStep -Name 'Krepis ABI 建置' -Executable $cmakeExe -Arguments @(
	'--build',
	'build/msvc-x64',
	'--config',
	'Debug',
	'--target',
	'krepis_c'
) -WorkingDirectory $krepisRoot

$env:NOTIST_KREPIS_NATIVE_TEST = '1'
$env:Path = "$krepisNativeDir;$env:Path"
Invoke-VerifyStep -Name '測試' -Executable $dartExe -Arguments @(
	$flutterTool,
	'test'
)
