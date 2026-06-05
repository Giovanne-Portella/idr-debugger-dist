# IDR Debugger — Distribuição

Este repositório hospeda a extensão **Mapeador de Jornada — IDR Studio** para instalação em massa via policy do Windows. O código-fonte é mantido em repositório privado separado.

## Instalar

Baixe e execute como usuário comum (não precisa de admin):

```powershell
Invoke-WebRequest `
    -Uri "https://giovanne-portella.github.io/idr-debugger-dist/install/install-idr-debugger.ps1" `
    -OutFile "$env:TEMP\install-idr-debugger.ps1"

powershell -ExecutionPolicy Bypass -File "$env:TEMP\install-idr-debugger.ps1"
```

Feche e reabra o Chrome/Edge/Brave/Opera que você usa. Em ~1 min após a reabertura, a extensão aparece na barra de ferramentas.

## Atualizações

São automáticas. Quando uma versão nova for publicada aqui, o navegador detecta na próxima inicialização e atualiza sozinho.

## Desinstalar

```powershell
Invoke-WebRequest `
    -Uri "https://giovanne-portella.github.io/idr-debugger-dist/install/uninstall-idr-debugger.ps1" `
    -OutFile "$env:TEMP\uninstall-idr-debugger.ps1"

powershell -ExecutionPolicy Bypass -File "$env:TEMP\uninstall-idr-debugger.ps1"
```

Reabra os navegadores; a extensão é removida automaticamente.

## Instalação em massa via GPO/SCCM (TI)

Em vez de rodar o `.ps1` por máquina, o time de TI pode aplicar a policy via GPO:

- Chave: `HKLM\Software\Policies\Google\Chrome\ExtensionInstallForcelist`
- Valor (slot 1, REG_SZ): `edopokmfofednhgnjdcjhgdjdgdglbdn;https://giovanne-portella.github.io/idr-debugger-dist/update.xml`

Replicar pra `Microsoft\Edge`, `BraveSoftware\Brave`, `Opera Software\Opera Stable` conforme os browsers em uso.

## Conteúdo deste repositório

| Arquivo | Função |
|---|---|
| `update.xml` | Manifest consultado periodicamente pelo Chrome para descobrir versões novas |
| `idr-debugger-X.Y.Z.crx` | Pacote da extensão assinado |
| `install/install-idr-debugger.ps1` | Script de instalação por usuário |
| `install/uninstall-idr-debugger.ps1` | Script de remoção |
