#!/bin/bash
if [ -e list.cpp && -e list.h && -e main.cpp ]; then
    clear
    g++ main.cpp list.cpp -o circleList.o 2> error.txt
    if [ -e circleList.o ]; then
	.circlelist.o
    else
    	echo "Program did not compile correctly. Please read error.txt."
    fi
else
    echo "One or more files do not exist"
fi
    
