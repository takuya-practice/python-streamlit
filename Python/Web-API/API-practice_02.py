import requests
import pandas as pd


REQUESTS_URL = 'https://app.rakuten.co.jp/services/api/IchibaItem/Search/20170706'
APP_ID = '1075290411130836313'

params = {
    'applicationId' : APP_ID,
    'format' : 'json', 
    'keyword' : 'violin', 
    'minPrice' : 10000
}

res = requests.get(REQUESTS_URL, params)
# print(res.status_code)
# print(res.json())
result = res.json()
items = result['Items']
print(len(items))

items = [item['Item'] for item in items]
# print(items[0])
df = pd.DataFrame(items)
# print(df.columns)

columns = [ 'itemCode', 'itemName', 'itemPrice','reviewCount','reviewAverage','availability', 'shopCode','shopName', 'shopUrl']
df = df[columns]
# print(df[:3])

new_columns = [ '商品コード', '商品名', '価格','レビュー数','レビュー値','利用可否', '店コード','店名','店名URL']
df.columns = new_columns
# print(df[:5])

# df.to_csv('rakuten.csv', index=False)

# print(df.sort_values('価格', ascending=False))

# 一般的な統計項目を表示
print(df.describe())

# 価格が５万円以内の項目を表示（dfで囲むことで、価格カラムだけでなく、対象のインデックスを表示）
print(df[df['価格'] < 50000])