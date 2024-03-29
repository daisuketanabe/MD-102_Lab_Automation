# Practice Lab: Synchronizing Identities by using Azure AD Connect 

Write-Host -ForegroundColor Blue "Starting Practice Lab: Synchronizing Identities by using Azure AD Connect"

# Prerequisites
$ScriptName = "./TaskSequences/lab0101.ps1"
Invoke-Expression $ScriptName

function Show-MessageBox {
  [CmdletBinding(PositionalBinding=$false)]
  param(
    [Parameter(Mandatory, Position=0)]
    [string] $Message,
    [Parameter(Position=1)]
    [string] $Title,
    [Parameter(Position=2)]
    [ValidateSet('OK', 'OKCancel', 'AbortRetryIgnore', 'YesNoCancel', 'YesNo', 'RetryCancel')]
    [string] $Buttons = 'OK',
    [ValidateSet('Information', 'Warning', 'Stop')]
    [string] $Icon = 'Information',
    [ValidateSet(0, 1, 2)]
    [int] $DefaultButtonIndex
  )

  # So that the $IsLinux and $IsMacOS PS Core-only
  # variables can safely be accessed in WinPS.
  Set-StrictMode -Off

  $buttonMap = @{ 
    'OK'               = @{ buttonList = 'OK'; defaultButtonIndex = 0 }
    'OKCancel'         = @{ buttonList = 'OK', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'AbortRetryIgnore' = @{ buttonList = 'Abort', 'Retry', 'Ignore'; defaultButtonIndex = 2; ; cancelButtonIndex = 0 }; 
    'YesNoCancel'      = @{ buttonList = 'Yes', 'No', 'Cancel'; defaultButtonIndex = 2; cancelButtonIndex = 2 };
    'YesNo'            = @{ buttonList = 'Yes', 'No'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
    'RetryCancel'      = @{ buttonList = 'Retry', 'Cancel'; defaultButtonIndex = 0; cancelButtonIndex = 1 }
  }

  $numButtons = $buttonMap[$Buttons].buttonList.Count
  $defaultIndex = [math]::Min($numButtons - 1, ($buttonMap[$Buttons].defaultButtonIndex, $DefaultButtonIndex)[$PSBoundParameters.ContainsKey('DefaultButtonIndex')])
  $cancelIndex = $buttonMap[$Buttons].cancelButtonIndex

  if ($IsLinux) { 
    Throw "Not supported on Linux." 
  }
  elseif ($IsMacOS) {

    $iconClause = if ($Icon -ne 'Information') { 'as ' + $Icon -replace 'Stop', 'critical' }
    $buttonClause = "buttons { $($buttonMap[$Buttons].buttonList -replace '^', '"' -replace '$', '"' -join ',') }"

    $defaultButtonClause = 'default button ' + (1 + $defaultIndex)
    if ($null -ne $cancelIndex -and $cancelIndex -ne $defaultIndex) {
      $cancelButtonClause = 'cancel button ' + (1 + $cancelIndex)
    }

    $appleScript = "display alert `"$Title`" message `"$Message`" $iconClause $buttonClause $defaultButtonClause $cancelButtonClause"            #"

    Write-Verbose "AppleScript command: $appleScript"

    # Show the dialogue.
    # Note that if a cancel button is assigned, pressing Esc results in an
    # error message indicating that the user cancelled.
    $result = $appleScript | osascript 2>$null

    # Output the name of the button chosen (string):
    # The name of the cancel button, if the dialogue was cancelled with ESC, or the
    # name of the clicked button, which is reported as "button:<name>"
    if (-not $result) { $buttonMap[$Buttons].buttonList[$buttonMap[$Buttons].cancelButtonIndex] } else { $result -replace '.+:' }
  }
  else { # Windows
    Add-Type -Assembly System.Windows.Forms        
    # Show the dialogue.
    # Output the chosen button as a stringified [System.Windows.Forms.DialogResult] enum value,
    # for consistency with the macOS behaviour.
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon, $defaultIndex * 256).ToString()
  }

}

# Task 1: Configure directory synchronization with Azure AD Connect

Write-Host -ForegroundColor Yellow "Checking if Azure AD connect V2 already installed."


# Download Entra Connect
Show-MessageBox 'Downloading Azure AD Connect V2'
$URL = "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi"
# Destination file
$CWD = Get-Location
$Dest = "$CWD\AzureADConnect.msi"
# Download the file
Invoke-WebRequest -Uri $URL -OutFile $Dest

Show-MessageBox 'Starting Azure AD Connect V2'
Show-MessageBox 'Follow the instruction from step 5 to install Azure AD Connect V2'
Start-Process "https://github.com/MicrosoftLearning/MD-102T00-Microsoft-365-Endpoint-Administrator/blob/master/Instructions/Labs/0102-Syncronizing%20Identities%20by%20using%20Azure%20AD%20Connect.md"

Start-Process $Dest

$Confirm = Read-Host -Prompt "Azure AD Connect V2 Installed? [Y/N]"
While ($Confirm.ToLower() -ne 'y'){
  $Confirm = Read-Host -Prompt "Azure AD Connect V2 Installed? [Y/N]"
}

# $Installed = $False
# While ($Installed -eq $False){
#   Write-Host -ForegroundColor Yellow "Checking Azure AD connect V2 installation."
#   Start-Sleep 10
# }


# Start Sync

Write-Host -ForegroundColor Blue "Completed Practice Lab: Synchronizing Identities by using Azure AD Connect"


