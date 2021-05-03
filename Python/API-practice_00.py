import requests

url = 'https://jsonplaceholder.typicode.com/posts/'

# res = requests.get(url)

# print(res.status_code)

# datum = res.json()[0]

# print(datum)

body = {
    'id' : 5
}
res = requests.get(url, body)

print(res.status_code)
print(res.json())