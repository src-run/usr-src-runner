#!/usr/bin/env bash

##
# This file is part of `scr-be/shared-project-knowledge`
#
# (c) Rob Frawley 2nd <rmf@scr.be>
#
# For the full copyright and license information, view the LICENSE.md
# file distributed with this source code.
##

RT_COMMANDS_ACT=(
    "${APP_MAKE_CLI} doctrine:database:create -n"
    "${APP_MAKE_CLI} doctrine:schema:create -n"
)

# EOF #
