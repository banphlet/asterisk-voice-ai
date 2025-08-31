#!/bin/bash

set -e

# run as user asterisk by default
ASTERISK_USER=${ASTERISK_USER:-asterisk}

if [ "$1" = "" ]; then
    COMMAND="/usr/sbin/asterisk -T -W -U ${ASTERISK_USER} -p -vvvdddf"
else
    COMMAND="$@"
fi

if [ "${ASTERISK_UID}" != "" ] && [ "${ASTERISK_GID}" != "" ]; then
    # recreate user and group for asterisk
    # if they've sent as env variables (i.e. to march with host user to fix permissions for mounted folders
    
    deluser asterisk && \
    adduser --gecos "" --no-create-home --uid ${ASTERISK_UID} --disabled-password ${ASTERISK_USER} || exit
    
    chown -R ${ASTERISK_UID}:${ASTERISK_UID} /etc/asterisk \
    /var/*/asterisk \
    /usr/*/asterisk
fi

if [[ -z "$TWILIO_ACCOUNT_SID" ]]; then
    echo "TWILIO_ACCOUNT_SID environment variable not set"
    exit 64
fi

if [[ -z "$AMI_USERNAME" ]]; then
    echo "AMI_USERNAME environment variable not set"
    exit 64
fi

if [[ -z "$AMI_PASSWORD" ]]; then
    echo "AMI_PASSWORD environment variable not set"
    exit 64
fi



if [[ -z "$TWILIO_MAIN_ACCOUNT_SIP_TRUNK_URL" ]]; then
    echo "TWILIO_MAIN_ACCOUNT_SIP_TRUNK_URL environment variable not set"
    exit 64
fi

if [[ -z "$TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_USERNAME" ]]; then
    echo "TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_USERNAME environment variable not set"
    exit 64
fi
 

if [[ -z "$TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_PASSWORD" ]]; then
    echo "TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_PASSWORD environment variable not set"
    exit 64
fi

if [[ -z "$HEPLIFY_SERVER_ADDR" ]]; then
    echo "HEPLIFY_SERVER_ADDR environment variable not set"
    exit 64
fi

if [[ -z "$PBX_MEDIA_MODULES_HOST" ]]; then
    echo "PBX_MEDIA_MODULES_HOST environment variable not set"
    exit 64
fi


if [[ -z "$PBX_MEDIA_DB_HOST" ]]; then
    echo "PBX_MEDIA_DB_HOST environment variable not set"
    exit 64
fi

if [[ -z "$PBX_MEDIA_DB_PORT" ]]; then
    echo "PBX_MEDIA_DB_PORT environment variable not set"
    exit 64
fi


if [[ -z "$PBX_MEDIA_DB_NAME" ]]; then
    echo "PBX_MEDIA_DB_NAME environment variable not set"
    exit 64
fi

if [[ -z "$PBX_MEDIA_DB_USER_NAME" ]]; then
    echo "PBX_MEDIA_DB_USER_NAME environment variable not set"
    exit 64
fi

if [[ -z "$PBX_MEDIA_DB_PASSWORD" ]]; then
    echo "PBX_MEDIA_DB_PASSWORD environment variable not set"
    exit 64
fi


# AGI Queue and MOH uri.  
PBX_MEDIA_QUEUE_MOH_API_URL="http://$PBX_MEDIA_MODULES_HOST:8124"
# AGI Billing URi
PBX_MEDIA_BILLING_URL="$PBX_MEDIA_MODULES_HOST:8123"

# pjsip

sed -i "s|TWILIO_ACCOUNT_SID|$TWILIO_ACCOUNT_SID|" /etc/asterisk/pjsip_wizard.conf
sed -i "s|TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_USERNAME|$TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_USERNAME|" /etc/asterisk/pjsip_wizard.conf
sed -i "s|TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_PASSWORD|$TWILO_MAIN_ACCOUNT_SIP_TRUNK_AUTH_PASSWORD|" /etc/asterisk/pjsip_wizard.conf
sed -i "s|TWILIO_MAIN_ACCOUNT_SIP_TRUNK_URL|$TWILIO_MAIN_ACCOUNT_SIP_TRUNK_URL|" /etc/asterisk/pjsip_wizard.conf

# AMI
sed -i "s|AMI_USERNAME|$AMI_USERNAME|" /etc/asterisk/manager.conf
sed -i "s|AMI_PASSWORD|$AMI_PASSWORD|" /etc/asterisk/manager.conf

# ARI
sed -i "s|AMI_USERNAME|$AMI_USERNAME|" /etc/asterisk/ari.conf
sed -i "s|AMI_PASSWORD|$AMI_PASSWORD|" /etc/asterisk/ari.conf

# # sip tracing
# sed -i "s|HEPLIFY_SERVER_ADDR|$HEPLIFY_SERVER_ADDR|" /etc/asterisk/hep.conf

# extensions ex
sed -i "s|PBX_MEDIA_BILLING_URL|$PBX_MEDIA_BILLING_URL|" /etc/asterisk/extensions.ael

# realtime (sorcery) for call queues.
sed -i "s|PBX_MEDIA_QUEUE_MOH_API_URL|$PBX_MEDIA_QUEUE_MOH_API_URL|" /etc/asterisk/extconfig.conf


# odbc.ini
sed -i "s|PBX_MEDIA_DB_HOST|$PBX_MEDIA_DB_HOST|" /etc/odbc.ini
sed -i "s|PBX_MEDIA_DB_PORT|$PBX_MEDIA_DB_PORT|" /etc/odbc.ini
sed -i "s|PBX_MEDIA_DB_NAME|$PBX_MEDIA_DB_NAME|" /etc/odbc.ini
sed -i "s|PBX_MEDIA_DB_USER_NAME|$PBX_MEDIA_DB_USER_NAME|" /etc/odbc.ini
sed -i "s|PBX_MEDIA_DB_PASSWORD|$PBX_MEDIA_DB_PASSWORD|" /etc/odbc.ini

exec /usr/sbin/asterisk  -vvvdddf -T -W  -U asterisk -p
