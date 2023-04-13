# ModelHunter : Pipeline for extract ML model from android applications

### ModelHunter is a pipeline that able us to test and extract model from application from the Google PlayStore.

---
## Requirement : 

A linux base system and firefox install to be able to download app with Selenium.

Some linux package : 
```console
sudo apt-get install aapt apktool silversearch-ag nm md5sum
```

There is some python package needed too.
To install them you can do it manually : 
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
- `googleplaydownloader/apkdownloader_combo/main.py` -  Python script to download Android app
- `modelhunter/modelhunter.py` - script to find and extract model 
- `modelhunter/model_stat.db` - result inside a SQLite DB 




---
## Basic usage

```console
$ ./hunt.sh -h
Usage hunt.sh [-v][-s][-h][-p {package_id}][-d]{directory with apk}
		-v | Verbose
		-s | Scrap package id on Google play, keyword for research are inside search-keyword.txt
		-p {package_id}| APK to test, it will be download, then test result can be found inside APP_RESULT, and databse
		-d {/path/to/apk_directory} | Directory with APK to test 
```

--- 

### Example : 

**Test an app :**

```console
$ ./hunt.sh -p com.example.app
Start analysis of package com.example.app
Try download it com.example.app
com.example.app will be save at : /ModelHunter/APK_DIRECTORY
```

**Test all app from a directory :**

```console
$./hunt.sh -d ./APK_DIRECTORY
Start analysis of package com.example.app
Try download it com.example.app
```


**Scrap Application package id on Google Play and start analyse them :**

```
$ ./hunt.sh -s
Start scrapping, list of application will be write in app_ids.txt
###
# Test 0/22541 with application : com.example.app
###
```



**You can use it without any option it will take the default config inside config.sh :**
```
#!/bin/bash
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

For example you can change the way you want download APK if you have a better tool to do it!

---

## Result : 
You will find : 
- inside APP_RESULT/ directory - all report of tested app and their model if model are found.
- inside modelhunter/model_stat.db - a SQLite DB with all importante information to further analysis 