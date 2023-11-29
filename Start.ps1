$Menu = @{
    '0101' = 'Practice Lab: Managing Identities in Azure AD'
    '0102' = 'Practice Lab: Synchronizing Identities by using Azure AD Connect'
}

$Menu = ($Menu.GetEnumerator() | Sort-Object -property:Key)

ForEach ($Item in $Menu){
    Write-Host "$($Item.Key) : $($Item.Value)"
}

$TaksSequence = Read-Host -Prompt "Select the lab exercise to auto complete"

$Confirm = $False
$Retry = $False

While ($Confirm -eq $False){
    While ($TaksSequence -notin $Menu.Key){
        if ($Retry -eq $False){
            Write-Host -ForegroundColor Red "Invalid Selection"
        }
        $Retry = $False
       
        ForEach ($Item in $Menu){
            Write-Host "$($Item.Key) : $($Item.Value)"
        }
        
        $TaksSequence = Read-Host -Prompt "Select the lab exercise to auto complete"
    }
    $Lab = $Menu | Where-Object {$_.Name -eq $TaksSequence}
    Write-Host -ForegroundColor Green "You selected Lab Exercise"
    Write-Host -ForegroundColor Yellow "$TaksSequence : $($Lab.Value)"
    
    $Confirm = Read-Host -Prompt "Do you want to proceeed [Y/N]"

    if ($Confirm.ToLower() -eq 'y'){
        Break
    }
    $Confirm = $False
    $TaksSequence = $Null
    $Retry = $True
}

$ScriptName = "./TaskSequences/lab$TaksSequence.ps1"

Invoke-Expression $ScriptName