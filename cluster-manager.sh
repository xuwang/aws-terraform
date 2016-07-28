#!/bin/bash
#
# Written by Xueshan Feng <xueshan.feng@gmail.com>
#
# Init variables and sanity checks
export DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
function init() {
    export PROJECTROOT=$DIR
    export GITROOT=$DIR
    export SCRIPTDIR=$GITROOT/scripts
    [ -f $DIR/envs.sh ] && source $DIR/envs.sh

    if [ ! -d $PROJECTROOT ];
    then 
        echo "$PROJECTROOT doesn't exist."
        exit 1
    fi
    aws --profile $AWS_PROFILE support help 2>/dev/null 1>&2
    if [ $? = "255" ];
    then
        echo "Account $AWS_PROFILE doesn't exit."
        exit 1
    fi
    # Update git repo
    cd $GITROOT
    git pull 
}

#############
# Subroutines
#############

# Show all resources
function showAllResources() {
  make show_all | more -R
}
# Make graph
function makeGraph() {
  make graph && echo "Graphs are generated under build/graph directory."
}

function updateResource() {
  make $resourceType -k 2>&1 | tee /tmp/$resourceType.$$.log
}

function createCluster() {
  make all -k 2>&1  | tee /tmp/build.$$.log
}

function distroyCluster() {
  make destroy_all -k 2>&1  | tee /tmp/destroy.$$.log
}

function hitAnyKey() {
    echo -n "Hit any key to continue, or Ctl-C to cancel....."
    read -n 1
    clear
}

# Get confirmation for an action
function answerMe() {
    answer='N'
    echo -n "Are you sure to contiune? [Y/N]: "
    read answer
    echo ""
}

# Core display screen
function clusterScreen() {
    echo "===== Cluster-Wide Operations ======"
    echo ""
    echo "0. Create Cluster"
    echo "1. Destroy Cluster"
    echo "2. Show all Resources"
    echo "3. Make graph"
    echo 
    echo "===== Update Individual Resources ======"
    echo "10. Admiral"
    echo "11. Worker"
    echo "12. Etcd"
    echo "13. Iam"
    echo "14. Elastic loadbalancer: CI"
    echo "15. Elastic loadbalancer: GitLab (WIP)"
    echo "16. Elastic loadbalancer: dockerhub (WIP)"
    echo "17. EFS"
    echo "18. RDS"
    echo "19. Route53"
    echo "20. S3 buckets"
    echo "21. VPC"
    echo "88. Exit"
    echo ""
    echo "Note: If resources already exist, current status will be displayed."
    echo -n "Please select one of the options above: "
    read CHOICE 
 
    echo ""
    case $CHOICE in
 	    0)
	        createCluster 
            hitAnyKey
            return $callAgain
	        ;;
        1)
            distroyCluster
            hitAnyKey
            return $callAgain
	        ;;
        2)
            showAllResources
            hitAnyKey
            return $callAgain
	        ;;
        3)
            makeGraph
            hitAnyKey
            return $callAgain
            ;;
        10)
            resourceType='admiral'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        11)
            resourceType='worker'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        12)
            resourceType='etcd'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        13)
            resourceType='iam'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        14)
            resourceType='elb-ci'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        15)
            resourceType='elb-gitlab'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        16)
            resourceType='elb-dockerhub'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        17)
            resourceType='efs'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        18)
            resourceType='rds'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        19)
            resourceType='route53'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        20)
            resourceType='s3'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        21)
            resourceType='vpc'
            updateResource
            hitAnyKey
            return $callAgain
            ;;
        88|q|quit|exit)
            # Reminder to uppdate git repo
            cd $GITROOT
            git status
            echo "Please commit changes!"
            exit 0
             ;;
        *)
            clear
            return $callAgain
    esac
} 

################
# Main routine. 
################

if [ ! -f "envs.sh" ];
then
    echo "Please define required environment variables in envs.sh"
    exit 1
fi
init
callAgain=99
status=$callAgain
while [ $status -eq $callAgain ]
do
    clusterScreen
    status=$?
    clear
done

exit 0

DOCS=<<__END_OF_DOCS__

=head1 NAME

cluster-manager.sh - Menu-driven script to install CoreOS docker platform.

=head1 FILES

The script reads the platform configuration from envs.sh.

=head1 AUTHORS

Xueshan Feng <xueshan.feng@gmail.com>

=cut
