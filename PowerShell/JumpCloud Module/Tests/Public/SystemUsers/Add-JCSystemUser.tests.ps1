Connect-JCTestOrg

Describe 'Add-JCSystemUser 1.0' {

    It "Adds a single user to a single system by Username and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID -force
        $UserAdd = Add-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID
        $UserAdd.Status | Should Be 'Added'
    }


    It "Adds a single user to a single system by UserID and SystemID" {
        $UserRemove = Remove-JCSystemUser -Username $PesterParams.Username -SystemID $PesterParams.SystemID -force
        $UserAdd = Add-JCSystemUser -UserID $PesterParams.UserID -SystemID $PesterParams.SystemID
        $UserAdd.Status | Should Be 'Added'
    }

    It "Adds two users to a single system using the pipeline and system ID" {
        $MultiUserRemove = Get-JCUser | Select-Object -Last 2 | Remove-JCSystemUser -SystemID $PesterParams.SystemID -force
        $MultiUserAdd = Get-JCUser | Select-Object -Last 2 | Add-JCSystemUser -SystemID $PesterParams.SystemID
        $MultiUserAdd.Status.Count | Should Be 2
    }

}

Describe 'Add-JCSystemUser 1.1.0' {

    It "Adds a JumpCloud User to a JumpCloud System with admin `$False using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser

        $FalseUser = Add-JCSystemUser -Username $User.username -SystemID $PesterParams.SystemID -Administrator $False

        $FalseUser.Administrator | Should Be $False

        $GetUser = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should Be $False

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin $False using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser

        $FalseUser = Add-JCSystemUser -Username $User.username -SystemID $PesterParams.SystemID -Administrator $False

        $FalseUser.Administrator | Should Be $False

        $GetUser = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $FalseUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should Be $False

    }

    It "Adds a JumpCloud User to a JumpCloud System with admin `$False using UserID" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser
    
        $FalseUser = Add-JCSystemUser -UserID $User._id -SystemID $PesterParams.SystemID -Administrator $False
    
        $FalseUser.Administrator | Should Be $False
    
        $GetUser = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $User.Username | Select-Object Administrator
    
        $GetUser.Administrator | Should Be $False
    
    }

    It "Adds a JumpCloud User to a JumpCloud System with admin `$True using UserID" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser
    
        $TrueUser = Add-JCSystemUser -UserID $User._id -SystemID $PesterParams.SystemID -Administrator $True
    
        $TrueUser.Administrator | Should Be $True
    
        $GetUser = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $User.Username | Select-Object Administrator
    
        $GetUser.Administrator | Should Be $True
    
    }

    It "Adds a JumpCloud User to a JumpCloud System with admin $True using username" {

        $User = New-RandomUserCustom -Domain 'pleasedelete' | New-JCUser

        $TrueUser = Add-JCSystemUser -Username $User.username -SystemID $PesterParams.SystemID -Administrator $True

        $TrueUser.Administrator | Should Be $True

        $GetUser = Get-JCSystemUser -SystemID $PesterParams.SystemID | Where-Object Username -EQ $TrueUser.Username | Select-Object Administrator

        $GetUser.Administrator | Should Be $True

    }


}