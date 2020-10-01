import requests, os
from bs4 import BeautifulSoup

data_path = 'data/'

if not os.path.exists(data_path):
    os.mkdir(data_path)

r = requests.get('https://msan.gouvernement.lu/fr/graphiques-evolution.html')

soup = BeautifulSoup(r.text, 'html.parser')

for table in soup.find_all('table'):
    table_name = table.find('caption').get_text()

    if True:
        fh = open(data_path + table_name + '.csv', 'w')

        for tr in table.find_all('tr'):
            # if it's the header row
            #if tr.th:
            fh.write(tr.get_text(',', strip=True) + '\n')
        fh.close()

        

