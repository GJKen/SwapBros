param(
    [Parameter(Mandatory = $true)][string]$CompilerPath,
    [Parameter(Mandatory = $true)][string]$BroforcePath,
    [Parameter(Mandatory = $true)][string]$UmmPath
)

$ErrorActionPreference = 'Stop'
$sourcePath = Join-Path $PSScriptRoot 'Swap Bros Mod'
$outputPath = Join-Path $PSScriptRoot 'bin\Release'
$managedPath = Join-Path $BroforcePath 'Broforce_beta_Data\Managed'
$frameworkPath = Join-Path $env:WINDIR 'Microsoft.NET\Framework\v2.0.50727'
$framework35Path = Join-Path ${env:ProgramFiles(x86)} 'Reference Assemblies\Microsoft\Framework\v3.5'
$references = @(
    (Join-Path $frameworkPath 'mscorlib.dll'),
    (Join-Path $frameworkPath 'System.dll'),
    (Join-Path $framework35Path 'System.Core.dll'),
    (Join-Path $managedPath 'Assembly-CSharp.dll'),
    (Join-Path $managedPath 'UnityEngine.dll'),
    (Join-Path $managedPath 'UnityEngine.CoreModule.dll'),
    (Join-Path $managedPath 'UnityEngine.IMGUIModule.dll'),
    (Join-Path $managedPath 'UnityEngine.TextRenderingModule.dll'),
    (Join-Path $UmmPath 'Core\0Harmony.dll'),
    (Join-Path $UmmPath 'Core\UnityModManager.dll'),
    (Join-Path $UmmPath 'Mods\BroMaker-BroMaker\BroMakerLib\BroMakerLib.dll'),
    (Join-Path $UmmPath 'Mods\RocketLib-RocketLib\RocketLib\RocketLib.dll')
)
foreach ($reference in @($CompilerPath) + $references) {
    if (-not (Test-Path -LiteralPath $reference -PathType Leaf)) { throw "Missing build reference: $reference" }
}

New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
$arguments = @('/nostdlib+', '/target:library', '/optimize+', '/deterministic+', '/define:TRACE', '/nologo')
$arguments += '/out:"' + (Join-Path $outputPath 'Swap Bros Mod.dll') + '"'
$arguments += $references | ForEach-Object { '/reference:"' + $_ + '"' }
$arguments += Get-ChildItem -LiteralPath $sourcePath -Recurse -Filter '*.cs' | ForEach-Object { '"' + $_.FullName + '"' }
$responsePath = Join-Path $outputPath 'build.rsp'
$arguments | Set-Content -Encoding UTF8 -LiteralPath $responsePath
& $CompilerPath /noconfig ('@' + $responsePath)
if ($LASTEXITCODE -ne 0) { throw "Swap Bros compilation failed: $LASTEXITCODE" }
Get-Item -LiteralPath (Join-Path $outputPath 'Swap Bros Mod.dll') | Select-Object FullName, Length, LastWriteTime
