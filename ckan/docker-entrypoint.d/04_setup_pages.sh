#!/bin/bash
if [[ $CKAN__PLUGINS == *"pages"* ]]; then
   echo "--- Starting CKAN PAGES configuration ---"
   #echo "CKAN_INI: $CKAN_INI"

   ckan -c $CKAN_INI db upgrade -p pages || {
   echo "ERROR: Failed to do a DB Upgrade for CKAN PAGES"
   exit 1
   }

else
   echo "INFO: Not configuring PAGES"
fi
