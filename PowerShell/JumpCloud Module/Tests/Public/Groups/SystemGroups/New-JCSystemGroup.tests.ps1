Describe 'New-JCSystemGroup' {

    It "Creates a new system group" {
        $NewG = New-JCSystemGroup -GroupName $(New-RandomString 8)
        $NewG.Result | Should -Be 'Created'
        $DeletedG = Remove-JCSystemGroup -GroupName $NewG.name  -force
    }

}
