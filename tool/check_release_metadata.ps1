$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$expectedPackageVersion = '0.1.0-beta.1+1'
$expectedTagVersion = '0.1.0-beta.1'
$expectedWindowsNumber = '0,1,0,1'

function Assert-Contains {
	param(
		[Parameter(Mandatory = $true)]
		[string] $Path,

		[Parameter(Mandatory = $true)]
		[string] $Text
	)

	$content = Get-Content -Raw -LiteralPath (Join-Path $projectRoot $Path)
	if (!$content.Contains($Text)) {
		throw "$Path 缺少預期版本文字：$Text"
	}
}

Assert-Contains -Path 'pubspec.yaml' -Text "version: $expectedPackageVersion"
Assert-Contains -Path 'windows\runner\Runner.rc' -Text "#define VERSION_AS_NUMBER $expectedWindowsNumber"
Assert-Contains -Path 'windows\runner\Runner.rc' -Text "#define VERSION_AS_STRING `"$expectedPackageVersion`""
Assert-Contains -Path 'CHANGELOG.md' -Text "## [$expectedTagVersion] - Unreleased"
Assert-Contains -Path 'docs\releases\0.1.0-beta.1.md' -Text "| Flutter package | ``$expectedPackageVersion`` |"
Assert-Contains -Path 'docs\releases\0.1.0-beta.1.md' -Text "| 預定 Git tag | ``v$expectedTagVersion`` |"

$runtimeFiles = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'lib') -Recurse -File |
	Where-Object { $_.Extension -in @('.dart', '.json', '.arb') }
$personalized = $runtimeFiles | Select-String -SimpleMatch -Pattern 'Chia-Yu', 'ChiaYu'
if ($personalized) {
	throw "runtime 仍含開發者個人識別：$($personalized.Path):$($personalized.LineNumber)"
}

$fixtureFiles = Get-ChildItem -LiteralPath (Join-Path $projectRoot 'design') -Recurse -File -Filter '*.krdf'
if ($fixtureFiles) {
	throw "發行資產不得包含 Flow fixture：$($fixtureFiles.FullName)"
}

Write-Host "Release metadata 一致：$expectedPackageVersion"
