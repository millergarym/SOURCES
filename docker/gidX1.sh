
XSOCK=/tmp/.X11-unix/X1
XAUTH=/tmp/.docker.xauth
xauth nlist :1 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
docker run -ti --rm \
    -v $XSOCK:$XSOCK \
    -v $XAUTH:$XAUTH \
    -e XAUTHORITY=$XAUTH \
    -e HOME=/usr/local/GreatSPN/models/usermodels \
    -e U_USER=$USER \
    -e U_UID=`id -u` \
    -e U_GID=`id -g` \
    -e DISPLAY=:1 \
    -v `pwd`:/usr/local/GreatSPN/models/usermodels \
    -w /usr/local/GreatSPN/models/usermodels \
    gspn
