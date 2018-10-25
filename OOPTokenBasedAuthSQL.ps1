$tenantName   = "{AAD DIRECTORY ID}"                                                # Tenant Name this is found in AAD > Properties > Directory ID
$clientId     = "{APPLICATION ID}"                                                  # Application ID is found in AAD > App Registrations > Application ID
$redirectUri  = "{REDIRECT URI}"                                                 # Rediret URI is found in AAD > App Registrations > Settings > Redirect URIs
$resourceUri  = "https://database.windows.net/"                                     # Resource URI > Found in AAD > App Registrations > Settings > Required Permissions >
                                                                                    # Add > Search Bar *Type in* > Azure SQL DB > Add Rights > OK > OK > Grant permissions
$authorityUri = "https://login.microsoftonline.com/$tenantName"                     # Authority URI https://login.microsoftonline.com/{DirectoryId|TenantName}

# Credit to Ray Held for this function, great stuff! 
function GetAuthToken {

    # 64 bit make sure to change the version to the one available on your machine
    $adalPath  = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\5.5.1"

    # 32 bit uncomment if this is your scenario
    # adalPath  = "${env:ProgramFiles(x86)}\WindowsPowerShell\Modules\AzureRM.profile\5.3.4"

    $adal      = "$adalPath\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
    $adalforms = "$adalPath\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"
        
    [System.Reflection.Assembly]::LoadFrom($adal) | Out-Null
    [System.Reflection.Assembly]::LoadFrom($adalforms) | Out-Null 
        
    $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authorityUri
    $authResult = $authContext.AcquireToken($resourceUri, $clientId, $redirectUri, "Always")   # Not sure when to use AcquireToken() or AcquireTokenAsync()
         
    return $authResult
}

# Call GetAuthToken to acquire token based on credentials entered in prompt
$authResult = GetAuthToken
$authResult.AccessToken

# Server name, database name and the connection string that will be used to open connection
$sqlServerUrl = "fcobo.database.windows.net"
$database = "fcobo"
$connectionString = "Server=tcp:$sqlServerUrl,1433;Initial Catalog=$database;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;"

# Create the connection object
$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

# Set AAD generated token to SQL connection token
$connection.AccessToken = $authResult.AccessToken
$connection.AccessToken

# prints the connection information, it's still closed at this point, will open later on. The token is already attached.
$connection 

# Query that will be sent when the connection is open. I had a 4,000 record table and I was able to truncate with this script
$query = "TRUNCATE TABLE TEST1"

# Opens connection to Azure SQL Database and executes a query
$connection.Open()
# After this, the token is no longer there, I believe this is because the authentication went through already, so it gets rid of it. 
$connection
$command = New-Object -Type System.Data.SqlClient.SqlCommand($query, $connection)
$command.ExecuteNonQuery()
$connection.Close()
