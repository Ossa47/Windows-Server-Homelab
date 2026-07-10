# Script to create a new user in Active Directory
Import-Module ActiveDirectory

New-ADUser -Name "Test.User" -GivenName "Test" -Surname "User" -UserPrincipalName "test.user@homelab.lan" -Enabled $true
