#!/bin/bash

echo PREFIX

##! { toggle feat/a:first }
echo 'feat/a:first'
# a mode may have comments, but no empty lines
echo 'feat/a:first multiline'

# this will not belong to feat/a:first anymore
echo IN_BETWEEN

##! { toggle feat/a:second }
#- # prefix lines with \`#- \` to mark disabled
#- echo 'feat/a:second'

# An empty mode can be defined for on/off switches
##! { toggle dark:off }
# add at least a comment to show as "enabled"
##! { toggle dark:on }
#- echo 'dark:on'

echo END
