$creds = Get-Credential
$user = $creds.UserName
$password = $creds.GetNetworkCredential().password

$url = “https://<nexpose:port>/api/3/assets/34886”  #note:  this is to pull down the info for a single host with an assetid of 34886, just as a simple test)

$usercreds = "${user}:${password}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($usercreds)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$header = @{Authorization = $basicAuthValue}

$resp = Invoke-WebRequest -Method Get -Uri $url -Headers $header 
