#!/bin/bash

# Deploy HDP2.3 Cluster and Services using Ambari Blueprint


[ "$#" -ne 5 ] && (echo "Expects 5 input agreements but found: $#"; exit 1)

# Host name of the Ambari server. Used by the REST API
AMBARI_HOSTNAME=$1

# The cluster name to be used when the cluster i created
CLUSTER_NAME=$2

# Name of the Blueprint to deploy
BLUEPRINT_NAME=$3

# File path containing the blueprint to deploy
BLUEPRINT_FILE=$4

# Blueprint host mapping file path
HOST_MAPPING_FILE=$5

echo "********************************************************************************"
echo " Deploy HDP2.3 Cluster: $CLUSTER_NAME , Blueprint: $BLUEPRINT_NAME       "
echo "********************************************************************************"

# cat $BLUEPRINT_FILE

cat $HOST_MAPPING_FILE

# Install the Blueprint
curl --user admin:admin -H 'X-Requested-By:ambari' -X POST http://$AMBARI_HOSTNAME:8080/api/v1/blueprints/$BLUEPRINT_NAME -d @$BLUEPRINT_FILE

# Wait for Ambari to initialize
sleep 15

# Deploy the cluster
curl --user admin:admin -H 'X-Requested-By:ambari' -X POST http://$AMBARI_HOSTNAME:8080/api/v1/clusters/$CLUSTER_NAME -d @$HOST_MAPPING_FILE

echo "Open http://<AMBARI_HOSTNAME>:8080 (user:admin, pass: admin) to monitor the installation progress"