# Changelog

# v2.0.0
  - Fundamentally change the code to remove complexity and adapt the code to meet the new requirements.

# v1.5.0

  - Remove `ext_nets` option for "name" only external networks
  - Add `networks` input var mirroring `additional_networks`,
    but adding ports as part of instance instead of attaching them.
    Also has an additional config field `access` for setting the `access_network` value.
  - Add `networks` output containing all ports created based on the `networks` input var
    (same as the `additional_networks` output).
# v1.4.4
  - Add ext_nets variable to assign an external network via dynmaic block

# v1.4.3
  - Move to github
  - Add additional metadata input to support passing complex information to instances (and Ansible) through terraform.
    Note that "groups" key is reserved and will be overwritten by the `tags` input variable which is used to define inventory groups.
# v1.4.2
  - Replace deprecated template_file data source usage with templatefile function
  - Remove userdata_vars input restriction
# v1.4.1
  - Add sensitive flag to server output
## v1.4

 - Add support for configuring block storage type (volume or local file).
   Defaults to local file

## v1.3.2

 - Make userdata file input optional

## v1.3.1

 - Hotfix add confid_drive input var to support user data for situations where early networking is not available

## v1.3

 - Also allow input of UUIDs instead of names for network, subnet and image based on a UUID regular expression
 - Replace static IP address input with dynamically calculated fixed IP addresses based on subnet cidr and host address index input
 - ~~Make subnet inputs optional~~ Reverted due to bug

## v1.2.1

- Add server and network info outputs
- Add changelog

## v1.2

- Upgrade to terraform 0.13 

## v1.1.1

- Add additional usage example

## v1.1

- Allow input of dictionary as context for rendering userdata template
- Replace id inputs with name inputs for increased reusability of code

## v1.0

- Initial Release
