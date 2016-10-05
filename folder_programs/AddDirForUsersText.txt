#!/bin/bash
# Script to add directories for users.

#List all users on system
awk -F ':' '{if ($3 >= 1000 && $3 <= 60000) {print $1, $3}}' /etc/passwd >file.txt

#Make directories in current directory
while read name id; do
	mkdir -p -m 770 "$name";
	chown "$id":"$id" "$name"
done	<file.txt

#Remove file.txt
if (-f file.txt)
	rm -rf file.txt
fi