<#
Script de automacao para atualizacao de firmware de switches HP 2530
Sem Job de reboot (com reboot automatico apos atualizacao) e com prova real apos reboot
Autor: Dimitri Dittrich
Data: 29/10/2017
#>

#------------AUTOMATIC-PATH-------------"
$completo = $MyInvocation.MyCommand.Path
$scriptname = $MyInvocation.MyCommand.Name
$caminho = $completo -replace $scriptname, ""
#-------------------------------------"
cls


Write-Host "`n"
Write-Host "`n"
#----------MODULOS-CAMINHOS-VARIAVEIS-----------"
$date = get-date
$cont = 0
$final_verification = "y"

#PRE-REQUISITOS E VALORES A SEREM ALTERADOS CONFORME NECESSIDADE
#Necessario ter instalado o modulo posh-ssh
$tftpserver = "100.100.0.151"
$csvfile = "$caminho.\ips-switches.csv"
[string]$username = "manager"
[string]$arqpassencrypted ="$caminho.\encryptpass\passcrypto.bin"
$desiredversion = "YA.15.16.0005r"
$arqfirmware = "YA_15_16_0005.swi"
$pathlog = "$caminho.\log.txt"
Import-Module -name posh-ssh
Remove-Module "function01-hp2530"
Import-Module "$caminho.\functions\function01-hp2530.psm1"
Remove-Module "function02-synctime"
Import-Module "$caminho.\functions\function02-synctime.psm1"
Remove-Module "create-pass-encrypt-hash-bin"
Import-Module "$caminho.\encryptpass\create-pass-encrypt-hash-bin.psm1"
cls
#----------------------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------CREDENCIAIS-SSH-----------#########"
[string]$username = Read-Host "Informe o USER para acessar o Switch por SSH"
create-pass-encrypt-hash-bin -path_encrypt $caminho
Write-Host "#########------------------------------------#########"

Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------PING-SW-----------#########"
$ColumnHeader = "IPaddress"
Write-Host "Reading file" $csvfile
$ipaddresses = import-csv $csvfile | select-object $ColumnHeader

foreach($ip in $ipaddresses) {
$cont = 0
$ipaddress = $ip.("IPAddress")
    
    while ($cont -le 2) {

    if (test-connection $ip.("IPAddress") -count 1 -quiet) {
        write-host $ip.("IPAddress") "Ping succeeded." -foreground green
        #variavel ipaddress recebe o ip que esta na vez do csv
        $cont = 4

Remove-SSHSession -Index 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20
Write-Host "#########-----------------------------#########"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------CONEXAO-SSH---------"
$encpwd = Get-Content $arqpassencrypted
Write-Host ">>>>>Converte o arquivo para um string confiável<<<<<"
$passwd = ConvertTo-SecureString $encpwd
Write-Host ">>>>>Define a credencial necessária<<<<<"
$cred = new-object System.Management.Automation.PSCredential $username,$passwd

Write-Host ">>>>>Cria sessao<<<<<"
$retorno_ssh = New-SSHSession -ComputerName $ipaddress -AcceptKey -Credential $cred -Verbose           

            Write-Host ">>>>>VALIDA-CONEXAO<<<<<"
            
            if ($retorno_ssh.Connected)
            {
            Write-Host "CONEXÃO SSH no Switch de IP $ipaddress REALIZADA COM SUCESSO!"
            [string]$log = $date.ToString() + " - CONEXAO SSH no Switch de IP " + $ipaddress.ToString() + " REALIZADA COM SUCESSO!"
            Add-Content -Path $pathlog -Value $log
            }
                else
                {
                Write-Host "CONEXÃO SSH no Switch de IP $ipaddress NÃO DEU CERTO! PRESSIONE QUALQUER TECLA PARA PROSSEGUIR AO PRÓXIMO IP DA LISTA"
                [string]$log = "#####PROBLEM#####"+$date.ToString() +" - CONEXÃO SSH no Switch de IP "+ $ipaddress.ToString() + " NÃO DEU CERTO!"
                Add-Content -Path $pathlog -Value $log
                pause
                cls
                break
                }
$session = Get-SSHSession -Index 0
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------CRIANDO-SHELL-STREAM---------"
$stream = $session.Session.CreateShellStream("Dimi", 1000, 1000, 1000, 1000, 1000)
$streamoutput = $stream.Read()
Clear-Variable streamoutput -Verbose
Start-Sleep -Seconds 1 -Verbose
$stream
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------ENTRADA---------"
$stream.Write("en`n")
Start-Sleep -Seconds 1
$streamoutput = $stream.Read()
Write-Host $streamoutput
Clear-Variable streamoutput
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------RUNNING-CONFIG---------"
function01-hp2530 -command "show run"
Write-Host "------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------VERIFICA-HORA---------"
$synctime = function02-synctime
                        if ($synctime -eq 'True')
                        {
                        Write-Host "HORA E DATA SINCRONIZADOS"
                        [string]$log = $date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " está com hora e data sincronizados!"
                        Add-Content -Path $pathlog -Value $log
                        }
                            else
                            {
                            Write-Host "HORA E DATA NAO SINCRONIZADOS, VERIFIQUE!"
                            Write-Host "PRESSIONE QUALQUER TECLA PARA PROSSEGUIR AO PRÓXIMO SWITCH!"
                            [string]$log = "#####PROBLEM#####"+$date.ToString()+" - Firmware do Switch de IP "+ $ipaddress.ToString() + " não foi atualizado pois a hora e data estão errados, verifique!"
                            Add-Content -Path $pathlog -Value $log
                            pause
                            cls
                            break
                            }
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "---------SHOW-VERSION----------"
$stream.Write("show version`n")
Start-Sleep -Seconds 1
$streamoutput = $stream.Read()
Write-Host $streamoutput
Write-Host "-----------------------------"
$version_firmware = $streamoutput.Contains($desiredversion)
    if ($version_firmware -ne 'true')
    {
#---------------TEST-PING-TFTP_SERVER---------------
Write-Host "#---------------TEST-PING-TFTP_SERVER---------------"
            $cont_tftp = 0   
            $break=""
            while ($cont_tftp -le 2)
            {
                if (test-connection $tftpserver -count 1 -quiet)
	            {
                write-host $tftpserver "Ping succeeded." -foreground green
                $cont_tftp = 4
	            }
	                else
	                {
                    write-host $tftpserver "Ping failed." -foreground red
                    Write-Host "Tentando pingar novamente"
                    $cont_tftp++
                    Start-Sleep -Seconds 2
             	        if ($cont_tftp -gt 2)
             	        {
                        Write-Host "$date - Switch de IP "+ $ipaddress.ToString() + " não foi atualizado pois o tftp server $tftpserver não respondeu ao ping"	
                        [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " não foi atualizado pois o tftp server $tftpserver não respondeu ao ping"
            	        Add-Content -Path $pathlog -Value $log
                        exit
            	        }
       	            }
            }
#----------------------------------------------------
            
            "`n`n---------atualizando-firmware---------"
            Clear-Variable streamoutput
            Write-Host "$date - `n`n###Firmware do switch $ipaddress iniciou o processo de atualizacao###`n`n"
            [string]$log = $date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " iniciou o processo de atualizacao de Firmware"
            Add-Content -Path $pathlog -Value $log

            $stream.Write("system-view`n")
            Start-Sleep -Seconds 1
            function01-hp2530 -command "tftp server"
                function01-hp2530 -command "dhcp config-file-update"
                    $stream.Write("tftp "+$tftpserver+" get flash "+$arqfirmware+"`n")
                    Start-Sleep -Seconds 1
                    $stream.Write("y")
                    Start-Sleep -Seconds 90
                    $streamoutput = $stream.Read()
                    Write-Host $streamoutput
                        $test_validation = $streamoutput.Contains("Validating and Writing System")
                        if ($test_validation -ne 'true')
                        {
                        Write-Host "`n`n#####$date - Algo deu errado com a valicação e escrita de Firmware do Switch de IP $ipaddress !!!#####`n`n"
                        [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Algo deu errado com a valicação e escrita de Firmware do Switch de IP "+ $ipaddress.ToString() 
                        Add-Content -Path $pathlog -Value $log
                        $final_verification = "n"
                        }
                            else
                            {
                            Write-Host "`n`n#####$date - Validacao e escrita de Firmware no filesystem do Switch de IP $ipaddress DEU CERTO!!!...reiniciando o switch...#####`n`n"
                            [string]$log = $date.ToString() +" - Validacao e escrita de Firmware no filesystem do Switch de IP "+ $ipaddress.ToString() + " DEU CERTO!!!...reiniciando o switch..."
                            Add-Content -Path $pathlog -Value $log
                            
                            Clear-Variable streamoutput
                                $stream.Write("reboot`n")
                                Start-Sleep -Seconds 1
                                $stream.Write("y")
                                Start-Sleep -Seconds 1
                                $stream.Write("y")
                                $streamoutput = $stream.Read()
                                Write-Host $streamoutput
                                Clear-Variable streamoutput
                                Start-Sleep -Seconds 100
                             }

    }
                else
                {
                "`n`n`n---------SWITCH JÁ ESTÁ NA VERSÃO DESEJADA!!!---------"
                Write-Host "$date - Firmware do switch $ipaddress já estava atualizado, nao foi necessario atualizar"
                [string]$log = $date.ToString() +" - Firmware do Switch de IP "+ $ipaddress.ToString() + " já estava atualizado"
                Add-Content -Path $pathlog -Value $log
                $final_verification = "n"
                }
Write-Host "-----------------------------"
Write-Host "`n"
Write-Host "`n"
Write-Host "--------REMOVENDO SESSAO SSH---------"
Remove-SSHSession -Index 0 -Verbose
Write-Host "-------------------------------------"









if ($final_verification -eq "y")
    {

Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------------------------------------------#########"
Write-Host "#########----------------------------------------------#########"
Write-Host "#########-------------VERIFICACAO-FINAL----------------#########"
#---------Cria sessao---------
New-SSHSession -ComputerName $ipaddress -AcceptKey -Credential $cred -Verbose 
$session = Get-SSHSession -Index 0

Write-Host "--------CRIANDO-SHELL-STREAM---------"
$stream = $session.Session.CreateShellStream("Dimi", 1000, 1000, 1000, 1000, 1000)
$streamoutput = $stream.Read()
Clear-Variable streamoutput -Verbose
Start-Sleep -Seconds 1 -Verbose
$stream
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "----------ENTRADA-----------"
function01-hp2530 -command "en"
Write-Host "-----------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "----------SHOW-VERSION-------------"
$stream.Write("show version`n")
Start-Sleep -Seconds 1
$streamoutput = $stream.Read()
Write-Host $streamoutput
    $version_firmware = $streamoutput.Contains($desiredversion)
            if ($version_firmware -ne 'true')
            {
            "`n`n---------Algo deu errado com a atualizacao de firmware---------"
            Write-Host "`n`n#####$date - O Firmware do switch de IP $ipaddress NÃO foi atualizado!!! Algo deu errado!#####`n`n"
            [string]$log = "#####PROBLEM#####"+$date.ToString() +" - O Firmware do Switch de IP "+ $ipaddress.ToString() + " NÃO foi atualizado!!! Algo deu errado!!"
             Add-Content -Path $pathlog -Value $log
            }

            else
                {
                "`n`n---------Seu switch foi atualizado com sucesso---------"
                Write-Host "`n`n#####$date - Firmware do switch $ipaddress FOI atualizado!!!#####`n`n"
                [string]$log = $date.ToString() +" - Firmware do Switch de IP "+ $ipaddress.ToString() + " atualizado com SUCESSO!"
                Add-Content -Path $pathlog -Value $log
                
                }

                Write-Host "`n"
                Write-Host "`n"
                Write-Host "--------REMOVENDO SESSAO SSH---------"
                Remove-SSHSession -Index 0 -Verbose
                Clear-Variable streamoutput
                Write-Host "-------------------------------------"
      
      }






} else {
         write-host $ip.("IPAddress") "Ping failed." -foreground red
         Write-Host "Tentando pingar novamente"
         $cont++
         Start-Sleep -Seconds 2
            if ($cont -gt 2)
            {
            [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " não respondeu ao ping, e por isso não pode ser verificado"
            Add-Content -Path $pathlog -Value $log
            }
       }
    
    }
    }