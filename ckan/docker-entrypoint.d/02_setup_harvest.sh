#!/bin/bash

if [[ $CKAN__PLUGINS == *"harvest ckan_harvester"* ]]; then
   echo "Set up ckan.harvest"
   ckan config-tool $CKAN_INI db upgrade -p harvest || echo "ckanext-harvest initdb command finished (may have already run or encountered a non-critical issue)."
   service apache2 restart
   supervisorctl reread
   supervisorctl add ckan_gather_consumer
   supervisorctl add ckan_fetch_consumer
   supervisorctl start ckan_gather_consumer
   supervisorctl start ckan_fetch_consumer
   supervisorctl enable ckan_gather_consumer
   supervisorctl enable ckan_fetch_consumer
   echo "*/30 * * * * ckan /usr/local/bin/ckan_harvester_job.sh >> /var/log/ckan/harvester_cron.log 2>&1" > /etc/cron.d/ckan_harvester_cron
   chmod 0644 /etc/cron.d/ckan_harvester_cron
else
   echo "Not configuring Harvester"
fi