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

$EXTENSION_ID = 'edopokmfofednhgnjdcjhgdjdgdglbdn'
$UPDATE_URL   = 'https://giovanne-portella.github.io/idr-debugger-dist/update.xml'

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKLM:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKLM:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKLM:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKLM:\Software\Policies\Opera Software\Opera Stable' }
)

$value = $EXTENSION_ID + ';' + $UPDATE_URL

Write-Host ''
Write-Host 'Instalando IDR Debugger via policy (HKLM)...' -ForegroundColor Cyan
Write-Host ('Extension ID: ' + $EXTENSION_ID)
Write-Host ('Update URL:   ' + $UPDATE_URL)
Write-Host ''

foreach ($b in $browsers) {
    $forcePath = Join-Path $b.Path 'ExtensionInstallForcelist'
    try {
        if (-not (Test-Path $forcePath)) {
            New-Item -Path $forcePath -Force | Out-Null
        }
        Set-ItemProperty -Path $forcePath -Name '1' -Value $value -Type String
        Write-Host ('  [OK] ' + $b.Name) -ForegroundColor Green
    } catch {
        Write-Host ('  [SKIP] ' + $b.Name + ' - ' + $_.Exception.Message) -ForegroundColor Yellow
    }
}

Write-Host ''
Write-Host 'Pronto!' -ForegroundColor Green
Write-Host ''
Write-Host 'Feche e reabra o(s) navegador(es) que voce usa.'
Write-Host 'A extensao sera instalada automaticamente em ate ~1 minuto.'
Write-Host ''
Write-Host 'Pra verificar: chrome://extensions/'
Write-Host '               (procure Mapeador de Jornada - IDR Studio)'
Write-Host ''
Read-Host 'Pressione Enter para fechar'
