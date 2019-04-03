#!/bin/bash
#Docker bench php

#Usage .\bensh.sh $action $startNum $endNum
#$action : add or del to add or remove containers containers
#$startNum : Start Number
#$endNum : end number

#Assign parameters
action=$1
startNum=$2
endNum=$3

if [ $action = "add" ]
then
	echo Pulling PHP5.4 image
	docker pull php:5.4-apache
	echo Genrating $endNum-$startNum containers
	for ((i=$startNum;i<=$endNum;i++)); 
	do 
		echo Genrating container $i
		docker run --name php$i --detach --publish-all --volume /var/www/html php:5.4-apache
	done
fi

if [ $action = "del" ]
then
	echo "deleting..."
	for ((i=$startNum;i<=$endNum;i++)); 
	do 
		echo "Deleting container" $i
		docker rm -v --force php$i
	done
fi

echo All done
