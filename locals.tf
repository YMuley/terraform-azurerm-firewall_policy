locals {   
    azure_firewall_policy = { for azure_firewall_policy in var.azure_firewall_policy_list: azure_firewall_policy.name  => azure_firewall_policy }     
}