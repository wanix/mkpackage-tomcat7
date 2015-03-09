#!/bin/bash
################################################################################
# packaging-tomcat7/bin/package-tomcat.sh
################################################################################
#   Author : Erwan SEITE (wanix.fr@gmail.com)
#   Source : https://github.com/wanix/packaging-tomcat7
################################################################################
# Aim : download and package tomcat7 from archive.apache.org
# Need : wget, tar, gzip, ruby, easyfpm
################################################################################
[ -f ~/.bash_profile ] && . ~/.bash_profile > /dev/null
#-------------------------------------------------------------------------------
# global vars
#-------------------------------------------------------------------------------
unset SCRIPT_NAME BASE_DIR SCRIPT_TMP SCRIPT_TMP_DIR SCRIPT_OUTPUT TOMCAT7_VERSION EASYFPM_CONF EASYFPM_OPTIONS TMP_DIR ACTUALDIR
typeset -x SCRIPT_NAME="$(basename $0)"
typeset -x BASE_DIR="$(dirname $(dirname $0))"
typeset -x SCRIPT_TMP_DIR="$(basename ${SCRIPT_NAME} .sh)${$}-tmp.d"
typeset -x ACTUALDIR=$PWD

#This parameters should be defined by cmd-line or by a config file : ${BASE_DIR}/cfg/$(basename ${SCRIPT_NAME} .sh).cfg
typeset -x SCRIPT_TMP="/tmp"
typeset -x SCRIPT_OUTPUT="${BASE_DIR}/var/packages"
typeset -x TOMCAT7_VERSION=""
typeset -x EASYFPM_CONF="${BASE_DIR}/cfg/easyfpm-tomcat7/easyfpm.cfg"
typeset -x EASYFPM_OPTIONS=""
typeset -x SRC_TOMCAT="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/apache-tomcat-_VERSION_TAG_.tar.gz"
typeset -x SRC_TOMCAT_DEPLOYER="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/apache-tomcat-_VERSION_TAG_-deployer.tar.gz"
typeset -x SRC_TOMCAT_FULLDOCS="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/apache-tomcat-_VERSION_TAG_-fulldocs.tar.gz"
typeset -x SRC_TOMCAT_CAT_JMX_REM="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/extras/catalina-jmx-remote.jar"
typeset -x SRC_TOMCAT_CAT_WS="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/extras/catalina-ws.jar"
typeset -x SRC_TOMCAT_JULI_ADAPT="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/extras/tomcat-juli-adapters.jar"
typeset -x SRC_TOMCAT_JULI="http://archive.apache.org/dist/tomcat/tomcat-7/v_VERSION_TAG_/bin/extras/tomcat-juli.jar"

#-------------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------------
f_usage(){
  #print help and exit
  cat << EOF
  ${SCRIPT_NAME} : download and package tomcat7 from archive.apache.org
    -h : help, this message
    -d : mandatory, tomcat7 version to download (ex 7.0.59)
    -c : facultative, easyfpm configfile to read, (default ${BASE_DIR}/easyfpm-tomcat7/easyfpm.cfg)
    -t : facultative, temporary dir for download and extract (default /tmp)
    -o : facultative, output dir for packages (default ${BASE_DIR}/var/packages), try to create it if non-existant.
    -e : facultative, easyfpm cmdline options

  examples:
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages -e "--label tomcat7-deb"
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages -e "--label tomcat7-deb-fulldocs,tomcat7-deb-deployer,tomcat7-deb-embed,tomcat7-deb-extra-catalina-jmx-remote,tomcat7-deb-catalina-ws,tomcat7-deb-juli-adapters,tomcat7-deb-juli"
EOF
}

f_clean_all(){
  #Clean all temporaries elements
  if [ -d ${TMP_DIR} ];
  then
    echo "rm -Rf ${TMP_DIR}"
  fi
  cd ${ACTUALDIR}
  unset SCRIPT_NAME BASE_DIR SCRIPT_TMP TMP_DIR SCRIPT_OUTPUT TOMCAT7_VERSION EASYFPM_CONF EASYFPM_OPTIONS ACTUALDIR
}

f_error_exit(){
  printf "$1\n"
  exit 1
}

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
trap "f_clean_all" HUP INT QUIT KILL EXIT TERM EXIT TERM

#Attemting to read config file
CFG_FILE="${BASE_DIR}/cfg/$(basename ${SCRIPT_NAME} .sh).cfg"
if [ -r ${CFG_FILE} ];
then
  OPT_TOMCAT7_VERSION=$(grep "^TOMCAT7_VERSION=" ${CFG_FILE} | head -n 1 | sed 's/^TOMCAT7_VERSION=//')
  [ -n "${OPT_TOMCAT7_VERSION}" ] && TOMCAT7_VERSION=${OPT_TOMCAT7_VERSION}
  OPT_SCRIPT_TMP=$(grep "^SCRIPT_TMP=" ${CFG_FILE} | head -n 1 | sed 's/^SCRIPT_TMP=//')
  [ -n "${OPT_SCRIPT_TMP}" ] && SCRIPT_TMP=${OPT_SCRIPT_TMP}
  OPT_SCRIPT_OUTPUT=$(grep "^SCRIPT_OUTPUT=" ${CFG_FILE} | head -n 1 | sed 's/^SCRIPT_OUTPUT=//')
  [ -n "${OPT_SCRIPT_OUTPUT}" ] && SCRIPT_OUTPUT=${OPT_SCRIPT_OUTPUT}
  OPT_EASYFPM_OPTIONS=$(grep "^EASYFPM_OPTIONS=" ${CFG_FILE} | head -n 1 | sed 's/^EASYFPM_OPTIONS=//')
  [ -n "${OPT_EASYFPM_OPTIONS}" ] && EASYFPM_OPTIONS=${OPT_EASYFPM_OPTIONS}
  OPT_EASYFPM_CONF=$(grep "^EASYFPM_CONF=" ${CFG_FILE} | head -n 1 | sed 's/^EASYFPM_CONF=//')
  [ -n "${OPT_EASYFPM_CONF}" ] && EASYFPM_CONF=${OPT_EASYFPM_CONF}
  OPT_SRC_TOMCAT=$(grep "^SRC_TOMCAT=" ${CFG_FILE} | head -n 1 | sed 's/^SRC_TOMCAT=//')
  [ -n "${OPT_SRC_TOMCAT}" ] && SRC_TOMCAT=${OPT_SRC_TOMCAT}
  OPT_SRC_TOMCAT_FULLDOCS=$(grep "^SRC_TOMCAT_FULLDOCS=" ${CFG_FILE} | head -n 1 | sed 's/^SRC_TOMCAT_FULLDOCS=//')
  [ -n "${OPT_SRC_TOMCAT_FULLDOCS}" ] && SRC_TOMCAT_FULLDOCS=${OPT_SRC_TOMCAT_FULLDOCS}
fi

## get and manage parameters
typeset -x OPTIND=1
while getopts d:t:o:e:c:h opt
do
  case ${opt} in
    d ) TOMCAT7_VERSION="${OPTARG}";;
    t ) SCRIPT_TMP="${OPTARG}";;
    o ) SCRIPT_OUTPUT="${OPTARG}";;
    e ) EASYFPM_OPTIONS="${OPTARG}";;
    c ) EASYFPM_CONF="${OPTARG}";;
    h ) f_usage
        exit 0;;
    \?) f_usage
        exit 1;;
  esac
done

[ -z "${SCRIPT_TMP}" ] && printf "Internal Error : SCRIPT_TMP should not be empty\n" && exit 1
[ -z "${SCRIPT_OUTPUT}" ] && printf "Internal Error : SCRIPT_OUTPUT should not be empty\n" && exit 1
[ -z "${EASYFPM_CONF}" ] && printf "Internal Error : EASYFPM_CONF should not be empty\n" && exit 1

## verifying parameters
# TOMCAT7_VERSION must not be empty
[ -z "${TOMCAT7_VERSION}" ] && printf "Error : parameter -d is mandatory\n" && f_usage && exit 1
[ ! -d ${SCRIPT_TMP} ] && printf "Error : temporary dir ${SCRIPT_TMP} is not a directory\n" && exit 1
[ ! -w ${SCRIPT_TMP} ] && printf "Error : temporary dir ${SCRIPT_TMP} is not writable\n" && exit 1
if [ ! -d ${SCRIPT_OUTPUT} ];
then
  #trying to create it
  mkdir -p ${SCRIPT_OUTPUT}
  [ $? -ne 0 ] && printf "Error : can't create output dir ${SCRIPT_OUTPUT}\n" && exit 1
fi
[ ! -r ${EASYFPM_CONF} ] && printf "Error : can't read easyfpm config file ${EASYFPM_CONF}\n" && exit 1
# Create temporary dir
typeset -x TMP_DIR=${SCRIPT_TMP}/${SCRIPT_TMP_DIR}
mkdir ${TMP_DIR}
[ $? -ne 0 ] && printf "Error : can't create working tmp dir under ${SCRIPT_TMP}\n" && exit 1
cd ${TMP_DIR}

HTTP_SOURCES=$(echo ${SRC_TOMCAT} ${SRC_TOMCAT_FULLDOCS} | sed "s/_VERSION_TAG_/${TOMCAT7_VERSION}/g")
for httpfile in ${HTTP_SOURCES};
do
  [ -z "$(echo ${httpfile} | sed 's/ //g')" ] && continue
  tarfile=$(basename ${httpfile})
  echo "  Retrieving ${tarfile}"
  wget -q ${httpfile} -O ${TMP_DIR}/${tarfile}
  [ $? -ne 0 ] && printf "Error : can't retrieve ${httpfile}\n" && exit 1
  wget -q ${httpfile}.md5 -O ${TMP_DIR}/${tarfile}.md5
  [ $? -ne 0 ] && printf "Error : can't retrieve ${httpfile}.md5\n" && exit 1
  md5sum --status -c ${tarfile}.md5
  [ $? -ne 0 ] && printf "Error : integrity failure for ${tarfile}\n" && exit 1
  tar xzf ${tarfile}
  [ $? -ne 0 ] && printf "Error : can't unpack ${tarfile}\n" && exit 1
  rm -f ${tarfile} ${tarfile}.md5
done
mv tomcat-7.0-doc/* apache-tomcat-${TOMCAT7_VERSION}/webapps/docs/
[ $? -ne 0 ] && printf "Error : Can't prepare doc\n" && exit 1
