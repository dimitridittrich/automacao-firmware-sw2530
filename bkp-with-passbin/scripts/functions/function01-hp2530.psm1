<#
Autor: Dimitri Dittrich
Data: 04/09/2017
Function para invoke de comandos em switch HP2530
#>

Function function01-hp2530
{
Param ([string]$command) 
    Process
    {
    $stream.Write("$command`n")
    Start-Sleep -Seconds 1
    $streamoutput = $stream.Read()
    Write-Host $streamoutput
    Clear-Variable streamoutput
    }
}