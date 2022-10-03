$resourceGroupName = ""
$nsgName = "nsg"
$ruleName = ""
$ruleDesc = "Allow RDP from my Home PC"
$rulePort = 3389
$myIp = (Invoke-WebRequest -uri "http://ifconfig.me/ip").Content

function AddOrUpdateRDPRecord {
    Process {
        #$nsg = Get-AzNetworkSecurityGroup -Name $_
        $nsg = Get-AzNetworkSecurityGroup -Name $nsgName -ResourceGroupName $resourceGroupName
        $ruleExists = (Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg).Name.Contains($ruleName);

        if($ruleExists)
        {
            # Update the existing rule with the new IP address
            $existingSourceIp = (Get-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg -Name $ruleName).SourceAddressPrefix
            ($nsg.SecurityRules | Where-Object {$_.Name -eq $ruleName}).SourceAddressPrefix = ([System.String[]] @($existingSourceIp, $myIp))
        }
        else
        {
            # Create a new rule
            $nsg | Add-AzNetworkSecurityRuleConfig `
                -Name $ruleName `
                -Description $ruleDesc `
                -Access Allow `
                -Protocol TCP `
                -Direction Inbound `
                -Priority 100 `
                -SourceAddressPrefix $myIp `
                -SourcePortRange * `
                -DestinationAddressPrefix * `
                -DestinationPortRange $rulePort
        }

        # Save changes to the NSG
        $nsg | Set-AzNetworkSecurityGroup
    }
}

# Connect-AzAccount
# Azure

# Step 1: Update the NSG for RDP Access 
$nsgName | AddOrUpdateRDPRecord
