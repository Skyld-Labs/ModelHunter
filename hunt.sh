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
		-s | Scrap package id on Google play, keyword for research are inside search-keyword.txt
		-p {package_id}| APK to test, it will be download, then test result can be found inside APP_RESULT, and databse
		-d {/path/to/apk_directory} | Directory with APK to test 
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
	echo "Start Static analysis"
	save_path="$PWD"
	dir_test="$APP_RESULT/$1"
	create_dir_ifnexist $dir_test
	cd "$MODELHUNTER_PATH"

	python3 modelhunter.py "$2/$1.apk"
	
	cd $save_path
	cp "$MODELHUNTER_PATH/output_dir/$1/report.md" $dir_test
	# If model is found 
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
			 echo "Scrap for $i"
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
		echo "Try download it $APP_ID" 
		$DOWNLOADER $APP_ID $DEST_APK/
	else 
		echo "Already download $APP_ID" 
	fi

	if [[ $? != -1 ]] ; then
		# Give app name and it will go search in the right directory 
		static_analysis "$APP_ID" "$DEST_APK"
		if [[ $SAVE_APK == 'FALSE' ]]; then
			echo "File supress"
			rm $APP_ID/$APP_ID.apk
		fi
	fi
}
#################################################################################
### 	Analyse list of App			
#################################################################################

# Take in argument a list of app
analyse_list(){
	LIST=$@
	MAX=$#
	COUNT=0
	for app in $LIST; do
		echo "###"
		echo "# Test $COUNT/$MAX with application : $app"
		echo "###"

		COUNT=$(($COUNT+1))
		DIFF=$(awk '$0 == "'$app'"' $APP_TESTED | wc -l) 
		
		# Search if application is already tested, if not test it
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
	echo "Start analysis of package $PACKAGE_ID"
	analyse $PACKAGE_ID $APK_DIRECTORY
	exit 1
fi

if [[ $SCRAPING == 'TRUE' ]]; then 
	# analyse application find by scrapping Google Play
	echo "Start scrapping, list of application will be write in $APP_ID"
	scrapping
	analyse_list $(cat $APP_ID)
else
	# analyse application download inside APK_DIRECTORY
	echo "Use 'config.sh' as base configuration."
	echo "..."
	echo "Start analyse application inside $APK_DIRECTORY"
	analyse_list $(ls $APK_DIRECTORY | sed 's/.apk//g')	
fi
