Function Get-JCAssociation
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('activedirectories', 'active_directory', 'commands', 'command', 'ldapservers', 'ldap_server', 'policies', 'policy', 'applications', 'application', 'radiusservers', 'radius_server', 'systemgroups', 'system_group', 'systems', 'system', 'usergroups', 'user_group', 'users', 'user', 'gsuites', 'g_suite', 'office365s', 'office_365')][string]$InputObjectType
    )
    DynamicParam
    {
        # $InputJCObject = Get-JCObject -Type:($InputObjectType);
        # $InputJCObjectIds = $InputJCObject.($InputJCObject.ById | Select-Object -Unique);
        # $InputJCObjectNames = $InputJCObject.($InputJCObject.ByName | Select-Object -Unique);
        $JCAssociationType = Get-JCAssociationType -InputObject:($InputObjectType);
        # Build parameter array
        $Params = @()
        # Define the new parameters
        $Params += @{'Name' = 'InputObjectId'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }#'ValidateSet' = $InputJCObjectIds; }
        $Params += @{'Name' = 'InputObjectName'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }#'ValidateSet' = $InputJCObjectNames; }
        $Params += @{'Name' = 'TargetObjectType'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateSet' = $JCAssociationType.Targets; }
        # $Params += @{'Name' = 'HideTargetData'; 'Type' = [System.Boolean]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'DontShow' = $true; 'ValidateSet' = ($true, $false); }
        # Create new parameters
        Return $Params | ForEach-Object {New-Object PSObject -Property:($_)} | New-DynamicParameter
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','") + "')"}).Replace("'True'", '$True').Replace("'False'", '$False'))
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
    }
    Process
    {
        $Results = Switch ($PSCmdlet.ParameterSetName)
        {
            'ById'
            {
                Invoke-JCAssociation -Action:('get') -InputObjectType:($InputObjectType) -InputObjectId:($InputObjectId) -TargetObjectType:($TargetObjectType); # -HideTargetData:($HideTargetData);
            }
            'ByName'
            {
                Invoke-JCAssociation -Action:('get') -InputObjectType:($InputObjectType) -InputObjectName:($InputObjectName) -TargetObjectType:($TargetObjectType); # -HideTargetData:($HideTargetData);
            }
        }
    }
    End
    {
        Return $Results
    }
}