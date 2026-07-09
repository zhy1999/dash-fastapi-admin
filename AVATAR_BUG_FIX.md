# 头像模块 Bug 修复文档

## Bug 描述

**问题**：用户更新头像后，刷新页面头像不显示。

**复现步骤**：
1. 登录系统
2. 进入个人资料页面
3. 上传新头像 → 显示正常
4. 刷新页面 → 头像丢失，显示默认图

## 根因分析

### 问题 1：缓存与数据库路径不一致

上传头像后，后端返回的是**相对路径**（如 `/profile/avatar/2026/06/12/xxx.png`），并存入数据库。

前端缓存 `avatar_c.py` 早期版本直接设置：
```python
CacheManager.set({'avatar': new_avatar_url})
```

但页面读取 `user_info['avatar']` 时值为 `None`，因为缓存 key 不一致。

**修复**：`avatar_c.py` 中更新 `user_info` 对象：
```python
user_info = CacheManager.get('user_info')
if user_info:
    user_info['avatar'] = new_avatar_url
    CacheManager.set({'user_info': user_info})
```

### 问题 2：头像 URL 拼接错误（ApiConfig.BaseUrl 带代理前缀）

`head.py`、`page_top.py`、`user_avatar.py` 读取头像时使用：
```python
f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
```

`ApiConfig.BaseUrl = http://10.10.30.31:38038/prod-api`（含 `/prod-api` 代理前缀）

但后端静态文件挂载在 `/profile/...`（无代理前缀），导致拼接后路径为：
`http://10.10.30.31:38038/prod-api/profile/avatar/...` → 404

**修复**：改用 `AppConfig.app_base_url`（不含代理前缀）拼接：
```python
f'{AppConfig.app_base_url}{CacheManager.get("user_info").get("avatar")}'
```

### 问题 3：CORS 跨域限制

后端 CORS 配置仅允许 `localhost:8088` 和 `127.0.0.1:8088`，实际前端运行在 `10.10.30.31:38039`，导致跨域请求被拦截。

**修复**：`middlewares/cors_middleware.py` 中添加：
```python
origins = [
    'http://localhost:8088',
    'http://10.10.30.31:8088',
    'http://10.10.30.31:38039',
]
```

### 问题 4：base_url 配置错误

前端 `.env.prod` 中 `APP_BASE_URL = 'http://127.0.0.1:38038'`，但服务器实际 IP 为 `10.10.30.31`，远程浏览器无法通过 `127.0.0.1` 访问。

**修复**：`APP_BASE_URL = 'http://10.10.30.31:38038'`

## 修改文件清单

| 文件 | 修改内容 |
|------|---------|
| `dash-fastapi-frontend/callbacks/system_c/user_c/profile_c/avatar_c.py` | 上传成功后更新 `user_info['avatar']`，使用 `AppConfig.app_base_url` 拼完整 URL |
| `dash-fastapi-frontend/views/layout/components/head.py` | 头像 src 改用 `AppConfig.app_base_url` 拼接，导入 `AppConfig` |
| `dash-fastapi-frontend/views/dashboard/components/page_top.py` | 头像 src 改用 `AppConfig.app_base_url` 拼接，导入 `AppConfig` |
| `dash-fastapi-frontend/views/system/user/profile/user_avatar.py` | 头像 src 改用 `AppConfig.app_base_url` 拼接，导入 `AppConfig` |
| `dash-fastapi-backend/middlewares/cors_middleware.py` | CORS origins 加入 `10.10.30.31:38039` |
| `dash-fastapi-frontend/.env.prod` | `APP_BASE_URL` 改为 `http://10.10.30.31:38038` |

## 正确的数据流

```
后端数据库：avatar = /profile/avatar/2026/06/12/xxx.png  (相对路径)
前端读取：AppConfig.app_base_url = http://10.10.30.31:38038
最终URL：http://10.10.30.31:38038/profile/avatar/2026/06/12/xxx.png ✅
```

## 注意事项

1. 静态文件路径（`/profile/...`）不走代理路径 `/prod-api`，头像这类资源需要直接用后端地址访问
2. 前端跨域配置需要包含实际运行的 IP 和端口
3. `127.0.0.1` 仅限服务器本地访问，远程浏览器访问需使用实际网卡 IP
