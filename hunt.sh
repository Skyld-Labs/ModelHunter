#!/usr/bin/env bash

source config.sh

#################################################################################
###				Test File Exist
#################################################################################
create_dir_ifnexist(){
	if [[ ! -d $1 ]]; then 
	    echo "[$(date +%FT%T)] - Create $1 directory"
	    mkdir $1
	fi
}

create_file_ifnexist(){
	if [[ ! -f $1 ]] ; then 
		echo "[$(date +%FT%T)] - Create $1 directory"
		touch $1
	fi
}

create_dir_ifnexist $APK_DIRECTORY
create_dir_ifnexist $APP_RESULT

create_file_ifnexist $APP_ID
create_file_ifnexist $APP_TESTED

#################################################################################
###				Test Option
#################################################################################

while getopts ":vshp:d:" option; do
   case $option in
      v) # Verbose 
         VERBOSE='TRUE'
        ;;
	  s)
	  	 SCRAPING='TRUE'
		 ;;
	  p)
	  	PACKAGE_ID=$OPTARG
		;;
	  d)
	  	APK_DIRECTORY=$OPTARG
		;;
	  h)
	  	echo "Usage $0 [-v][-s][-h][-p {package_id}][-d]{directory with apk}"
		echo """
		-v | Verbose
		-s | Scrap package id on Google play, keywords for research are inside search-keyword.txt
		-p {package_id}| APK to test, it will be downloaded, the results can be found inside APP_RESULT and the database
		-d {/path/to/apk_directory} | Directory with APKs to test 
		"""
		exit 0
		;;
   esac
done

#################################################################################
###				ModelHunter
#################################################################################

# param : 
# app_name download_directory
static_analysis(){
	echo "Starting Static analysis"
	save_path="$PWD"
	dir_test="$APP_RESULT/$1"
	create_dir_ifnexist $dir_test
	cd "$MODELHUNTER_PATH"

	python3 modelhunter.py "$2/$1.apk"
	
	cd $save_path
	cp "$MODELHUNTER_PATH/output_dir/$1/report.md" $dir_test
	# If a model is found 
	if [[ $(ls "$MODELHUNTER_PATH/output_dir/models/" | wc -c) -gt 0 ]]; then
		create_dir_ifnexist "$dir_test/models"
		for i in $(ls "$MODELHUNTER_PATH/output_dir/models/")
		do
			cp "$MODELHUNTER_PATH/output_dir/models/$i" "$dir_test/models"
		done
	fi
	rm -Rf "$MODELHUNTER_PATH/output_dir/"
	rm -Rf "$MODELHUNTER_PATH/decomposed_dir/"
}

#################################################################################
###				Scrapping
#################################################################################

scrapping(){
	for i in $(cat $KEYWORD_SCRAPPING)
	do	
		if [[ $SCRAPING == 'TRUE' ]]; then
			 echo "Scrapping keyword $i"
			./scrapping-playstore.sh -rq $i >> $APP_ID
		fi
	done
}

#################################################################################
### 	Analyse an App			
#################################################################################

analyse(){
	APP_ID=$1
	DEST_APK=$(readlink -e $2)
	# Download APK with selenium on firefox
	if [[ ! -f "$DEST_APK/$APP_ID.apk" ]] ; then 
		echo "Trying to download $APP_ID" 
		$DOWNLOADER $APP_ID $DEST_APK/
	else 
		echo "Already downloaded $APP_ID" 
	fi

	if [[ $? != -1 ]] ; then
		# Give an app name and it will go search in the right directory 
		static_analysis "$APP_ID" "$DEST_APK"
		if [[ $SAVE_APK == 'FALSE' ]]; then
			echo "File supressed"
			rm $APP_ID/$APP_ID.apk
		fi
	fi
}
#################################################################################
### 	Analyse list of Apps			
#################################################################################

# Take as argument a list of apps
analyse_list(){
	LIST=$@
	MAX=$#
	COUNT=0
	for app in $LIST; do
		echo "###"
		echo "# Test $COUNT/$MAX application : $app"
		echo "###"

		COUNT=$(($COUNT+1))
		DIFF=$(awk '$0 == "'$app'"' $APP_TESTED | wc -l) 
		
		# Search if the application is already tested, if not test it
		if [[ $DIFF -eq 0 ]] ; then
			# Analyse app 
			analyse "$app" $APK_DIRECTORY
			echo "$j" >> $APP_TESTED
		else
			echo "Already tested !"
		fi
	done
}


#################################################################################
###			Main
#################################################################################

if [[ $VERBOSE == 'TRUE' ]]; then
	echo "Start creating App id list" 2>&1
fi

if [[ "$PACKAGE_ID" != "" ]]; then 
	echo "Starting analysis of package $PACKAGE_ID"
	analyse $PACKAGE_ID $APK_DIRECTORY
	exit 1
fi

if [[ $SCRAPING == 'TRUE' ]]; then 
	# analyse application find by scrapping Google Play
	echo "Starting scrapping, list of application will be writen in $APP_ID"
	scrapping
	analyse_list $(cat $APP_ID)
else
	# analyse application download inside APK_DIRECTORY
	echo "Use 'config.sh' as base configuration."
	echo "..."
	echo "Starting analyse of applications inside $APK_DIRECTORY"
	analyse_list $(ls $APK_DIRECTORY | sed 's/.apk//g')	
fi
