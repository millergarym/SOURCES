FROM fedora as builder

RUN dnf -y install git

RUN dnf -y install \
    gcc \
    gcc-c++ \
    gmp-devel \
    gmp-c++ \
    gmp \
    boost-devel \
    flex-devel \
    ant \
    glib2-devel \
    patch \
    python \
    libxml-devel \
    glpk-devel \
    lpsolve-devel \
    autoconf \
    automake \
    libtool \
    zip \
    flex git \
    byacc \
    time \
    graphviz \
    suitesparse-devel \
    motif-devel \
    make \
    libxml++-devel \
    glibmm24-devel \
    lpsolve-devel 

RUN git clone git://git.code.sf.net/p/meddly/code-git meddly
RUN cd meddly; \
    aclocal && autoconf && libtoolize && autoheader && automake --add-missing \
    && ./autogen.sh \
    &&  LDFLAGS="-O2" ./configure --prefix=/usr/local \
    && make -j 4 \
    && make install

COPY / /SOURCES
RUN cd /SOURCES; rm -r `find . -name .antlr` || true  
RUN cd /SOURCES; make print_binaries
RUN cd /SOURCES; make JavaGUI-antlr
RUN cd /SOURCES; make java-jars
RUN cd /SOURCES; make derived_objects
RUN cd /SOURCES; make libraries
RUN cd /SOURCES; make binaries
RUN cd /SOURCES; make scripts
RUN cd /SOURCES; make install

FROM fedora

RUN dnf -y install \
    graphviz ant

COPY --from=builder /usr/local/GreatSPN /usr/local/GreatSPN
RUN mkdir /usr/local/GreatSPN/models/development
COPY /JavaGUI/*.PNPRO /usr/local/GreatSPN/development/

ENV DISPLAY :0
RUN set +o history
COPY /launch_in_docker.sh /launch_in_docker.sh


RUN echo 'if [ "$U_USER" == "" ]; then \
printf "\n\
XSOCK=/tmp/.X11-unix \n\
XAUTH=/tmp/.docker.xauth \n\
xauth nlist :0 | sed -e \'s/^..../ffff/\' | xauth -f $XAUTH nmerge - \n\
docker run -ti --rm \ \n\
    -v $XSOCK:$XSOCK \ \n\
    -v $XAUTH:$XAUTH \ \n\
    -e XAUTHORITY=$XAUTH \ \n\
    -e HOME=/usr/local/GreatSPN/models/usermodels \ \n\
    -e U_USER=$USER \ \n\
    -e U_UID=`id -u` \ \n\
    -e U_GID=`id -g` \ \n\
    -e DISPLAY=:0 \ \n\
    -v `pwd`:/usr/local/GreatSPN/models/usermodels \ \n\
    -w /usr/local/GreatSPN/models/usermodels \ \n\
     millergarym/greatspn \n\
    \n"; exit 1; fi; /lauch_in_docker.sh;' > /launch.sh

RUN chmod +x /launch.sh
CMD [ "sh", "-c", "/launch.sh" ]
