#!/usr/bin/python3.6
from urllib.request import urlopen
from bs4 import BeautifulSoup
import sys

response = urlopen("https://www.rottentomatoes.com/")
pageHtml = response.read()

soup = BeautifulSoup(pageHtml, 'html.parser')

topBoxOffice = soup.find('table', id='Top-Box-Office')
scores = []
movieTitles = []
earnings = []

for score in topBoxOffice.find_all('td', class_='left_col'):
    scores.append(score.find('span', class_='tMeterScore').get_text())

for title in topBoxOffice.find_all('td', class_='middle_col'):
    movieTitles.append(title.find('a').get_text())

for earning in topBoxOffice.find_all('td', class_='right_col'):
    earningStr = earning.find('a').get_text()
    earningStr = earningStr.replace(' ', '')
    earningStr = earningStr.replace('\n', '')
    earnings.append(earningStr)

index = int(sys.argv[1])

print(scores[index] + " - " + movieTitles[index] + " - " + earnings[index])
