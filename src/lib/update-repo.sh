#!/bin/bash

# Check if repository is already cloned
if [ ! -d "/usr/lib/doil/tpl/repos/ilias" ]
then
  git clone git@github.com:ILIAS-eLearning/ILIAS.git /usr/lib/doil/tpl/repos/ilias
else
  cd /usr/lib/doil/tpl/repos/ilias && git fetch origin
fi
if [ ! -d "/usr/lib/doil/tpl/repos/catilias" ]
then
  git clone git@github.com:conceptsandtraining/ILIAS.git /usr/lib/doil/tpl/repos/catilias
else
  cd /usr/lib/doil/tpl/repos/catilias && git fetch origin
fi
if [ ! -d "/usr/lib/doil/tpl/repos/tms" ]
then
  git clone git@github.com:conceptsandtraining/TMS.git /usr/lib/doil/tpl/repos/tms
else
  cd /usr/lib/doil/tpl/repos/tms && git fetch origin
fi
