#!/bin/bash
################################################################################
# packaging-tomcat7/package-tomcat.sh
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
unset SCRIPT_NAME SCRIPT_TMP SCRIPT_OUTPUT TOMCAT7_VERSION EASYFPM_CONF EASYFPM_OPTIONS
typeset -x SCRIPT_NAME="$(basename $0)"
typeset -x SCRIPT_TMP="/tmp"
typeset -x SCRIPT_OUTPUT="${PWD}"
typeset -x SCRIPT_TMP_DIR="$(basename ${SCRIPT_NAME} .sh)${$}-tmp.d"
typeset -x TOMCAT7_VERSION=""
typeset -x EASYFPM_CONF="$(dirname ${SCRIPT_NAME})/_easyfpm/easyfpm.cfg"
typeset -x EASYFPM_OPTIONS=""

#-------------------------------------------------------------------------------
# functions
#-------------------------------------------------------------------------------
f_usage(){
  #print help and exit
  cat << EOF
  ${SCRIPT_NAME} : download and package tomcat7 from archive.apache.org
    -h : help, this message
    -d : mandatory, tomcat7 version to download (ex 7.0.59)
    -t : facultative, temporary dir for download and extract (default /tmp)
    -o : facultative, output dir for packages (default working dir), try to create it if non-existant.
    -e : facultative, easyfpm cmdline options

  examples:
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages -e "--label tomcat7"
    ${SCRIPT_NAME} -d 7.0.59 -o /data/packages -e "--label tomcat7-fulldocs,tomcat7-deployer,tomcat7-embed,tomcat7-extra-catalina-jmx-remote,tomcat7-catalina-ws,tomcat7-juli-adapters,tomcat7-juli"
EOF
}

f_clean_all(){
  #Clean all temporaries elements
  if [ -d ${SCRIPT_TMP}/${SCRIPT_TMP_DIR} ];
  then
    rm -Rf ${SCRIPT_TMP}/${SCRIPT_TMP_DIR}
  fi
  unset SCRIPT_NAME SCRIPT_TMP SCRIPT_OUTPUT TOMCAT7_VERSION EASYFPM_CONF EASYFPM_OPTIONS
}

f_error_exit(){
  printf "$1\n"
  exit 1
}

#-------------------------------------------------------------------------------
# main
#-------------------------------------------------------------------------------
trap "f_clean_all" HUP INT QUIT KILL EXIT TERM EXIT TERM

## get and manage parameters
typeset -x OPTIND=1
while getopts d:t:o:e:h opt
do
  case ${opt} in
    d ) TOMCAT7_VERSION="${OPTARG}";;
    t ) SCRIPT_TMP="${OPTARG}";;
    o ) SCRIPT_OUTPUT="${OPTARG}";;
    e ) EASYFPM_OPTIONS="${OPTARG}";;
    h ) f_usage
        exit 0;;
    \?) f_usage
        exit 1;;
  esac
done

## verifying parameters
