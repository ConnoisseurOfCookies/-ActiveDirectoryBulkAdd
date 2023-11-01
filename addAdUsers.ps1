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
    foreach ($group in $users.Groups) {
        if(!$ADGrList.Name.Contains($group) -and !$NewUserGroupList.Contains($group) -and $group -ne ""){
            $NewUserGroupList += $group
        }
    }
}

# Add new OU's to the domain
foreach ($OU in $NewOUList){
    Write-Output "`nThe OU $OU does not exist, do you want to create it?`n"
    New-ADOrganizationalUnit -Name $ou  -Confirm
}

# Add new Groups to the domain
foreach ($NewGroup in $NewUserGroupList){
    
    $willCreateGroup = Read-Host "`nThe Group $NewGroup does not exist, do you want to create it? (Y) (N)`n"

    # If not Y, quit
    if($willCreateGroup -ne 'Y'.Trim() -or $willCreateGroup -ne 'y'.Trim()) {
        
        break
    }
    
    Write-Output "`nWhich OU will $NewGroup belong to?`n"
    
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
    
    New-ADGroup -Name $NewGroup -Path "OU=$ouGroup,$DCPath" -GroupScope DomainLocal
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
    $UseDefaultPassword = Read-Host -Prompt "`nDo you want to use a default password for each user or assign a unique password for each individual user?`n (1) Use Default Password`n (2) Assign Individually`n"


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
    $groups = $user.Groups
    $Role = $user.Role

    
    

    if($ADUserList.samaccountname.Contains($username)){
        Write-Warning "`nUser with accountname $username is already added to the domain.`n"
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
                    Write-Warning "`nPasswords do not match, please try again:`n"
                }
            } while (!$passwordsMatch)
        }

        # Create new AD user
        New-ADUser  -GivenName $firstname -Surname $lastname -Name "$firstname $lastname" -UserPrincipalName $username -SamAccountName $username -Path $ouFullAddress -AccountPassword $password -ChangePasswordAtLogon $False -PasswordNeverExpires $True -EmailAddress $email -Department $Role -Enabled $True
        
        #Prompt user created
        Write-Output "User $firstname $lastname Created"

    }
    
   
    #Add user to Groups
    ForEach ($group in $groups) {
        if($group -ne ""){
        
            $memberCount = Get-ADGroup $group -Properties "Members" | Select-Object "Members"
            $memberCount = $memberCount.Members.Count
            if($memberCount -eq 0){
                Add-ADGroupMember -Identity $group -Members $username
                Write-Warning  "$firstname $lastname added to $group"
            }
    
            $members = Get-ADGroupMember $group | Select-Object samaccountname
            if(!$members.samaccountname.Contains($username)){
                Add-ADGroupMember -Identity $group -Members $username
                Write-Output  "$firstname $lastname added to $group"
            }else {
                Write-Warning "$username is already a member of $group" 
            }
        }

    }

  }