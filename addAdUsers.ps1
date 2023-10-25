# Import AD Module
Import-Module ActiveDirectory

# JSON FilePath, same as script path
$users = Get-Content  .\addAdUsersJson.json | ConvertFrom-Json

#Loop through and find all OU's and Groups that don't exist

# List of all OU's and Groups currently in the Domain
$ADOuList = Get-ADOrganizationalUnit -Filter "*" | select Name
$ADGrList = Get-ADGroup -Filter "*" | select Name


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
    echo "`nThe OU $OU does not exist, do you want to create it?"
    New-ADOrganizationalUnit -Name $ou -ProtectedFromAccidentalDeletion $false -Confirm
}

# Add new Groups to the domain
foreach ($Group in $NewUserGroupList){
    
    $willCreateGroup = Read-Host "`nThe Group $Group does not exist, do you want to create it? (Y) (N)"

    # If not Y, quit
    if($willCreateGroup -ne 'Y'.Trim() -or $willCreateGroup -ne 'y'.Trim()) {
        
        break
    }
    
    echo "`nWhich OU will $Group belong to?`n"
    
    # Update ADOuList
    $ADOuList = Get-ADOrganizationalUnit -Filter "*" |  select Name


    for(($i = 1); $i -lt $ADOuList.Count; $i++){
        
        $ouName = $ADOuList[$i].Name

        echo "($i) $ouName" 
    }

    [int]$userInput = Read-Host "OU number"
  

    if($userInput -lt 0 -or $userInput -ge $ADOuList.Count) {
    
        echo "Invalid Input"
        continue
    }

    $ouGroup = $ADOuList[$userInput].Name
    $DCPath = $users[0].DC
    New-ADGroup -Name $Group -Path "OU=$ouGroup,$DCPath" -GroupScope DomainLocal
}


#Get full list of users
$ADUserList = Get-ADUser -Filter "*" | select samaccountname


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
    $password = ConvertTo-SecureString $user.Password -AsPlainText -Force

    if($ADUserList.samaccountname.Contains($username)){
        Write-Output "User with accountname $username is already added to the domain. Check user details."
    }else {
        # Create new AD user
        New-ADUser  -GivenName $firstname -Surname $lastname -Name "$firstname $lastname" -UserPrincipalName $username -SamAccountName $username -Path $ouFullAddress -AccountPassword $password -ChangePasswordAtLogon $False -PasswordNeverExpires $True -EmailAddress $email -Department $Role -Enabled $True
        
        #Prompt user created
        echo "User $firstname $lastname Created"

    }
    
   
    #Add user to Groups
    if($grp1 -ne ""){
        
        $memberCount = Get-ADGroup $grp1 -Properties "Members" | select "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp1 -Members $username
            echo  "$firstname $lastname added to $grp1"
        }

        $members = Get-ADGroupMember $grp1 | select samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp1 -Members $username
            echo  "$firstname $lastname added to $grp1"
        }else {
            echo "$username is already a member of $grp1" 
        }
    }


    if($grp2 -ne ""){
        
        $memberCount = Get-ADGroup $grp2 -Properties "Members" | select "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp2 -Members $username
            echo  "$firstname $lastname added to $grp2"
        }

        $members = Get-ADGroupMember $grp2 | select samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp2 -Members $username
            echo  "$firstname $lastname added to $grp2"
        }else {
            echo "$username is already a member of $grp2" 
        }

    
    }

    if($grp3 -ne ""){
        
        $memberCount = Get-ADGroup $grp3 -Properties "Members" | select "Members"
        $memberCount = $memberCount.Members.Count
        if($memberCount -eq 0){
            Add-ADGroupMember -Identity $grp3 -Members $username
            echo  "$firstname $lastname added to $grp3"
        }

        $members = Get-ADGroupMember $grp3 | select samaccountname
        if(!$members.samaccountname.Contains($username)){
            Add-ADGroupMember -Identity $grp3 -Members $username
            echo  "$firstname $lastname added to $grp3"
        }else {
            echo "$username is already a member of $grp3" 
        }

    
    }

  }