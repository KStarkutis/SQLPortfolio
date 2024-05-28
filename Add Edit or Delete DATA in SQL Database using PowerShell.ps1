# Timeout parameters
$QueryTimeout = 120
$ConnectionTimeout = 30

# SQL settings 
$ServerName = "FLT-PF34HM6B\SQLEXPRESS"
$DatabaseName = "Veri kul dotabaise"
$userId = "test"
$password = "test"

# Action of connecting to the Database and executing the query and returning results if there were any.
$conn=New-Object System.Data.SqlClient.SQLConnection
$ConnectionString = "Server={0};Database={1};User ID={2};Password={3};Connect Timeout={4}" -f $ServerName,$DatabaseName,$userId,$password,$ConnectionTimeout
$conn.ConnectionString=$ConnectionString
$conn.Open()
$ds=New-Object system.Data.DataSet
$da=New-Object system.Data.SqlClient.SqlDataAdapter($cmd)

$cmd = $null
$correctInput = $false

# Loop until correct input is provided
do 
{
    #UI
    $UI_MainOp = Read-Host -Prompt "`nEnter coresponding number to Add, Edit or Delete row in the Persons table`nAdd-1`nEdit-2`nDelete-3`n"

    if ($UI_MainOp -eq 1)
    {
        # Initialize variable to control the loop
        $correctInput = $false

        # Loop until correct input is provided
        do {
            # Reset variables holding user input
            $UI_Add_Name = $null
            $UI_Add_Surname = $null
            $UI_Add_Age = $null

            # Prompt user to enter Name, Surname, and Age
            $UI_Add_Name = Read-Host -Prompt "Enter Name"
            $UI_Add_Surname = Read-Host -Prompt "Enter Surname"
            $UI_Add_Age = Read-Host -Prompt "Enter Age"

            # Display the entered data and ask if it's correct
            $UI_Add_Ask_Correct = Read-Host -Prompt "Is this correct?`n`n$UI_Add_Name $UI_Add_Surname $UI_Add_Age`n`nYes-1`nNo-2`n"

            # If data is correct, set $correctInput to true to exit the loop
            if ($UI_Add_Ask_Correct -eq 1) {
                Write-Host "`nData added to the table!`n"
                $correctInput = $true
            }
            elseif($UI_Add_Ask_Correct -eq 2) {
                Write-Host "`nLet's try this again!`n"
                
            }else{Write-Host "`nWrong input!`n"}
        } until ($correctInput)

        $Query = "INSERT INTO [Veri kul dotabaise].[dbo].[Persons] (Name, Surname, Age)
        VALUES ('$UI_Add_Name', '$UI_Add_Surname', '$UI_Add_Age')"

        $cmd = New-Object system.Data.SqlClient.SqlCommand($Query, $conn)
        $cmd.CommandTimeout = $QueryTimeout
        $cmd.ExecuteNonQuery()

    }
    elseif ($UI_MainOp -eq 2)
    {
        #Initialize variable to control the loop
        $correctInput = $false

        # Loop until correct input is provided
        do {
            $UI_Edit_ID = Read-Host -Prompt "Enter row ID you want to edit"

            $UI_Edit_ID_Query = "SELECT ID, Name, Surname, Age FROM [Veri kul dotabaise].[dbo].[Persons] WHERE ID = '$UI_Edit_ID'"

            $cmd = New-Object system.Data.SqlClient.SqlCommand($UI_Edit_ID_Query, $conn)
            $cmd.CommandTimeout = $QueryTimeout

            # Execute the query and store the result
            $result = $cmd.ExecuteReader()

            # Check if any row is returned
            if ($result.HasRows) {
                # Read the row data
                while ($result.Read()) {
                    # Display the row data
                    $id = $result["ID"]
                    $name = $result["Name"]
                    $surname = $result["Surname"]
                    $age = $result["Age"]
                    Write-Host "`nID | Name | Surname | Age"
                    Write-Host "$id | $name | $surname | $age"
                }
            } else {
                Write-Host "No record found with ID $UI_Edit_ID"
                $result.Dispose()
                $result = $null
            }

            $UI_Edit_ID_Correct = Read-Host -Prompt "`nIs this correct row?`n`nYes-1`nNo-2`n"

            if ($UI_Edit_ID_Correct -eq 1) {
                $correctInput = $true
                $result.Dispose()
                $result = $null
            }
            elseif($UI_Edit_ID_Correct -eq 2) {
                $result.Dispose()
                $result = $null
                Write-Host "`nLet's try this again!`n"
            }else{
                Write-Host "`nWrong input!`n"
                $result.Dispose()
                $result = $null
            }
        } until ($correctInput)

        $correctInput = $false

        # Loop until correct input is provided
        do {

            $UI_Edit_New_Name = $null
            $UI_Edit_New_Surname = $null
            $UI_Edit_New_Age = $null

            $UI_Edit_New_Name = Read-Host -Prompt "Enter new Name"
            $UI_Edit_New_Surname = Read-Host -Prompt "Enter new Surname"
            $UI_Edit_New_Age = Read-Host -Prompt "Enter new Age"

            $UI_Edit_Ask_Correct = Read-Host -Prompt "Is this correct?`n`n$UI_Edit_New_Name $UI_Edit_New_Surname $UI_Edit_New_Age`n`nYes-1`nNo-2`n"
            
            if ($UI_Edit_Ask_Correct -eq 1) {
                $correctInput = $true
                $UI_Edit_Query = "UPDATE [Veri kul dotabaise].[dbo].[Persons] SET Name = '$UI_Edit_New_Name', Surname = '$UI_Edit_New_Surname', Age = '$UI_Edit_New_Age' WHERE ID = '$UI_Edit_ID'"

                $cmd = New-Object system.Data.SqlClient.SqlCommand($UI_Edit_Query, $conn)
                $cmd.CommandTimeout = $QueryTimeout
                $cmd.ExecuteNonQuery()

                Write-Host "`nData edited!`n"
            }
            elseif($UI_Edit_Ask_Correct -eq 2) {
                Write-Host "`nLet's try this again!`n"
            }else{
                Write-Host "`nWrong input!`n"
            }

        } until ($correctInput)
    }
    elseif ($UI_MainOp -eq 3)
    {
        #Initialize variable to control the loop
        $correctInput = $false

        # Loop until correct input is provided
        do {
            $UI_Delete_ID = Read-Host -Prompt "Enter row ID you want to delete"

            $UI_Delete_ID_Query = "SELECT ID, Name, Surname, Age FROM [Veri kul dotabaise].[dbo].[Persons] WHERE ID = '$UI_Delete_ID'"
            $cmd = New-Object system.Data.SqlClient.SqlCommand($UI_Delete_ID_Query, $conn)
            $cmd.CommandTimeout = $QueryTimeout

            # Execute the query and store the result
            $result = $cmd.ExecuteReader()

            # Check if any row is returned
            if ($result.HasRows) {
                # Read the row data
                while ($result.Read()) {
                    # Display the row data
                    $id = $result["ID"]
                    $name = $result["Name"]
                    $surname = $result["Surname"]
                    $age = $result["Age"]
                    Write-Host "`nID | Name | Surname | Age"
                    Write-Host "$id | $name | $surname | $age"
                }
            } else {
                Write-Host "No record found with ID $UI_Delete_ID"
                $result.Dispose()
                $result = $null
            }

            $UI_Delete_ID_Correct = Read-Host -Prompt "`nIs this correct row?`n`nYes-1`nNo-2`n"

            if ($UI_Delete_ID_Correct -eq 1) {
                $result.Dispose()
                $result = $null

                $UI_Delete_Query = "DELETE FROM [Veri kul dotabaise].[dbo].[Persons] WHERE ID = '$UI_Delete_ID'"

                $cmd = New-Object system.Data.SqlClient.SqlCommand($UI_Delete_Query, $conn)
                $cmd.CommandTimeout = $QueryTimeout
                $cmd.ExecuteNonQuery()

                Write-Host "`nData deleted!`n"
                
                $correctInput = $true
            }
            elseif($UI_Delete_ID_Correct -eq 2) {
                $result.Dispose()
                $result = $null
                Write-Host "`nLet's try this again!`n"
            }else{
                Write-Host "`nWrong input!`n"
                $result.Dispose()
                $result = $null
            }
        } until ($correctInput)
    }

}until ($correctInput)



# Fill dataset using the adapter 
[void]$da.fill($ds)
$conn.Close()

Start-Sleep 10
