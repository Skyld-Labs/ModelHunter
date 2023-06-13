# ModelHunter: ML Model Extraction Pipeline for Android Applications

### ModelHunter is a powerful pipeline designed to extract and test machine learning models from Android applications available on the Google Play Store.

---
## Requirements : 

A Linux-based system with Firefox installed to enable app downloads using Selenium.
Install the following Linux packages:

```console
sudo apt-get install aapt apktool silversearch-ag nm md5sum
```

Install the required Python packages with pip:
```
pip install configparser progressbar db-sqlite3 selenium
```

Or install poetry and use the poetry environement : 
```console
$ poetry install
Creating virtualenv modelhunter-6WcazSRI-py3.10 in /home/user/.cache/pypoetry/virtualenvs
Updating dependencies
Resolving dependencies... (2.6s)

Writing lock file

Package operations: 20 installs, 0 updates, 0 removals

  • Installing attrs (22.2.0)
  • Installing async-generator (1.10)
  • Installing exceptiongroup (1.1.0)
  • Installing h11 (0.14.0)
  • Installing idna (3.4)
  • Installing outcome (1.2.0)
  • Installing sniffio (1.3.0)
  • Installing sortedcontainers (2.4.0)
  • Installing antiorm (1.2.1)
  • Installing pysocks (1.7.1)
  • Installing trio (0.22.0)
  • Installing wsproto (1.2.0)
  • Installing certifi (2022.12.7)
  • Installing db (0.1.1)
  • Installing trio-websocket (0.9.2)
  • Installing urllib3 (1.26.14)
  • Installing configparser (5.3.0)
  • Installing db-sqlite3 (0.0.1)
  • Installing progressbar (2.5)
  • Installing selenium (4.8.0)

$ poetry shell 
Spawning shell within ...

```

---
## Files : 

- `hunt.sh` - Pipeline for app analysis
- `scrapping-playstore.sh` - Scrap Google Play 
- `sort-report.sh` - extract some information from report
- `googleplaydownloader/apkdownloader_combo/main.py` -  Python script to download Android apps
- `modelhunter/modelhunter.py` - script to find and extract models 
- `modelhunter/model_stat.db` - results inside a SQLite DB 




---
## Basic usage

```console
$ ./hunt.sh -h
Usage hunt.sh [-v][-s][-h][-p {package_id}][-d]{directory with apks}
		-v | Verbose
		-s | Scrap package ID on Google play, keywords for research are inside search-keyword.txt
		-p {package_id}| APK to test, it will be downloaded, the results can be found inside APP_RESULT and the database
		-d {/path/to/apk_directory} | Directory with APKs to test 
```

--- 

### Example : 

**Testing an app :**

```console
$ ./hunt.sh -p com.example.app
Starting analysis of com.example.app
Trying to download com.example.app
com.example.app will be saved at : /ModelHunter/APK_DIRECTORY
```

**Testing all apps from a directory :**

```console
$./hunt.sh -d ./APK_DIRECTORY
Starting analysis of com.example.app
Trying to download com.example.app
```


**Scraping application package IDs on Google Play and analysing them :**

```
$ ./hunt.sh -s
Start scrapping, list of applications will be writen in app_ids.txt
###
# Test 0/22541 with application : com.example.app
###
```



**You can use it without any options, it will take the default config inside config.sh :**
```
#!/usr/bin/env bash
APP_ID='app_ids.txt'
APP_TESTED='app_ids_tested.txt'

APP_RESULT='./APP_RESULT'
APK_DIRECTORY='./APK_DIRECTORY'

# APK_DIRECTORY="$PWD/APK_DIRECTORY"
MODELHUNTER_PATH='./modelhunter'
KEYWORD_SCRAPPING='./search-keyword.txt'
DOWNLOADER='python3 ./googleplaydownloader/apkdownloader_combo/main.py'
VERBOSE='FALSE'
SAVE_APK='TRUE' # FALSE TO NOT SAVE APK
SCRAPING='FALSE'
```

For example you can change the way you want to download the APKs if you have a better tool to do it!

---

## Results : 
You will find : 
- inside APP_RESULT/ directory - all reports of tested apps and their models if a model was found.
- inside modelhunter/model_stat.db - a SQLite DB with all important information for further analysis 
