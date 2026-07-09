# IP 归属地改用客户端 Header — Windows 升级手册

> **目标**：把 Windows 上的 dash-fastapi-admin 升级到本次（2026-06-29）版本
> **本次改动**：3 个文件（前端 2 个 + 后端 1 个）
> **本次含上午 9 项修复的延续**（auto-login 全套）— 上午已升过的机器**只需升本次新增的 3 个文件**
> **上午没升过的机器**：需要按本手册一次性升完（含 12 项改动）
> **前提**：管理员或服务运行用户身份操作
> **适配环境**：Python 3.13（site-packages 在 `%LOCALAPPDATA%\Programs\Python\Python313\Lib\site-packages\`）

---

## 一、本次（2026-06-29 下午）升级涉及的 3 个改动

| # | 文件路径 | 改动内容 | 解决什么 |
|---|---------|---------|---------|
| 1 | `dash-fastapi-backend/module_admin/annotation/log_annotation.py` | 读 `X-Login-Location` header；改用 `OrderedDict` LRU 缓存 + sanitize | IP 归属地不再依赖百度 API，内网/离线可用 |
| 2 | `dash-fastapi-frontend/utils/request.py` | Flask `api_request` 转发 `X-Login-Location` 到 FastAPI | 把浏览器 header 桥接给后端 |
| 3 | `dash-fastapi-frontend/assets/js/login_location.js`（**新建**） | 浏览器侧捕获位置（3 源降级：GPS → ipwho.is → 搜狐 IP）+ 拦截 fetch/XHR 注入 header | 给浏览器加位置采集 + 自动注入能力 |

---

## 二、什么是"离线包"？

**离线包 = 一个压缩文件**（`ip-location-from-client-2026-06-29.tar.gz`，约 14KB）。

里面装的是**这次升级要替换的所有文件的副本** + 配套的部署/回滚脚本 + 说明文档。

```
ip-location-from-client-2026-06-29.tar.gz
└── ip-location-from-client-2026-06-29/        ← 解压后的目录
    ├── README.md                              ← 升级手册
    ├── ip-location-from-client-2026-06-29.patch ← git apply 用的 patch（备用）
    ├── log_annotation.py                      ← 直接覆盖用的文件
    ├── request.py                             ← 直接覆盖用的文件
    ├── login_location.js                      ← 新建的文件（直接放到 assets/js/）
    ├── deploy.sh                              ← Linux 部署脚本
    ├── rollback.sh                            ← Linux 回滚脚本
    └── md5sum.txt                             ← 校验码
```

**为什么要打包**：目标机器可能没装 git、可能没网、可能 Python 环境不一致。打包后只需要"拷过去 → 解压 → 覆盖 → 重启"四步。

---

## 三、管理机（Linux/macOS）打包步骤

如果你**已经在管理机上**用 `docs/upgrades/package.sh` 打过包，跳过本节。

如果你要重新打：

```bash
cd /root/.openclaw/workspace/dash-fastapi-admin
bash docs/upgrades/package.sh

# 输出示例：
# === 打包完成 ===
# -rw-r--r-- 1 root root 14573 Jun 29 07:57 .../ip-location-from-client-2026-06-29.tar.gz
# MD5:
# 18d8a1ae535aa7a0e070cd24da32ce9e  .../ip-location-from-client-2026-06-29.tar.gz
```

或手动打包：

```bash
cd /root/.openclaw/workspace/dash-fastapi-admin

tar czf /tmp/ip-location-from-client-2026-06-29.tar.gz \
  dash-fastapi-backend/module_admin/annotation/log_annotation.py \
  dash-fastapi-frontend/utils/request.py \
  dash-fastapi-frontend/assets/js/login_location.js

ls -lh /tmp/ip-location-from-client-2026-06-29.tar.gz
# 输出参考：-rw-r--r-- 1 root root 14K ... /tmp/ip-location-from-client-2026-06-29.tar.gz
```

---

## 四、传到 Windows（3 种方式选一个）

### 方法 A：scp（推荐）

```bash
# 在 Linux/macOS 终端
scp /root/.openclaw/workspace/dash-fastapi-admin/docs/upgrades/dist/ip-location-from-client-2026-06-29.tar.gz \
    administrator@<windows-ip>:/c/upgrade/
```

> 注意 Windows 的 OpenSSH 把 `/c/upgrade/` 映射到 `C:\upgrade\`。如果 sshd 没装，用 WinSCP。

### 方法 B：WinSCP（图形化）

1. 打开 WinSCP，连到目标 Windows
2. 左本地：导航到打包目录，选中 `ip-location-from-client-2026-06-29.tar.gz`
3. 右远程：`C:\upgrade\`（没有就右键新建）
4. 拖过去 / F5 复制

### 方法 C：共享文件夹 / U 盘 / 远程桌面剪贴板

直接把 `ip-location-from-client-2026-06-29.tar.gz` 拷到 Windows 的 `C:\upgrade\` 下。

---

## 五、Windows 解压（3 种方式）

### 方法 1：PowerShell 自带 tar（**Windows 10 1803+ / Windows 11 自带，无需装任何东西**）

```powershell
# 进入升级目录
cd C:\upgrade

# 解压（PowerShell 默认 PATH 里有 tar.exe）
tar -xzf ip-location-from-client-2026-06-29.tar.gz

# 验证解压结果
dir ip-location-from-client-2026-06-29\
# 应看到 README.md, deploy.sh, rollback.sh, patch, 3 个代码文件
```

### 方法 2：7-Zip（如果你装了）

```powershell
# 7-Zip 命令行
& "C:\Program Files\7-Zip\7z.exe" x ip-location-from-client-2026-06-29.tar.gz -oC:\upgrade\
# 7z 解 tar.gz 会解两层（先 .gz 再 .tar），或者用 7z x 直接解
```

### 方法 3：WinRAR（如果你装了）

右键 → `Extract to ip-location-from-client-2026-06-29\`。

---

## 六、Windows 一条龙升级（管理员 PowerShell）

把下面整段贴到 PowerShell，**只需修改前两行的 `$dst` 和 `$bundle`**：

```powershell
# ================== 配置 ==================
$dst      = "C:\path\to\dash-fastapi-admin"   # ← 改成你的项目根目录
$bundle   = "C:\upgrade\ip-location-from-client-2026-06-29.tar.gz"

# 自动定位 Python
$pyExe    = (Get-Command python).Source
if (-not $pyExe) {
    Write-Host "  ✗ 找不到 python，请先安装 Python 3.11+ 并加入 PATH" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ 使用 Python: $pyExe"

# ================== 1. 停服 ==================
Write-Host "`n[1/7] 停服..." -ForegroundColor Cyan
foreach ($svc in @("DashFrontend", "DashBackend")) {
    try {
        & nssm stop $svc 2>$null
        Write-Host "  ✓ nssm stop $svc"
    } catch {
        Write-Host "  ⚠️  $svc 停服跳过（如果不是 NSSM 部署）" -ForegroundColor Yellow
    }
}
Start-Sleep -Seconds 2

# ================== 2. 备份 ==================
Write-Host "`n[2/7] 备份现有 3 个代码文件..." -ForegroundColor Cyan
$backup = "C:\backup\dash-ip-location-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

$files = @(
    "dash-fastapi-backend\module_admin\annotation\log_annotation.py",
    "dash-fastapi-frontend\utils\request.py"
    # login_location.js 是新建文件，不存在就不备份
)
foreach ($f in $files) {
    $src = "$dst\$f"
    if (Test-Path $src) {
        $dst_dir = Split-Path "$backup\$f" -Parent
        New-Item -ItemType Directory -Path $dst_dir -Force | Out-Null
        Copy-Item $src "$backup\$f" -Force
        Write-Host "  ✓ 已备份 $f"
    }
}
Write-Host "  备份到: $backup"

# ================== 3. 解压覆盖 ==================
Write-Host "`n[3/7] 解压覆盖..." -ForegroundColor Cyan
# 确保目标目录存在
New-Item -ItemType Directory -Path "$dst\dash-fastapi-backend\module_admin\annotation" -Force | Out-Null
New-Item -ItemType Directory -Path "$dst\dash-fastapi-frontend\utils" -Force | Out-Null
New-Item -ItemType Directory -Path "$dst\dash-fastapi-frontend\assets\js" -Force | Out-Null

tar -xzf $bundle -C $dst --strip-components=1
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 解压失败，请检查 tar.gz 是否损坏" -ForegroundColor Red
    exit 1
}

# 验证关键文件已就位
$expected = @(
    "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py",
    "$dst\dash-fastapi-frontend\utils\request.py",
    "$dst\dash-fastapi-frontend\assets\js\login_location.js"
)
foreach ($f in $expected) {
    if (-not (Test-Path $f)) {
        Write-Host "  ✗ 文件缺失: $f" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  ✓ 3 个文件已就位"

# ================== 4. 清理 pycache ==================
Write-Host "`n[4/7] 清理 pycache..." -ForegroundColor Cyan
Get-ChildItem -Path "$dst\dash-fastapi-backend", "$dst\dash-fastapi-frontend" `
    -Recurse -Filter "__pycache__" `
    -ErrorAction SilentlyContinue | Remove-Item -Recurse -Force
Get-ChildItem -Path "$dst\dash-fastapi-backend", "$dst\dash-fastapi-frontend" `
    -Recurse -Filter "*.pyc" `
    -ErrorAction SilentlyContinue | Remove-Item -Force
Write-Host "  ✓ 已清理"

# ================== 5. 语法校验 ==================
Write-Host "`n[5/7] 语法校验..." -ForegroundColor Cyan
& $pyExe -m py_compile `
    "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py" `
    "$dst\dash-fastapi-frontend\utils\request.py"
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ Python 语法错误！从备份回滚" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ Python 语法 OK"

# JS 语法（用 node，没有就跳过）
$nodeExe = (Get-Command node).Source
if ($nodeExe) {
    & $nodeExe --check "$dst\dash-fastapi-frontend\assets\js\login_location.js"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  ✓ JS 语法 OK"
    }
} else {
    Write-Host "  ⚠️  未检测到 node，跳过 JS 语法检查（手动验证浏览器打开应用即可）" -ForegroundColor Yellow
}

# ================== 6. 重启服务 ==================
Write-Host "`n[6/7] 重启服务..." -ForegroundColor Cyan
foreach ($svc in @("DashBackend", "DashFrontend")) {
    try {
        & nssm start $svc 2>$null
        Write-Host "  ✓ nssm start $svc"
    } catch {
        Write-Host "  ⚠️  请手动启动 $svc" -ForegroundColor Yellow
    }
}
Start-Sleep -Seconds 3

# 端口监听检查
$ports = @{
    "DashFrontend (38039)" = 38039
    "DashBackend  (9099)"  = 9099
}
foreach ($label in $ports.Keys) {
    $port = $ports[$label]
    $listen = Get-NetTCPConnection -LocalPort $port -State Listen -ErrorAction SilentlyContinue
    if ($listen) {
        Write-Host "  ✓ $label 监听中"
    } else {
        Write-Host "  ✗ $label 未监听，请查服务日志" -ForegroundColor Red
    }
}

# ================== 7. 验证 ==================
Write-Host "`n[7/7] 验证..." -ForegroundColor Cyan
Write-Host "  请按下方'浏览器验证'步骤操作"
Write-Host "  关键检查：DevTools → Network → 任意 callback 请求" -ForegroundColor Yellow
Write-Host "  应能看到 header: X-Login-Location: <具体地址>"

Write-Host "`n✅ 升级完成" -ForegroundColor Green
```

---

## 七、浏览器验证（3 步必过，**用隐身窗口 Ctrl+Shift+N**）

| # | 测试 | 步骤 | 预期 |
|---|------|------|------|
| ① | DevTools 看 header | F12 → Network → 触发任意 callback（点菜单/刷新页面） | Request Headers 里有 `X-Login-Location: 北京市 海淀区`（或实际定位） |
| ② | 数据库查 | 登录一次后查 `logininfor` 表 | `login_location` 字段是具体地址（不再是"未知"） |
| ③ | 拒绝权限 | 浏览器设置拒绝位置权限，再触发 callback | header 降级为 `ipwho.is` 或 `搜狐 IP` 返回的城市（如"北京市"），功能正常 |

数据库查询命令：
```sql
SELECT user_name, ipaddr, login_location, login_time 
FROM logininfor 
ORDER BY login_time DESC 
LIMIT 5;
```

---

## 八、上午 vs 下午的升级区别（如果你上午升过 auto-login 全套）

| 项目 | 上午（auto-login 9 项） | 下午（IP 归属地 3 项） |
|------|----------------------|----------------------|
| 文件数 | 7 个 + 3 个 .map 占位 | 3 个 |
| 涉及范围 | 仅前端 | 前端 + 后端 |
| 是否需要停前端 | ✅ | ✅ |
| 是否需要停后端 | ❌（仅前端代码） | ✅（改 `log_annotation.py`） |
| 重启服务 | `DashFrontend` | `DashBackend` + `DashFrontend` |

**上午升过、下午只升本次**：
- 只跑本手册步骤即可
- 注意 `DashBackend` 也要重启（这是和上午唯一区别）

**上午没升过、要一次升完**：
- 先跑 `auto-login-windows-deploy-2026-06-29.md` 全部步骤
- 再跑本手册步骤
- 或者合并成一个 tar.gz 一次性分发（按需扩展 `package.sh`）

---

## 九、回滚（一行命令）

如果出问题需要立即回退：

```powershell
# 1. 停服
nssm stop DashBackend
nssm stop DashFrontend

# 2. 从备份恢复
$backup = "C:\backup\dash-ip-location-<时间戳>"   # 改成实际的备份目录
Copy-Item "$backup\dash-fastapi-backend\module_admin\annotation\log_annotation.py" `
          "$dst\dash-fastapi-backend\module_admin\annotation\log_annotation.py" -Force
Copy-Item "$backup\dash-fastapi-frontend\utils\request.py" `
          "$dst\dash-fastapi-frontend\utils\request.py" -Force
Remove-Item "$dst\dash-fastapi-frontend\assets\js\login_location.js" -Force

# 3. 清 pycache
Get-ChildItem "$dst\dash-fastapi-backend", "$dst\dash-fastapi-frontend" `
    -Recurse -Filter "__pycache__" | Remove-Item -Recurse -Force

# 4. 重启
nssm start DashBackend
nssm start DashFrontend
```

或者用 git 反向 apply（如果项目是 git 仓库）：

```powershell
cd $dst
git apply -R ip-location-from-client-2026-06-29.patch
nssm restart DashBackend
nssm restart DashFrontend
```

---

## 十、常见问题

### Q1: `tar` 命令找不到？
A: Windows 10 1803 以下或某些精简版没自带 tar。改用：
- 7-Zip：`& "C:\Program Files\7-Zip\7z.exe" x bundle.tar.gz -oC:\upgrade\`
- WinRAR：右键解压

### Q2: NSSM 没装，服务是怎么起的？
A: 看启动方式。可能是：
- 手动开 cmd 跑 `python app.py` — 那就关掉 cmd 重开
- Windows Task Scheduler — 触发一次任务
- 别的服务管理器 — 对应重启命令

如果不知道，**直接重启机器最快**（前提是服务设了开机自启）。

### Q3: `__pycache__` 没清完？
A: Python 会缓存编译后的 `.pyc`，有时即使文件改了 Python 还用旧的。手动清：
```powershell
Remove-Item "$dst\dash-fastapi-backend\module_admin\annotation\__pycache__" -Recurse -Force
Remove-Item "$dst\dash-fastapi-frontend\utils\__pycache__" -Recurse -Force
```

### Q4: 升级后浏览器还看不到 `X-Login-Location` header？
排查顺序：
1. **清浏览器缓存**：Ctrl+Shift+R 强刷（`login_location.js` 是新文件，浏览器可能缓存了旧版）
2. **看 Network 是否有 `login_location.js` 请求**：应该是 `200 OK`，不是 `304`
3. **看 Flask 日志**：搜 `[api]` 应该正常输出
4. **看后端日志**：登录时应该看到新写入的 `login_location` 值

### Q5: 备份目录要不要长期保留？
A: **保留至少 2 周**。如果上线 2 周后没问题，可以清理。

---

## 十一、操作清单（贴到工单系统）

```
□ 1. 管理机打包：bash docs/upgrades/package.sh
□ 2. 传到 Windows：scp ... administrator@<ip>:/c/upgrade/
□ 3. 解压：tar -xzf ... -C C:\upgrade\
□ 4. 修改脚本里 $dst / $bundle 路径
□ 5. 跑升级 PowerShell
□ 6. 浏览器隐身窗口验证（DevTools 看 X-Login-Location）
□ 7. 数据库查 logininfor 表确认有具体地址
□ 8. 保留备份目录至少 2 周
```
