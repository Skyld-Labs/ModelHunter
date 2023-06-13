#!/usr/bin/env bash

VERBOSE='FALSE'
RECURSIVE='FALSE'
SEARCH='lens'
while getopts ":vrq:" option; do
   case $option in
      v) # Verbose 
         VERBOSE='TRUE'
        ;;
      r) # Recursive
         RECURSIVE='TRUE' 
      ;;
      q) # Query
         SEARCH=$OPTARG
      ;;
   esac
done

playstore_search(){



URL="https://play.google.com/store/search?q=$SEARCH&c=apps"
RESULT=$(curl $URL -s | grep -o '"/store/apps/details?id[^"]*' | sort | uniq | sed 's/\\u003d/=/g' | cut -d'=' -f2 | sort | uniq )

if [[ $VERBOSE == 'TRUE' ]]; then
	echo "Searching app for $1...." 1>&2
	echo "url : $URL" 1>&2
   echo "curl $URL "
fi

if [[ $RECURSIVE == 'TRUE' ]]; then
for i in $RESULT; do
   URL="https://play.google.com/store/apps/details?id=$i&c=apps"
   RESULT2=$(curl $URL -s | grep -o '"/store/apps/details?id[^"]*' | sort | uniq | sed 's/\\u003d/=/g' | sed 's/\\u0026hl//g' | cut -d'=' -f2 | sort | uniq )

   FINAL_RESULT+=$RESULT2

   
done
fi
FINAL_RESULT+=$RESULT
printf '%s\n' "${FINAL_RESULT[@]}" |sort |uniq 

}


playstore_search $SEARCH