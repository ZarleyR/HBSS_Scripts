Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationCore,PresentationFramework

####################################################################################
#                                                                                  #
#                                Purpose/Scope                                     #
#     The purpose of this application is to hash known binaries used by Motorola   #
#   Solutions, Inc. and third party applications.  The user selects predefined     #
#   inventories lists that are stored within the ..\Data\ directory.  Each entry   #
#   within the 'astroInventory.txt' will be used to populate the combobox.  The    #
#   'astroInventory.txt' is stored within the ..\Scripts\ directory.               #
#                                                                                  #
####################################################################################

####################################################################################
#                                Variables Start                                   #
####################################################################################

# get the directory in which the application ran.  In this manner, the application can
# theoretically run from any location as long as the folder structure stay the same.
# This application utilizes a \Scripts\ and \Data\ directory tree structure.
$path = (Get-Item $MyInvocation.MyCommand.Path).Directory.parent.FullName
# path to the Data folder
$dataPath = $path + "\Data\"
# path to the Script folder
$scriptPath = $path + "\Scripts\"
# use this to change the icon
$ico = $scriptPath+"Motorola-logo-icon.ico"
# global variable used to store selected values within the application
$Global:val = ""
# path to the astroInventory_values.txt to populate comboBox1
$valuePath = $dataPath + "astroInventory_values.txt"
# test the path to the astroInventory_values.txt
$valuePathValid = Test-Path $valuePath
# used to tell whether the program is running or not
$isRunning = $false
# get Date and Time format for Exported CSV file
$Global:dateTime = Get-Date -Format "yyyy-MM-dd-hhmmss"

####################################################################################
#                            Variables End                                         #
####################################################################################

####################################################################################
#                                                                                  #
#                        Inventory Check Start                                     #
# this is used to populate the array of Computer selections first, check whether   #
# the application finds the astroInventory.txt file to populate the comboBox1.     #
#                                                                                  #
####################################################################################

# astroInventory is checked to see if the path is found
if ($valuePathValid -eq $true) {
    # the astroInventory.txt file was found.
    # The astroInventory.txt file is loaded into the array 'astroInventoryArray'
    # Select-String -NotMatch "^#" ignores the comments within the imported .txt file
    # The comments are used for version control within the .txt files.
    $astroInventoryArray = Get-Content $valuePath | Select-String -NotMatch "^#"
} else {
    # the astroInventory.txt file was not found.
    # display error message that astroInventory.txt file was not found
    $ButtonType = [System.Windows.MessageBoxButton]::Ok
    $MessageIcon = [System.Windows.MessageBoxImage]::Error
    $MessageBody = "Device Inventory 'astroInventory.txt' file not found!"
    $MessageTitle = "astroInventory.txt file not found!"
    $Result = [System.Windows.MessageBox]::Show($MessageBody,$MessageTitle,$ButtonType,$MessageIcon)
}

####################################################################################
#                          Inventory Check End                                     #
####################################################################################


####################################################################################
#                                 Form Start                                       #
####################################################################################

# AstroInventory is the name of the Windows Form
$AstroInventory = New-Object system.Windows.Forms.Form
$AstroInventory.Text = "ASTRO Inventory Tool"
$AstroInventory.TopMost = $true
$AstroInventory.Width = 650
$AstroInventory.Height = 550
$AstroInventory.StartPosition = 'CenterScreen'
$AstroInventory.FormBorderStyle = 'Fixed3D'
$AstroInventory.MaximizeBox = $false
$AstroInventory.Icon = $ico

# Label for ComboBox1
$label = New-Object system.windows.Forms.Label
$label.Text = "ASTRO Client Selection"
$label.AutoSize = $true
$label.Width = 25
$label.Height = 10
$label.location = new-object system.drawing.point(30,30)
$label.Font = "Microsoft Sans Serif,10"
$AstroInventory.controls.Add($label)

# ComboBox populated by astroInventoryArray
$comboBox1 = New-Object system.windows.Forms.ComboBox
$comboBox1.Width = 303
$comboBox1.Height = 20
$comboBox1.location = new-object system.drawing.point(30,54)
$comboBox1.Font = "Microsoft Sans Serif,10"
# astroInventory is checked to see if the path is found
if ($valuePathValid -eq $true) {
    # the astroInventory.txt file was found.
    # for each item listed within the astroInventory.txt file, the elements are
    # added to the comboBox.
    foreach ($element in $astroInventoryArray) {$comboBox1.Items.Add($element)}
    # this appends the comboBox to add the 'Custom..." to the list of items.
    # Using the 'Custom...' selection the user can load custom inventory lists
    $comboBox1.Items.Add("Custom...")
    } else {
    # the astroInventory.txt file was not found.
    # Using the 'Custom...' selection the user can load custom inventory lists.
    # this ensures that the user can use the application if the astroInventory
    # is not utilized.
    $comboBox1.Items.Add("Custom...")
    }
# an event handler is added to identify when the comboBox has been changed
$comboBox1_SelectedIndexChanged = {
    # identifies whether the comboBox selection change was greater than 0
    if ($comboBox1.SelectedIndex -ge 0){
        # clears/resets the event messages display
        $textBox2.Text = ""
        # did the user select 'Custom...' from comboBox
        if($comboBox1.Text -eq "Custom..."){
            # 'Custom...' selected by user
            # make the label for the custom directory input
            $label3.Visible = $true
            # make the textbox visible for the user to browse to a directory to hash
            $textBox1.Visible = $true
            # make the browse button visible for the user to browse to a directory to hash
            $buttonBrowse.Visible = $true
        } else {
            # another selection besides 'Custom...' was selected from comboBox
            # clears/resets the browse textbox
            $textBox1.Text = ""
            # make the label invisible
            $label3.Visible = $false
            # make the textbox invisible
            $textBox1.Visible = $false
            # make the browse button invisible
            $buttonBrowse.Visible = $false
            # This function is used to check that the _values.txt file exists in data folder
            Load-Inventory
        }
    }
}
$comboBox1.add_SelectedIndexChanged($comboBox1_SelectedIndexChanged)
$AstroInventory.controls.Add($comboBox1)

# Groupbox around radioButtons
$groupBox = New-Object System.Windows.Forms.GroupBox
$groupBox.Location = New-Object System.Drawing.Size(485,15)
$groupBox.size = New-Object System.Drawing.Size(120,80)
$groupBox.text = "Hash Value:"
$groupBox.Font = "Microsoft Sans Serif,9"
$AstroInventory.Controls.Add($groupBox)

# Radio button used for SHA 1 selection
$RadioButton1 = New-Object System.Windows.Forms.RadioButton
$RadioButton1.Location = new-object system.drawing.point(10,25)
$RadioButton1.size = '100,20'
$RadioButton1.Checked = $true 
$RadioButton1.Text = "SHA1"
$groupBox.Controls.Add($RadioButton1)

# Radio button used for SHA 256 selection
$RadioButton2 = New-Object System.Windows.Forms.RadioButton
$RadioButton2.Location = new-object system.drawing.point(10,50)
$RadioButton2.size = '100,20'
$RadioButton2.Checked = $false
$RadioButton2.Text = "SHA256"
$groupBox.Controls.Add($RadioButton2)

# Label for 'Custom...' user input for a custom file
$label3 = New-Object system.windows.Forms.Label
$label3.Text = "Add custom directory list...  (example: custom_values.txt)"
$label3.AutoSize = $true
$label3.Width = 25
$label3.Height = 20
$label3.Visible = $false
$label3.location = new-object system.drawing.point(30,100)
$label3.Font = "Microsoft Sans Serif,10"
$AstroInventory.controls.Add($label3)

# This textbox is used when 'Custom...' is selected from the comboBox.
# Used for user input for custom directory
$textBox1 = New-Object system.windows.Forms.TextBox
$textBox1.Width = 482
$textBox1.Height = 20
$textBox1.Visible = $false
$textBox1.location = new-object system.drawing.point(30,125)
$textBox1.Font = "Microsoft Sans Serif,10"
$AstroInventory.controls.Add($textBox1)

# Browse button used to file selection used to import custom_values.txt
$buttonBrowse = New-Object system.windows.Forms.Button
$buttonBrowse.Text = "Browse..."
$buttonBrowse.Width = 90
$buttonBrowse.Height = 23
$buttonBrowse.Visible = $false
$buttonBrowse.location = new-object system.drawing.point(515,124)
$buttonBrowse.Font = "Microsoft Sans Serif,10"
# an event handler used to identify when the Browse button is clicked
$buttonBrowse.Add_Click({
    # populates the textbox with the OpenDialog file picker when the browse button
    # is selected
    $textBox1.Text = Get-Folder
})
$AstroInventory.controls.Add($buttonBrowse)

# Label for Textbox2
$label2 = New-Object system.windows.Forms.Label
$label2.Text = "Event Messages:"
$label2.AutoSize = $true
$label2.Width = 25
$label2.Height = 20
$label2.location = new-object system.drawing.point(30,160)
$label2.Font = "Microsoft Sans Serif,10"
$AstroInventory.controls.Add($label2)

# Event Messages
$textBox2 = New-Object system.windows.Forms.TextBox
$textBox2.Width = 570
$textBox2.Height = 250
$textBox2.ScrollBars = "Vertical"
$textBox2.Multiline = $true
$textBox2.location = new-object system.drawing.point(30,185)
$textBox2.Font = "Microsoft Sans Serif,10"
$AstroInventory.controls.Add($textBox2)

# Start Button
$buttonStart = New-Object system.windows.Forms.Button
$buttonStart.Text = "Start"
$buttonStart.Width = 90
$buttonStart.Height = 25
$buttonStart.location = new-object system.drawing.point(510,450)
$buttonStart.Font = "Microsoft Sans Serif,10"
# an event handler used to identify when the Start button is clicked
$buttonStart.Add_Click({
    # ensure that the comboBox is not empty
    if ($comboBox1.Text -ne "") {
        # is the selection of the comboBox is NOT equal to 'Custom...'
        if ($comboBox1.Text -ne "Custom...") {
            # user selected 'Custom...'
            # append Event Message that the Inventory was started
            $textBox2.Text += "`r`nInventory Started"
            # Add some delay
            Start-Sleep -Milliseconds 500
            # This function is used to create the SHA hashes against all files within the
            # specified _values.txt files once the start button is pressed
            SHA-Hash
        } else {
            # is the selection of the comboBox IS equal to 'Custom...'.
            # Ensure the user typed something into the browse textbox
            if ($textBox1.Text -ne "") {
                # get the value of the browse textbox
                $val = $textBox1.Text
                # test the path of the browse textbox to ensure it is valid
                $validval = Test-Path $val
                # validity check for the browse textbox
                if ($validval) {
                    # browse textbox is valid
                    # append event message that the inventory was loaded
                    $textBox2.Text = "Inventory Loaded - Ready"
                    # Add some delay
                    Start-Sleep -Milliseconds 500
                    # This function is used to create the SHA hashes against all files within the
                    # specified _values.txt files once the start button is pressed
                    SHA-Hash
                } else {
                    # browse textbox is NOT valid
                    # append event message that the browse textbox was not valid
                    $textBox2.Text = "Inventory Loaded - Failed to find directory"
                }
            } else {
                # get the value of the browse textbox
                # if the browse textbox is empty, inform the user that it was empty
                $textBox2.Text = "Please enter directory path"
            }
        }
    }
})
$AstroInventory.controls.Add($buttonStart)

# Close Button
$buttonClose = New-Object system.windows.Forms.Button
$buttonClose.Text = "Close"
$buttonClose.Width = 90
$buttonClose.Height = 25
$buttonClose.location = new-object system.drawing.point(30,450)
$buttonClose.Font = "Microsoft Sans Serif,10"
# an event handler used to identify when the Close button is clicked
$buttonClose.Add_click({
    # method to release unmanaged resources used by your application. 
    $AstroInventory.Dispose()
})
$AstroInventory.controls.Add($buttonClose)


####################################################################################
#                                 Form End                                         #
####################################################################################


####################################################################################
#                                 Functions Start                                  #
####################################################################################

# This function is used when the user clicks the browse button
Function Get-Folder($initialDirectory)
{
    # Dialog box to select _custom.txt
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.initialDirectory = $initialDirectory
    $OpenFileDialog.filter = "TXT (*.txt)| *.txt"
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
    return $filename
}

# This function is used to check that the values.txt file exists in data folder
Function Load-Inventory() 
{
    # saves the comboBox selection and appends '_values.txt' in a global variable
    # this links the comboBox selection to the \Data\ directory based on the Astro
    # client selection
    $Global:val = $comboBox1.Text+"_values.txt"
    # test the path to ensure the comboBox selection has the appropriate _values.txt
    # file present for loading
    $inventoryData = Test-Path $dataPath$Global:val
    # is the inventory path valid
    if ($inventoryData) {
        # append the Event Messages to update user that the inventory was loaded
        $textBox2.Text = "Inventory Loaded - Ready"
    } else {
        # append the Event Messages to update user that the inventory failed to
        # locate the path to the _values.txt base on comboBox selection
        $textBox2.Text = "Inventory Not Found - Failed"
    }

}

# This function is used to create the SHA hashes against all files within the
# specified _values.txt files once the start button is pressed
Function SHA-Hash()
{
    # get the value of the combobox selection
    # if the value of the combobox is "Custom..."
    if ($comboBox1.Text -eq "Custom...") {
        # comboBox selection is 'Custom...'
        # store value used for exporting to .csv
        # env:UserProfile is used to export the .csv to users desktop for easy location
        $output = $env:UserProfile+"\Desktop\custom_"+$Global:dateTime+".csv"
        # store value from the custom browse textbox
        # the import variable is used to build the list of system directories stored 
        # within the custom selection
        $import = $textbox1.Text
    } else {
        # comboBox selection is anything other than 'Custom...'
        # append the event messages textbox that the hashing process has started
        $textBox2.Text += "`r`nHashing Binaries in Directory - $Global:val"
        # store the value of the Astro Client Selection
        $b = $comboBox1.Text
        # store the data path used to locate the appropriate _values.txt file
        $c = $dataPath
        # store value used for exporting to .csv
        # env:UserProfile is used to export the .csv to users desktop for easy location
        $output = $env:UserProfile+"\Desktop\"+$comboBox1.Text+"_"+$Global:dateTime+".csv"
        # the import variable is used to build the list of system directories stored 
        # within the custom selection
        $import = "$dataPath$Global:val"
    }
    # Get the hash level of encryption selected by user SHA1 is default
    if ($RadioButton1.Checked){
        $algorithm = "SHA1"
    } else {
        $algorithm = "SHA256"
    }
    # variable used to count how many directories are hashed
    $count = 0
    # List used to store the system directories that will be hashed
    $Global:List = Get-Content $import
    # for each entry within the list
    ForEach ($entry in $list){
        # check if the entry is blank or contains a # indicating that it is a comment
        if ($entry -eq "" -or $entry -contains "#") {} else {
            # the entry was valid
            # Test the path of the entry within the list
            $isValid = Test-Path $entry
            # if it is valid
            if($isValid) {
                # the path was valid
                # add 1 to the count
                $count += 1
                # check all files within the directory that have the -include extension.  
                # hash the file based on the algorithm selected
                # export to the directory 
                Get-ChildItem -Path $entry -Include *.exe, *.com, *.ps1, *.dll, *.bat, *.vbs, *.sys, *.msi -Recurse | Get-FileHash -Algorithm $algorithm | Select-Object Algorithm,Hash,Path | Export-Csv $output -NoTypeInformation -Append
                # append the event messages to update the user that the directory has been
                # hashed successfully
                $textBox2.Text += "`r`nDirectory - $entry - Completed"
            } else {
                # the path was NOT valid
                # append the event messages to update the user that the directory has NOT
                # been hashed due to the path within the _values.txt could NOT be found
                $textBox2.Text += "`r`nDirectory - $entry - Not Found"
            }
        # This section of code is used to autoscroll the event messages
        $textBox2.SelectionStart = $textBox2.Text.Length
        $textBox2.ScrollToCaret()
        # section end
        # Adds delay between each directory hash
        Start-Sleep -Milliseconds 250
        }
    }
    # The hashing process has been completed
    # append the event messages textbox to update the user that the process has completed
    # and display how many directories have been successful
    $textBox2.Text += "`r`nHashing Process Complete - {$count Directories Successful}"
    # This section of code is used to autoscroll the event messages
    $textBox2.SelectionStart = $textBox2.Text.Length
    $textBox2.ScrollToCaret()
    # section end
}

####################################################################################
#                                 Functions End                                    #
####################################################################################

# shows the application in GUI
[void]$AstroInventory.ShowDialog()
# method to release unmanaged resources used by your application. 
$AstroInventory.Dispose()
