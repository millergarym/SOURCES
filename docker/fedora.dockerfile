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
COPY /JavaGUI/*.PNPRO /usr/local/GreatSPN/models/development/

ENV DISPLAY :0
RUN set +o history
COPY /launch_in_docker.sh /launch_in_docker.sh


RUN echo 'if [ "$U_USER" == "" ]; then \
printf "\n\
-------------------------------------------------------------------------\n\
----           To run GreatSPN from inside a docker container        ----\n\
-------------------------------------------------------------------------\n\
\n\
XSOCK=/tmp/.X11-unix \n\
XAUTH=/tmp/.docker.xauth \n\
xauth nlist :0 | sed -e \"s/^..../ffff/\" | xauth -f \$XAUTH nmerge - \n\
docker run -ti --rm \
-v \$XSOCK:\$XSOCK \
-v \$XAUTH:\$XAUTH \
-e XAUTHORITY=\$XAUTH \
-e HOME=/usr/local/GreatSPN/models/usermodels \
-e U_USER=\$USER \
-e U_UID=\`id -u\` \
-e U_GID=\`id -g\` \
-e DISPLAY=:0 \
-v \`pwd\`:/usr/local/GreatSPN/models/usermodels \
-w /usr/local/GreatSPN/models/usermodels \
millergarym/greatspn \
\n"; exit 1; fi; /launch_in_docker.sh;' > /launch.sh

RUN chmod +x /launch.sh
CMD [ "sh", "-c", "/launch.sh" ]
