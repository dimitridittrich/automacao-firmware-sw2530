#Scriptcriado por: Dimitri Dittrich
#Data: 04/09/2017
#Objetivo: Criar arquivo *.bin com password encriptado
#------------AUTOMATIC-PATH-------------"
$completo = $MyInvocation.MyCommand.Path
$scriptname = $MyInvocation.MyCommand.Name
$caminho = $completo -replace $scriptname, ""
#-------------------------------------"

Function create-pass-encrypt-hash-bin
{
param($path_encrypt)
    Process
    {
    #$passwd = Read-Host "Informe a senha" -AsSecureString
    #$encpwd = ConvertFrom-SecureString $passwd
    #$encpwd > "$path_encrypt./encryptpass/passcrypto.bin"


    Get-Credential | Export-Clixml -"$caminho.\pass.xml"
    }
}