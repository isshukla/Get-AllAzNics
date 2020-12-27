
<#
 .Synopsis
  List All NICs in a Subscription along with few other details like SubnetNSG,VNET,Location,UDR,ResourceGroup,Subscription,etc.
  
 .Description
  List All NICs in a Subscription along with few other details like SubnetNSG,VNET,Location,UDR,ResourceGroup,Subscription,etc.
  
 .Parameter
  None.
  
 .Example
   #List All NICs and few other details for a Subscription.
   Get-AllAzNics
#>

#------------------------------------------------------------------------------
#
#
# THIS CODE AND ANY ASSOCIATED INFORMATION ARE PROVIDED “AS IS” WITHOUT
# WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT
# LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS
# FOR A PARTICULAR PURPOSE. THE ENTIRE RISK OF USE, INABILITY TO USE, OR
# RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
#
#------------------------------------------------------------------------------

Function Get-AllAzNics (){

Param ()

$vmname = @()
$nsgobj = @()
$rg = @()
$getsubpernic = @()

$getnic = Get-AzureRmNetworkInterface
$date = (get-date).ToUniversalTime()

If((Get-Module Split-AzResourceID -ListAvailable) -eq $null){
Write-Host "Split-AzResourceID module is required to run this module. Installing Split-AzResourceID module"
Install-Module -Name Split-AzResourceID -MinimumVersion 2.1 -Scope CurrentUser 
}


$vmname = $getnic | ForEach-Object {$_.VirtualMachine.Id -replace ".*/"}
$rgvnet = $getnic | ForEach-Object {$_.IpConfigurations.subnet.id   -replace ".*/resourcegroups/" -replace "/providers/.*"}
$rg = $getnic | ForEach-Object {$_.ResourceGroupName}



For ($i=0; $i -lt $getnic.Count; $i++){

$getsubpernic += Get-AzVirtualNetworkSubnetConfig -ResourceId $getnic[$i].IpConfigurations[0].subnet.id

}




For ($i=0; $i -lt $getnic.Count; $i++){


$hash =  [ordered]@{

    NICName 					= $getnic[$i].Name
    ResourceGroupName 			= $getnIC[$I].ResourceGroupName
    Subscription 				= $(($getnic[$i].Id | Split-AzResourceID).subscription)
    Location 					= $getnic[$i].Location
    VM 							= $vmname[$i]
    PrivateIPs					= $getnic[$i].IpConfigurations.privateipaddress
    Subnet  					= $getnic[$i].IpConfigurations.subnet.id             
    VNET 						= $(($getnic[$i].IpConfigurations.subnet.id | Split-AzResourceID).resourcename) 
    NicDNS 						= $getnic[$i].DnsSettings.DnsServers
    VMid 						= $getnic[$i].VirtualMachine.Id 
    ApplicationGateway 			= $getnic[$i].IpConfigurations.ApplicationGatewayBackendAddressPools.id
    LoadBalancer 				= $getnic[$i].IpConfigurations.LoadBalancerBackendAddressPools.id
    #VNETDNS 					= ''
    NicNSG 						= $getnic[$i].NetworkSecurityGroup.Id
    EnableIPForwarding 			= $getnic[$i].EnableAcceleratedNetworking
    SubnetNSG 					= $getsubpernic[$i].NetworkSecurityGroup.id                     
    EnableAcceleratedNetworking = $getnic[$i].EnableAcceleratedNetworking
    SubnetUDR 					= $getsubpernic[$i].routetable.id              
    ProvisioningState 			= $getnic[$i].ProvisioningState
    PrivateEndPointFQDNs 		= $getnic[$i].IpConfigurations.PrivateLinkConnectionProperties.Fqdns
    PrivateEndPointGroupID 		= $getnic[$i].IpConfigurations.PrivateLinkConnectionProperties.GroupID
    ServiceEndpoints            = $getsubpernic[$i].ServiceEndpoints
    MacAddress                  = $getnic[$i].MacAddress
    Date 						= $date

} 


$nsgobj += New-Object PSObject  -Property $hash

} 

# Output
$nsgobj


####

}


#Export-ModuleMember -Function  Get-AllAzNics
