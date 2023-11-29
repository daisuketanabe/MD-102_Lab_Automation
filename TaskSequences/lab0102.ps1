# Practice Lab: Synchronizing Identities by using Azure AD Connect 

# Prerequisites
$PSScriptRoot
$ScriptName = "./TaskSequences/lab0101.ps1"

Invoke-Expression $ScriptName

# Task 1: Configure directory synchronization with Azure AD Connect
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
  
      # Show the dialog.
      # Note that if a cancel button is assigned, pressing Esc results in an
      # error message indicating that the user canceled.
      $result = $appleScript | osascript 2>$null
  
      # Output the name of the button chosen (string):
      # The name of the cancel button, if the dialog was canceled with ESC, or the
      # name of the clicked button, which is reported as "button:<name>"
      if (-not $result) { $buttonMap[$Buttons].buttonList[$buttonMap[$Buttons].cancelButtonIndex] } else { $result -replace '.+:' }
    }
    else { # Windows
      Add-Type -Assembly System.Windows.Forms        
      # Show the dialog.
      # Output the chosen button as a stringified [System.Windows.Forms.DialogResult] enum value,
      # for consistency with the macOS behavior.
      [System.Windows.Forms.MessageBox]::Show($Message, $Title, $Buttons, $Icon, $defaultIndex * 256).ToString()
    }
  
  }

Show-MessageBox 'This lab exercise cannot be automated by PowerShell'

# Download Entra Connect
Show-MessageBox 'Downlaoding Azure AD Connect V2'
$URL = "https://download.microsoft.com/download/B/0/0/B00291D0-5A83-4DE7-86F5-980BC00DE05A/AzureADConnect.msi"
# Destination file
$CWD = Get-Location
$Dest = "$CWD/AzureADConnect.msi"
# Download the file
Invoke-WebRequest -Uri $URL -OutFile $Dest

Show-MessageBox 'Starting Azure AD Connect V2'
Show-MessageBox 'Follow the instruciton from step 5 to install Azure AD Connect V2'
Start-Process "https://github.com/MicrosoftLearning/MD-102T00-Microsoft-365-Endpoint-Administrator/blob/master/Instructions/Labs/0102-Syncronizing%20Identities%20by%20using%20Azure%20AD%20Connect.md"

Start-Process $Dest

# Start Sync

