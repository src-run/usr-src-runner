#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

export ACTION=""

if [[ ${SCRIPT_CALLER_MAIN} ]]
then
    case "${1}" in
        up)
            ACTION=up-php
        ;;

        down)
            ACTION=up-php
        ;;

        dn)
            ACTION=up-php
        ;;

        up-php)
            ACTION=up-php
        ;;

        dn-php)
            ACTION=dn-php
        ;;

        up-app)
            ACTION=up-app
        ;;

        dn-app)
            ACTION=dn-app
        ;;

        *)
            echo -en "\nUsage:\n\t./${SCRIPT_CALLER_NAME} (up-|dn-)(php|env)\n\nExamples:\n" \
                "\t./${SCRIPT_CALLER_NAME} up-php    [ setup php requirements - before composer run or tests ]\n" \
                "\t./${SCRIPT_CALLER_NAME} dn-php    [ handle post-test operations - submit code coverage, etc ]\n" \
                "\t./${SCRIPT_CALLER_NAME} up-app    [ setup php app requirements - install fixtures, etc ]\n" \
                "\t./${SCRIPT_CALLER_NAME} dn-app    [ not currently used for anything - placeholder ]\n\n"
            exit
        ;;
    esac

    newLine
    outWelcome \
        "ENV-BUILDER" \
        "@@license ... MIT License" \
        "@@version ... 0.9.0" \
        "@@author .... Rob Frawley 2nd <rmf@build.fail>" \
        "@ @ Simple build tool for PHP projects that uses a collection of bash scripts" \
        "to bring a system environment into a desired state. See the readme distributed" \
        "with the source for usage information."

    case "${1}" in
        up)
            newLine
            outWarning "Use of the 'up' command has been depecated in favor of 'up-php' and will" \
                "therefore be removed in a subsequent release."
            ACTION=up-php
            sleep 5
        ;;

        down)
            newLine
            outWarning "Use of the 'down' command has been depecated in favor of \"dn-php\" and will" \
                "therefore be removed in a subsequent release."
            sleep 5
            ACTION=dn-php
        ;;

        dn)
            newLine
            outWarning "Use of the 'dn' command has been depecated in favor of \"dn-php\" and will" \
                "therefore be removed in a subsequent release."
            sleep 5
            ACTION=dn-php
        ;;
    esac
fi

. /etc/lsb-release || \
    outError "Automatic builds only supported on Ubuntu at this time. Could not find lsb_release file."

[[ $(valueInList ${DISTRIB_CODENAME:-x} ${VER_ENV_DIST_SUPPORTED}) != "true" ]] || \
    outError "Automatic builds only supported on OS versions (${VER_ENV_DIST_SUPPORTED}) at this time." \
    "Found version ${DISTRIB_CODENAME}."

[[ "${BIN_PHP:-x}" == "x" ]] && \
    outError "Could not find a valid PHP binary within your configured path: \"${PATH}\"."

if [ "${TRAVIS:-x}" == "x" ]
then
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        CMD_PRE="sudo "
        env_location="local"
        env_with_phpenv="no"
        env_ver_phpenv="(PHPENV n/a)"
    else
        env_location="local"
        env_with_phpenv="yes"
        env_ver_phpenv="(PHPENV v${VER_PHPENV})"
    fi
else
    if [ "${BIN_PHPENV:-x}" == "x" ]; then
        env_location="travis"
        env_with_phpenv="no"
        env_ver_phpenv="(PHPENV n/a)"
    else
        env_location="travis"
        env_with_phpenv="yes"
        env_ver_phpenv="(PHPENV v${VER_PHPENV})"
    fi
fi

if [ "${PKG_ENV_VARIABLE:-x}" == "x" ]
then
    outError "The 'build_package' enviornment variable must be defined!"
fi

if [ "${PKG_ENV_VARIABLE}" == "true" ]
then
    PKG_ENV_VARIABLE="${PKG_YML_FILEPATH}" && \
        outInfo "Attempting to use default package config location of ${PKG_YML_FILEPATH}."
fi

if [ ! -f "${SCRIPT_CALLER_ROOT}/${PKG_ENV_VARIABLE}" ]; then
    outError "Unable to find the package configuration. This must be defined and set to the" \
        "location of your configuration YAML, or simply true to use the default path."
fi

eval $(parseYaml "${SCRIPT_CALLER_ROOT}/${PKG_ENV_VARIABLE}" "${PKG_PRE_VARIABLE}")

for item in $(commaToSpaceSeparated ${PKG_REQ_VARIABLE})
do
    if [ ${item:-x} == "x" ] || [ ${!item:-x} == "x" ] || [ ${!item:-x} == "~" ]
    then
        assignIndirect "${item}" ""
    fi
done

if [[ -z "${scr_pkg_app_path}" ]]
then
    export APP_MAKE_CLI="$(readlink -m ${DIR_CWD}/app/console)"
else
    export APP_MAKE_CLI="$(readlink -m ${DIR_CWD}/${scr_pkg_app_path})"
fi

# EOF #
