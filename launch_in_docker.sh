#!/bin/bash
set -x
set +o history
groupadd -g $U_GID $U_USER
useradd -u $U_UID -g $U_USER -d /usr/local/GreatSPN/models/usermodels $U_USER
export GREATSPN_INSTALLDIR=/usr/local/GreatSPN

# subdirectories for binaries, scripts, libraries
export GREATSPN_BINDIR=${GREATSPN_INSTALLDIR}/bin
export GREATSPN_LIBDIR=${GREATSPN_INSTALLDIR}/lib
export GREATSPN_SCRIPTDIR=${GREATSPN_INSTALLDIR}/scripts

LnF=""
if [[ $1 == '-gtk' ]] ; then
    su $U_USER -c "java -mx2000m -Duser.home=/usr/local/GreatSPN/models/usermodels -Dswing.defaultlaf=com.sun.java.swing.plaf.gtk.GTKLookAndFeel -splash:${GREATSPN_BINDIR}/lib/splash.png -jar ${GREATSPN_BINDIR}/Editor.jar"
else
    su $U_USER -c "java -mx2000m -Duser.home=/usr/local/GreatSPN/models/usermodels -splash:${GREATSPN_BINDIR}/lib/splash.png -jar ${GREATSPN_BINDIR}/Editor.jar"
fi



# su $U_USER -c "java -Duser.home=/SOURCES/usermodels -cp /SOURCES/JavaGUI/Editor/dist/lib/swing-layout-1.0.4.jar:/SOURCES/JavaGUI/Editor/dist/lib/AbsoluteLayout.jar:/SOURCES/JavaGUI/Editor/dist/lib/antlr-runtime-4.2.1.jar:/SOURCES/JavaGUI/Editor/dist/lib/jlatexmath-1.0.4.jar:/SOURCES/JavaGUI/Editor/dist/Editor.jar editor.Main"
