$ErrorActionPreference = 'Stop'

$projectRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$kallopisSha = '465c5fec9a2fb5691c7ca7388d61744a1e847def'
$krepisSha = '1f35fab7409f04c75c11ba4077abd5cafa6ae497'
$pubspec = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'pubspec.yaml')
$lockfile = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'pubspec.lock')
$windowsCmake = Get-Content -Raw -LiteralPath (Join-Path $projectRoot 'windows\CMakeLists.txt')

if ($pubspec -match '(?m)^dependency_overrides:') {
	throw 'pubspec.yaml 不得使用 dependency_overrides。'
}
if (!$pubspec.Contains('https://github.com/MiuDog/Kallopis.git') -or
	!$pubspec.Contains("ref: $kallopisSha")) {
	throw 'Kallopis 必須固定到核准的 GitHub commit。'
}
if (!$lockfile.Contains("resolved-ref: `"$kallopisSha`"") -or
	!$lockfile.Contains('url: "https://github.com/MiuDog/Kallopis.git"')) {
	throw 'pubspec.lock 的 Kallopis resolved-ref 或正式 URL 不符。'
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
	!$windowsCmake.Contains('message(FATAL_ERROR "Notist requires Krepis ABI minor 7")')) {
	throw 'Windows CMake 缺少 Krepis ABI fail-closed gate。'
}

Write-Host "Provider pins 一致：Kallopis $kallopisSha；Krepis $krepisSha"
