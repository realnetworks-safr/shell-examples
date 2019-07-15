#!/bin/sh

BASE_URL="https://cv-event.int2.real.com"
AUTHENTICATION=$1
AUTHORIZATION=$2

echo "===> Retrieving the current time from the server. <==="
echo "curl $BASE_URL/event/status -H \"X-RPC-AUTHORIZATION: $AUTHENTICATION\" -H \"Authorization: $AUTHORIZATION\""

curl \
  "$BASE_URL/event/status" \
  -H "X-RPC-AUTHORIZATION: $AUTHENTICATION" \
  -H "Authorization: $AUTHORIZATION"\
 | python -m json.tool > response_mod_date.json

cat response_mod_date.json

lastModDate=$( grep "lastModDate" response_mod_date.json | awk ' { print $2 }' | tr -d ',')
originalModDate=$lastModDate

while : 
do 
	echo "curl $BASE_URL/event/status/?since=$lastModDate -H \"X-RPC-AUTHORIZATION: $AUTHENTICATION\" -H \"Authorization: $AUTHORIZATION\""
    curl \
     "$BASE_URL/event/status/?since=$lastModDate" \
      -H "X-RPC-AUTHORIZATION: $AUTHENTICATION" \
      -H "Authorization: $AUTHORIZATION"\
     | python -m json.tool > response_mod_date.json

    cat response_mod_date.json

    previousModDate=$lastModDate
    lastModDate=$( grep "lastModDate" response_mod_date.json | awk ' { print $2 }' | tr -d ',')

    if [ -z "$lastModDate" ]
    then
        lastModDate=$previousModDate
        echo "==================================== no events...204 =========================================="
    else
		echo "$BASE_URL/events?sinceModDate=$previousModDate&sinceTime=$originalModDate -H \"X-RPC-AUTHORIZATION: $AUTHENTICATION\" -H \"Authorization: $AUTHORIZATION\""
        curl \
         "$BASE_URL/events?sinceModDate=$previousModDate&sinceTime=$originalModDate" \
          -H "X-RPC-AUTHORIZATION: $AUTHENTICATION" \
          -H "Authorization: $AUTHORIZATION"\
         | python -m json.tool > events_response_mod_date.json

        cat events_response_mod_date.json
    fi
    echo " ===> Last mod date: $lastModDate, Previous last mod date: $previousModDate <=== "
done



