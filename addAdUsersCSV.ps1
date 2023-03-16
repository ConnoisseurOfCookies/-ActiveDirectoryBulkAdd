# Import AD Module
Import-Module ActiveDirectory

# CSV FilePath, same as script path
$users = Import-Csv .\addAdUsersCSV.csv

# Iterate through each user in users
ForEach ($user in $users) {
    
    #Gather User Info
    $firstname = $user.FirstName
    $lastname = $user.LastName
    $username = $user.UserName
    $email = $user.EmailAddress
    $ou = $user.Ou
    $grp1 = $user.Grp1
    
    $grp2 = $user.Grp2 
    $grp3 = $user.Grp3
    
    
    $Role = $user.Role
    $password = ConvertTo-SecureString $user.Password -AsPlainText -Force


    # Create new AD user
    New-ADUser  -GivenName $firstname -Surname $lastname -Name "$firstname $lastname" -UserPrincipalName $username -SamAccountName $username -Path $ou -AccountPassword $password -ChangePasswordAtLogon $False -PasswordNeverExpires $True -EmailAddress $email -Department $Role -Enabled $True

    #Prompt user created
    echo "User $firstname $lastname Created"

    #Add to Groups
    Add-ADGroupMember -Identity $grp1 -Members $username
    echo "$firstname $lastname added to $grp1"


    if($grp2){
        Add-ADGroupMember -Identity $grp2 -Members $username
        echo "$firstname $lastname added to $grp2"
    }

    if($grp3) {
        Add-ADGroupMember -Identity $grp3 -Members $username
        echo "$firstname $lastname added to $grp3"
    }
}


Start-Sleep -Seconds 10