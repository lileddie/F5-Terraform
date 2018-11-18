# Building a Basic F5 VIP with Terraform

Getting you started automating your VIP builds with Terraform.  This is not a best practices doc but a quick-and-dirty HOW-TO.

## What'cha need?

To use Terraform you should have a firm grasp with using the command line interface and a dedicated Linux node that you regularly back-up and at least 1 F5 Appliance (Virtual or hardware) to accept your configuration commands.

### Configuration Prereqs

Unfortunately the F5 Terraform plugin, known as a Provider in TF speak, does not allow certificate based auth, so you should create dedicated TF credentials, or use a service account if you have one.  To ensure you configure the active node in an HA environment, allow port 443 on a firewall protected floating IP address and define that as the host.

## Allow Port 443 on the floating IP

ssh to the F5 node and allow port 443 to one of the floating IP addresses so we can connect to the active node:
~~~
modify net self 192.168.4.5 allow-service add { tcp:443 }
~~~

NOTE: In a production environment this Self-IP should be firewall protected if you are allowing logins from remote systems.  Whitelisting IPs of management servers is recommended.

### Build your stuff already

Install [Terraform](https://www.terraform.io/downloads.html) Please see link for newest version.
```
wget https://releases.hashicorp.com/terraform/0.11.10/terraform_0.11.10_linux_amd64.zip ; unzip terraform_0.11.10_linux_amd64.zip -d /usr/bin/
```
Clone this repo:
```
git clone git@github.com:lileddie/F5-Terraform.git
```

If you haven't have git/github, fret not!! git's easy.  Just follow this [link.](https://www.digitalocean.com/community/tutorials/how-to-contribute-to-open-source-getting-started-with-git)

Use the text editor of your choice, [Atom](https://flight-manual.atom.io/getting-started/sections/installing-atom/) is great, or vi, pico...

We have 2 separate projects created - intranet and www-static-content.  Edit intranet/terraform.tfvars adding your service account username, password, and the floating IP address you are allowing port 443 to connect to:
```
f5_host = "192.168.2.5" - CHANGE ME to your IP or hostname
f5_user = "terraform"   - CHANGE ME to your service account user
f5_pass = "T3rraform"   - CHANGE ME to your service account password
```
Can that really be it?

## Running the tests

From the intranet directory, initialize terraform, this will download the Terraform provider files needed to interact with your F5 appliance:
```
terraform init
```
Now run 'plan' to check your syntax and see what will be built:
```
terraform plan
```

If any errors, don't move forward, correct the syntax using [Terraform's documentation](https://www.terraform.io/docs/providers/bigip/)
If no errors, build your nodes, pool, and VIPs:
```
terraform apply
```
You should see 0 errors, your output should look similar to:

```
troy@ubuntu18:~/testF5/intranet$ terraform apply

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  + bigip_ltm_monitor.intranet
      id:                           <computed>
      destination:                  "*:80"
      interval:                     "15"
      ip_dscp:                      "0"
      manual_resume:                "disabled"
      name:                         "/Common/http_monitor_80"
      parent:                       "/Common/http"
      reverse:                      "disabled"
      send:                         "GET /status.html\\r\\n"
      time_until_up:                "0"
      timeout:                      "46"
      transparent:                  "disabled"

  + bigip_ltm_node.intra1
      id:                           <computed>
      address:                      "10.32.10.64"
      connection_limit:             "0"
      dynamic_ratio:                "0"
      name:                         "/Common/intra1"
      state:                        "user-up"

  + bigip_ltm_node.intra2
      id:                           <computed>
      address:                      "10.32.10.65"
      connection_limit:             "0"
      dynamic_ratio:                "0"
      name:                         "/Common/intra2"
      state:                        "user-up"

  + bigip_ltm_node.intra3
      id:                           <computed>
      address:                      "10.32.10.66"
      connection_limit:             "0"
      dynamic_ratio:                "0"
      name:                         "/Common/intra3"
      state:                        "user-up"

  + bigip_ltm_pool.intraPool
      id:                           <computed>
      allow_nat:                    "yes"
      allow_snat:                   "yes"
      load_balancing_mode:          "round-robin"
      monitors.#:                   "1"
      monitors.249948722:           "/Common/http_monitor_80"
      name:                         "/Common/intraPool"
      reselect_tries:               "0"
      service_down_action:          "none"
      slow_ramp_time:               "10"

  + bigip_ltm_pool_attachment.intra1
      id:                           <computed>
      node:                         "/Common/intra1:80"
      pool:                         "/Common/intraPool"

  + bigip_ltm_pool_attachment.intra2
      id:                           <computed>
      node:                         "/Common/intra2:80"
      pool:                         "/Common/intraPool"

  + bigip_ltm_pool_attachment.intra3
      id:                           <computed>
      node:                         "/Common/intra3:80"
      pool:                         "/Common/intraPool"

  + bigip_ltm_virtual_server.http
      id:                           <computed>
      client_profiles.#:            <computed>
      destination:                  "10.33.7.23"
      fallback_persistence_profile: <computed>
      ip_protocol:                  <computed>
      mask:                         "255.255.255.255"
      name:                         "/Common/intranet_http"
      persistence_profiles.#:       <computed>
      pool:                         "/Common/intraPool"
      port:                         "80"
      profiles.#:                   "1"
      profiles.576276785:           "/Common/http"
      server_profiles.#:            <computed>
      snatpool:                     <computed>
      source:                       "0.0.0.0/0"
      source_address_translation:   "automap"
      translate_address:            "enabled"
      translate_port:               "enabled"
      vlans_enabled:                <computed>

  + bigip_ltm_virtual_server.https
      id:                           <computed>
      client_profiles.#:            "1"
      client_profiles.3561477966:   "/Common/clientssl"
      destination:                  "10.33.7.23"
      fallback_persistence_profile: <computed>
      ip_protocol:                  <computed>
      mask:                         "255.255.255.255"
      name:                         "/Common/intranet_https"
      persistence_profiles.#:       <computed>
      pool:                         "/Common/intraPool"
      port:                         "443"
      profiles.#:                   "1"
      profiles.576276785:           "/Common/http"
      server_profiles.#:            <computed>
      snatpool:                     <computed>
      source:                       "0.0.0.0/0"
      source_address_translation:   "automap"
      translate_address:            "enabled"
      translate_port:               "enabled"
      vlans_enabled:                <computed>


Plan: 10 to add, 0 to change, 0 to destroy.

Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes

bigip_ltm_node.intra2: Creating...
  address:          "" => "10.32.10.65"
  connection_limit: "" => "0"
  dynamic_ratio:    "" => "0"
  name:             "" => "/Common/intra2"
  state:            "" => "user-up"
bigip_ltm_node.intra3: Creating...
  address:          "" => "10.32.10.66"
  connection_limit: "" => "0"
  dynamic_ratio:    "" => "0"
  name:             "" => "/Common/intra3"
  state:            "" => "user-up"
bigip_ltm_node.intra1: Creating...
  address:          "" => "10.32.10.64"
  connection_limit: "" => "0"
  dynamic_ratio:    "" => "0"
  name:             "" => "/Common/intra1"
  state:            "" => "user-up"
bigip_ltm_monitor.intranet: Creating...
  destination:   "" => "*:80"
  interval:      "" => "15"
  ip_dscp:       "" => "0"
  manual_resume: "" => "disabled"
  name:          "" => "/Common/http_monitor_80"
  parent:        "" => "/Common/http"
  reverse:       "" => "disabled"
  send:          "" => "GET /status.html\\r\\n"
  time_until_up: "" => "0"
  timeout:       "" => "46"
  transparent:   "" => "disabled"
bigip_ltm_node.intra2: Creation complete after 1s (ID: /Common/intra2)
bigip_ltm_node.intra1: Creation complete after 2s (ID: /Common/intra1)
bigip_ltm_node.intra3: Creation complete after 2s (ID: /Common/intra3)
bigip_ltm_monitor.intranet: Creation complete after 6s (ID: /Common/http_monitor_80)
bigip_ltm_pool.intraPool: Creating...
  allow_nat:           "" => "yes"
  allow_snat:          "" => "yes"
  load_balancing_mode: "" => "round-robin"
  monitors.#:          "" => "1"
  monitors.249948722:  "" => "/Common/http_monitor_80"
  name:                "" => "/Common/intraPool"
  reselect_tries:      "" => "0"
  service_down_action: "" => "none"
  slow_ramp_time:      "" => "10"
bigip_ltm_pool.intraPool: Creation complete after 3s (ID: /Common/intraPool)
bigip_ltm_pool_attachment.intra2: Creating...
  node: "" => "/Common/intra2:80"
  pool: "" => "/Common/intraPool"
bigip_ltm_virtual_server.https: Creating...
  client_profiles.#:            "0" => "1"
  client_profiles.3561477966:   "" => "/Common/clientssl"
  destination:                  "" => "10.33.7.23"
  fallback_persistence_profile: "" => "<computed>"
  ip_protocol:                  "" => "<computed>"
  mask:                         "" => "255.255.255.255"
  name:                         "" => "/Common/intranet_https"
  persistence_profiles.#:       "" => "<computed>"
  pool:                         "" => "/Common/intraPool"
  port:                         "" => "443"
  profiles.#:                   "0" => "1"
  profiles.576276785:           "" => "/Common/http"
  server_profiles.#:            "" => "<computed>"
  snatpool:                     "" => "<computed>"
  source:                       "" => "0.0.0.0/0"
  source_address_translation:   "" => "automap"
  translate_address:            "" => "enabled"
  translate_port:               "" => "enabled"
  vlans_enabled:                "" => "<computed>"
bigip_ltm_pool_attachment.intra3: Creating...
  node: "" => "/Common/intra3:80"
  pool: "" => "/Common/intraPool"
bigip_ltm_virtual_server.http: Creating...
  client_profiles.#:            "" => "<computed>"
  destination:                  "" => "10.33.7.23"
  fallback_persistence_profile: "" => "<computed>"
  ip_protocol:                  "" => "<computed>"
  mask:                         "" => "255.255.255.255"
  name:                         "" => "/Common/intranet_http"
  persistence_profiles.#:       "" => "<computed>"
  pool:                         "" => "/Common/intraPool"
  port:                         "" => "80"
  profiles.#:                   "0" => "1"
  profiles.576276785:           "" => "/Common/http"
  server_profiles.#:            "" => "<computed>"
  snatpool:                     "" => "<computed>"
  source:                       "" => "0.0.0.0/0"
  source_address_translation:   "" => "automap"
  translate_address:            "" => "enabled"
  translate_port:               "" => "enabled"
  vlans_enabled:                "" => "<computed>"
bigip_ltm_pool_attachment.intra1: Creating...
  node: "" => "/Common/intra1:80"
  pool: "" => "/Common/intraPool"
bigip_ltm_pool_attachment.intra3: Creation complete after 1s (ID: /Common/intraPool-/Common/intra3:80)
bigip_ltm_pool_attachment.intra1: Creation complete after 1s (ID: /Common/intraPool-/Common/intra1:80)
bigip_ltm_pool_attachment.intra2: Creation complete after 1s (ID: /Common/intraPool-/Common/intra2:80)
bigip_ltm_virtual_server.http: Creation complete after 9s (ID: /Common/intranet_http)
bigip_ltm_virtual_server.https: Creation complete after 9s (ID: /Common/intranet_https)

Apply complete! Resources: 10 added, 0 changed, 0 destroyed.
troy@ubuntu18:~/testF5/intranet$
```

Terraform will try to build each piece of config as quickly as it can, so it is important to utilize 'depends_on = []' if a resource cannot be created before another one has been built. BUT.

### Verify the VIPs are built correctly

Logging into your F5 appliance you should now see a VIP built named intranet_http and intranet_https.


### Note about Default Profiles

You may have noticed that we didn't have to define any of the default profiles used for our VIPs, such as or client TCP profile.  This is because Terraform assumes the default selections used in building a VIP with TMSH or the GUI.
```
ltm virtual intranet_http {
    creation-time 2018-11-13:20:20:49
    destination 10.33.7.23:http
    ip-protocol tcp
    last-modified-time 2018-11-13:20:20:52
    mask 255.255.255.255
    pool intraPool
    profiles {
        http { }
        tcp { }
    }
    source 0.0.0.0/0
    source-address-translation {
        type automap
    }
    translate-address enabled
    translate-port enabled
    vs-index 42
}
ltm virtual intranet_https {
    creation-time 2018-11-13:20:20:49
    destination 10.33.7.23:https
    ip-protocol tcp
    last-modified-time 2018-11-13:20:20:52
    mask 255.255.255.255
    pool intraPool
    profiles {
        clientssl {
            context clientside
        }
        http { }
        tcp { }
    }
    source 0.0.0.0/0
    source-address-translation {
        type automap
    }
    translate-address enabled
    translate-port enabled
    vs-index 43
}
```

## Importance of maintaining TF State

Terraform will give you errors if any of your syntax is off, but it WILL NOT roll back your config.  If your monitor was good, nodes were correct, and pool information spot on, BUT the VIP config was riddled with errors - ONLY the VIP config will not be built.  Correct your syntax, run a
```terraform plan```
then a
```terraform apply```
and you're in business!  How is this state maintained?

Every project will have a .tfstate file.  Perform an ```ls``` in your project directory and you'll see it.  This file knows the build state and will help ensure configuration and build parity.

## Sharing TF State

Since the .tfstate file is only created when you perform an terraform init and updated on apply, other users that do the same locally will have a totally separate version of .tfstate - for this reason anyone using Terraform as a team needs to keep the tfstate file in a central location - with version control.  This can be done by specifying the location for the tfstate file in the root/main.tf file.

## Mopping up

Terraform makes cleaning up the 20 parallel environments created for project X easy!  From the root project folder simply run:

```terraform destroy```

Confirm with a yes and watch your environment evaporate.  Since Terraform will attempt to destroy as quick as it builds, some errors can be expected when items are destroyed before their dependents are cleaned up.  Simply running the destroy command a 2nd time usually clears up the issue:
```
troy@ubuntu18:~/testF5/intranet$ terraform destroy
bigip_ltm_monitor.intranet: Refreshing state... (ID: /Common/http_monitor_80)
bigip_ltm_node.intra1: Refreshing state... (ID: /Common/intra1)
bigip_ltm_node.intra2: Refreshing state... (ID: /Common/intra2)
bigip_ltm_node.intra3: Refreshing state... (ID: /Common/intra3)
bigip_ltm_pool.intraPool: Refreshing state... (ID: /Common/intraPool)
bigip_ltm_pool_attachment.intra2: Refreshing state... (ID: /Common/intraPool-/Common/intra2:80)
bigip_ltm_virtual_server.http: Refreshing state... (ID: /Common/intranet_http)
bigip_ltm_virtual_server.https: Refreshing state... (ID: /Common/intranet_https)
bigip_ltm_pool_attachment.intra1: Refreshing state... (ID: /Common/intraPool-/Common/intra1:80)
bigip_ltm_pool_attachment.intra3: Refreshing state... (ID: /Common/intraPool-/Common/intra3:80)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - bigip_ltm_monitor.intranet

  - bigip_ltm_node.intra1

  - bigip_ltm_node.intra2

  - bigip_ltm_node.intra3

  - bigip_ltm_pool.intraPool

  - bigip_ltm_pool_attachment.intra1

  - bigip_ltm_pool_attachment.intra2

  - bigip_ltm_pool_attachment.intra3

  - bigip_ltm_virtual_server.http

  - bigip_ltm_virtual_server.https


Plan: 0 to add, 0 to change, 10 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

bigip_ltm_node.intra2: Destroying... (ID: /Common/intra2)
bigip_ltm_pool_attachment.intra1: Destroying... (ID: /Common/intraPool-/Common/intra1:80)
bigip_ltm_virtual_server.https: Destroying... (ID: /Common/intranet_https)
bigip_ltm_node.intra1: Destroying... (ID: /Common/intra1)
bigip_ltm_pool_attachment.intra2: Destroying... (ID: /Common/intraPool-/Common/intra2:80)
bigip_ltm_pool_attachment.intra3: Destroying... (ID: /Common/intraPool-/Common/intra3:80)
bigip_ltm_node.intra3: Destroying... (ID: /Common/intra3)
bigip_ltm_virtual_server.http: Destroying... (ID: /Common/intranet_http)
bigip_ltm_pool_attachment.intra1: Destruction complete after 0s
bigip_ltm_virtual_server.http: Destruction complete after 0s
bigip_ltm_pool_attachment.intra2: Destruction complete after 0s
bigip_ltm_virtual_server.https: Destruction complete after 0s
bigip_ltm_pool_attachment.intra3: Destruction complete after 0s
bigip_ltm_pool.intraPool: Destroying... (ID: /Common/intraPool)
bigip_ltm_node.intra1: Destruction complete after 0s
bigip_ltm_node.intra3: Destruction complete after 3s
bigip_ltm_pool.intraPool: Destruction complete after 3s
bigip_ltm_monitor.intranet: Destroying... (ID: /Common/http_monitor_80)
bigip_ltm_monitor.intranet: Destruction complete after 2s

Error: Error applying plan:

1 error(s) occurred:

* bigip_ltm_node.intra2 (destroy): 1 error(s) occurred:

* bigip_ltm_node.intra2: HTTP 400 :: {"code":400,"message":"01070110:3: Node address '/Common/intra2' is referenced by a member of pool '/Common/intraPool'.","errorStack":[],"apiError":3}

Terraform does not automatically rollback in the face of errors.
Instead, your Terraform state file has been partially updated with
any resources that successfully completed. Please address the error
above and apply again to incrementally change your infrastructure.


troy@ubuntu18:~/testF5/intranet$ terraform destroy
bigip_ltm_node.intra2: Refreshing state... (ID: /Common/intra2)

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  - destroy

Terraform will perform the following actions:

  - bigip_ltm_node.intra2


Plan: 0 to add, 0 to change, 1 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes

bigip_ltm_node.intra2: Destroying... (ID: /Common/intra2)
bigip_ltm_node.intra2: Destruction complete after 0s

Destroy complete! Resources: 1 destroyed.
troy@ubuntu18:~/testF5/intranet$
```

## Open Source versions for TF Enterprise

So far we have only tried [Atlantis](https://www.runatlantis.io/) which worked flawlessly to deploy projects, versioning not so much.  Each Github pull request/merge cloned the repo to a new folder without copying the tfstate file - to avoid errors and duplicate builds, make sure to use a remote and centrally located tfstate file!  Included in repo is an atlantis.yaml file for syntax purposes.

## Authors

* **Troy Schmid**

## Acknowledgments

* Terraform.io
* devcentral
* Jeff Tweedy "Together at Last"
