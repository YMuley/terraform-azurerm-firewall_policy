# --------- firewall ------------
resource "azurerm_firewall_policy" "azure_firewall_policy" {
    for_each            = local.azure_firewall_policy
        name                = each.value.name
        resource_group_name = var.resource_group_output[each.value.resource_group_name].name
        location            = each.value.location == null ? var.default_values.location : each.value.location
        #base_policy_id     =  each.value.base_policy_id
        private_ip_ranges   = length(each.value.private_ip_ranges) == 0 ? null : each.value.private_ip_ranges
        auto_learn_private_ranges_enabled = each.value.auto_learn_private_ranges_enabled
        sku = each.value.sku
        threat_intelligence_mode  = each.value.threat_intelligence_mode == null ? "Alert" :  each.value.threat_intelligence_mode
        sql_redirect_allowed  =  each.value.sql_redirect_allowed 
       

        dynamic "dns" {
            for_each =   each.value.dns
            content{
                proxy_enabled = dns.value.proxy_enabled == null ? false : dns.value.proxy_enabled
                servers = dns.value.servers
            }          
        }

        dynamic "identity" {
            for_each = length(each.value.identity) == 0 ? [] : [{}]
            content{
                type = "UserAssigned"
                identity_ids = flatten([for user_identity in var.user_identity_output : user_identity.id if contains(each.value.identity ,user_identity.name ) == true ])
            }          
        }
        
        # dynamic "insights" {
        #     for_each = each.value.insights
        #     content{
        #         enabled  = insights.value.enabled
        #         default_log_analytics_workspace_id = var.log_analytics_workspace_output[insights.value.default_log_analytics_workspace_name].id
        #         retention_in_days  =  insights.value.retention_in_days
        #         dynamic "log_analytics_workspace" {
        #             for_each = insights.value.log_analytics_workspace
        #             content{
        #                 id = var.log_analytics_workspace_output[log_analytics_workspace.value.log_analytics_workspace_name].id
        #                 firewall_location  = log_analytics_workspace.value.firewall_location
        #             }
        #         } 
        #     }          
        # }

        dynamic "intrusion_detection" {
            for_each = each.value.intrusion_detection 
            content{ 
                mode = intrusion_detection.value.mode
                private_ranges  = intrusion_detection.value.private_ranges

                dynamic "signature_overrides"{
                    for_each = intrusion_detection.value.signature_overrides
                    content{
                        id = signature_overrides.value.id
                        state = signature_overrides.value.state
                    }
                }
                 
                dynamic "traffic_bypass"{
                    for_each = intrusion_detection.value.traffic_bypass
                    content{
                        name  = traffic_bypass.value.name
                        protocol   = traffic_bypass.value.protocol 
                        description  = traffic_bypass.value.description
                        destination_addresses  = length(traffic_bypass.value.destination_addresses) == 0 ? null : traffic_bypass.value.destination_addresses
                        destination_ip_groups  =length(traffic_bypass.value.destination_ip_groups) == 0 ? null : traffic_bypass.value.destination_ip_groups
                        destination_ports  = length(traffic_bypass.value.destination_ports) == 0 ? null : traffic_bypass.value.destination_ports
                    }
                }
            }          
        }     

        
       dynamic "tls_certificate"  {
            for_each =  each.value.tls_certificate 
            content{
                key_vault_secret_id = format("https://%s.vault.azure.net/secrets/%s",tls_certificate.value.Key_vault_name,tls_certificate.value.secret_name)
                name = format("tls_certificate_name_%s_%s",tls_certificate.value.Key_vault_name,tls_certificate.value.key_vault_secret_name)
            }
        } 
         
        # dynamic "explicit_proxy"  {
        #     for_each =  each.value.explicit_proxy
        #     content{
        #        enabled = explicit_proxy.value.enabled
        #        http_port  = explicit_proxy.value.http_port 
        #        https_port  = explicit_proxy.value.https_port 
        #        enable_pac_file  = explicit_proxy.value.enable_pac_file 
        #        pac_file_port = explicit_proxy.value.pac_file_port
        #        pac_file = explicit_proxy.value.pac_file
        #     }

        # } 
         
        dynamic "threat_intelligence_allowlist"  {
            for_each = each.value.threat_intelligence_allowlist
            content{
               fqdns = threat_intelligence_allowlist.value.fqdns
               ip_addresses  = threat_intelligence_allowlist.value.ip_addresses
            }
        } 

        
        tags                = each.value.tags == null ? var.default_values.tags : each.value.tags

}

