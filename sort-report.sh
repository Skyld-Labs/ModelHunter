#!/usr/bin/env bash

APP_RESULT='APP_RESULT/'
SORT_RESULT='SORT_RESULT'

#################################################################################
###				Test File Exists
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

create_dir_ifnexist $SORT_RESULT

cd $APP_RESULT

echo -n "Number of applications tested (some errors were not checked for the moment) : "
cat ../app_ids_tested.txt | wc -l

echo -n "Number of Reports :"
find . -name report.md | wc -l

echo -n "Number of applications with AI keyword found :"
find . -name report.md -exec bash -c "grep -q 'magic word .*:' {} && echo {}" \; | grep -o "./[^/]*/" | sed "s/\(\.\/\|\/\)//g"  > ../$SORT_RESULT/'app_with_keyword_found.txt'
find . -name report.md -exec bash -c "grep -q 'magic word .*:' {} && echo {}" \; | grep -o "./[^/]*/" | wc -l

echo -n "Number of applications with AI keyword found (without cnn, rnn) :"
find . -name report.md -exec bash -c "cat {} | grep 'magic word' | grep -v 'cnn\|rnn' && echo {}" \; | grep -o "./[^/]*/" | sed "s/\(\.\/\|\/\)//g" > ../$SORT_RESULT/'app_with_keyword_found_without_cnn_rnn.txt'
find . -name report.md -exec bash -c "cat {} | grep 'magic word' | grep -v 'cnn\|rnn' && echo {}" \; | grep -o "./[^/]*/" | wc -l

echo -n "Number of models found (can contain false positives) : "
find . -type f -wholename "*/models/*" -exec echo {} \; | wc -l

echo -n "Number of models encrypted found (can contain false positives) : "
for i in $(find . -type f -wholename "*/models/*" -exec echo {} \; | sort | cut -d'/' -f2 | uniq); do  cat $i/report.md | grep '^[0-9]\.[0-9]*'; done | grep '^[7-9]\.9[0-9]*' | wc -l

echo -n "Number of applications that contain models :"
find . -name models -exec echo {} \; | grep -o "./[^/]*/" | sed "s/\(\.\/\|\/\)//g" > ../$SORT_RESULT/'app_with_models.txt'
find . -name models -exec echo {} \; | grep -o "./[^/]*/" | wc -l

echo -n "Number of applications which have models and keywords : "
comm -12 <(find . -name models -exec echo {} \; | grep -o "./[^/]*/" | sort) <(find . -name report.md -exec bash -c "grep -q 'magic word .*:' {} && echo {}" \; | grep -o "./[^/]*/" | sort ) | sed "s/\(\.\/\|\/\)//g" > ../$SORT_RESULT/'app_with_models_and_keyword.txt'
comm -12 <(find . -name models -exec echo {} \; | grep -o "./[^/]*/" | sort) <(find . -name report.md -exec bash -c "grep -q 'magic word .*:' {} && echo {}" \; | grep -o "./[^/]*/" | sort ) | wc -l

echo -n "Number of applications which haven't models and keyword tensorflow : "
comm -12 <(find . -type d -exec test -e "{}/models" ';' -prune -o -print |  grep -o "./[^/]*/" | sort -u) <(find . -name report.md -exec bash -c "grep -q 'magic word tensorflow:' {} && echo {}" \; | grep -o "./[^/]*/" | sort ) | sed "s/\(\.\/\|\/\)//g" > ../$SORT_RESULT/'app_without_models_and_keyword_tensorflow.txt'
comm -12 <(find . -type d -exec test -e "{}/models" ';' -prune -o -print |  grep -o "./[^/]*/" | sort -u) <(find . -name report.md -exec bash -c "grep -q 'magic word tensorflow:' {} && echo {}" \; | grep -o "./[^/]*/" | sort ) | wc -l

echo -n "Number of applications with a TensorFlow models : "
find . -type f -wholename "*/models/*" -exec echo {} \; | grep '\.tfl' | sort | cut -d'/' -f2 | uniq > ../$SORT_RESULT/'app_with_tensorflow_model.txt'
find . -type f -wholename "*/models/*" -exec echo {} \; | grep '\.tfl' | sort | cut -d'/' -f2 | uniq | wc -l

echo -n "Number of Tensorflow models : "
find . -type f -wholename "*/models/*" -exec echo {} \; | grep '\.tfl' | sort | cut -d'/' -f4 | uniq | wc -l

echo -n "Number of applications containing Tensorflow encrypted models : "
find . -name report.md -exec bash -c "cat {} | grep '\.tfl' | grep '^[7-9]\.9[0-9]*'" \; -exec echo {} \; | grep -o "./[^/]*/" | sed "s/\(\.\/\|\/\)//g" > ../$SORT_RESULT/'app_with_encrypted_models.txt'
find . -name report.md -exec bash -c "cat {} | grep '\.tfl' | grep '^[7-9]\.9[0-9]*'" \; -exec echo {} \; | grep -o "./[^/]*/" | sed "s/\(\.\/\|\/\)//g" | wc -l


echo -n "Number of Tensorflow encrypted models : "
find . -name report.md -exec cat {} \; | grep '\.tfl' | grep '^[7-9]\.9[0-9]*' | awk '{ print $3 }' > ../$SORT_RESULT/'name_tensorflow_encrypted_models.txt'
find . -name report.md -exec cat {} \; | grep '\.tfl' | grep '^[7-9]\.9[0-9]*' | awk '{ print $3 }' | wc -l

echo "_____________________________"
echo "Number of time each keyword was found :"
find . -name report.md -exec bash -c "grep 'magic word .*:' {} " \; | sort | uniq -c | awk '{ print $5, $1 }'

