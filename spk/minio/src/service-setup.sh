# Setup environment
PATH="${SYNOPKG_PKGDEST}/bin:${PATH}"

CONFIG_DIR="${SYNOPKG_PKGDEST}/var"
CFG_FILE="${CONFIG_DIR}/options.conf"

service_postinst ()
{
    echo "Running service_postinst script" >> "${INST_LOG}"

    if [ "${SYNOPKG_PKG_STATUS}" == "INSTALL" ]; then
        sed -i \
          -e "s|@wizard_data_directory@|${wizard_data_directory}|g" \
          -e "s|@wizard_access_key@|${wizard_access_key}|g" \
          -e "s|@wizard_secret_key@|${wizard_secret_key}|g" \
          -e "s|@wizard_minio_auto_update@|${wizard_minio_auto_update}|g" \
          ${CFG_FILE}
    fi

    echo "Install busybox binaries" >> "${INST_LOG}"
    BIN=${SYNOPKG_PKGDEST}/bin
    $BIN/busybox --install $BIN >> ${INST_LOG}
}

service_prestart ()
{    
    if [ -f $CFG_FILE ]
    then
      . $CFG_FILE
    fi
    
    # if enabled in install wizard run auto update before starting
    if [ "$WIZARD_MINIO_AUTO_UPDATE" = 'true' ]
    then
      "${SYNOPKG_PKGDEST}/bin/minio" --quiet update
    fi

    SERVICE_OPTIONS="server --quiet --anonymous ${WIZARD_DATA_DIRECTORY}"
    
    export MINIO_ACCESS_KEY=$WIZARD_ACCESS_KEY
    export MINIO_SECRET_KEY=$WIZARD_SECRET_KEY

    # Required: start-stop-daemon do not set environment variables
    HOME=${SYNOPKG_PKGDEST}/var
    export HOME
}
