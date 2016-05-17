#!/bin/bash
#######################################################
## THIS SCRIPT SUBSTITUTES VPC AVAILABILITY ZONE RELATED PLACEHOLDERS
## IN $(BUILD)/.terraform/modules/*.tf AND $(BUILD)/*.tf FILES
#######################################################

# If number of command line arguments supplied is less than 2
if [ "$#" -lt 2 ]; then
    echo "Illegal number of arguments"
		echo "Usage: $(basename $0) <path to dir for terraform modules> <path to module_*.tf files (can be more than 1)>"
		exit 0
fi

# first argument: path to dir for terraform modules
TF_MODULES_DIRECTORY=$1
# shift to read all arguments except 1st
# path to module-*.tf files
shift
TF_FILES=$@

# Map of AWS availability zones
declare -A AWS_AZS=(["us-east-1"]=${AZ_US_EAST_1}
				 ["us-west-1"]=${AZ_US_WEST_1}
				 ["us-west-2"]=${AZ_US_WEST_2}
				 ["eu-west-1"]=${AZ_EU_WEST_1}
				 ["eu-central-1"]=${AZ_EU_CETNRAL_1}
				 ["ap-southeast-1"]=${AZ_AP_SOUTHEAST_1}
				 ["ap-southeast-2"]=${AZ_AP_SOUTHEAST_2}
         ["ap-northeast-1"]=${AZ_AP_NORTHEAST_1}
				 ["ap-northeast-2"]=${AZ_AP_NORTHEAST_2}
				 ["sa-east-1"]=${AZ_SA_EAST_1})

# fetch AWS_REGION from the config file
CONFIG_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
AWS_REGION=$($CONFIG_DIR/read_cfg.sh $HOME/.aws/config "profile $AWS_PROFILE" region)

# extract availability zone letters and store them in an array: CURRENT_REGION_AZS_LETTERS
CURRENT_REGION_AZS_LETTERS=""
IFS=',' read -r -a AVAIL_ZONES <<< "${AWS_AZS["${AWS_REGION}"]}"
for az in "${AVAIL_ZONES[@]}"
do
	CURRENT_REGION_AZS_LETTERS+=(${az: -1})
done

#######################################################
## FOR /modules/*.tf.tmpl FILE SUBSTITUTIONS
## creates new files with substituted values and extension ".tf"
## (variable definitions and their usage)
#######################################################
# find files with .tf.tmpl extension in the directory: $TF_MODULES_DIRECTORY
TF_MODULES_FILES=$(find $TF_MODULES_DIRECTORY -type f -iname "*.tf.tmpl")

# find files which contain any of the three placeholders
files=$(grep -s -l -e \<%MODULE-SUBNET-VARIABLES%\> -e \<%MODULE-AZ-VARIABLES-ARRAY%\> -e \<%MODULE-ID-VARIABLES-ARRAY%\> -r $TF_MODULES_FILES)
current_module_name=""
for f in $files
do
	# extract module from file name like *modules/<MODULE_NAME>/*.tf
	current_module_name=${f##*modules/}
	current_module_name=${current_module_name%%/*}

	variables=""
	az_variables_array="["
	id_variables_array="["
	for az_letter in ${CURRENT_REGION_AZS_LETTERS[@]}
	do
		# variables definitions for varaibles.tf files
    #
    # (to preserve \" while writing in terraform file use \\\")
    # any character sequence written in a terraform file will be processed then written
    # so make sure to preserve characters by using escape sequences
		variables="$variables
		variable \\\"${current_module_name}_subnet_${az_letter}_id\\\" { }
		variable \\\"${current_module_name}_subnet_az_${az_letter}\\\" { }"

		# array of variable usage
		az_variables_array="$az_variables_array \\\"\\\${var.${current_module_name}_subnet_az_${az_letter}}\\\","
		id_variables_array="$id_variables_array \\\"\\\${var.${current_module_name}_subnet_${az_letter}_id}\\\","
	done

	# Remove trailing comma and append closing bracket
	az_variables_array="${az_variables_array::-1} ]"
	id_variables_array="${id_variables_array::-1} ]"

  # create a new file tf file without the .tmpl extension
  newFile="${f%%.tmpl*}"
  cp $f $newFile
	# Replace placeholders with their respective values in the new tf file
  perl -p -i -e "s/<%MODULE-SUBNET-VARIABLES%>/${variables}/g" "${newFile}"
	perl -p -i -ne "s/<%MODULE-AZ-VARIABLES-ARRAY%>/${az_variables_array}/g" "${newFile}";
	perl -p -i -e "s/<%MODULE-ID-VARIABLES-ARRAY%>/${id_variables_array}/g" "${newFile}"
done

#######################################################
## FOR module-*.tf FILE SUBSTITUTIONS
## Substitutes values in resouces/terraform/module-*.tf.tmpl files
#######################################################
# find files which contain any of the three placeholders
files=$(grep -s -l -e \<%MODULE-SUBNET-IDS-AND-AZS%\> -e \<%ADMIRAL-SUBNET-IDS-AND-AZS%\> -e \<%WORKER-SUBNET-IDS-AND-AZS%\> -r $TF_FILES)
current_module_name=""
for f in $files
do
	# extract module from file name like *module-<MODULE_NAME>.tf
	current_module_name=${f##*module-}
	current_module_name=${current_module_name%%.tf*}

	module_vpc_ids=""
	module_vpc_azs=""
	admiral_vpc_ids=""
	admiral_vpc_azs=""
	worker_vpc_ids=""
	worker_vpc_azs=""
	for az_letter in ${CURRENT_REGION_AZS_LETTERS[@]}
	do
		# If module has own vpc subnet
		module_vpc_ids="${module_vpc_ids}
		${current_module_name}_subnet_${az_letter}_id = \\\"\\\${module.vpc.${current_module_name}_subnet_${az_letter}_id}\\\""
		module_vpc_azs="${module_vpc_azs}
		${current_module_name}_subnet_az_${az_letter} = \\\"\\\${module.vpc.${current_module_name}_subnet_az_${az_letter}}\\\""

		# If module uses admiral vpc subnet
		admiral_vpc_ids="${admiral_vpc_ids}
		${current_module_name}_subnet_${az_letter}_id = \\\"\\\${module.vpc.admiral_subnet_${az_letter}_id}\\\""
		admiral_vpc_azs="${admiral_vpc_azs}
		${current_module_name}_subnet_az_${az_letter} = \\\"\\\${module.vpc.admiral_subnet_az_${az_letter}}\\\""

		# If module uses worker vpc subnet
		worker_vpc_ids="${worker_vpc_ids}
		${current_module_name}_subnet_${az_letter}_id = \\\"\\\${module.vpc.worker_subnet_${az_letter}_id}\\\""
		worker_vpc_azs="${worker_vpc_azs}
		${current_module_name}_subnet_az_${az_letter} = \\\"\\\${module.vpc.worker_subnet_az_${az_letter}}\\\""
	done

	# Concatenate results
	module_result="${module_vpc_ids}
	${module_vpc_azs}"
	admiral_result="${admiral_vpc_ids}
	${admiral_vpc_azs}"
	worker_result="${worker_vpc_ids}
	${worker_vpc_azs}"

  # create a new file tf file without the .tmpl extension
  newFile="${f%%.tmpl*}"
  cp $f $newFile
	# Replace placeholders with their respective values in the file
	perl -p -i -e "s/<%MODULE-SUBNET-IDS-AND-AZS%>/${module_result}/g" ${newFile}
	perl -p -i -e "s/<%ADMIRAL-SUBNET-IDS-AND-AZS%>/${admiral_result}/g" ${newFile}
	perl -p -i -e "s/<%WORKER-SUBNET-IDS-AND-AZS%>/${worker_result}/g" ${newFile}
done
