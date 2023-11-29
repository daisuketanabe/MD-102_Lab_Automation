#Practice Lab: Managing Identities in Azure AD

$ModuleInstalled = $False
$ModuleVersionInstalled = $False
$ModuleName = "Microsoft.Graph"
$Modules = Get-Module -Name $ModuleName -ListAvailable

ForEach ($Module in $Modules){
    $ModuleInstalled = $True
    if ($Module -ge 2.10.0){
        $ModuleVersionInstalled = $True
    }
}
if ($ModuleInstalled){
    if ($ModuleVersionInstalled){
        Write-Host -ForegroundColor Green "√ $ModuleName is already installed with a compatible version"
    }else{
        Uninstall-Module $ModuleName 
        Install-Module $ModuleName -Force -Scope CurrentUser
    }
}else{
    Install-Module $ModuleName -Scope CurrentUser
}

Connect-MgGraph -Scopes "User.ReadWrite.All, Group.ReadWrite.All, RoleManagement.ReadWrite.Directory, Organization.ReadWrite.All" -NoWelcome

#Exercise 1: Creating users in Azure AD

#Task 1: Create users by using the Microsoft Entra admin center

$TenantId = Read-Host "Enter your tenant ID"

$DomainName = $TenantId + ".onmicrosoft.com"

$PasswordProfile = @{
    Password = 'Pa55-w.rd!';
    ForceChangePasswordNextSignIn = $false
    }

$UPN =  "ereeve@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" | Measure-Object

if ($User.Count -eq 0){
    New-MgUser `
        -DisplayName "Edmund Reeve" `
        -GivenName "Edmund" -Surname "Reeve" `
        -MailNickname "ereeve" `
        -UsageLocation "US" `
        -UserPrincipalName "$UPN" `
        -PasswordProfile $PasswordProfile -AccountEnabled `
        -Department "HR" -JobTitle "HR Rep"
}else{
    Write-Host -ForegroundColor Green "√ User account $UPN already exists"
}

$UPN =  "msnider@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" | Measure-Object

if ($User.Count -eq 0){
    New-MgUser `
        -DisplayName "Miranda Snider" `
        -GivenName "Miranda" -Surname "Snider" `
        -MailNickname "msnider" `
        -UsageLocation "US" `
        -UserPrincipalName "$UPN" `
        -PasswordProfile $PasswordProfile -AccountEnabled `
        -Department "Operations" -JobTitle "Helpdesk Manager"
}else{
    Write-Host -ForegroundColor Green "√ User account $UPN already exists"
}


#Task 2: Create users by using PowerShell

$PWProfile = @{
    Password = "Pa55w.rd";
    ForceChangePasswordNextSignIn = $false
    }

$UPN =  "cgodinez@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" | Measure-Object
    
if ($User.Count -eq 0){
    New-MgUser `
    -DisplayName "Cody Godinez" `
    -GivenName "Cody" -Surname "Godinez" `
    -MailNickname "cgodinez" `
    -UsageLocation "US" `
    -UserPrincipalName "$UPN" `
    -PasswordProfile $PWProfile -AccountEnabled `
    -Department "Sales" -JobTitle "Sales Rep"
}else{
    Write-Host -ForegroundColor Green "√ User account $UPN already exists"
}

#Exercise 2: Assigning Administrative Roles in Azure AD

$RoleName = "Global Administrator"
$Role = Get-MgDirectoryRole | Where-Object {$_.DisplayName -eq $RoleName}
$UPN =  "AllanD@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

$Members = Get-MgDirectoryRoleMember -DirectoryRoleId $Role.Id

if($User.Id -notin $Members.Id) {
    $DirObject = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
        }

    New-MgDirectoryRoleMemberByRef `
        -DirectoryRoleId $Role.Id `
        -BodyParameter $DirObject
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already assigned to $RoleName"
}

$RoleName = "User Administrator"
$Role = Get-MgDirectoryRole | Where-Object {$_.DisplayName -eq $RoleName}
$UPN =  "ereeve@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

$Members = Get-MgDirectoryRoleMember -DirectoryRoleId $Role.Id

if($User.Id -notin $Members.Id) {
    $DirObject = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
        }

    New-MgDirectoryRoleMemberByRef `
        -DirectoryRoleId $Role.Id `
        -BodyParameter $DirObject
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already assigned to $RoleName"
}

$RoleName = "Helpdesk Administrator"
$Role = Get-MgDirectoryRole | Where-Object {$_.DisplayName -eq $RoleName}
$UPN =  "msnider@" + $DomainName
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

$Members = Get-MgDirectoryRoleMember -DirectoryRoleId $Role.Id

if($User.Id -notin $Members.Id) {
    $DirObject = @{
        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($User.Id)"
        }

    New-MgDirectoryRoleMemberByRef `
        -DirectoryRoleId $Role.Id `
        -BodyParameter $DirObject
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already assigned to $RoleName"
}

# Exercise 3: Creating and managing groups and validating license assignment

# Task 1: Create groups by using the Microsoft Entra admin center

$GroupName = "Contoso_Managers"
$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'" | Measure-Object

if ($Group.Count -eq 0){
    New-MgGroup `
        -DisplayName "Contoso_Managers" `
        -MailEnabled:$false `
        -Mailnickname "Contoso_Sales" -SecurityEnabled
}else{
    Write-Host -ForegroundColor Green "√ $GroupName group already exists"
}

$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"

$Members = Get-MgGroupMember -GroupId $Group.Id

$UPN =  "ereeve@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

if ($User.Id -notin $Members.Id){
    New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $User.Id
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already a member of $GroupName"  
}

$UPN =  "msnider@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

if ($User.Id -notin $Members.Id){
    New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $User.Id
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already a member of $GroupName"  
}

# Task 2: Create groups by using PowerShell

$GroupName = "Contoso_Sales"
$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'" | Measure-Object

if ($Group.Count -eq 0){
    New-MgGroup `
        -DisplayName "Contoso_Sales" `
        -Description "Contoso Sales team users" `
        -MailEnabled:$false `
        -Mailnickname "Contoso_Sales" -SecurityEnabled
}else{
    Write-Host -ForegroundColor Green "√ $GroupName group already exists"
}

$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"

$UPN =  "cgodinez@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

$Members = Get-MgGroupMember -GroupId $Group.Id

if ($User.Id -notin $Members.Id){
    New-MgGroupMember -GroupId $Group.Id -DirectoryObjectId $User.Id
}else{
    Write-Host -ForegroundColor Green "√ $UPN is already a member of $GroupName"  
}

# Task 3: Review licenses and modify company branding

$Organization = Get-MgOrganization   
Update-MgOrganizationBranding -OrganizationId $Organization.Id -SignInPageText "Contoso Corp. Sign-in Page" 

$SKU = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -eq 'ENTERPRISEPREMIUM'}

$UPN =  "cgodinez@$DomainName"
$User = Get-MgUser -Filter "UserPrincipalName eq '$UPN'"

$UserSKUs = Get-MgUserLicenseDetail -UserId $User.Id

if ($SKU.SkuId -notin $UserSKUs.SkuId){
    Set-MgUserLicense `
        -UserId $User.Id `
        -AddLicenses @{SkuId = $SKU.SkuId} `
        -RemoveLicenses @()
}else{
    Write-Host -ForegroundColor Green "√ $UPN already has Office 365 E5 Licence"  
}

$GroupName =  "Contoso_Managers"
$Group = Get-MgGroup -Filter "DisplayName eq '$GroupName'"

Set-MgGroupLicense `
    -GroupId $Group.Id `
    -AddLicenses @{SkuId = $SKU.SkuId} `
    -RemoveLicenses @() `
    -ErrorAction Ignore

$SKU = Get-MgSubscribedSku | Where-Object {$_.SkuPartNumber -eq 'EMSPREMIUM'}

Set-MgGroupLicense `
    -GroupId $Group.Id `
    -AddLicenses @{SkuId = $SKU.SkuId} `
    -RemoveLicenses @() `
    -ErrorAction Ignore
