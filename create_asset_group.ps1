#word of warning.  if you are unaccustomed to dealing with json, it is CaSE sEnSitiVE.
#nexpose expects all keys/names to be in all lower case.  

$uri = "https://<nexpose url>/api/3/asset_groups"

# you will need to use get-credential or fetch from a secure password file
$pair = "${user}:${password}"
$bytes = [System.Text.Encoding]::ASCII.GetBytes($pair)
$base64 = [System.Convert]::ToBase64String($bytes)
$basicAuthValue = "Basic $base64"
$header = @{Authorization = $basicAuthValue}

#if you're adding hosts by hostname or IP address, it would be pretty simple to read them from a CSV and iterate through, inserting a new 
#hashtable into the "$filters" array below
#of course, creating a DAG by hostname is not a useful way to do things for most purposes
#read the Nexpose APIv3 documentation if you don't already have ideas on the filtering you need to do
$pc = "joeblow-pc"
$pc1 = "janedoe-pc1"
$pc2 = "utility-server"

#the list of filter combos is mind-boggling.  check the Nexpose APIv3 documentation.
$filters = @()
$filters += @{"field"="host-name";"operator"="contains";"value"="$pc"}
$filters += @{"field"="host-name";"operator"="contains";"value"="$pc1"}
$filters += @{"field"="host-name";"operator"="contains";"value"="$pc2"}

#create a hash table of hash tables and arrays, then convert it to json on the invoke-restmethod
#you can omit "[ordered]", but by default, posh does not preserve order when adding elements to a hash table
#you could create "1,2,3,4,5" and when you ask for it back from posh, you might get "2,5,3,1,4"
#nexpose doesnt care, but it will help debugging if you get a 400 response back from the nexpose server
$body = [ordered]@{}
$body.Add("description","apiv3 test")
$body.Add("name","DAG test")
$body.Add("searchcriteria",[ordered]@{})
$body.searchcriteria.Add("filters",$filters)
$body.searchcriteria.Add("match","any")
$body.Add("type","dynamic")


try
{
    #critical piece here - the "-depth" switch.  by default, posh will only convert the first 2 levels of a hash table to json
    #it will render the rest as system.hashtable.object or something like that.  you have to know before hand how deep your hash table
    #goes, then supply the appropriate value here
    $response = Invoke-RestMethod -Method POST -Uri $uri -Headers $header -Body $($body | ConvertTo-Json -Depth 3) -ContentType "application/json"
    #do whatever you need to do with response here - this is basic powershell and not in scope for these tutorials
}
#in case of an error, particularly error 400 (poorly formed/illegal json) or 500 (internal server error)
#unfortunately, there doesn't appear to be a way to force powershell to store the error response in the $response variable
catch
{
    $e = $_.exception
    $msg = $e.message
    while ($e.innerexception)
    {
        $e = $e.innerexception
        $msg += "`n" + $e.message
    }
    $msg
}

**************************************************************************************************
the above script will produce a json object that looks like this
{
    "description":  "apiv3 test",
    "name":  "DAG test",
    "searchcriteria":  {
                           "filters":  [
                                           {
                                               "field":  "host-name",
                                               "operator":  "contains",
                                               "value":  "joeblow-pc"
                                           },
                                           {
                                               "field":  "host-name",
                                               "operator":  "contains",
                                               "value":  "janedoe-pc1"
                                           },
                                           {
                                               "field":  "host-name",
                                               "operator":  "contains",
                                               "value":  "utility-server"
                                           }
                                       ],
                           "match":  "any"
                       },
    "type":  "dynamic"
}
