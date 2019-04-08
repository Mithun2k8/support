Connect-JCTestOrg

It "Remove-JCUser 1.0" {
    $NewUser = New-RandomUser "PesterTest$(Get-Date -Format MM-dd-yyyy)" | New-JCUser
    $DeleteUser = Remove-JCUser -UserID $NewUser._id -ByID -Force
    $DeleteUser.results | Should -be 'Deleted'
}


Describe "Remove-JCUser 1.10" {

    It "Removes JumpCloud User by Username and -force" {

        $NewUser = New-RandomUser -domain "pleasedelete" | New-JCUser

        $RemoveUser = Remove-JCUser  -Username $NewUser.username -force
    
        $RemoveUser.Results | Should -be 'Deleted'

    }

    It "Removes JumpCloud User by UserID and -force" {

        $NewUser = New-RandomUser -domain "pleasedelete" | New-JCUser

        $RemoveUser = Remove-JCUser  -UserID $NewUser._id -force
    
        $RemoveUser.Results | Should -be 'Deleted'

    }

}