[CmdletBinding()]
param(
	[string] $BuildDirectory,

	[string] $OutputDirectory,

	[string] $KallopisSource = $env:NOTIST_KALLOPIS_SOURCE,

	[string] $KrepisSource = $env:NOTIST_KREPIS_SOURCE
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path

function Invoke-Gate {
	param(
		[Parameter(Mandatory = $true)]
		[string] $Script
	)

	& pwsh.exe -NoProfile -ExecutionPolicy Bypass -File (Join-Path $PSScriptRoot $Script)
	if ($LASTEXITCODE -ne 0) {
		throw "$Script 失敗，結束碼：$LASTEXITCODE"
	}
}

function Resolve-Directory {
	param(
		[Parameter(Mandatory = $true)]
		[string] $Path,

		[Parameter(Mandatory = $true)]
		[string] $Label
	)

	if (!(Test-Path -LiteralPath $Path -PathType Container)) {
		throw "$Label 不存在：$Path"
	}
	return (Resolve-Path -LiteralPath $Path).Path
}

function Resolve-KallopisSource {
	if ($KallopisSource) {
		return Resolve-Directory -Path $KallopisSource -Label 'Kallopis source'
	}

	$packageConfigPath = Join-Path $projectRoot '.dart_tool\package_config.json'
	if (!(Test-Path -LiteralPath $packageConfigPath -PathType Leaf)) {
		throw '缺少 .dart_tool/package_config.json；請先執行 locked dependency resolution。'
	}
	$config = Get-Content -Raw -LiteralPath $packageConfigPath | ConvertFrom-Json
	$package = $config.packages | Where-Object { $_.name -eq 'kallopis' } | Select-Object -First 1
	if (!$package) {
		throw 'package_config.json 缺少 Kallopis。'
	}

	$rootUri = [Uri]::new([Uri]::new($packageConfigPath), $package.rootUri)
	return Resolve-Directory -Path $rootUri.LocalPath -Label 'Kallopis source'
}

function Resolve-KrepisSource {
	if ($KrepisSource) {
		return Resolve-Directory -Path $KrepisSource -Label 'Krepis source'
	}

	return Resolve-Directory `
		-Path (Join-Path $projectRoot 'build\windows\x64\_deps\krepis-src') `
		-Label 'Krepis FetchContent source'
}

function Assert-RequiredPath {
	param(
		[Parameter(Mandatory = $true)]
		[string] $Root,

		[Parameter(Mandatory = $true)]
		[string] $RelativePath,

		[ValidateSet('Leaf', 'Container')]
		[string] $PathType = 'Leaf'
	)

	$path = Join-Path $Root $RelativePath
	if (!(Test-Path -LiteralPath $path -PathType $PathType)) {
		throw "Windows bundle 缺少 $RelativePath。"
	}
}

Invoke-Gate -Script 'check_release_metadata.ps1'
Invoke-Gate -Script 'check_provider_pins.ps1'

$dirty = @(& git -C $projectRoot status --porcelain=v1 --untracked-files=all)
if ($LASTEXITCODE -ne 0) {
	throw '無法檢查 Git worktree 狀態。'
}
if ($dirty.Count -gt 0) {
	throw "Packaging 拒絕 dirty worktree：$($dirty -join '; ')"
}

$pubspec = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'pubspec.yaml')
if ($pubspec -notmatch '(?m)^version:\s*([^\s]+)\s*$') {
	throw 'pubspec.yaml 缺少 version。'
}
$packageVersion = $Matches[1]
$archiveVersion = $packageVersion.Split('+')[0]
$archiveBaseName = "Notist-$archiveVersion-windows-x64"

if (!$BuildDirectory) {
	$BuildDirectory = Join-Path $projectRoot 'build\windows\x64\runner\Release'
}
$bundleRoot = Resolve-Directory -Path $BuildDirectory -Label 'Windows Release bundle'

if (!$OutputDirectory) {
	$OutputDirectory = Join-Path $projectRoot 'dist'
}
$outputRoot = [System.IO.Path]::GetFullPath($OutputDirectory)
$archivePath = Join-Path $outputRoot "$archiveBaseName.zip"
$checksumPath = "$archivePath.sha256"
if ((Test-Path -LiteralPath $archivePath) -or (Test-Path -LiteralPath $checksumPath)) {
	throw "Packaging 不覆寫既有成品：$archivePath"
}

Assert-RequiredPath -Root $bundleRoot -RelativePath 'notist.exe'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'flutter_windows.dll'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'krepis_c.dll'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data' -PathType Container
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data\icudtl.dat'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data\app.so'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data\flutter_assets' -PathType Container
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data\flutter_assets\AssetManifest.bin'
Assert-RequiredPath -Root $bundleRoot -RelativePath 'data\flutter_assets\NativeAssetsManifest.json'

$headEpoch = & git -C $projectRoot show -s --format=%ct HEAD
if ($LASTEXITCODE -ne 0 -or $headEpoch -notmatch '^\d+$') {
	throw '無法取得 HEAD timestamp。'
}
$minimumBuildTime = [DateTimeOffset]::FromUnixTimeSeconds([long] $headEpoch).UtcDateTime
$freshArtifacts = @(
	'notist.exe',
	'krepis_c.dll',
	'data\app.so',
	'data\flutter_assets\AssetManifest.bin',
	'data\flutter_assets\NativeAssetsManifest.json'
)
foreach ($relativePath in $freshArtifacts) {
	$artifact = Get-Item -LiteralPath (Join-Path $bundleRoot $relativePath)
	if ($artifact.LastWriteTimeUtc -lt $minimumBuildTime) {
		throw "Packaging 拒絕 stale artifact：$relativePath ($($artifact.LastWriteTimeUtc.ToString('o')))"
	}
}

$exeVersion = (Get-Item -LiteralPath (Join-Path $bundleRoot 'notist.exe')).VersionInfo.ProductVersion
if ($exeVersion -ne $packageVersion) {
	throw "notist.exe ProductVersion $exeVersion 與 pubspec $packageVersion 不一致。"
}

$releaseNotes = Join-Path $projectRoot "docs\releases\$archiveVersion.md"
if (!(Test-Path -LiteralPath $releaseNotes -PathType Leaf)) {
	throw "缺少 release notes：$releaseNotes"
}
$kallopisRoot = Resolve-KallopisSource
$krepisRoot = Resolve-KrepisSource
$kallopisLicense = Get-ChildItem -LiteralPath $kallopisRoot -File |
	Where-Object { $_.Name -match '^LICENSE(?:\.|$)' } |
	Select-Object -First 1
if (!$kallopisLicense) {
	throw 'Kallopis 缺少專案自身 LICENSE；不得封裝。'
}
$kallopisThirdPartyLicenses = @(
	Join-Path $kallopisRoot 'THIRD_PARTY_NOTICES.md'
	Join-Path $kallopisRoot 'assets\icons\ui_oval\LUCIDE_LICENSE.txt'
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }
if (!$kallopisThirdPartyLicenses) {
	throw 'Kallopis 缺少 third-party notices／licenses；不得封裝。'
}
$krepisLicense = Get-ChildItem -LiteralPath $krepisRoot -File |
	Where-Object { $_.Name -match '^LICENSE(?:\.|$)' } |
	Select-Object -First 1
if (!$krepisLicense) {
	throw 'Krepis 缺少專案自身 LICENSE；授權裁決前不得封裝。'
}
$krepisThirdPartyLicenses = Join-Path $krepisRoot 'third_party\licenses'
if (!(Test-Path -LiteralPath $krepisThirdPartyLicenses -PathType Container) -or
	!(Get-ChildItem -LiteralPath $krepisThirdPartyLicenses -Recurse -File | Select-Object -First 1)) {
	throw 'Krepis 缺少 third-party licenses；不得封裝。'
}

New-Item -ItemType Directory -Force -Path $outputRoot | Out-Null
$stagingRoot = Join-Path $outputRoot ".$archiveBaseName-$([Guid]::NewGuid().ToString('N'))"
$stagingBundle = Join-Path $stagingRoot $archiveBaseName
$temporaryArchive = Join-Path $stagingRoot "$archiveBaseName.zip"

try {
	New-Item -ItemType Directory -Force -Path $stagingBundle | Out-Null
	Get-ChildItem -LiteralPath $bundleRoot -Force |
		Copy-Item -Destination $stagingBundle -Recurse
	Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination $stagingBundle
	Copy-Item -LiteralPath $releaseNotes -Destination (Join-Path $stagingBundle 'RELEASE_NOTES.md')
	Copy-Item -LiteralPath (Join-Path $projectRoot 'SECURITY.md') -Destination $stagingBundle

	$licenseRoot = Join-Path $stagingBundle 'licenses'
	New-Item -ItemType Directory -Force -Path (Join-Path $licenseRoot 'Kallopis') | Out-Null
	New-Item -ItemType Directory -Force -Path (Join-Path $licenseRoot 'Krepis') | Out-Null
	Copy-Item -LiteralPath $kallopisLicense.FullName -Destination (Join-Path $licenseRoot 'Kallopis')
	foreach ($thirdPartyLicense in $kallopisThirdPartyLicenses) {
		Copy-Item -LiteralPath $thirdPartyLicense -Destination (Join-Path $licenseRoot 'Kallopis')
	}
	Copy-Item -LiteralPath $krepisLicense.FullName -Destination (Join-Path $licenseRoot 'Krepis')
	Copy-Item `
		-LiteralPath $krepisThirdPartyLicenses `
		-Destination (Join-Path $licenseRoot 'Krepis\third_party') `
		-Recurse

	$manifestFiles = Get-ChildItem -LiteralPath $stagingBundle -Recurse -File |
		Sort-Object FullName |
		ForEach-Object {
			[ordered]@{
				path = $_.FullName.Substring($stagingBundle.Length + 1).Replace('\', '/')
				size = $_.Length
				sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
			}
		}
	$manifest = [ordered]@{
		packageVersion = $packageVersion
		sourceCommit = (& git -C $projectRoot rev-parse HEAD).Trim()
		kallopisCommit = '9d8b2d078b1c6750d2220d212be4d19626b094ad'
		krepisCommit = '546891bc2663105f87cdcf94da6513a6c051d1cf'
		createdAtUtc = [DateTime]::UtcNow.ToString('o')
		files = @($manifestFiles)
	}
	$manifest | ConvertTo-Json -Depth 5 |
		Set-Content -LiteralPath (Join-Path $stagingBundle 'manifest.json') -Encoding utf8NoBOM

	Compress-Archive -LiteralPath $stagingBundle -DestinationPath $temporaryArchive
	$archiveHash = (Get-FileHash -LiteralPath $temporaryArchive -Algorithm SHA256).Hash.ToLowerInvariant()
	Move-Item -LiteralPath $temporaryArchive -Destination $archivePath
	"$archiveHash  $([System.IO.Path]::GetFileName($archivePath))" |
		Set-Content -LiteralPath $checksumPath -Encoding ascii
}
finally {
	if (Test-Path -LiteralPath $stagingRoot) {
		$resolvedOutput = [System.IO.Path]::GetFullPath($outputRoot).TrimEnd('\') + '\'
		$resolvedStaging = [System.IO.Path]::GetFullPath($stagingRoot)
		if (!$resolvedStaging.StartsWith($resolvedOutput, [StringComparison]::OrdinalIgnoreCase)) {
			throw "拒絕清理 output 以外的 staging path：$resolvedStaging"
		}
		Remove-Item -LiteralPath $resolvedStaging -Recurse -Force
	}
}

Write-Host "Windows package：$archivePath"
Write-Host "SHA-256：$checksumPath"
