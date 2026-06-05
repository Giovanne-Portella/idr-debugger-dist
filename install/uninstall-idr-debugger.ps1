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

$browsers = @(
    @{ Name = 'Google Chrome';  Path = 'HKLM:\Software\Policies\Google\Chrome' },
    @{ Name = 'Microsoft Edge'; Path = 'HKLM:\Software\Policies\Microsoft\Edge' },
    @{ Name = 'Brave';          Path = 'HKLM:\Software\Policies\BraveSoftware\Brave' },
    @{ Name = 'Opera';          Path = 'HKLM:\Software\Policies\Opera Software\Opera Stable' }
)

Write-Host ''
Write-Host 'Removendo IDR Debugger da policy...' -ForegroundColor Cyan
Write-Host ''

foreach ($b in $browsers) {
    $forcePath = Join-Path $b.Path 'ExtensionInstallForcelist'
    if (-not (Test-Path $forcePath)) {
        Write-Host ('  [PULAR] ' + $b.Name + ' - nao tinha policy')
        continue
    }
    try {
        $entries = Get-Item $forcePath
        $removed = $false
        foreach ($name in $entries.Property) {
            $val = (Get-ItemProperty -Path $forcePath -Name $name).$name
            if ($val -like ($EXTENSION_ID + ';*')) {
                Remove-ItemProperty -Path $forcePath -Name $name
                $removed = $true
            }
        }
        $entries = Get-Item $forcePath
        if (-not $entries.Property -or $entries.Property.Count -eq 0) {
            Remove-Item $forcePath -Force
        }
        if ($removed) {
            Write-Host ('  [OK] ' + $b.Name) -ForegroundColor Green
        } else {
            Write-Host ('  [PULAR] ' + $b.Name + ' - nao havia entrada do IDR Debugger')
        }
    } catch {
        Write-Host ('  [ERRO] ' + $b.Name + ' - ' + $_.Exception.Message) -ForegroundColor Red
    }
}

Write-Host ''
Write-Host 'Pronto!' -ForegroundColor Green
Write-Host 'Reabra o(s) navegador(es). A extensao sera desinstalada automaticamente.'
Write-Host ''
Read-Host 'Pressione Enter para fechar'
