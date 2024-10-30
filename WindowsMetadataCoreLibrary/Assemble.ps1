[CmdletBinding(PositionalBinding=$false)]
param(
    [Parameter(Mandatory=$false)]
    [string] $SourcePath = "",
    [Parameter(Mandatory=$true)]
    [string] $OutputPath
)

if (!$SourcePath) {
    $SourcePath = "$PSScriptRoot\\mscorlib.il"
}

& "$Env:windir\\Microsoft.NET\\Framework64\\v4.0.30319\\ilasm.exe" `
    /nologo /quiet `
    /noautoinherit /dll `
    /output=$OutputPath `
    $SourcePath