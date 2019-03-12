Function Get-JCObject
{
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    Param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 1, ParameterSetName = 'ByValue')][ValidateNotNullOrEmpty()][ValidateSet('ById', 'ByName')][string]$SearchBy,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, Position = 2, ParameterSetName = 'ByValue', HelpMessage = 'Specify the item which you want to search for. Supports wildcard searches using: *')][ValidateNotNullOrEmpty()][string]$SearchByValue,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 3, HelpMessage = 'An array of the fields/properties/columns you want to return from the search.')][ValidateNotNullOrEmpty()][array]$Fields = @(),
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 4)][ValidateNotNullOrEmpty()][ValidateRange(1, [int]::MaxValue)][int]$Limit = 100,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 5)][ValidateNotNullOrEmpty()][ValidateRange(0, [int]::MaxValue)][int]$Skip = 0,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, Position = 6)][switch]$ReturnHashTable
    )
    DynamicParam
    {
        $ObjectType = Get-JCObjectType
        # Build parameter array
        $RuntimeParameterDictionary = New-Object -TypeName System.Management.Automation.RuntimeDefinedParameterDictionary
        New-DynamicParameter -Name:('Type') -Type:([System.String]) -Mandatory -Position:(0) -ValueFromPipelineByPropertyName -ValidateNotNullOrEmpty -ValidateSet:($ObjectType.Types) -RuntimeParameterDictionary:($RuntimeParameterDictionary) | Out-Null
        Return $RuntimeParameterDictionary
    }
    Begin
    {
        # Create new variables for script
        $PsBoundParameters.GetEnumerator() | ForEach-Object {New-Variable -Name:($_.Key) -Value:($_.Value) -Force}
        Write-Debug ('[CallFunction]' + $MyInvocation.MyCommand.Name + ' ' + ($PsBoundParameters.GetEnumerator() | Sort-Object Key | ForEach-Object { '-' + $_.Key + ":('" + ($_.Value -join "','").Replace("'True'", '$True').Replace("'False'", '$False') + "')"}) )
        If ($PSCmdlet.ParameterSetName -ne '__AllParameterSets') {Write-Verbose ('[ParameterSet]' + $MyInvocation.MyCommand.Name + ':' + $PSCmdlet.ParameterSetName)}
        $CurrentErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'
    }
    Process
    {
        Try
        {
            # Identify the command type to run to get the object for the specified item
            $ObjectTypeItem = $ObjectType | Where-Object {$Type -in $_.Types}
            If ($ObjectTypeItem)
            {
                $ObjectTypeItem.Types = $Type
                $Singular = $ObjectTypeItem.Singular
                $Plural = $ObjectTypeItem.Plural
                $UrlOrg = $ObjectTypeItem.Url
                $Url = $ObjectTypeItem.Url
                $Method = $ObjectTypeItem.Method
                $ById = $ObjectTypeItem.ById
                $ByName = $ObjectTypeItem.ByName
                $Paginate = $ObjectTypeItem.Paginate
                $SupportRegexFilter = $ObjectTypeItem.SupportRegexFilter
                $Limit = $ObjectTypeItem.Limit
                # If searching ByValue add filters to query string and body.
                If ($PSCmdlet.ParameterSetName -eq 'ByValue')
                {
                    $QueryStrings = @()
                    $BodyParts = @()
                    # Determine search method
                    $PropertyIdentifier = Switch ($SearchBy)
                    {
                        'ById' {$ObjectTypeItem.ById};
                        'ByName' {$ObjectTypeItem.ByName};
                    }
                    # Populate Url placeholders. Assumption is that if an endpoint requires an Id to be passed in the Url that it does not require a filter because its looking for an exact match already.
                    If ($Url -match '({)(.*?)(})')
                    {
                        Write-Verbose ('Populating ' + $Matches[0] + ' with ' + $SearchByValue)
                        $Url = $Url.Replace($Matches[0], $SearchByValue)
                    }
                    Else
                    {
                        Switch ($SearchBy)
                        {
                            'ById'
                            {
                                $Url = $Url + '/' + $SearchByValue
                            }
                            'ByName'
                            {
                                # Add filters for exact match and wildcards
                                If ($SearchByValue -match '\*')
                                {
                                    If ($SupportRegexFilter)
                                    {
                                        $BodyParts += ('"filter":[{"' + $PropertyIdentifier + '":{"$regex": "(?i)(' + $SearchByValue.Replace('*', ')(.*?)(') + ')"}}]').Replace('()', '')
                                    }
                                    Else
                                    {
                                        Write-Error ('The endpoint ' + $Url + ' does not support wildcards in the $SearchByValue. Please remove "*" from "' + $SearchByValue + '".')
                                    }
                                }
                                Else
                                {
                                    $QueryStrings += 'filter=' + $PropertyIdentifier + ':eq:' + $SearchByValue
                                    $BodyParts += '"filter":[{"' + $PropertyIdentifier + '":"' + $SearchByValue + '"}]'
                                }
                            }
                        }
                    }
                    # Build query string and body
                    $JoinedQueryStrings = $QueryStrings -join '&'
                    $JoinedBodyParts = $BodyParts -join ','
                    # Build final body and url
                    If ($JoinedBodyParts)
                    {
                        $Body = '{' + $JoinedBodyParts + '}'
                    }
                    If ($JoinedQueryStrings)
                    {
                        $Url = $Url + '?' + $JoinedQueryStrings
                    }
                }
                ## Escape Url????
                # $Url = ([uri]::EscapeDataString($Url)
                # Run command
                # Hacky logic to get g_suite directories
                If ($Type -in ('gsuites', 'g_suite'))
                {
                    $Results = Invoke-JCApi -Url:($UrlOrg) -Method:($Method) -Body:($Body) -Fields:($Fields) -Limit:($Limit) -Skip:($Skip) -Paginate:($Paginate)
                    $Results = $Results | Where-Object {$_.Type -eq 'g_suite'}
                }
                # Hacky logic to get office_365 directories
                ElseIf ($Type -in ('office365s', 'office_365'))
                {
                    $Results = Invoke-JCApi -Url:($UrlOrg) -Method:($Method) -Body:($Body) -Fields:($Fields) -Limit:($Limit) -Skip:($Skip) -Paginate:($Paginate)
                    $Results = $Results | Where-Object {$_.Type -eq 'office_365'}
                }
                Else
                {
                    # Normal logic
                    If ($ReturnHashTable)
                    {
                        $Key = If ($PropertyIdentifier) {$PropertyIdentifier} Else {$ById}
                        $Results = Get-JCHash -Url:($Url) -Method:($Method) -Body:($Body) -Key:($Key) -Values:($Fields) -Limit:($Limit) -Skip:($Skip)
                    }
                    Else
                    {
                        $Results = Invoke-JCApi -Url:($Url) -Method:($Method) -Body:($Body) -Fields:($Fields) -Limit:($Limit) -Skip:($Skip) -Paginate:($Paginate)
                    }
                }
                If ($Results)
                {
                    # Update results
                    $Results | ForEach-Object {
                        # Create the default property display set
                        $defaultDisplayPropertySet = New-Object System.Management.Automation.PSPropertySet('DefaultDisplayPropertySet', [string[]]$_.PSObject.Properties.Name)
                        $PSStandardMembers = [System.Management.Automation.PSMemberInfo[]]@($defaultDisplayPropertySet)
                        # Add the list of standard members
                        Add-Member -InputObject:($_) -MemberType:('MemberSet') -Name:('PSStandardMembers') -Value:($PSStandardMembers)
                        # Add ById and ByName as hidden properties to results
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('ById') -Value:($ById)
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('ByName') -Value:($ByName)
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('Singular') -Value:($Singular)
                        Add-Member -InputObject:($_) -MemberType:('NoteProperty') -Name:('Plural') -Value:($Plural)
                    }
                }
                Else
                {
                    Write-Verbose ('No results found.')
                }
            }
            Else
            {
                Write-Error ('$Type of "' + $Type + '" not found. $Type must be:' + ($ObjectType.Types -join ','))
            }
        }
        Catch
        {
            $Exception = $_.Exception
            $Message = $Exception.Message
            While ($Exception.InnerException)
            {
                $Exception = $Exception.InnerException
                $Message += "`n" + $Exception.Message
            }
            Write-Error ($_.FullyQualifiedErrorId.ToString() + "`n" + $_.InvocationInfo.PositionMessage + "`n" + $Message)
        }
    }
    End
    {
        $ErrorActionPreference = $CurrentErrorActionPreference
        Return $Results
    }
}