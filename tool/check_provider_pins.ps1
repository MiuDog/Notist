$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$kallopisSha = 'ee42c3854d12cd7b4100b7b61697c90c938ce570'
$krepisSha = 'd39c1cdf92faa6f6301ff19229aa21602f5bfe56'
$expectedKallopisPath = (Resolve-Path -LiteralPath (Join-Path $projectRoot '..\Kallopis')).Path
$pubspec = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'pubspec.yaml')
$lockfile = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'pubspec.lock')
$windowsCmake = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'windows\CMakeLists.txt')

if ($pubspec -match '(?m)^dependency_overrides:') {
	throw 'pubspec.yaml 不得使用 dependency_overrides。'
}

$usesGitKallopis = $pubspec -match "(?ms)^\s*kallopis:\s*\r?\n\s*git:\s*\r?\n\s*url:\s*https://github\.com/MiuDog/Kallopis\.git\s*\r?\n\s*ref:\s*" + [regex]::Escape($kallopisSha)
$usesPathKallopis = $pubspec -match "(?ms)^\s*kallopis:\s*\r?\n\s*path:\s*(?:'|"")?\.{2}/Kallopis(?:'|"")?"

if (!($usesGitKallopis -or $usesPathKallopis)) {
	throw 'Kallopis 依賴必須為核准的 GitHub commit 或本機 ../Kallopis path。'
}

if ($usesGitKallopis) {
	if ((!$lockfile.Contains("resolved-ref: $kallopisSha") -and
		!$lockfile.Contains("resolved-ref: `"$kallopisSha`"")) -or
		!$lockfile.Contains('url: "https://github.com/MiuDog/Kallopis.git"')) {
		throw 'pubspec.lock 的 Kallopis resolved-ref 或正式 URL 不符。'
	}
	Write-Host "Kallopis provider 採用 commit pin：$kallopisSha"
}

if ($usesPathKallopis) {
	if (!(Test-Path -LiteralPath $expectedKallopisPath -PathType Container)) {
		throw "pubspec.yaml 使用本機 path 依賴，但找不到路徑：$expectedKallopisPath"
	}
	if (!$lockfile.Contains('source: path') -or !$lockfile.Contains('path: "../Kallopis"')) {
		throw 'pubspec.lock 的 Kallopis source/path 與 ../Kallopis 來源資訊不符。'
	}
	Write-Host "Kallopis provider 採用本機 path 依賴：../Kallopis"
}

if (!$windowsCmake.Contains('https://github.com/MiuDog/Krepis.git') -or
	!$windowsCmake.Contains($krepisSha)) {
	throw 'Windows CMake 必須固定到核准的 Krepis GitHub commit。'
}
if ($windowsCmake.Contains('../../Krepis') -or
	$windowsCmake.Contains('..\..\Krepis')) {
	throw 'Windows CMake 不得依賴 sibling Krepis checkout。'
}
if (!$windowsCmake.Contains('message(FATAL_ERROR "Notist requires Krepis ABI major 1")') -or
	!$windowsCmake.Contains('message(FATAL_ERROR "Notist requires Krepis ABI minor 11")')) {
	throw 'Windows CMake 缺少 Krepis ABI fail-closed gate。'
}

if ($usesGitKallopis) {
	Write-Host "Provider pins 一致：Kallopis $kallopisSha；Krepis $krepisSha"
} else {
	Write-Host "Provider pins：Kallopis 本機 path；Krepis $krepisSha"
}
