import requests
URL = 'https://webservice.recruit.co.jp/hotpepper/gourmet/v1/'

API_KEY = '7e63fa01ac8127f1'

params = {
    'key' : API_KEY,
    'keyword' : '沖縄',
    'format' : 'json',
    'count' : 100
}

res = requests.get(URL, params)

print(res.status_code)

result = res.json()
# print(result)

items = result['results']['shop']

print(len(items))


import pandas as pd

df = pd.DataFrame(items)
# print(df.head())
# print(df.columns)

df = df[['name', 'address', 'wifi']]
print(df.head())

df.to_csv('hotpepper.csv', index=False)

