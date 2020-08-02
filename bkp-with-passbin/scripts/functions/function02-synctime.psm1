<#
Autor: Dimitri Dittrich
Data: 31/10/2017
Function para configuracao de sntp em switche hp2530 e comparacao de horarios para posterior agendamento de job
#>

#Import-Module function01-hp2530.psm1"

Function function02-synctime
{
    Process
    {
    Write-Host "`n"
    Write-Host "`n"
    Write-Host "---------CONFIG-SNTP----------"
    function01-hp2530 -command "system-view"
    function01-hp2530 -command "timesync sntp"
    function01-hp2530 -command "sntp unicast" 
    function01-hp2530 -command "sntp 600" 
    function01-hp2530 -command "sntp server priority 1 10.0.0.128" 
    function01-hp2530 -command "time daylight-time-rule user-defined begin-date 10/15 end-date 02/17" 
    function01-hp2530 -command "time timezone -180"
    function01-hp2530 -command "save"   
    Start-Sleep -Seconds 5 -Verbose
    Write-Host "-----------------------------"

    Write-Host "`n"
    Write-Host "`n"
    Write-Host "---------SHOW-TIME----------"
    $date_hm = Get-Date -UFormat "%H:%M"
    $stream.Write("show time`n")
    Start-Sleep -Seconds 1
    $streamoutput = $stream.Read()
    Write-Host $streamoutput
    Write-Host "-----------------------------"
    
    Write-Host "`n"
    Write-Host "`n"
    Write-Host "---------COMPARE-TIME----------"
    $synctime = $streamoutput.Contains($date_hm)
    Write-Host "-----------------------------"
    return $synctime
    }
}
