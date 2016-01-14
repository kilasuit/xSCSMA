data LocalizedData  
{  
    # culture="en-US"  
    ConvertFrom-StringData -StringData @'  
 VariableDoesNotMatch = variable {0} has value {1} expected {2}.  
 VariableDescriptionDoesNotMatch = variable {0} has description {1} expected {2}.
 VariableNotFound = Failed to find variable {0}.
'@  
} 

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $value,

        [System.String]
        $Description,

        [parameter(Mandatory = $true)]
        [System.String]
        $WebServiceEndpoint,

        [System.UInt32]
        $Port = 9090
    )
    
    $Set = $true
    try
    {
        $variable = Get-SmaVariable -Name $Name -WebServiceEndpoint $webserviceendpoint -port $port -ErrorAction Stop

        # check variable value match
        if($variable.Value -ne $value)
        {
            Write-Verbose ( $($LocalizedData.VariableDoesNotMatch) -f $Name, $variable.Value, $value)
            $Set = $false
        }

        # check description match
        if($variable.Description -ne $Description )
        {
            # check description are not supposed to be empty
            if( !(($variable.Description -eq $null) -and ($Description -eq ""))  )
            {
                Write-Verbose ( $($LocalizedData.VariableDescriptionDoesNotMatch) -f $Name, $variable.Description, $Description)
                $Set = $false
            }
        }
    }
    catch
    {
        Write-Verbose ( $($LocalizedData.VariableNotFound) -f $Name)
        $Set = $false
    }
    
    $returnValue = @{
        Name = [System.String]$Name
        value = [System.String]$value
        Description = [System.String]$Description
        Set = [System.Boolean]$Set
        WebServiceEndpoint = [System.String]$WebServiceEndpoint
        Port = [System.UInt32]$Port
    }

    $returnValue
}


function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $value,

        [System.String]
        $Description,

        [parameter(Mandatory = $true)]
        [System.String]
        $WebServiceEndpoint,

        [System.UInt32]
        $Port = 9090
    )

    Set-SmaVariable -Name $Name -Value $value -Description $Description -WebServiceEndpoint $webserviceendpoint -port $port -ErrorAction Stop
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory = $true)]
        [System.String]
        $Name,

        [parameter(Mandatory = $true)]
        [System.String]
        $value,

        [System.String]
        $Description,

        [parameter(Mandatory = $true)]
        [System.String]
        $WebServiceEndpoint,

        [System.UInt32]
        $Port = 9090
    )
    
    return (Get-TargetResource @PSBoundParameters).Set -eq $true
}


Export-ModuleMember -Function Get-TargetResource, Set-TargetResource, Test-TargetResource

