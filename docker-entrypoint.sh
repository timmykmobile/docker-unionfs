#!/bin/bash

echo "hello!"
echo $SOURCE_SUBDIR_RW
echo $SOURCE_SUBDIR_RO1
echo $SOURCE_SUBDIR_RO2
echo $SOURCE_SUBDIR_RO3

# Making the /config directory
MOUNT_SOURCE_RW=mount-source-rw/"$SOURCE_SUBDIR_RW"
MOUNT_SOURCE_RO1=mount-source-ro1/"$SOURCE_SUBDIR_RO1"
MOUNT_SOURCE_RO2=mount-source-ro2/"$SOURCE_SUBDIR_RO2"
MOUNT_SOURCE_RO3=mount-source-ro3/"$SOURCE_SUBDIR_RO3"
MOUNT_TARGET=mount-target

echo "## List of mount directories below"
echo $MOUNT_SOURCE_RW
echo $MOUNT_SOURCE_RO1
echo $MOUNT_SOURCE_RO2
echo "##"

ztestname=mount-source-ro1/$SOURCE_SUBDIR_RO1
echo "test of folder witout quotes check"
echo $ztestname


#mkdir /config
#mkdir /$MOUNT_SOURCE
#mkdir /$MOUNT_TARGET

# creating the user... not sure how to do this from env variables
#PUID=${PUID:-911}
#PGID=${PGID:-911}

PUID=1000
PGID=1000



# Create a group for our gid if required
if [ -z "$(getent group abc)" ]; then
        echo "creating abc group for gid ${PGID}"
        groupadd -g ${PGID} -o abc >/dev/null 2>&1
fi



# Create a user for our uid if required
if [ -z "$(getent passwd abc)" ]; then
        echo "creating abc group for uid ${PUID}"
        useradd -u ${PUID} -g ${PGID} \
         -s /bin/bash -m -d "/config" \
         abc >/dev/null 2>&1
fi


##################################
# Check if the source and target directory (and subdirectory) are there
##################################
        if [ ! -d /$MOUNT_SOURCE_RW ]; then
                echo "The source read write directory is not found.  please check that plexdrive is up and running and that it is has the destination $ENCFS_SUBDIR_SOURCE"
                while [ ! -d /$MOUNT_SOURCE_RW ]; do
                        sleep 5;
                done
                echo "Source read write directory has been found. Continuing with mounting"
        fi
        echo "Source read write directory is available"

        if [ ! -d /$MOUNT_SOURCE_RO1 ]; then
                echo "The source read only 1 directory '/$MOUNT_SOURCE_RO1' is not found.  please check that plexdrive is up and running and that it is has the destination $ENCFS_SUBDIR_SOURCE"
                while [ ! -d /$MOUNT_SOURCE_RO1 ]; do
                        sleep 5;
                done
                echo "Source read only 1 directory has been found. Continuing with mounting"
        fi
        echo "Source read only 1 directory is available"

        if [ ! -d /$MOUNT_SOURCE_RO2 ]; then
                echo "The source read only 2 directory is not found.  please check that plexdrive is up and running and that it is has the destination $ENCFS_SUBDIR_SOURCE"
                while [ ! -d /$MOUNT_SOURCE_RO2 ]; do
                        sleep 5;
                done
                echo "Source read only 2 directory has been found. Continuing with mounting"
        fi
        echo "Source read only 2 directory is available"


        if [ ! -d /$MOUNT_TARGET ]; then
                echo "The target directory is not found.  please check that plexdrive is up and running and that it is has the destination $ENCFS_SUBDIR_TARGET";
                while [ ! -d /$MOUNT_TARGET ]; do
                        sleep 5;
                done
                echo "Target directory has been found.  Continuing with mounting."
        fi
        echo "Target directory is available"

        echo "taking ownership of /config for abc"
        chown ${PUID}:${PGID} /config
        chown ${PUID}:${PGID} /$MOUNT_SOURCE_RW
        chown ${PUID}:${PGID} /$MOUNT_SOURCE_RO1
        chown ${PUID}:${PGID} /$MOUNT_SOURCE_RO2
        chown ${PUID}:${PGID} /$MOUNT_SOURCE_RO3
        chown ${PUID}:${PGID} /$MOUNT_TARGET

# Check if existing mount
if grep -qs '/$MOUNT_TARGET ' /proc/mounts; then
    echo "It's mounted."
else
    echo "It's not mounted."



# Mount away!
    echo "Mounting unionfs now..."
    unionfs-fuse -o cow,allow_other "/$MOUNT_SOURCE_RW"=RW:"/$MOUNT_SOURCE_RO1"=RO:"$MOUNT_SOURCE_RO2"=RO "/$MOUNT_TARGET"
    if grep -qs '/$MOUNT_TARGET ' /proc/mounts; then
    echo "It's mounted."
    fi
fi


#if [ "$ENCFS_REVERSE" -eq "0" ]; then
#    ENCFS6_CONFIG='/config/'$ENCFS_XML_NAME encfs --extpass="cat /config/$ENCFS_PASSWORD_NAME" -o allow_other /$MOUNT_SOURCE /$MOUNT_TARGET
#echo "it thinks encfs_reverse equals 0"
#else
#echo "it thinks encfs_revers is not equal to 0"
#    encfs -o allow_other $MOUNT_SOURCE $MOUNT_TARGET
#    encfs --extpass="cat /config/$ENCFS_PASSWORD_NAME" --reverse -o allow_other "/$MOUNT_SOURCE" "/$MOUNT_TARGET"

#fi
#fi


tail -f /dev/null
