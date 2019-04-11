Function Get-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][string]$Type
    )
    DynamicParam
    {
        # Determine if help files are being built
        If ((Get-PSCallStack).Command -like '*MarkdownHelp')
        {
            # Get targets list
            $JCAssociationType = Get-JCObjectType | Where-Object { $_.Category -eq 'JumpCloud' };
            # Get count of JCObject to determine if script should load dynamic parameters
            $JCObjectCount = 999999
        }
        Else
        {
            # Get targets list
            $JCAssociationType = Get-JCObjectType -Type:($Type) | Where-Object { $_.Category -eq 'JumpCloud' };
            # Get count of JCObject to determine if script should load dynamic parameters
            $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
        }
        # Build parameter array
        $Params = @()
        # Define the new parameters
        If ($JCObjectCount -le 300)
        {
            if ($Type -notin ("ldap_server", "g_suite", "office_365"))
            {
                $JCObject = Get-JCObject -Type:($Type);
                $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); 'Alias' = (@('_id')); 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); 'Alias' = (@('username', 'groupName')); 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); }

            }

            else
            {
                $JCObject = Get-JCObject -Type:($Type);
                $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $false; 'ParameterSets' = @('ById'); 'Alias' = (@('_id')); 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $false; 'ParameterSets' = @('ByName'); 'Alias' = (@('username', 'groupName')); 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); }
            }

        }
        Else
        {
            $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 1; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('_id')); 'ParameterSets' = @('ById'); }
            $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('username', 'groupName')); 'ParameterSets' = @('ByName'); }
        }
        $Params += @{'Name' = 'TargetType'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateSet' = $JCAssociationType.Targets; }
        $Params += @{'Name' = 'HideTargetData'; 'Type' = [Switch]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; }
        # Create new parameters
        Return $Params | ForEach-Object { New-Object PSObject -Property:($_) } | New-DynamicParameter
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object { New-Variable -Name:($_.Key) -Value:($_.Value) -Force }
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False') }) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') { Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName) }
    }
    Process
    {
        $Action = 'get'
        # Create hash table to store variables
        $FunctionParameters = [ordered]@{ }
        # Add input parameters from function in to hash table and filter out unnecessary parameters
        $PSBoundParameters.GetEnumerator() | ForEach-Object { $FunctionParameters.Add($_.Key, $_.Value) | Out-Null }
        # Add parameters from the script to the FunctionParameters hashtable
        $FunctionParameters.Add('Action', $Action) | Out-Null
        if ($Type -in ("ldap_server", "g_suite", "office_365"))
        {
            if (! $FunctionParameters.id -and ! $FunctionParameters.name)
            {
                $JCObject = Get-JCObject -Type:($Type);
                $FunctionParameters.Add("Id", $JCObject.id)
            }

        }
        Write-Debug ('Splatting Parameters');
        If ($DebugPreference -ne 'SilentlyContinue') { $FunctionParameters }
        # Run the command
        $Results = Invoke-JCAssociation @FunctionParameters
    }
    End
    {
        Return $Results
    }
}
