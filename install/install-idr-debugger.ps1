$ErrorActionPreference = 'Stop'

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host ''
    Write-Host 'Esta operacao requer permissao de administrador.' -ForegroundColor Yellow
    Write-Host 'Uma janela de UAC vai aparecer -- clique em SIM para continuar.' -ForegroundColor Yellow
    Write-Host ''
    $scriptPath = $MyInvocation.MyCommand.Path
    if (-not $scriptPath) { $scriptPath = $PSCommandPath }
    Start-Process powershell -Verb RunAs -Wait -ArgumentList ('-ExecutionPolicy Bypass -File "' + $scriptPath + '"')
    exit
}

$EXTENSION_ID  = 'edopokmfofednhgnjdcjhgdjdgdglbdn'
$UPDATE_URL    = 'https://giovanne-portella.github.io/idr-debugger-dist/update.xml'
$INSTALL_PAGE  = 'https://giovanne-portella.github.io/idr-debugger-dist/'
$INSTALL_SOURCE = 'https://giovanne-portella.github.io/*'

Write-Host ''
Write-Host 'Configurando IDR Debugger para instalacao...' -ForegroundColor Cyan
Write-Host ''

# --- 1. ExtensionInstallForcelist (tentativa automatica) --------------------
$forcePath = 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallForcelist'
try {
    if (-not (Test-Path $forcePath)) { New-Item -Path $forcePath -Force | Out-Null }
    Set-ItemProperty -Path $forcePath -Name '1' -Value ($EXTENSION_ID + ';' + $UPDATE_URL) -Type String
    Write-Host '[1/3] ExtensionInstallForcelist configurado' -ForegroundColor Green
} catch {
    Write-Host ('[1/3] ExtensionInstallForcelist - SKIP: ' + $_.Exception.Message) -ForegroundColor Yellow
}

# --- 2. ExtensionInstallSources (permite instalar pelo site) ----------------
$srcPath = 'HKLM:\Software\Policies\Google\Chrome\ExtensionInstallSources'
try {
    if (-not (Test-Path $srcPath)) { New-Item -Path $srcPath -Force | Out-Null }
    Set-ItemProperty -Path $srcPath -Name '1' -Value $INSTALL_SOURCE -Type String
    Write-Host '[2/3] ExtensionInstallSources configurado' -ForegroundColor Green
} catch {
    Write-Host ('[2/3] ExtensionInstallSources - SKIP: ' + $_.Exception.Message) -ForegroundColor Yellow
}

# --- 3. Edge (mesmo mecanismo) -----------------------------------------------
$edgeSrcPath = 'HKLM:\Software\Policies\Microsoft\Edge\ExtensionInstallSources'
try {
    if (-not (Test-Path $edgeSrcPath)) { New-Item -Path $edgeSrcPath -Force | Out-Null }
    Set-ItemProperty -Path $edgeSrcPath -Name '1' -Value $INSTALL_SOURCE -Type String
    Write-Host '[3/3] ExtensionInstallSources (Edge) configurado' -ForegroundColor Green
} catch {
    Write-Host ('[3/3] Edge - SKIP: ' + $_.Exception.Message) -ForegroundColor Yellow
}

Write-Host ''
Write-Host 'Pronto! Agora abra o Chrome e acesse:' -ForegroundColor Green
Write-Host ''
Write-Host ('    ' + $INSTALL_PAGE) -ForegroundColor Cyan
Write-Host ''
Write-Host 'Clique em "Instalar IDR Debugger" e confirme no dialogo do Chrome.' -ForegroundColor White
Write-Host ''
Read-Host 'Pressione Enter para fechar'
