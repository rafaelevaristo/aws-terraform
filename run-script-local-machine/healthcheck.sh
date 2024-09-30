#!/bin/sh

result=$(curl -X GET --header "Accept: */*" "https://$DESTINATION/todos/1" | jq -r '.id')

if [ $result -eq 1 ]
then
   exit 0
else
   exit 1
fi