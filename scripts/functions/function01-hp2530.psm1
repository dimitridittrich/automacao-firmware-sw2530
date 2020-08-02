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
# SIG # Begin signature block
# MIIEOgYJKoZIhvcNAQcCoIIEKzCCBCcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUx4Yau/N5Oo8dvl42KKGoxQON
# qWCgggJEMIICQDCCAa2gAwIBAgIQVB3qufqZrZpKhWR9rnNo7zAJBgUrDgMCHQUA
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
# DQEJBDEWBBSfLK3egfYirpt0y8q8bYQoYp0ErTANBgkqhkiG9w0BAQEFAASBgIfn
# gybp5wXDkfzPMgqiAo/FbrR7Ksk0dk7MVAnIRYjvdbuPCAQ5AJkpARpeTBwBXdlf
# rM1QriJfYxOB52C3RbGilwVMuzZ/uP5jh36jzPnjd1sjvBs9gOljRE/QDnqodkwI
# I+prxKC2JXDFcwXkmzYPzPZ3hS9mvNkheiWp5ROt
# SIG # End signature block
