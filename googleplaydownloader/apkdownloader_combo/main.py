#!/bin/python3 

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.firefox.options import Options
from selenium.webdriver.firefox.service import Service
from selenium.webdriver.common.action_chains import ActionChains
import time, sys, os


def get_browser(directory):
    firefox_options = Options()
    if directory:
        # Change directory where download are sent 
        firefox_options.set_preference("browser.download.folderList", 2)
        firefox_options.set_preference("browser.download.useDownloadDir", True)
        firefox_options.set_preference("browser.download.dir", directory)

        # Open firefox without GUI
        firefox_options.add_argument('--headless')

    browser = webdriver.Firefox(options=firefox_options)

    # Make sure we have enough space to see buttons
    browser.set_window_size(1920, 1080)

    return browser

def getDownLoadedFileName(browser, waitTime):
    browser.get("about:downloads")

    endTime = time.time()+waitTime
    progressbar = browser.find_elements(By.CLASS_NAME,'downloadProgress')
    
    end = False
    while not end and len(progressbar) >= 1:
        end = True
        # Check progress bar statut
        for element in progressbar:
            print('\r' + element.get_attribute('value') + '%',end='')
            if element.get_attribute('value') != '100':
                end = False

    fileName = browser.execute_script("return document.querySelector('#contentAreaDownloadsView .downloadMainArea .downloadContainer description:nth-of-type(1)').value")
    if fileName:
        return fileName


def download_app(full_path, appid):
    browser = get_browser(full_path)

    browser.get("https://apkcombo.com/fr/downloader/#package=" + appid)
    time.sleep(10)
    
    # Accep cookie :
    # Remove from site ???
    browser.find_elements(By.XPATH,'//*[text()[contains(.,"AGREE")]]')[0].click()

    download_button = browser.find_elements(By.CSS_SELECTOR,"a[href*='https://download.apkcombo.com']")
    if len(download_button) == 0:
        download_button = browser.find_elements(By.CSS_SELECTOR,"a[href*='https://gcdn.androidcombo.com']")
    if len(download_button) == 0:
        download_button = browser.find_elements(By.CSS_SELECTOR,"a[href*='https://download.apkcombo.app']")
    
    if len(download_button) == 0:
        print('No Download Button found')
        browser.close()
        exit(-1)

    # Scroll to download button 
    browser.execute_script("window.scrollTo(0, "+str(download_button[0].location['y'])+")")
    download_button[0].click()
    
    time.sleep(5)

    # Remove AD
    action = ActionChains(browser)
    action.click()

    time.sleep(5)
    # Wait end of download 
    latestDownloadedFileName = getDownLoadedFileName(browser, 180) #waiting 3 minutes to complete the download
    
    os.rename(full_path + "/" + latestDownloadedFileName, full_path + "/" + appid + ".apk" )
    print('Success Download') 
    browser.close()


###########################
# Tool to download android APK from command-line 
#
# Usage : 
# 	main.py com.spotify.music DirectoryWhereToDownload
#
def main():
    if len(sys.argv) < 3:
        print('Usage: %s com.exemple.text directory' % sys.argv[0])
        exit(-1)

    full_path = os.path.abspath(sys.argv[2])
    print('%s will be save at : %s' % (sys.argv[1], full_path))
    download_app(full_path, sys.argv[1])
    exit(0)

main()

