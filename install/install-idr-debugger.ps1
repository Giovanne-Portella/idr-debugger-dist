# =============================================================================
# Instalador do IDR Debugger via policy do Windows (HKLM)
#
# Escreve em HKLM\Software\Policies - requer admin. Se o script nao for
# iniciado como admin, ele se relancarado com "Executar como Administrador"
# automaticamente (o UAC vai pedir a senha/confirmacao).
#
# Uso:
#   .\install-idr-debugger.ps1
#
# Pra desinstalar: rode uninstall-idr-debugger.ps1
# =============================================================================

$ErrorActionPreference = 'Stop'

# --- Auto-elevacao -----------------------------------------------------------
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)
if (-not $isAdmin) {
    Write-Host "Requerendo permissao de administrador..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}
# -----------------------------------------------------------------------------

$EXTENSION_ID = 'edopokmfofednhgnjdcjhgdjdgdglbdn'
$UPDATE_URL   = 'https://giovanne-portella.github.io/idr-debugger-dist/update.xml'

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKLM:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKLM:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKLM:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKLM:\Software\Policies\Opera Software\Opera Stable' }
)

$value = "$EXTENSION_ID;$UPDATE_URL"

Write-Host "Instalando IDR Debugger via policy (HKLM)..." -ForegroundColor Cyan
Write-Host "Extension ID: $EXTENSION_ID"
Write-Host "Update URL:   $UPDATE_URL"
Write-Host ""

foreach ($b in $browsers) {
    $forcePath = Join-Path $b.Path 'ExtensionInstallForcelist'
    try {
        if (-not (Test-Path $forcePath)) {
            New-Item -Path $forcePath -Force | Out-Null
        }
        Set-ItemProperty -Path $forcePath -Name '1' -Value $value -Type String
        Write-Host "  [OK] $($b.Name)" -ForegroundColor Green
    } catch {
        Write-Host "  [SKIP] $($b.Name) - $($_.Exception.Message)" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Pronto." -ForegroundColor Cyan
Write-Host "Feche e reabra o(s) navegador(es) que voce usa. A extensao sera"
Write-Host "instalada automaticamente em ate ~1 minuto apos a reabertura."
Write-Host ""
Write-Host "Pra verificar:"
Write-Host "  chrome://extensions/  (procure Mapeador de Jornada - IDR Studio)"
Write-Host ""
Write-Host "Pra desinstalar mais tarde, rode uninstall-idr-debugger.ps1"
Write-Host ""
pause
