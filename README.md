# Mapeador de Jornada — IDR Studio

Extensão de uso interno da **Robbu** para análise de jornadas IDR diretamente no Invenio Center.  
Distribuída via **Chrome Web Store (privada)** com instalação forçada por policy do Windows.

---

## Instalar

Execute o comando abaixo no PowerShell (não precisa abrir como administrador — o script pede elevação automaticamente):

```powershell
Invoke-WebRequest -Uri "https://giovanne-portella.github.io/idr-debugger-dist/install/install-idr-debugger.ps1" -OutFile "$env:TEMP\install-idr-debugger.ps1" -UseBasicParsing
powershell -ExecutionPolicy Bypass -File "$env:TEMP\install-idr-debugger.ps1"
```

1. Uma janela de UAC aparece — clique em **Sim**
2. O script configura a policy nos navegadores instalados (Chrome, Edge, Brave, Opera)
3. **Feche e reabra o navegador**
4. O Chrome contata a Chrome Web Store e instala a extensão automaticamente em ~1 min
5. A extensão aparece fixada na barra de ferramentas e **não pode ser desativada pelo usuário** (instalação forçada por policy)

---

## Desinstalar

```powershell
Invoke-WebRequest -Uri "https://giovanne-portella.github.io/idr-debugger-dist/install/uninstall-idr-debugger.ps1" -OutFile "$env:TEMP\uninstall-idr-debugger.ps1" -UseBasicParsing
powershell -ExecutionPolicy Bypass -File "$env:TEMP\uninstall-idr-debugger.ps1"
```

Feche e reabra o navegador. A extensão é removida automaticamente.

---

## Atualizações

Automáticas. O Chrome verifica atualizações na Chrome Web Store a cada inicialização.  
Não é necessária nenhuma ação por parte do usuário.

---

## Instalação em massa via GPO / SCCM (TI)

Em vez de rodar o script por máquina, o time de TI pode distribuir a policy via GPO:

**Chave:** `HKLM\Software\Policies\Google\Chrome\ExtensionInstallForcelist`  
**Valor (REG_SZ):** `chjppnjbcimagfgoimogjojchfjlnifl;https://clients2.google.com/service/update2/crx`

Replicar para `Microsoft\Edge`, `BraveSoftware\Brave` e `Opera Software\Opera Stable` conforme os navegadores em uso na organização.

---

## Solução de problemas

| Sintoma | O que verificar |
|---|---|
| Extensão não aparece após reabrir o Chrome | Aguardar ~2 min; ou ir em `chrome://extensions` e clicar "Atualizar" |
| Erro no script de instalação | Confirmar que o UAC foi aceito; rodar PowerShell como Administrador manualmente |
| `chrome://policy` não mostra `ExtensionInstallForcelist` | Rodar o script de instalação novamente |
| A extensão aparece mas fica desabilitada | Verificar se há outra policy bloqueando — contatar TI |

---

## Informações técnicas

| Campo | Valor |
|---|---|
| ID da extensão | `chjppnjbcimagfgoimogjojchfjlnifl` |
| Versão atual | 2.2.1 |
| Update URL | `https://clients2.google.com/service/update2/crx` |
| Distribuição | Chrome Web Store — privada (não aparece em busca pública) |
| Código-fonte | Repositório privado separado |
