# =============================================================================
# Instalador do IDR Debugger via policy do Windows
#
# Escreve as chaves de registro que fazem Chrome, Edge, Brave e Opera
# baixarem e instalarem a extensao automaticamente, sem passar pela Chrome
# Web Store e sem precisar de modo desenvolvedor.
#
# Escreve em HKCU (HKEY_CURRENT_USER) - NAO precisa de admin. O Chrome moderno
# le tanto HKLM (politica corporativa) quanto HKCU (politica de usuario).
# Pra instalacao em massa via GPO/SCCM, basta escrever em HKLM com o mesmo
# valor.
#
# Uso:
#   .\install-idr-debugger.ps1
#
# Pra desinstalar: rode uninstall-idr-debugger.ps1
# =============================================================================

$ErrorActionPreference = 'Stop'

$EXTENSION_ID = 'edopokmfofednhgnjdcjhgdjdgdglbdn'
$UPDATE_URL   = 'https://giovanne-portella.github.io/idr-debugger-dist/update.xml'

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKCU:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKCU:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKCU:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKCU:\Software\Policies\Opera Software\Opera Stable' }
)

$value = "$EXTENSION_ID;$UPDATE_URL"

Write-Host "Instalando IDR Debugger via policy..." -ForegroundColor Cyan
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
