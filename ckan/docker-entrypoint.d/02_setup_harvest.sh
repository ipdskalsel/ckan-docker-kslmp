#!/bin/bash
if [[ $CKAN__PLUGINS == *"harvest ckan_harvester"* ]]; then
   echo "--- Starting CKAN HARVEST configuration ---"
   #echo "CKAN_INI: $CKAN_INI"

   ckan -c $CKAN_INI db upgrade -p harvest || {
   echo "ERROR: Failed to do a DB Upgrade for CKAN HARVEST"
   exit 1
   }

else
   echo "INFO: Not configuring Harvester"
fi
