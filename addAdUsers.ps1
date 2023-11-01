# Import AD Module
Import-Module ActiveDirectory

# JSON FilePath, same as script path
$users = Get-Content  .\samples\addAdUsers.json | ConvertFrom-Json

#Loop through and find all OU's and Groups that don't exist

# List of all OU's and Groups currently in the Domain
$ADOuList = Get-ADOrganizationalUnit -Filter "*" | Select-Object Name
$ADGrList = Get-ADGroup -Filter "*" | Select-Object Name


$NewOUList = @()
$NewUserGroupList = @()

# Check if the document contains any OU's and Groups that don't exist in the domain
foreach ($user in $users){

    # If OU does not exist, Add to list of "OU's to add"
    if(!$ADOuList.Name.Contains($user.Ou) -and !$NewOUList.Contains($user.Ou)){
        $NewOUList += $user.Ou
    }

    # If Group does not exist, add to list of Groups to add, for Grp1, Grp2 and Grp3
    if(!$ADGrList.Name.Contains($user.Grp1) -and !$NewUserGroupList.Contains($user.Grp1) -and $user.Grp1 -ne ""){
        $NewUserGroupList += $user.Grp1
    }

    if(!$ADGrList.Name.Contains($user.Grp2) -and !$NewUserGroupList.Contains($user.Grp2)  -and $user.Grp2 -ne ""){
        $NewUserGroupList += $user.Grp2
    }

    if(!$ADGrList.Name.Contains($user.Grp3) -and !$NewUserGroupList.Contains($user.Grp3)  -and $user.Grp3 -ne ""){
        $NewUserGroupList += ($user.Grp3)
    }
}

# Add new OU's to the domain
foreach ($OU in $NewOUList){
    Write-Output "`nThe OU $OU does not exist, do you want to create it?"
    New-ADOrganizationalUnit -Name $ou  -Confirm
}

# Add new Groups to the domain
foreach ($Group in $NewUserGroupList){
    
    $willCreateGroup = Read-Host "`nThe Group $Group does not exist, do you want to create it? (Y) (N)"

    # If not Y, quit
    if($willCreateGroup -ne 'Y'.Trim() -or $willCreateGroup -ne 'y'.Trim()) {
        
        break
    }
    
    Write-Output "`nWhich OU will $Group belong to?`n"
    
    # Update ADOuList
    $ADOuList = Get-ADOrganizationalUnit -Filter "*" |  Select-Object Name


    for(($i = 1); $i -lt $ADOuList.Count; $i++){
        
        $ouName = $ADOuList[$i].Name

        Write-Output "($i) $ouName" 
    }

    [int]$userInput = Read-Host "OU number"
  

    if($userInput -lt 0 -or $userInput -ge $ADOuList.Count) {
    
        Write-Output "Invalid Input"
        continue
    }

    $ouGroup = $ADOuList[$userInput].Name
    $DCPath = $users[0].DC
    New-ADGroup -Name $Group -Path "OU=$ouGroup,$DCPath" -GroupScope DomainLocal
}


#Get full list of users
$ADUserList = Get-ADUser -Filter "*" | Select-Object samaccountname


# Prompt the user on whether they want to create passwords now or later
$UsingDefaultPwd = $false
$password

# If user chooses default password, prompt twice and move on.
# If user unique passwords, move on
# Otherwise, prompt again
do {
    # The prompt
    $UseDefaultPassword = Read-Host -Prompt "Do you want to use a default password for each user or assign a unique password for each individual user?`n (1) Use Default Password`n (2) Assign Individually`n"


    switch ($UseDefaultPassword) {
        1 { 
            $passwordsMatch = $false
            while(!$passwordsMatch){
                $password = Read-Host -AsSecureString -Prompt "`nInsert Password"
                $password2 = Read-Host -AsSecureString -Prompt "Type the Password Again"
                $passwordsMatch = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)) -eq [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2))
                if ($passwordsMatch) {
                    $UsingDefaultPwd = $true
                    break
                }
                Write-Warning "`nPasswords do not match, please try again`n"
            }
            break
        }

        2 {
            $UsingDefaultPwd = $false; Break
        }
        Default {Write-Warning "`nInvalid input, please try again`n" }
    }
} while (
    # Do while neither 1 or 2 is selected
    !($UseDefaultPassword -eq 1 -or $UseDefaultPassword -eq 2)
)

# Iterate through each user in users
ForEach ($user in $users) {
    
    #Gather User Info
    $firstname = $user.FirstName
    $lastname = $user.LastName
    $username = $user.UserName
    $email = $user.EmailAddress
    $ouFullAddress = "OU=" + $user.Ou + "," + $user.DC 
    $ou = $user.Ou
    $grp1 = $user.Grp1
    $grp2 = $user.Grp2 
    $grp3 = $user.Grp3
    $Role = $user.Role

    
    

    if($ADUserList.samaccountname.Contains($username)){
        Write-Output "User with accountname $username is already added to the domain. Check user details."
    }else {
        # Check whether or not user chooses default passwords
        if (!$UsingDefaultPwd) {

            # Prompt for user password
            $passwordsMatch = $false
            do {
                $password = Read-Host -AsSecureString -Prompt "Create password for $username"
                $password2 = Read-Host -AsSecureString -Prompt "Type the password again"
                $passwordsMatch = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password)) -eq [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($password2))
                if(!$passwordsMatch){
                    Write-Warning "Passwords do not match, please try again:"
                }
            } while (!$passwordsMatch)
        }

        # Create new AD user
        New-ADUser  -GivenName $firstname -Surname $lastname -Name "$firstname $lastname" -UserPrincipalName $username -SamAccountName $username -Path $ouFullAddress -AccountPassword $password -ChangePasswordAtLogon $False -PasswordNeverExpires $True -EmailAddress $email -Department $Role -Enabled $True
        
        #Prompt user created
        Write-Output "User $firstname $lastname Created"

    }
    
   
    #Add user to Groups
    if($grp1 -ne ""){
        
        $memberCount = Get-ADGroup $grp1 -Properties "Members" | Select-Object "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp1 -Members $username
            Write-Output  "$firstname $lastname added to $grp1"
        }

        $members = Get-ADGroupMember $grp1 | Select-Object samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp1 -Members $username
            Write-Output  "$firstname $lastname added to $grp1"
        }else {
            Write-Output "$username is already a member of $grp1" 
        }
    }


    if($grp2 -ne ""){
        
        $memberCount = Get-ADGroup $grp2 -Properties "Members" | Select-Object "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp2 -Members $username
            Write-Output  "$firstname $lastname added to $grp2"
        }

        $members = Get-ADGroupMember $grp2 | Select-Object samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp2 -Members $username
            Write-Output  "$firstname $lastname added to $grp2"
        }else {
            Write-Output "$username is already a member of $grp2" 
        }

    
    }

    if($grp3 -ne ""){
        
        $memberCount = Get-ADGroup $grp3 -Properties "Members" | Select-Object "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp3 -Members $username
            Write-Output  "$firstname $lastname added to $grp3"
        }

        $members = Get-ADGroupMember $grp3 | Select-Object samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp3 -Members $username
            Write-Output  "$firstname $lastname added to $grp3"
        }else {
            Write-Output "$username is already a member of $grp3" 
        }

    
    }

  }