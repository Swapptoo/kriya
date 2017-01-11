import os
import sys
import json
import io
import requests
import time
import csv
from selenium import webdriver
from selenium.common.exceptions import WebDriverException
from selenium.webdriver.support.ui import WebDriverWait
from BeautifulSoup import BeautifulSoup as bs
from check_source import check_source
from random import randint
import csv

reload(sys)
sys.setdefaultencoding('UTF8')

f = open('skills.csv', 'r')
data = csv.reader(f)

driver = webdriver.PhantomJS()
driver.set_window_size(1920, 1080)

url = 'https://duckduckgo.com?q='

for i, skill_1 in enumerate(data):
    for ii, skill_2 in enumerate(data):

        if i == ii:
            continue

        driver.get(url + skill_1[0] + " and " + skill_2[0])
        check_source(driver)

        print(skill_1[0] + " and " + skill_2[0] + " comparison html extracted")

        driver.save_screenshot('screens/' + skill_1[0] + ' ' + skill_2[0] + '.png')
        source = bs(driver.page_source.encode('utf-8')).prettify()

        with open('html/' + skill_1[0] + ' ' + skill_2[0] +  '.html', 'w') as outfile:
            outfile.write(source)
            outfile.close()
