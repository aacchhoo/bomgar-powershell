# This to create an account in Bomgar Managed password store
# Also then permisson the group that can manage it.
#
# created  Date:- 20191101
#

Get-Module -Name LSClientAgentCommandlets

##setup client settings on server
#Set-LSClientSettings -CustomPort 443 -EnableWebService 1 -IntegratedAuth 1 -Page /clientagentrequests.asp -SSLEnabled 1 -VerboseLogging 0 -WebserverName bomgar-uat.domain.com -WebServiceAddress https://<servername>.domain.com/erpmwebservice/authservice.svc
#$tok = Get-LSLoginToken -Password ******** -Username service_bomgar_uat_api

# service_bomgar_uat_api is the service account that has grant all access in the "web application  global delegation permissions"
$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist (Get-Credential -Credential "service_bomgar_uat_api")

$tok = Get-LSLoginToken -Credential $cred

### Creating an account in bomgar ###
##In managed area... import file looks like this
##System_Name,InstanceName,Namespace,AccountName,Password,Comment,AssetTag,
##domain.com,,DomainAD,_powershell_import1,import1,Test fake AD Import,,


$sSystemName = 'domain.com'
$sNamespace = 'DomainAD' # netbios domain name
$sAccountName = '_powershell_import1' # Account name to add
$sPass = 'import2' # password for the account
$sComment = 'Test powershell import 1'
$sGroupName = ''
$sAssetTag = ''

$sIdentityName = 'DomainAD\ManagedPassword Grp developers'


if ((Get-LSListAvailableAccounts -AuthenticationToken $tok -Search $sAccountName)){
    Write-Output "account $sAccountName found in Bomgar" 
    }
    Else
    {
    Write-Output "not found.... creating"
    Set-LSPassword -AccountName $sAccountName -AssetTag $sAssetTag -AuthenticationToken $tok -Comment $sComment -GroupName $sGroupName -Namespace $sNamespace -Password $sPass -SystemName $sSystemName

    }



## Creating a Deligation on that above account for DomainName\ManagedAccount Group
$tok = Get-LSLoginToken -Credential $cred


$PAPerm = New-Object –TypeName RouletteWebService.DelegationPermissionOnAccount
$PAPerm.IdentityName = $sIdentityName 
$PAPerm.SystemName = $sSystemName
$PAPerm.NameSpace = $sNamespace
$PAPerm.AccountName = $sAccountName
$PAPerm.AlertForIncident = 0
$PAPerm.AlertForChange = 0
$PAPerm.PermissionViewAccounts = 1
$PAPerm.PermissionViewPasswords = 1
$PAPerm.PermissionRequestPasswords = 0
$PAPerm.PermissionGrantPasswordRequests = 1
$PAPerm.PermissionAllowRemoteSessions = 1

Set-LSDelegationPermissionOnAccount -AuthenticationToken $tok -PermissionOnAccount $PAPerm
