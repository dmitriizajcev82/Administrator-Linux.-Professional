#!/bin/bash
# open file user
echo "****************USER**************************"
lsof | wc -l
# open file ROOT
echo "****************ROOT**************************"
sudo lsof | wc -l

echo "**********************************************"
files=$(sudo lsof -P -i -n | cut -f 1 -d " " | uniq | tail -n +2)
printf "$files"
echo "**********************************************"
lsof -iTCP | grep firefox
echo "**********************************************"
sudo lsof -iTCP | grep ssh

exit 0
