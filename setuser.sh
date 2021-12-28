#!/bin/bash

USERS=$( cat /etc/passwd | cut -d ":" -f 1 | tr "\n" "!" )

USR=$(
	yad --form                           \
	--title="Filter by user"             \
	--width=300 --height=100 --center    \
	--window-icon="icon.ico"             \
	--no-escape                          \
	--fixed                              \
	--field="User:CB" !^all!${USERS}     \
	--button="Filtrar:0" | tr -d "|"
)

echo "${USR}"
