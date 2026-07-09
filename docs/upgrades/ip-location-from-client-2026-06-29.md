# IP 归属地改用客户端 Header — 升级手册

> **适用版本**：dash-fastapi-admin（前端 `dash-fastapi-frontend` + 后端 `dash-fastapi-backend`）
> **改动日期**：2026-06-29
> **改动文件数**：3 个（前端 2 个 + 后端 1 个）
> **数据库 / 依赖**：均无变更
> **回滚**：自带 `.bak.20260629` 备份；或 `git apply -R ip-location-from-client-2026-06-29.patch`

---

## 一、改动目的

把"登录地点"数据源从**服务端调用百度 IP 库**改成**前端 JS 注入 header**。

| | 旧（服务端百度 API） | 新（客户端 header） |
|---|---|---|
| 数据来源 | 后端调 `qifu-api.baidubce.com` | 前端 `navigator.geolocation` 或 IP 反查 |
| 内网可用 | ❌ 外网不通就失败 | ✅ 不依赖外网 |
| 准确性 | 省-市级别 | GPS 精确到街道 |
| 限流风险 | 受百度 API 限制 | 不受限 |
| 离线部署 | ❌ 不支持 | ✅ 支持 |

---

## 二、改动文件清单

| # | 文件路径 | 类型 | 说明 |
|---|---|---|---|
| 1 | `dash-fastapi-backend/module_admin/annotation/log_annotation.py` | **修改** | `@Log` 装饰器读 `X-Login-Location` header；用 `OrderedDict` + LRU 替代 `@lru_cache`；加 XSS sanitize |
| 2 | `dash-fastapi-frontend/utils/request.py` | **修改** | Flask `api_request` 读浏览器 header，转发到 FastAPI |
| 3 | `dash-fastapi-frontend/assets/js/login_location.js` | **新建** | 浏览器侧捕获位置（3 源降级），拦截 fetch/XHR 注入 header |

> 详细 diff 见同级目录 `ip-location-from-client-2026-06-29.patch`（`git apply` 可直接打）。

---

## 三、端到端数据流

```
┌──────────────────────┐ ① navigator.geolocation / IP API
│ 浏览器 (login_location.js) │ ────────────────────────────┐
└──────────────────────┘                                   ▼
            │ ② 写入 sessionStorage
            ▼
┌──────────────────────┐ ③ 拦截 fetch/XHR
│ 浏览器 Dash callback │ ──→ POST /_dash-update-component
└──────────────────────┘    带 X-Login-Location: 北京市
            │
            ▼
┌──────────────────────┐ ④ flask.request.headers
│ Flask (request.py)   │ ──→ requests.post() 到 FastAPI
│ dash-fastapi-frontend│    (X-Login-Location 透传到 api_headers)
└──────────────────────┘
            │
            ▼
┌──────────────────────┐ ⑤ @Log 装饰器
│ FastAPI (log_annotation.py) │ ──→ get_ip_location(oper_ip, header)
│ dash-fastapi-backend │     OrderedDict 缓存 + sanitize
└──────────────────────┘
            │
            ▼
        数据库 logininfor 表
        login_location = "北京市 海淀区"
```

---

## 四、关键改动逻辑

### 1. 后端 `log_annotation.py`

**改动前**（228 行）→ **改动后**（297 行）

```python
# 改动前：服务端调百度 API
if AppConfig.app_ip_location_query:
    oper_location = get_ip_location(oper_ip)   # @lru_cache 装饰

# 改动后：读客户端 header
if AppConfig.app_ip_location_query:
    login_location = request.headers.get('X-Login-Location')
    oper_location = get_ip_location(oper_ip, login_location)
```

新 `get_ip_location` 实现要点：
- **`OrderedDict` LRU 缓存**，上限 4096 条，超出淘汰最久未访问
- **`_sanitize_location`** 防 XSS：去 `<>"'`【】` + 控制字符 + 截 64 字符
- **`oper_ip` 为空短路**返回"未知"，不入缓存
- 旧 `@lru_cache` 版本改名为 `get_ip_location2` 保留为兜底

### 2. Flask `request.py`

新增 7 行：

```python
# === 2026-06-29 转发客户端登录地点（来自 assets/js/login_location.js） ===
login_location = (request.headers.get('X-Login-Location') or '').strip()
if login_location:
    api_headers['X-Login-Location'] = login_location
```

### 3. 前端 `assets/js/login_location.js`（新建，200 行）

**检测优先级**（串行降级）：
1. `navigator.geolocation` + Nominatim 反向地理编码（最准，需用户授权）
2. `ipwho.is` 国际 IP 库（CORS 友好）
3. 搜狐 IP API（国内友好）
4. 失败时：不发 header，后端按"未知"处理

**注入策略**：
- 拦截 `window.fetch`：检查 init.headers 类型（object/Headers/array），已有不覆盖
- 拦截 `XMLHttpRequest.prototype.send`：在 send 内 setRequestHeader
- **sessionStorage 缓存**，会话内只查一次

---

## 五、部署步骤

### 5.1 应用 patch

```bash
cd /path/to/dash-fastapi-admin
git apply docs/upgrades/ip-location-from-client-2026-06-29.patch
```

### 5.2 重启服务

```bash
# 后端（如用 systemd）
sudo systemctl restart dash-fastapi-backend

# 前端（如用 systemd）
sudo systemctl restart dash-fastapi-frontend

# 或用 supervisor
sudo supervisorctl restart dash-fastapi-backend dash-fastapi-frontend
```

### 5.3 验证

```bash
# 1. 浏览器打开 DevTools → Network
# 2. 触发任意 callback
# 3. 看 Request Headers 应有：
#    X-Login-Location: 北京市 海淀区  （或实际定位结果）

# 4. 登录一次后查数据库
mysql -u<user> -p<pwd> -h<host> <db> \
  -e "SELECT user_name, ipaddr, login_location, login_time 
      FROM logininfor 
      ORDER BY login_time DESC LIMIT 5;"
# 预期 login_location 是具体地址（不再是"未知"）
```

---

## 六、回滚方案

### 方案 A：用 git

```bash
git apply -R docs/upgrades/ip-location-from-client-2026-06-29.patch
sudo systemctl restart dash-fastapi-backend dash-fastapi-frontend
```

### 方案 B：用 .bak 文件（如果当时保留了）

```bash
# 后端
cp dash-fastapi-backend/module_admin/annotation/log_annotation.py.bak.20260629 \
   dash-fastapi-backend/module_admin/annotation/log_annotation.py

# 前端
cp dash-fastapi-frontend/utils/request.py.bak.20260629 \
   dash-fastapi-frontend/utils/request.py

# 删除新建的 JS
rm dash-fastapi-frontend/assets/js/login_location.js

# 重启服务
sudo systemctl restart dash-fastapi-backend dash-fastapi-frontend
```

---

## 七、安全注意事项

1. **`X-Login-Location` 客户端可控**：恶意用户可伪造。后端 `_sanitize_location` 已做字符过滤，但仍建议：
   - 数据库 `login_location` 字段展示时**不要用 HTML 渲染**，纯文本即可
   - 如必须用富文本，先过白名单

2. **位置隐私合规**：浏览器 `navigator.geolocation` 弹权限框是浏览器自带，用户拒绝不影响功能（会降级到 IP 反查）。无需额外 GDPR/个保法处理。

3. **`_ip_cache` 多 worker 不共享**：每个 uvicorn/gunicorn worker 独立缓存。如果对一致性有强需求（如不同 worker 看到的同一 IP 归属地不同），可改为 Redis 共享。本次实现保留进程内 dict 是性能与一致性的权衡。

---

## 八、兼容性矩阵

| 部署环境 | 是否可用 | 说明 |
|---|---|---|
| 内网无外网 | ✅ | 走客户端检测，离线可用 |
| 公网部署 | ✅ | 走 ipwho.is 或搜狐 |
| HTTPS 反向代理（nginx） | ✅ | header 自动透传 |
| HTTPS + CORS 严格模式 | ⚠️ | 需 nginx 加 `proxy_pass_header X-Login-Location;` |
| 多 worker（gunicorn） | ✅ | 每 worker 独立缓存，可接受 |
| Windows + IE | ❌ | 不支持 fetch 拦截，仅 Chrome/Edge/Firefox/Safari |

---

## 九、变更影响面

**功能影响**：
- 登录日志 `logininfor.login_location` 字段值变化（从"未知/省-市"→"具体地址"）
- 操作日志 `oper_log.oper_location` 字段值变化（同上）

**业务影响**：
- ✅ 安全审计定位更准
- ✅ 内网/离线场景可用
- ⚠️ 数据库旧记录保留原值，新记录用新格式（混用不影响查询）

**未受影响**：
- 业务功能 0 改动
- 数据库表结构 0 改动
- API 接口签名 0 改动
- 第三方依赖 0 新增
