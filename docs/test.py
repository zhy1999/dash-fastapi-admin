import requests

uuid_resp = requests.get("http://127.0.0.1:38038/captchaImage")
uuid = uuid_resp.json()["uuid"]

login_resp = requests.post(
"http://127.0.0.1:38038/login",
#data={"username": "admin", "password": "admin123", "code": "", "uuid": uuid},
data={"username": "test", "password": "test123", "code": "", "uuid": uuid},
headers={"Content-Type": "application/x-www-form-urlencoded"}
)
token = login_resp.json()["token"]

info_resp = requests.get(
"http://127.0.0.1:38038/getInfo",
headers={"Authorization": f"Bearer {token}"}
)
print(info_resp.json())
