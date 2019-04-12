Function Invoke-JCAssociation
{
    [CmdletBinding(DefaultParameterSetName = 'ById')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 0)][ValidateNotNullOrEmpty()][ValidateSet('add', 'get', 'remove')][string]$Action,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1)][ValidateNotNullOrEmpty()][ValidateSet('active_directory', 'command', 'ldap_server', 'policy', 'application', 'radius_server', 'system_group', 'system', 'user_group', 'user', 'g_suite', 'office_365')][string]$Type
    )
    DynamicParam
    {
        If ($Action -and $Type)
        {
            # Determine if help files are being built
            If ((Get-PSCallStack).Command -like '*MarkdownHelp')
            {
                # Get targets list
                $JCAssociationType = Get-JCObjectType | Where-Object {$_.Category -eq 'JumpCloud'};
                # Get count of JCObject to determine if script should load dynamic parameters
                $JCObjectCount = 999999
            }
            Else
            {
                # Get targets list
                $JCAssociationType = Get-JCObjectType -Type:($Type) | Where-Object {$_.Category -eq 'JumpCloud'};
                # Get count of JCObject to determine if script should load dynamic parameters
                $JCObjectCount = (Get-JCObject -Type:($Type) -ReturnCount).totalCount
            }
            # Build parameter array
            $Params = @()
            # Define the new parameters
            If ($JCObjectCount -ge 1 -and $JCObjectCount -le 300)
            {
                $JCObject = Get-JCObject -Type:($Type);
                If ($JCObjectCount -eq 1)
                {
                    # Don't require Id and Name to be passed through and set a default value
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); 'Alias' = (@('_id')); 'DefaultValue' = $JCObject.($JCObject.ById)}
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $false; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); 'Alias' = (@('username', 'groupName')); 'DefaultValue' = $JCObject.($JCObject.ByName)}
                }
                Else
                {
                    # Do populate validate set with list of items
                    $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); 'Alias' = (@('_id')); 'ValidateSet' = @($JCObject.($JCObject.ById | Select-Object -Unique)); }
                    $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); 'Alias' = (@('username', 'groupName')); 'ValidateSet' = @($JCObject.($JCObject.ByName | Select-Object -Unique)); }
                }
            }
            Else
            {
                # Don't populate validate set
                $Params += @{'Name' = 'Id'; 'Type' = [System.String]; 'Position' = 2; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('_id')); 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'Name'; 'Type' = [System.String]; 'Position' = 3; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'Alias' = (@('username', 'groupName')); 'ParameterSets' = @('ByName'); }
            }
            $Params += @{'Name' = 'TargetType'; 'Type' = [System.String]; 'Position' = 4; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ValidateSet' = $JCAssociationType.Targets; }
            If ($Action -in ('add', 'remove'))
            {
                $Params += @{'Name' = 'TargetId'; 'Type' = [System.String]; 'Position' = 5; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ById'); }
                $Params += @{'Name' = 'TargetName'; 'Type' = [System.String]; 'Position' = 6; 'ValueFromPipelineByPropertyName' = $true; 'Mandatory' = $true; 'ValidateNotNullOrEmpty' = $true; 'ParameterSets' = @('ByName'); }
            }
            If ($Action -eq 'get')
            {
                $Params += @{'Name' = 'HideTargetData'; 'Type' = [Switch]; 'Position' = 7; 'ValueFromPipelineByPropertyName' = $true; 'DefaultValue' = $false; }
            }
            # Create new parameters
            $NewParams = $Params | ForEach-Object {New-Object PSObject -Property:($_)} | New-DynamicParameter
            # Return new parameters
            Return $NewParams
        }
    }
    Begin
    {
        # For parameters with a default value set that value
        $NewParams.Values | Where-Object {$_.IsSet -and $_.Attributes.ParameterSetName -eq $PSCmdlet.ParameterSetName} | ForEach-Object {$PSBoundParameters[$_.Name] = $_.Value}
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {Set-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        # Debug message for parameter call
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { ('-' + $_.Key + ":('" + ($_.Value -join "','") + "')").Replace("'True'", '$True').Replace("'False'", '$False')}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $Method = Switch ($Action)
        {
            'get' {'GET'}
            'add' {'POST'}
            'remove' {'POST'}
        }
        $Results = @()
    }
    Process
    {
        $SearchBy = $PSCmdlet.ParameterSetName
        Switch ($SearchBy)
        {
            'ById'
            {
                $ObjectSearchByValue = $Id
                $TargetSearchByValue = $TargetId
            }
            'ByName'
            {
                $ObjectSearchByValue = $Name
                $TargetSearchByValue = $TargetName
            }
        }
        # Set the $TypePlural to use the plural version of value
        $TypePlural = $JCAssociationType.Plural
        # Get Object.
        $Objects = Get-JCObject -Type:($TypePlural) -SearchBy:($SearchBy) -SearchByValue:($ObjectSearchByValue)
        If ($Objects.Count -gt 1)
        {
            Write-Warning -Message:('Found ' + [string]$Objects.Count + ' ' + $TypePlural + ' with the ' + $SearchBy.Replace('By', '').ToLower() + ' of "' + $ObjectSearchByValue + '"!')
        }
        ForEach ($Info In $Objects)
        {
            $Id = $Info.($Info.ById)
            $Name = $Info.($Info.ByName)
            #Build Url
            $URL_Template_Associations = '/api/v2/{0}/{1}/associations?targets={2}'
            $Uri_Associations = $URL_Template_Associations -f $TypePlural, $Id, $TargetType
            # Exceptions for specific combinations
            If (($TypePlural -eq 'usergroups' -and $TargetType -eq 'user') -or ($TypePlural -eq 'systemgroups' -and $TargetType -eq 'system'))
            {
                $URL_Template_Associations = '/api/v2/{0}/{1}/members'
                $Uri_Associations = $URL_Template_Associations -f $TypePlural, $Id
            }
            If ( $Action -eq 'get' -and ($TypePlural -eq 'systems' -and $TargetType -eq 'system_group') -or ($TypePlural -eq 'users' -and $TargetType -eq 'user_group'))
            {
                $URL_Template_Associations = '/api/v2/{0}/{1}/memberof'
                $Uri_Associations = $URL_Template_Associations -f $TypePlural, $Id
            }
            If ($Action -eq 'get')
            {
                $Associations = Invoke-JCApi -Method:($Method) -Paginate:($true) -Url:($Uri_Associations)
                # If using a member* path then get the paths attribute
                If ($Uri_Associations -match 'memberof')
                {
                    $Associations = $Associations.Paths
                }
                # Get the input objects associations type
                $AssociationsTypes = $Associations.to.type | Select-Object -Unique
                ForEach ($AssociationsType In $AssociationsTypes)
                {
                    # Get the input objects associations id's that match the specific type
                    $AssociationsByType = ($Associations | Where-Object {$_.to.Type -eq $AssociationsType})
                    # Get all target objects of that specific type and then filter them by id
                    $Targets = If (!($HideTargetData)) {Get-JCObject -Type:($AssociationsType) | Where-Object {$_.($_.ById) -in $AssociationsByType.to.id}}
                    # Get Target object ids associated with Object
                    ForEach ($AssociationTarget In $AssociationsByType)
                    {
                        $Attributes = $AssociationTarget.attributes
                        $AssociationTargetTo = $AssociationTarget.to
                        $TargetAttributes = $AssociationTargetTo.attributes
                        $TargetId = $AssociationTargetTo.id
                        $TargetType = $AssociationTargetTo.type
                        $ResultRecord = [PSCustomObject]@{
                            'Type'       = $TypePlural;
                            'Id'         = $Id;
                            'Name'       = $Name;
                            'Attributes' = $Attributes;
                            'Info'       = $Info;
                            'TargetType' = $TargetType;
                            'TargetId'   = $TargetId;
                        }
                        If (!($HideTargetData))
                        {
                            # Find specific target object
                            $TargetInfo = $Targets | Where-Object {$_.($_.ById) -eq $TargetId}
                            Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetName') -Value:($TargetInfo.($TargetInfo.ByName))
                        }
                        Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetAttributes') -Value:($TargetAttributes)
                        If (!($HideTargetData)) {Add-Member -InputObject:($ResultRecord) -MemberType:('NoteProperty') -Name:('TargetInfo') -Value:($TargetInfo)}
                        # Output Object and Target
                        $Results += $ResultRecord
                    }
                }
            }
            Else
            {
                # Get Target object.
                $Target = Get-JCObject -Type:($TargetType) -SearchBy:($SearchBy) -SearchByValue:($TargetSearchByValue)
                $TargetId = $Target.($Target.ById)
                $TargetName = $Target.($Target.ByName)
                # Exceptions for specific combinations
                If (($TypePlural -eq 'systems' -and $TargetType -eq 'system_group') -or ($TypePlural -eq 'users' -and $TargetType -eq 'user_group'))
                {
                    $URL_Template_Associations = '/api/v2/{0}/{1}/members'
                    $Uri_Associations = $URL_Template_Associations -f $Target.Plural, $TargetId
                    $JsonBody = '{"op":"' + $Action + '","type":"' + $Info.Singular + '","id":"' + $Id + '","attributes":null}'
                }
                Else
                {
                    # Build body to be sent to endpoint.
                    $JsonBody = '{"op":"' + $Action + '","type":"' + $Target.Singular + '","id":"' + $TargetId + '","attributes":null}'
                }
                # Send body to endpoint.
                Write-Verbose ("$Action association from '$Name' to '$TargetName'")
                $Results += Invoke-JCApi -Body:($JsonBody) -Method:($Method) -Url:($Uri_Associations)
            }
        }
    }
    End
    {
        Return $Results
    }
}