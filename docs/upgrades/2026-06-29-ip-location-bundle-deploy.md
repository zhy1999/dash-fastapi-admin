# 2026-06-29 IP 归属地改造 — 离线包部署记录

> **本次改动日期**：2026-06-29
> **打包时间**：2026-06-29 08:17 UTC
> **打包人**：自动生成
> **离线包**：`ip-location-from-client-2026-06-29.tar.gz`（8.2KB）
> **MD5**：`4fa339e57de9899634b0e0027f7b38fc`
> **目标机器**：Windows（项目路径 `D:\webadmin\PythonServer\dash-fastapi-admin\`）
> **服务名**：`DashBackend` + `DashFrontend`（NSSM 部署）

---

## 一、本次改动文件清单

| # | 文件路径 | 状态 | 改动目的 |
|---|---|---|---|
| 1 | `dash-fastapi-backend/module_admin/annotation/log_annotation.py` | 覆盖 | IP 归属地从百度 API → 读 `X-Login-Location` header |
| 2 | `dash-fastapi-frontend/utils/request.py` | 覆盖 | Flask `api_request` 转发 `X-Login-Location` 到 FastAPI |
| 3 | `dash-fastapi-frontend/assets/js/login_location.js` | **新增** | 浏览器侧捕获位置 + 拦截 fetch/XHR 注入 header |
| 4 | `dash-fastapi-backend/module_admin/annotation/log_annotation.py.bak.20260629` | 备份 | 上面 #1 的原版（兜底用） |
| 5 | `dash-fastapi-frontend/utils/request.py.bak.20260629` | 备份 | 上面 #2 的原版（兜底用） |

**未改动**：所有其他文件、数据库、Python 依赖、前端依赖、配置文件（`.env`）。

---

## 二、离线包结构

解压后目录（路径前缀 `dash-fastapi-admin/`，对应目标根目录）：

```
dash-fastapi-admin/
├── dash-fastapi-backend/
│   └── module_admin/
│       └── annotation/
│           ├── log_annotation.py                       ← 覆盖
│           └── log_annotation.py.bak.20260629          ← 备份（来自管理机）
└── dash-fastapi-frontend/
    ├── assets/
    │   └── js/
    │       └── login_location.js                       ← 新增
    └── utils/
        ├── request.py                                  ← 覆盖
        └── request.py.bak.20260629                     ← 备份（来自管理机）
```

---

## 三、目标机器部署步骤（和上午风格一致）

### 3.1 上传离线包到 Windows

```powershell
# 在 Windows 上传包（任选一种方式）
# 方式 A：WinSCP 拖 ip-location-from-client-2026-06-29.tar.gz 到 D:\webadmin\PythonServer\
# 方式 B：scp（从管理机）
#    scp ip-location-from-client-2026-06-29.tar.gz administrator@<windows-ip>:/d/webadmin/PythonServer/
```

确认包已到位：

```powershell
PS D:\webadmin\PythonServer> dir ip-location-from-client-2026-06-29.tar.gz

    Directory: D:\webadmin\PythonServer

Mode                 LastWriteTime         Length   Name
----                 -------------         ------   ----
-a----         6/29/2026   8:17 AM           8397   ip-location-from-client-2026-06-29.tar.gz
```

### 3.2 执行替换（用户指定的命令）

```powershell
PS D:\webadmin\PythonServer> $dst    = "D:\webadmin\PythonServer\dash-fastapi-admin\"
PS D:\webadmin\PythonServer> $bundle = "D:\webadmin\PythonServer\ip-location-from-client-2026-06-29.tar.gz"
PS D:\webadmin\PythonServer> tar -xzf $bundle -C $dst
```

**预期输出**：无（tar 解压成功静默返回 0）

### 3.3 验证文件已就位

```powershell
PS D:\webadmin\PythonServer> Get-ChildItem $dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py, $dst\dash-fastapi-frontend\utils\request.py, $dst\dash-fastapi-frontend\assets\js\login_location.js | Select-Object FullName, Length, LastWriteTime
```

**预期输出**：

```
FullName                                                                                Length   LastWriteTime
--------                                                                                ------   -------------
D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-backend\module_admin\...py    12368    2026-06-29 08:17
D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend\utils\request.py     6296     2026-06-29 08:17
D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend\assets\js\logi...js 7011     2026-06-29 08:17
```

> 注意 LastWriteTime 应该是今天（2026-06-29），不是几个月前的老时间。

### 3.4 清理 pycache（避免 Python 加载旧字节码）

```powershell
PS D:\webadmin\PythonServer> Remove-Item "$dst\dash-fastapi-backend\module_admin\annotation\__pycache__" -Recurse -Force -ErrorAction SilentlyContinue
PS D:\webadmin\PythonServer> Remove-Item "$dst\dash-fastapi-frontend\utils\__pycache__" -Recurse -Force -ErrorAction SilentlyContinue
PS D:\webadmin\PythonServer> Write-Host "✓ pycache cleared"
```

### 3.5 语法快速校验

```powershell
PS D:\webadmin\PythonServer> python -m py_compile "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py"
PS D:\webadmin\PythonServer> python -m py_compile "$dst\dash-fastapi-frontend\utils\request.py"
# 两次都无输出 = OK
PS D:\webadmin\PythonServer> Write-Host "✓ Python syntax OK"
```

### 3.6 重启服务

**本次和上午唯一区别**：后端也改了 `log_annotation.py`，所以 **Backend 必须重启**（上午只重启 Frontend 即可）。

```powershell
PS D:\webadmin\PythonServer> nssm restart DashBackend
PS D:\webadmin\PythonServer> nssm restart DashFrontend
PS D:\webadmin\PythonServer> Start-Sleep -Seconds 3
PS D:\webadmin\PythonServer> Get-NetTCPConnection -LocalPort 9099,38039 -State Listen | Format-Table LocalAddress, LocalPort, State
```

**预期**：

```
LocalAddress    LocalPort  State
------------    ---------  -----
0.0.0.0         9099       Listen
0.0.0.0         38039      Listen
```

---

## 四、业务验证（必做）

### 4.1 浏览器 DevTools 看 header

1. **隐身窗口**（Ctrl+Shift+N）打开应用
2. F12 → Network → 触发任意 callback（点菜单/刷新）
3. 看 Request Headers 里有 `X-Login-Location: <具体地址>`

**预期**：
```
X-Login-Location: 北京市 海淀区
```
或你浏览器检测到的实际位置。

### 4.2 数据库看 logininfor 表

```sql
SELECT user_name, ipaddr, login_location, login_time 
FROM logininfor 
ORDER BY login_time DESC 
LIMIT 5;
```

**预期**：`login_location` 是具体地址（不再是"未知"或"北京-北京"）。

### 4.3 拒绝权限降级测试（可选）

浏览器设置拒绝位置权限 → 刷新页面 → 再触发 callback → header 应降级为 `ipwho.is` 或 `搜狐 IP` 返回的城市。

---

## 五、回滚（万一出问题）

离线包里自带了备份文件，可以直接恢复：

```powershell
PS D:\webadmin\PythonServer> $dst = "D:\webadmin\PythonServer\dash-fastapi-admin\"

# 1. 把备份文件复制回去（去掉 .bak.20260629 后缀覆盖）
Copy-Item "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py.bak.20260629" `
          "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py" -Force

Copy-Item "$dst\dash-fastapi-frontend\utils\request.py.bak.20260629" `
          "$dst\dash-fastapi-frontend\utils\request.py" -Force

# 2. 删除新增的 JS 文件
Remove-Item "$dst\dash-fastapi-frontend\assets\js\login_location.js" -Force

# 3. 清 pycache
Remove-Item "$dst\dash-fastapi-backend\module_admin\annotation\__pycache__" -Recurse -Force -EA SilentlyContinue
Remove-Item "$dst\dash-fastapi-frontend\utils\__pycache__" -Recurse -Force -EA SilentlyContinue

# 4. 重启
nssm restart DashBackend
nssm restart DashFrontend

Write-Host "✓ 回滚完成"
```

---

## 六、附录：本次变更的核心代码片段

### 6.1 后端 `log_annotation.py` 关键改动

```python
# L77-82：读客户端 header
if AppConfig.app_ip_location_query:
    # 从访问头中获取访问地址（前端 JS 定位结果）
    login_location = request.headers.get('X-Login-Location')
    oper_location = get_ip_location(oper_ip, login_location)

# L211-273：新增 LRU 缓存 + sanitize（替代旧 @lru_cache + 百度 API）
_ip_cache = OrderedDict()
_IP_CACHE_MAX = 4096

def _sanitize_location(raw):
    if not raw: return ''
    s = unquote(raw).strip()
    _BAD_CHARS = {'<', '>', chr(34), chr(39), chr(96), chr(0x3010), chr(0x3011)}
    s = ''.join(c for c in s if c not in _BAD_CHARS and ord(c) >= 0x20)
    return s[:_LOCATION_MAX_LEN]

def get_ip_location(oper_ip, defaut_location=''):
    if not oper_ip: return '未知'
    if oper_ip in _ip_cache:
        _ip_cache.move_to_end(oper_ip)
        return _ip_cache[oper_ip]
    if oper_ip in ('127.0.0.1', 'localhost', '::1'):
        value = '内网IP'
    elif defaut_location:
        cleaned = _sanitize_location(defaut_location)
        value = cleaned if cleaned else '未知'
    else:
        value = '未知'
    _ip_cache[oper_ip] = value
    _ip_cache.move_to_end(oper_ip)
    while len(_ip_cache) > _IP_CACHE_MAX:
        _ip_cache.popitem(last=False)
    return value
```

### 6.2 Flask `request.py` 关键改动

```python
# L64-67：转发 header
# === 2026-06-29 转发客户端登录地点（来自 assets/js/login_location.js） ===
login_location = (request.headers.get('X-Login-Location') or '').strip()
if login_location:
    api_headers['X-Login-Location'] = login_location
```

### 6.3 前端 `login_location.js` 关键逻辑（新建文件）

```javascript
// 三源降级检测位置
function detectLocation() {
    return tryBrowserGeolocation()      // 1. GPS + Nominatim（最准，需用户授权）
        .catch(() => tryIpWhoIs())      // 2. ipwho.is 国际 IP 库
        .catch(() => trySohuIp());      // 3. 搜狐 IP API（国内友好）
}

// 拦截 fetch
var origFetch = window.fetch;
window.fetch = function (input, init) {
    init = init || {};
    var loc = safeGetStorage();
    if (loc) {
        if (init.headers instanceof Headers) {
            if (!init.headers.has('X-Login-Location')) init.headers.set('X-Login-Location', loc);
        } else if (Array.isArray(init.headers)) {
            // ... 数组形式
        } else {
            init.headers = init.headers || {};
            if (!('X-Login-Location' in init.headers)) init.headers['X-Login-Location'] = loc;
        }
    }
    return origFetch.call(this, input, init);
};

// 拦截 XHR（Dash 部分组件用 XHR）
var origSend = XMLHttpRequest.prototype.send;
XMLHttpRequest.prototype.send = function (body) {
    var loc = safeGetStorage();
    if (loc) { try { this.setRequestHeader('X-Login-Location', loc); } catch(e){} }
    return origSend.call(this, body);
};
```

---

## 七、变更影响面总结

| 维度 | 影响 |
|---|---|
| 功能 | `logininfor.login_location` 和 `oper_log.oper_location` 字段值变化（更准确） |
| API 接口 | 0 改动 |
| 数据库结构 | 0 改动 |
| 第三方依赖 | 0 新增 |
| 业务代码 | 0 改动 |
| 配置 | 0 改动（`AppConfig.app_ip_location_query` 仍为 `True`） |
| 性能 | 字典缓存 O(1)，无网络调用，比之前更快 |
| 风险 | 低（前端 header 客户端可控，已做 XSS sanitize） |
| 回滚 | 自带备份，3 行 PowerShell 搞定 |

---

## 八、变更元数据

| 字段 | 值 |
|---|---|
| 打包脚本 | `docs/upgrades/package.sh`（direct 模式） |
| 包大小 | 8.2KB |
| MD5 | `4fa339e57de9899634b0e0027f7b38fc` |
| 包路径 | `docs/upgrades/dist/ip-location-from-client-2026-06-29.tar.gz` |
| 改动文件数 | 3 个代码文件 + 2 个备份文件 = 5 个 |
| 兼容性 | Python 3.11+ / 任意现代浏览器 |
| 离线包有效期 | 永久（除非项目结构调整） |
