[CmdletBinding(PositionalBinding=$false)]
param(
    [Parameter(Mandatory=$false)]
    [string] $BuildDir
)

if (!$BuildDir) {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        "AMD64" { $TargetTripleArch = "x86_64" }
        "x86" { $TargetTripleArch = "i686" }
        default { throw "Unknown architecture: $env:PROCESSOR_ARCHITECTURE" }
    }

    $TargetTriple = "$TargetTripleArch-unknown-windows-msvc"
    $BuildDir = "$PSScriptRoot\.build\$TargetTriple\debug"
}

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
& $PSScriptRoot\WindowsMetadataCoreLibrary\Assemble.ps1 -OutputPath $BuildDir\mscorlib.winmd