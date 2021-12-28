#!/bin/bash

A=$( yad --form --title='Schudle Process' --field='Command:'TEXT --field='Min':NUM )

COMMAND=$(echo "$A" | cut -d'|' -f1)
MIN=$(echo "$A" | cut -d'|' -f2)
TEMPO=$(date --date "now +${MIN%%.*} min" | egrep -o '[0-9]{2}:[0-9]{2}')
at ${TEMPO} <<< ${COMMAND}

