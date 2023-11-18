function InputBox {
  param (
    [String]$Title,
    [String]$Question
  )

  $WindowWidth = 400
  $WindowHeight = 150

  $XLMPath = "$PSScriptRoot\ui.xml"
  $xamlContent = Get-Content -Path $XLMPath -Raw
  $xamlContent = $xamlContent -replace '%Title%', "$Title"
  $xamlContent = $xamlContent -replace '%Question%', "$Question"
  $xamlContent = $xamlContent -replace '%WindowWidth%', "$WindowWidth"
  $xamlContent = $xamlContent -replace '%WindowHeight%', "$WindowHeight"
  $ButtonWidth = ($WindowWidth * (3/16)) 
  $xamlContent = $xamlContent -replace '%ButtonWidth%', "$ButtonWidth"
  $TextBoxWidth = ($WindowWidth * (14/16))
  $TextBoxHeight = ($WindowHeight * (1/6))
  $xamlContent = $xamlContent -replace '%TextBoxWidth%', "$TextBoxWidth"
  $xamlContent = $xamlContent -replace '%TextBoxHeight%', "$TextBoxHeight"
  

  Function LoadForm {
    [CmdletBinding()]
    Param (
      [Parameter(Mandatory = $True, Position = 1)]
      [string]$XamlPath
    )

    # Import the XAML code
    [xml]$Global:xmlWPF = $XamlPath
    # Add WPF and Windows Forms assemblies
    Try {
      Add-Type -AssemblyName PresentationCore, PresentationFramework, WindowsBase, System.Windows.Forms
    }
    Catch {
      Throw "Failed to load Windows Presentation Framework assemblies."
    }

    # Create the XAML reader using a new XML node reader
    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xmlWPF))

    # Create hooks to each named object in the XAML
    $xmlWPF.SelectNodes("//*[@Name]") | ForEach-Object {
      Set-Variable -Name $_.Name -Value $xamGUI.FindName($_.Name) -Scope Global
    }
  }

  # Call the LoadForm function to load the XAML and create the GUI
  LoadForm -XamlPath $xamlContent
  # Define the event handler for the OK button click
  $OKButton.Add_Click({
    $xamGUI.Close()  
  })

  # Define the event handler for the Enter key press
  $NameTextBox.Add_KeyDown({
    if ($_.Key -eq "Enter") {
      $xamGUI.Close()
    }
  })

  # Define the event handler for the Cancel button click
  $CancelButton.Add_Click({
    $NameTextBox.Text = $null
    $xamGUI.Close()  
  })


  # Launch the window
  $xamGUI.ShowDialog() | Out-Null

  return $NameTextBox.Text
  
}

Write-Host (InputBox -Title "Prompt for Computer Name:" -Question "Enter the name for the new computer")