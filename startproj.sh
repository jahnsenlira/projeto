#!/bin/bash

A=$( yad --entry --title='Start Process' --entry-label='Command:' )
bash -c "gnome-terminal -- $A"
