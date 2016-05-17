# Step 1: Add new folder `<module-name>` in modules section

Then create terraform and terraform template files as follows:

1. `<module-name>`.tf.tmpl
2. security.tf
3. variables.tf.tmpl

The terraform template files (.tf.tmpl) can contain certai placeholders (such as placeholders for availability zones and etc) which are replaced when .tf files are generated from them
look others for inspiration; most of the times they are similiar except few simple name changes.

# Step 2: Create `<module-name>.yaml` file

Create `<module-name>.yaml` file in `./resources/cloud-config`

e.g.

`elk.yaml`

This is the most important and key file; as in this file you will have to define the systemd units that you want to run!

# Step 3: Create `cloudinit-<module-name>.def` file

Create `cloudinit-<module-name>.def` file in `./resources/cloud-config`

e.g.

`cloudinit-elk.def`

# Step 4: Create policy

<module-name>_policy.json

e.g.

`elk_policy.json`

# Step 5: Create terraform template

module-<module-name>.tf.tmpl

`module-elk.tf.tmpl`

The terraform template files (.tf.tmpl) can contain certai placeholders (such as placeholders for availability zones variables and etc) which are replaced when .tf files are generated from them

# Step 6: Create make file

<module-name>.mk

`elk.mk`

# Step 7: Define configurations

if your systemd unit which runs a docker container needs some configuration then you can put them under a config folder of that module

(and it will be automatically uploaded and downloaded into the instance under /etc/configs/); still WIP

# Step 8: Define Subnet?

not sure but we might need to setup <module-name>-subnet.tf in vpc module; but i don't think its mandatory for simple modules; need to check with xu wang


