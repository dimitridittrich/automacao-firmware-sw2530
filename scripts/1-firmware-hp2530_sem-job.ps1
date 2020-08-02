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
#---------------------------------------"
cls


Write-Host "`n"
Write-Host "`n"
#----------MODULOS-CAMINHOS-VARIAVEIS-----------"
$cont = 0
$final_verification = "y"

#PRE-REQUISITOS E VALORES A SEREM ALTERADOS CONFORME NECESSIDADE
#Necessario ter instalado o modulo posh-ssh
#Alterar horario de versao na funcion timesync conforme necessidade
$tftpserver = Read-Host  "Digite o IP do Server TFTP"
$csvfile = "$caminho.\ips-switches.csv"
[string]$arqpassencrypted ="$caminho.\pass.xml"
$desiredversion = "YA.16.05.0007"
$arqfirmware = "YA_16_05_0007.swi"
$pathlog = "$caminho.\log.txt"
$synctime = ''

Import-Module -name posh-ssh
Remove-Module "function01-hp2530"
Import-Module "$caminho.\functions\function01-hp2530.psm1"
Remove-Module "function02-synctime"
Import-Module "$caminho.\functions\function02-synctime.psm1"
cls
#----------------------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "#########----------CREDENCIAIS-SSH-----------#########"
$encpwd = Get-Credential | Export-Clixml -Path "$caminho.\pass.xml"
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
    Write-Host "Teste de ping no switch de ip $ipaddress da lista CSV"
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
$cred = Import-Clixml -Path $arqpassencrypted

Write-Host ">>>>>Cria sessao<<<<<"
$retorno_ssh = New-SSHSession -ComputerName $ipaddress -AcceptKey -Credential $cred -Verbose           

            Write-Host ">>>>>VALIDA-CONEXAO<<<<<"
            
            if ($retorno_ssh.Connected)
            {
            $date = get-date
            Write-Host "CONEXÃO SSH no Switch de IP $ipaddress REALIZADA COM SUCESSO!"
            [string]$log = $date.ToString() + " - CONEXAO SSH no Switch de IP " + $ipaddress.ToString() + " REALIZADA COM SUCESSO!"
            Add-Content -Path $pathlog -Value $log
            }
                else
                {
                $date = get-date
                Write-Host "CONEXÃO SSH no Switch de IP $ipaddress NÃO DEU CERTO!"
                [string]$log = "#####PROBLEM#####"+$date.ToString() +" - CONEXÃO SSH no Switch de IP "+ $ipaddress.ToString() + " NÃO DEU CERTO!"
                Add-Content -Path $pathlog -Value $log
                Start-Sleep -Seconds 5
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
Write-Host "-----------ENTRADA------------"
$stream.Write("en`n")
Start-Sleep -Seconds 1
$streamoutput = $stream.Read()
Write-Host $streamoutput
Clear-Variable streamoutput
Write-Host "------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "--------RUNNING-CONFIG---------"
function01-hp2530 -command "show run"
Write-Host "-------------------------------"

Write-Host "`n"
Write-Host "`n"
Write-Host "---------------CONFIGURA-E-VERIFICA-HORA----------------"
$synctime = function02-synctime
                        
                        if ($synctime -eq 'True')
                        {
                        $date = get-date
                        Write-Host "HORA E DATA SINCRONIZADOS"
                        [string]$log = $date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " está com hora e data sincronizados!"
                        Add-Content -Path $pathlog -Value $log
                        }
                            else
                            {
                            Write-Host "HORA E DATA NAO SINCRONIZADOS, VERIFIQUE!"
                            [string]$log = "#####PROBLEM#####"+$date.ToString()+" - Firmware do Switch de IP "+ $ipaddress.ToString() + " não foi atualizado pois a hora e data estão errados, verifique!"
                            Add-Content -Path $pathlog -Value $log
                            Start-Sleep -Seconds 5
                            cls
                            break
                            }
                            
Write-Host "--------------------------------------------------------"

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
    Write-Host "$date - Este Switch de IP $ipaddress nao está na versão de firmware desejada! Iniciando verificacoes iniciais para upgrade..."
#---------------TEST-PING-TFTP_SERVER---------------
Write-Host "`n"
Write-Host "`n"
Write-Host "#---------------TEST-PING-TFTP_SERVER---------------"
            $cont_tftp = 0
            $break = $false
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
                        $date = get-date
                        Write-Host "$date - Switch de IP $ipaddress não foi atualizado pois o tftp server $tftpserver não respondeu ao ping"	
                        [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " não foi atualizado pois o tftp server $tftpserver não respondeu ao ping"
            	        Add-Content -Path $pathlog -Value $log
                        $break = $true
            	        }
       	            }
            }
                if($break)
                {
                Start-Sleep -Seconds 5
                cls
                Break
                }
#----------------------------------------------------
            "`n`n---------atualizando-firmware---------"
            Clear-Variable streamoutput
            Write-Host "$date - ###Firmware do switch $ipaddress iniciou o processo de atualizacao###`n`n"
            [string]$log = $date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " iniciou o processo de atualizacao de Firmware"
            Add-Content -Path $pathlog -Value $log

            $stream.Write("system-view`n")
            Start-Sleep -Seconds 1
            function01-hp2530 -command "tftp server"
                function01-hp2530 -command "dhcp config-file-update"
                    $stream.Write("tftp "+$tftpserver+" get flash "+$arqfirmware+"`n")
                    Start-Sleep -Seconds 1
                    $stream.Write("y")
                    Start-Sleep -Seconds 140
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
                            $final_verification = "y"
                            Clear-Variable streamoutput
                                $stream.Write("reboot`n")
                                Start-Sleep -Seconds 1
                                $stream.Write("y")
                                Start-Sleep -Seconds 1
                                $stream.Write("y")
                                $streamoutput = $stream.Read()
                                Write-Host $streamoutput
                                Clear-Variable streamoutput
                                Start-Sleep -Seconds 180
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
$date = get-date
$retorno_ssh = New-SSHSession -ComputerName $ipaddress -AcceptKey -Credential $cred -Verbose 
$session = Get-SSHSession -Index 0

            Write-Host ">>>>>VALIDA-CONEXAO<<<<<"
            
            if ($retorno_ssh.Connected)
            {
            $date = get-date
            Write-Host "CONEXÃO SSH no Switch de IP $ipaddress PARA VERIFICACAO FINAL REALIZADA COM SUCESSO!"
            [string]$log = $date.ToString() + " - CONEXAO SSH no Switch de IP " + $ipaddress.ToString() + " PARA VERIFICACAO FINAL REALIZADA COM SUCESSO!"
            Add-Content -Path $pathlog -Value $log
            }
                else
                {
                $date = get-date
                Write-Host "CONEXÃO SSH no Switch de IP $ipaddress PARA VERIFICACAO FINAL NÃO DEU CERTO!"
                [string]$log = "#####PROBLEM#####"+$date.ToString() +" - CONEXÃO SSH no Switch de IP "+ $ipaddress.ToString() + " PARA VERIFICACAO FINAL NÃO DEU CERTO!"
                Add-Content -Path $pathlog -Value $log
                Start-Sleep -Seconds 5
                cls
                break
                }
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
         $date = get-date
         Start-Sleep -Seconds 2
            if ($cont -gt 2)
            {
            [string]$log = "#####PROBLEM#####"+$date.ToString() +" - Switch de IP "+ $ipaddress.ToString() + " não respondeu ao ping, e por isso não pode ser verificado"
            Add-Content -Path $pathlog -Value $log
            }
       }
    
    }
    }
# SIG # Begin signature block
# MIIEOgYJKoZIhvcNAQcCoIIEKzCCBCcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUpPoBHVPVcEyXnBGgrkdV3XL/
# 9EegggJEMIICQDCCAa2gAwIBAgIQVB3qufqZrZpKhWR9rnNo7zAJBgUrDgMCHQUA
# MCwxKjAoBgNVBAMTIVBvd2VyU2hlbGwgTG9jYWwgQ2VydGlmaWNhdGUgUm9vdDAe
# Fw0xNzA3MTQxMjEyMTdaFw0zOTEyMzEyMzU5NTlaMCExHzAdBgNVBAMTFkRpbWl0
# cmkgUG93ZXJTaGVsbCBDU0MwgZ8wDQYJKoZIhvcNAQEBBQADgY0AMIGJAoGBALXt
# 21SuIH+ODd1F82+fp45oUFGw2R+NzvdfKyao44xABoxtqkv2uquqRbo1Fi+jsd80
# HzcHO3BOPUZJsFtuADZhQZmhV3oMjWoSaGmWgOaERkYb01AJo311LNMd9duwQjqz
# XY6VtOj4SnqwB9xY6VmUVvpsNdIPBsD9pziX3sdFAgMBAAGjdjB0MBMGA1UdJQQM
# MAoGCCsGAQUFBwMDMF0GA1UdAQRWMFSAEGPPo05+xF03EpNY4Co5jEqhLjAsMSow
# KAYDVQQDEyFQb3dlclNoZWxsIExvY2FsIENlcnRpZmljYXRlIFJvb3SCEHt8lZC+
# seeASfvlb8W6Jc4wCQYFKw4DAh0FAAOBgQApVBuK8PfCTBdPMTgv+o/sq0rVCc9Z
# ozaUkfUW91B8APzCL52cHmLN8GQsnm7Up2l0iD9ul3EqaAPrLaoxoeYdCrea5Boi
# TA+zYaS4Cp2oDL/SWtQH4TNpEbQEl+4a5Rn7iq8RqsB1m7EsG80Q1aDrzVyeLhYK
# 8IT6eqWnoiqR6TGCAWAwggFcAgEBMEAwLDEqMCgGA1UEAxMhUG93ZXJTaGVsbCBM
# b2NhbCBDZXJ0aWZpY2F0ZSBSb290AhBUHeq5+pmtmkqFZH2uc2jvMAkGBSsOAwIa
# BQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgor
# BgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3
# DQEJBDEWBBSrKy8iIlBXHKyJ34AgEyph6r7cVTANBgkqhkiG9w0BAQEFAASBgDOL
# ohv9nui0Oc3M+d9rjTWZAn5rG6eZ28w07lZ76PjxWMpSn4amF5dfIPP9g2LV6Nym
# 68NTvqIb51RMsxcpxtw9ffScNR2KFiINIc+2JbhTxxZLad3iEUHJDHnyg7l+dnNA
# bsZD5Bjd9m8rXJ8lzD9CXVBGXv3cUtMSllSx1qAo
# SIG # End signature block
