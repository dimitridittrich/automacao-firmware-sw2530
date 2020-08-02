# Projeto Automação Update de Firmware em Switches modelo HP2530-24G

Projeto criado para manter os scripts de automação para atualização de firmware dos switches HP 2530-24G de forma distribuida, versionada e economizar tempo de operação.

[Diagrama do script sem JOB (reinicialização e prova real no mesmo script)](/docs/Sem-Job-Model-Update-Switches.png)

[Diagrama do script com JOB (reinicialização agendada por JOB, sem prova real)] (/docs/Com-Job-Model-Update-Switches.png)


## Pré-requisitos para utilização deste projeto :exclamation:

Para pleno funcionamento deste projeto, você precisará:
- CRIAR UM SERVIDOR TFTP NA SUA MÁQUINA COM O ARQUIVO DO FIRMWARE DESEJADO PARA A ATUALIZAÇÃO (Sugiro utilização do "OpenTFTPServer");
- TER INSTALADO O MÓDULO POSH-SSH NO SEU POWERSHELL.
- TER A LISTA DE IPS DOS SWITCHES QUE DESEJA ATUALIZAR O FIRMWARE
- SETAR HORARIO DE VERAO NA FUNCTION "/scripts/functions/function02-synctime.psm1"


## Como Utilizar este projeto

**Na pasta "Scripts" há duas opções de Scripts principais:**<br />
1 - "1-firmware-hp2530_sem-job.ps1"
Este script faz a reinicialização imediatamente e automaticamente após a atualização do firmware. Na sequência após o reboot, faz uma checagem final (prova real) para verificar se o firmware foi realmente atualizado.<br />
Aconselho a utilização deste script para ser rodado fora do horário de trabalho da empresa (após às 22h00m).<br />
[Para acessar esse script clique aqui](/scripts/1-firmware-hp2530_sem-job.ps1)

2 - "2-firmware-hp2530_com-job.ps1"
Este script cria uma JOB (tarefa agendada) no Switch para reiniciar (em data em horário que são solicitados no início da execução do próprio Script) logo após a atualização do firmware. Neste caso, não há uma verificação final (prova real). Para fazer uma última checagem, será necessário rodar o script por inteiro novamente após a reinicialização.<br />
Aconselho a utilização deste script para ser rodado durante o horário de trabalho da empresa (08h00m às 22h00m).<br />
[Para acessar esse script clique aqui](/scripts/2-firmware-hp2530_com-job.ps1)

**Na pasta "Scripts\functions\" há duas functions que são utilizadas pelos scripts principais, são elas:**<br />
1 - "function01-hp2530.psm1"<br />
Esta function é utilizada pelos scripts principais para invoke de comandos nos switches HP2530<br />
[Para acessar essa function clique aqui](scripts/functions/function01-hp2530.psm1)

2 - "function02-synctime.psm1"<br />
Esta função é utilizada pelos scripts principais para configurações de SNTP no switch, e posterior verificação/comparação da hora entre o Switche e o S.O. onde o Script está sendo rodado.<br />
[Para acessar essa function clique aqui](scripts/functions/function02-synctime.psm1)

**Na pasta "Scripts" existe um arquivo CSV que contém a lista de IPs dos switches a serem atualizados. Altere essa lista conforme sua necessidade:**<br />
1 - "ips-switches.csv"<br />
[Para acessar esse arquivo com a lista de IPs clique aqui](scripts/ips-switches.csv)

**Na pasta "Scripts" existe um arquivo txt onde são guardados todos os LOGs que os scripts geram:**<br />
1 - "log.txt"<br />
[Para acessar esse arquivo de log clique aqui](scripts/log.txt)

**Na pasta "Scripts" há um arquivo referente à criptografia das credenciais para acesso SSH:**<br />
1 - "pass.xml"<br />
Este .xml é o arquivo gerado pelo script principal, com base nas credenciais digitadas pelo usuário. Nele contem um hash criptografado da senha digitada para conexão SSH nos switches.<br />
[Para acessar esse arquivo .xml clique aqui](scripts/pass.xml)



