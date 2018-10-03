$tenantName   = "{TENANT ID}"
$applicationId     = "{APPLICATION ID}"
$redirectUri  = "http://localhost/"                                
$resourceUri  = "https://database.windows.net/"                
$authorityUri = "https://login.microsoftonline.com/$tenantName"
$sqlServerUrl = "{SERVERNAME}.database.windows.net"
$database = "{DATABASENAME}"
$tablename = "PSAADTokenBasedTable"
function GetAuthToken{
     
    #64
     $adalPath64  = "${env:ProgramFiles}\WindowsPowerShell\Modules\AzureRM.profile\5.5.1"
     $adalDll64 = "$adalPath64\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
     $adalForms64 = "$adalPath64\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"   
     [System.Reflection.Assembly]::LoadFrom($adalDll64) | Out-Null
     [System.Reflection.Assembly]::LoadFrom($adalForms64) | Out-Null 

     <#32
     $adalPath32  = "${env:ProgramFiles(x86)}\WindowsPowerShell\Modules\AzureRM.profile\4.6.0"
     $adalDll32 = "$adalPath32\Microsoft.IdentityModel.Clients.ActiveDirectory.dll"
     $adalForms32 = "$adalPath32\Microsoft.IdentityModel.Clients.ActiveDirectory.WindowsForms.dll"   
     [System.Reflection.Assembly]::LoadFrom($adalDll32) | Out-Null
     [System.Reflection.Assembly]::LoadFrom($adalForms32) | Out-Null#>
     
     $authContext = New-Object "Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext" -ArgumentList $authorityUri
     $authToken = $authContext.AcquireToken($resourceUri, $applicationId, $redirectUri, "Always")
          
     return $authToken.AccessToken
}

$authToken = GetAuthToken
$authToken | Out-File -FilePath "C:\AuthToken.txt"

$tokenPath = "C:\AuthToken.txt"
$tokenText = [IO.File]::ReadAllText($tokenPath)
$tokenText

$connectionString = "Server=tcp:$sqlServerUrl,1433;Initial Catalog=$database;Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;"

$connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)

$connection.AccessToken = $authToken

$connection | Out-File -FilePath "C:\ConnectionStats.txt"
$sqlQuery = "CREATE TABLE $tablename(id int)"

$connection.Open()
$command = New-Object -Type System.Data.SqlClient.SqlCommand($sqlQuery, $connection)
$command.ExecuteNonQuery()
$connection.Close()