function Find-BADOuFiltered {
    param (
        $Users
    )
    
    $NewOUList = @()
    $ADOuList = Get-ADOrganizationalUnit -Filter "*" | select Name

    foreach ($user in $Users) {

        # If OU does not exist, Add to list of "OU's to add"
        if (!$ADOuList.Name.Contains($user.Ou) -and !$NewOUList.Contains($user.Ou)) {
            $NewOUList += $user.Ou
        }
    }


    return $NewOUList
}

function Find-BADGroupFiltered {
    param (
        $Users
    )
    
    $NewUserGroupList = @()

    foreach ($user in $Users) {

        # If Group does not exist, add to list of Groups to add, for Grp1, Grp2 and Grp3
        if (!$ADGrList.Name.Contains($user.Grp1) -and !$NewUserGroupList.Contains($user.Grp1) -and $user.Grp1 -ne "") {
            $NewUserGroupList += $user.Grp1
        }

        if (!$ADGrList.Name.Contains($user.Grp2) -and !$NewUserGroupList.Contains($user.Grp2) -and $user.Grp2 -ne "") {
            $NewUserGroupList += $user.Grp2
        }

        if (!$ADGrList.Name.Contains($user.Grp3) -and !$NewUserGroupList.Contains($user.Grp3) -and $user.Grp3 -ne "") {
            $NewUserGroupList += ($user.Grp3)
        }
    }


    return $NewUserGroupList
}