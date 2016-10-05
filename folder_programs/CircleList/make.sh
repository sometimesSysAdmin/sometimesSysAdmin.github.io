#!/bin/bash
echo -e "Please enter file name to link with main"
read file
if [ -e $file.cpp ]; then
    clear
    g++ -Wall -Wextra main.cpp $file.cpp -o $file.o 2> error.txt
    if [ -e $file.o ]; then
	./$file.o
    fi
else
    echo "File does not exist"
fi
    
