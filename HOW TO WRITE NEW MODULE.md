# Step 1: Add new folder `<module-name>` in modules section

Then create three terraform files:

1. `<module-name>`.tf
2. security.tf
3. variables.tf

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

# Step 5: Create terraform

module-<module-name>.tf

`module-elk.tf`

# Step 6: Create make file

<module-name>.mk

`elk.mk`

# Step 6: Upload configurations

