# Gerenciador de instalacoes silenciosas
# Ivo Dias

# Escreve a funcao em Powershell
function Escreva-Powershell {
    param (
        [parameter(position=0, Mandatory=$True)]
        $NomeSoftware,
        [parameter(position=1, Mandatory=$True)]
        $Path,
        [parameter(position=2, Mandatory=$True)]
        $instalador,
        [parameter(position=3, Mandatory=$True)]
        $Parametro,
        [parameter(position=4, Mandatory=$True)]
        $SoftwarePath,
        [parameter(position=5, Mandatory=$True)]
        $ScriptPath
    )

    # Cabecalho
    $versao = Get-Date -Format yyyyMMddThhmmss # Gera a versao
    $padrao = "# Script de instalacao do $NomeSoftware
# Gerado pela ferramenta desenvolvida por IGD753
# Versao $versao"

    # Biblioteca de funcoes:
    # Configuracoes gerais
    $configuracoesGerais = "
# Configuracoes gerais
@#%PastaTI = &&&C:\TI&&& # Define o caminho padrao da pasta de Logs
@#%pastaLOGs = &&&@#%PastaTI\LOGs&&& # Configura a pasta para os Desligamentos
@#%identificacao = Get-Date -Format LOG@ddMMyyyymmss # Cria um codigo baseado no dia mes ano (02102019)
@#%identificacao += &&&.txt&&& # Atribui um tipo ao log
@#%pastaOk = &&&@#%pastaLOGs\OK&&& # Define a pasta de logs que funcionaram
@#%pastaErro = &&&@#%pastaLOGs\Erro&&& # Define a pasta de logs que nao funcionaram
@#%pastaAndamento = &&&@#%pastaLOGs\Agora&&& # Define a pasta de logs que estao em andamento
@#%LogOk = &&&@#%pastaOk\@#%identificacao&&& # Define o arquivo de logs que funcionaram
@#%LogErro = &&&@#%pastaErro\@#%identificacao&&& # Define o arquivo de que não funcionaram
@#%LogAndamento = &&&@#%pastaAndamento\@#%identificacao&&& # Define o arquivo dos que estao em andamento"
    $configuracoesGerais = $configuracoesGerais -replace "@#%", '$' # Altera os valores para deixar o texto com as variaveis
    $configuracoesGerais = $configuracoesGerais -replace "&&&", '"' # Altera os valores para configurar as ""

    # Validar Pastas
    $funcaoValidarPastas = "
# Verifica se as pastas estao criadas
function Validar-Pasta {
    param (
        [parameter(position=0,Mandatory=@#%True)]
        @#%caminho
    )
    # Verifica se ja existe
    @#%Existe = Test-Path -Path @#%caminho
    # Cria a pasta
    if (@#%Existe -eq @#%false) {
        try {
            @#%noReturn = New-Item -ItemType directory -Path @#%caminho # Cria a pasta
        }
        catch {
            exit
        }
    }
}"
    $funcaoValidarPastas = $funcaoValidarPastas -replace "@#%", '$' # Altera os valores para deixar o texto com as variaveis

    # Validacao dos caminhos
    $validacaoCaminhos = "
# Validacao dos caminhos
Validar-Pasta @#%PastaINFRA
Validar-Pasta @#%pastaLOGs
Validar-Pasta @#%pastaOk
Validar-Pasta @#%pastaErro
Validar-Pasta @#%pastaAndamento"
    $validacaoCaminhos = $validacaoCaminhos -replace "@#%", '$' # Altera os valores para deixar o texto com as variaveis

    # Instalacao de software
    $funcaoInstalarPrograma = "
# Funcao para instalar programas
function Instalar-Software {
    param (
        [parameter(position=0, Mandatory=@#%True)]
        @#%NomeSoftware,
        [parameter(position=1, Mandatory=@#%True)]
        @#%Path,
        [parameter(position=2, Mandatory=@#%True)]
        @#%instalador,
        [parameter(position=3, Mandatory=@#%True)]
        @#%Parametro,
        [parameter(position=4, Mandatory=@#%True)]
        @#%SoftwarePath
    )
    # Verifica se o programa esta instalado
    if (@#%SoftwarePath -eq @#%false) {
        try {
            Add-Content -Path &&&@#%LogAndamento&&& -Value &&&@#%NomeSoftware : Copiando os arquivos&&& # Grava o log
            Copy-Item &&&@#%Path\@#%instalador&&& -Destination &&&@#%PastaINFRA&&& -Force # Copia o arquivo
            Add-Content -Path &&&@#%LogAndamento&&& -Value &&&@#%NomeSoftware : Instalando..&&& # Grava o log
            cmd /c &&&@#%PastaINFRA\@#%instalador @#%Parametro&&& # Faz a instalacao
            Add-Content -Path &&&@#%LogOk&&& -Value &&&@#%NomeSoftware : Instalado&&& # Grava o log
            Remove-Item -Path &&&@#%LogAndamento&&& -Force # Remove o log em Andamento
        }
        catch {
            @#%ErrorMessage = @#%_.Exception.Message # Recebe o erro
            Add-Content -Path &&&@#%LogErro&&& -Value &&&@#%NomeSoftware : @#%ErrorMessage&&& # Grava o log
        }
    } else {
        Add-Content -Path &&&@#%LogOk&&& -Value &&&@#%NomeSoftware ja esta instalado&&&
    }
}"
    $funcaoInstalarPrograma = $funcaoInstalarPrograma -replace "@#%", '$' # Altera os valores para deixar o texto com as variaveis
    $funcaoInstalarPrograma = $funcaoInstalarPrograma -replace "&&&", '"' # Altera os valores para configurar as ""

    # Parametros
    $parametros = "
# Parametros
@#%NomeSoftware = &&&$NomeSoftware&&&
@#%Path = &&&$Path&&&
@#%instalador = &&&$instalador&&&
@#%Parametro = &&&$Parametro&&&
@#%SoftwarePath = Test-Path -Path &&&$SoftwarePath&&&
# Faz a instalacao
Instalar-Software @#%NomeSoftware @#%Path @#%instalador @#%Parametro @#%SoftwarePath"
    $parametros = $parametros -replace "@#%", '$' # Altera os valores para deixar o texto com as variaveis
    $parametros = $parametros -replace "&&&", '"' # Altera os valores para configurar as ""

    # Configura o nome
    $nomeScript = $NomeSoftware -replace " ", '-' # Remove os espacos
    $ScriptPath += "\$nomeScript.ps1"

    # Escreve o script
    try {
        Write-Host "Escrevendo o script.."
        Add-Content -Path "$ScriptPath" -Value "$padrao"
        Add-Content -Path "$ScriptPath" -Value "$configuracoesGerais"
        Add-Content -Path "$ScriptPath" -Value "$funcaoValidarPastas"
        Add-Content -Path "$ScriptPath" -Value "$validacaoCaminhos"
        Add-Content -Path "$ScriptPath" -Value "$funcaoInstalarPrograma"
        Add-Content -Path "$ScriptPath" -Value "$parametros"
        Write-Host "Script disponivel em: $ScriptPath"
    }
    catch {
        $ErrorMessage = $_.Exception.Message # Recebe o erro
        Write-Host "Erro: $ErrorMessage"
    }
}