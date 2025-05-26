#!/bin/bash
if [[ $CKAN__PLUGINS == *"harvest ckan_harvester"* ]]; then
   echo "--- Starting CKAN HARVEST configuration ---"
   #echo "CKAN_INI: $CKAN_INI"

   ckan -c $CKAN_INI db upgrade -p harvest || {
   echo "ERROR: Failed to do a DB Upgrade for CKAN HARVEST"
   exit 1
   }

   echo "Starting Supervisor"
   service supervisor start 

   echo "Waiting Supervisor to start"
   sleep 5

else
   echo "INFO: Not configuring Harvester"
fi
