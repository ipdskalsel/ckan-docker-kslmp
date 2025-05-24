FROM ckan/ckan-base:2.11

# Install any extensions needed by your CKAN instance
# See Dockerfile.dev for more details and examples

USER root
RUN pip install --upgrade setuptools
### Scheming ###
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-scheming.git@master#egg=ckanext-scheming'

### Harvester ###
RUN pip3 install -e 'git+https://github.com/ckan/ckanext-harvest.git@master#egg=ckanext-harvest' && \
   pip3 install -r ${APP_DIR}/src/ckanext-harvest/pip-requirements.txt
# will also require gather_consumer and fetch_consumer processes running (please see https://github.com/ckan/ckanext-harvest)
RUN apt update && \
   apt install -y cron
COPY setup/ckan_harvesting.conf /etc/supervisor/conf.d/ckan_harvesting.conf
RUN echo "*/30 * * * * ckan -c /etc/ckan/default/ckan.ini harvester run  >> /var/log/ckan/harvester_cron.log 2>&1" > /etc/cron.d/ckan_harvester_cron
RUN chmod 0644 /etc/cron.d/ckan_harvester_cron

### Pages ###
RUN  pip3 install -e git+https://github.com/ckan/ckanext-pages.git#egg=ckanext-pages

### DCAT ###
# RUN  pip3 install -e git+https://github.com/ckan/ckanext-dcat.git@v0.0.6#egg=ckanext-dcat && \
#     pip3 install -r https://raw.githubusercontent.com/ckan/ckanext-dcat/v0.0.6/requirements.txt
RUN pip install ckanext-dcat
# Copy custom initialization scripts
COPY --chown=ckan-sys:ckan-sys docker-entrypoint.d/* /docker-entrypoint.d/


# Apply any patches needed to CKAN core or any of the built extensions (not the
# runtime mounted ones)
COPY --chown=ckan-sys:ckan-sys patches ${APP_DIR}/patches

USER ckan

RUN for d in $APP_DIR/patches/*; do \
        if [ -d $d ]; then \
            for f in `ls $d/*.patch | sort -g`; do \
                cd $SRC_DIR/`basename "$d"` && echo "$0: Applying patch $f to $SRC_DIR/`basename $d`"; patch -p1 < "$f" ; \
            done ; \
        fi ; \
    done
