<#
Autor: Dimitri Dittrich
Data: 31/10/2017
Function para configuracao de sntp em switche hp2530 e comparacao de horarios para posterior agendamento de job
.
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
[Datetime] $timesw = $streamoutput | Where-Object {$_ -match "[0-9]{1,2}:[0-9]{1,2}:[0-9]{1,2}"} | Foreach {$Matches[0]}
$date_hm = Get-Date

if ($date_hm -le $timesw.AddMinutes(3) -and $date_hm -ge $timesw.AddMinutes(-3)){
   Write-Host "Sincronia de horário dentro da tolerância de 3min"
   $synctime = 'true'
}else{
   Write-Host "Sincronia de horário fora da tolerância de 3min"
   $synctime = 'false'
}

    #$synctime = $streamoutput.Contains($date_hm)
    Write-Host "-----------------------------"
    return $synctime
    }
}

# SIG # Begin signature block
# MIIEOgYJKoZIhvcNAQcCoIIEKzCCBCcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQURNJEym/d5LHl7ZLnyEcarmrE
# lF2gggJEMIICQDCCAa2gAwIBAgIQVB3qufqZrZpKhWR9rnNo7zAJBgUrDgMCHQUA
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
# DQEJBDEWBBTCq6hrHQi+HtRC145tcMm/XRg+DjANBgkqhkiG9w0BAQEFAASBgCDD
# HZWftYMiKPxp3GwUYrFGUHrVxvFggMgCZ636C0VKoOhuubgz4/4lZju0YT1Gn3B4
# XnkmiMBw0YOcAhfEgCknmNCAs1fXi0wCRIOzD30g11fhmFKXfCln3RS3XtGtJNyI
# 9mgKyE57z5QgaSk0p8FReFd0Q9+TSAiZOeIVT667
# SIG # End signature block
