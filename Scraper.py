from bs4 import BeautifulSoup
import requests
stonks =['AMGEN','MA','V','FEDX','Apple','CAT','ENLC']
URL = 'https://www.google.com/search?q='

def scrape():
    r=requests.get(URL+QUERY)
    s=BeautifulSoup(r.text,'html.parser')
    ans=s.find('div',class_='BNeawe iBp4i AP7Wnd')
    return ans.text
i=0
for i in range(len(stonks)):
    QUERY = '{0}+stock+price+in+usd'.format(stonks[i])
    print(stonks[i]+': $'+scrape())

