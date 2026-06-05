# =============================================================================
# Desinstalador do IDR Debugger
#
# Remove a entrada da policy de cada navegador. Na proxima reabertura, o
# Chrome/Edge/etc detecta que a policy sumiu e desinstala a extensao
# automaticamente.
# =============================================================================

$ErrorActionPreference = 'Stop'

$EXTENSION_ID = 'edopokmfofednhgnjdcjhgdjdgdglbdn'

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKCU:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKCU:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKCU:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKCU:\Software\Policies\Opera Software\Opera Stable' }
)

Write-Host "Removendo IDR Debugger da policy..." -ForegroundColor Cyan
Write-Host ""

foreach ($b in $browsers) {
    $forcePath = Join-Path $b.Path 'ExtensionInstallForcelist'
    if (-not (Test-Path $forcePath)) {
        Write-Host "  [PULAR] $($b.Name) — nao tinha policy"
        continue
    }
    try {
        # Procura todos os values cujo conteudo comece com o nosso ID
        $entries = Get-Item $forcePath
        $removed = $false
        foreach ($name in $entries.Property) {
            $val = (Get-ItemProperty -Path $forcePath -Name $name).$name
            if ($val -like "$EXTENSION_ID;*") {
                Remove-ItemProperty -Path $forcePath -Name $name
                $removed = $true
            }
        }
        # Se a chave ficou vazia, remove ela tambem
        $entries = Get-Item $forcePath
        if (-not $entries.Property -or $entries.Property.Count -eq 0) {
            Remove-Item $forcePath -Force
        }
        if ($removed) {
            Write-Host "  [OK] $($b.Name)" -ForegroundColor Green
        } else {
            Write-Host "  [PULAR] $($b.Name) — nao havia entrada do IDR Debugger"
        }
    } catch {
        Write-Host "  [ERRO] $($b.Name) — $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "Pronto." -ForegroundColor Cyan
Write-Host "Reabra o(s) navegador(es). A extensao sera desinstalada automaticamente"
Write-Host "na proxima reabertura."
