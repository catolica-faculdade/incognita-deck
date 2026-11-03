param(
    [string]$Godot = 'godot',
    [switch]$Render,
    [switch]$Playtest,
    [string]$CaptureDirectory = ''
)

$projectDirectory = Split-Path -Parent $PSScriptRoot
$runnerScene = if ($Playtest) { 'res://tests/playtest_runner.tscn' } else { 'res://tests/test_runner.tscn' }
$engineArguments = @('--path', $projectDirectory, $runnerScene, '--max-fps', '120', '--quit-after', '15000')
if ($Render) {
    $engineArguments += @('--rendering-method', 'gl_compatibility', '--windowed', '--resolution', '1280x800')
} else {
    $engineArguments += '--headless'
}
if ($CaptureDirectory) {
    $capturePath = [System.IO.Path]::GetFullPath($CaptureDirectory)
    New-Item -ItemType Directory -Force -Path $capturePath | Out-Null
    $engineArguments += @('--', "--capture-dir=$capturePath")
}

$engineOutput = @(& $Godot @engineArguments 2>&1)
$engineExitCode = $LASTEXITCODE
$outputText = ($engineOutput | ForEach-Object { $_.ToString() }) -join "`n"
Write-Output $outputText
$expectedResult = if ($Playtest) { 'PLAYTEST: \d+/4 vitórias, 0 falhas de execução' } else { 'REGRESSAO: \d+ verificações, 0 falhas' }
if ($engineExitCode -ne 0 -or $outputText -match 'SCRIPT ERROR:|ERROR:' -or $outputText -notmatch $expectedResult) {
    Write-Error 'A validação falhou ou não terminou. Consulte a saída do Godot acima.'
    exit 1
}
exit 0
