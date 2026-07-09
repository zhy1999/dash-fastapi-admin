# Auto-Login 全套升级指南（6/26-6/29）

> **目标**：把 Windows 上的 dash-fastapi-admin 升级到最新
> **含本次会话（2026-06-29）全部 9 个修复**（含 feffery 包 .map 占位修复）
> **范围**：只动前端 `dash-fastapi-frontend/`，**后端无需重启**
> **前提**：以管理员或服务运行用户身份操作
> **适配环境**：全局 Python 3.13（site-packages 在 `%LOCALAPPDATA%\Programs\Python\Python313\Lib\site-packages\`）

---

## 一、本次升级涉及的 9 个改动

| # | 文件 | 改动内容 | 解决什么 |
|---|------|---------|---------|
| 1 | `views/layout/__init__.py:85-93` | 注释 `fac.AntdRow(render_productapp_topbar(...))` | 临时隐藏 productapp 顶栏（用户要求） |
| 2 | `callbacks/router_c.py:40-52` | 已登录分支开头加 `pathname in ('/', '')` → 跳 `/system/user` | 根路径 `/` 显示 404 |
| 3 | `callbacks/router_c.py:30` | `prevent_initial_call=True` → `'initial_duplicate'` | 初始 pathname 不触发 callback，auto-login 跳转后空白 |
| 4 | `callbacks/router_c.py:116` | 去掉分支 B 的 `url_trigger == 'load'` 限制 | 浏览器 302 跳转时 trigger 是 `'push'` 不是 `'load'` |
| 5 | `callbacks/router_c.py:116` | 分支 B 条件 `not session_token` → `token_result != session_token` | 第二次 auto-login（前后端 token 不一致）跳 /login |
| 6 | `auto_login.py:54-65` | `_login_error_redirect` 加 `session.clear()` | 错密码/瞎 token 跳登录页后，残留 session 导致 callback 渲染"登录页 + 完整菜单"混合 |
| 7 | `auto_login.py:73-95` | token 分支加 `LoginApi.get_info()` 验证 | 过期/瞎 token 被静默跳到目标页后页面空白 |
| 8 | `views/layout/components/aside.py:12-52` | auto-login 时仍渲染 `logo-text` 节点（`display: none`） | 360 浏览器折叠菜单/响应式变化时报 "nonexistent object: logo-text" |
| 9 | `site-packages\feffery_*\.min.js.map`（创建空 `{}` 占位） | 为 `feffery_antd_charts` / `feffery_markdown_components` / `feffery_utils_components` 三个包各创建一个空的 `.map` 文件 | 三个 feffery 包发布时漏发 .map 文件，浏览器 DevTools 报 500 错误 `SourceMap HTTP 500` |

**额外保留（6/27 已有的基础功能）**：

| 文件 | 内容 |
|------|------|
| `auto_login.py`（基础） | `/auto-login` 路由，username/password + token 两种方式，open redirect 防护 |
| `views/layout/__init__.py`（基础） | `render()` 增加 `is_auto_login` 参数透传 |
| `views/layout/components/head.py` | auto-login 时不渲染右上角头像 + 下拉菜单 |
| `views/layout/components/productapp_topbar.py` | 顶栏菜单（本次已注释） |
| `callbacks/layout_c/productapp_topbar_c.py` | 顶栏回调（本次已注释） |

---

## 二、需要替换的文件清单（7 个代码文件 + 3 个 .map 占位）

### 2.1 代码文件（7 个）

| # | 相对路径 | 大小（参考）|
|---|---------|-----------|
| 1 | `dash-fastapi-frontend/auto_login.py` | ~5.4 KB |
| 2 | `dash-fastapi-frontend/views/layout/__init__.py` | ~6.3 KB |
| 3 | `dash-fastapi-frontend/views/layout/components/aside.py` | ~3.6 KB |
| 4 | `dash-fastapi-frontend/views/layout/components/head.py` | ~4.7 KB |
| 5 | `dash-fastapi-frontend/callbacks/router_c.py` | ~7.3 KB |
| 6 | `dash-fastapi-frontend/views/layout/components/productapp_topbar.py` | ~4.9 KB |
| 7 | `dash-fastapi-frontend/callbacks/layout_c/productapp_topbar_c.py` | ~1.4 KB |

> 文件 6、7 即便本次只是注释了顶栏引用，但为保持版本一致也要一起覆盖。
> `head.py` 文件本身本次没改，但属于基础功能必须存在。

### 2.2 .map 占位文件（3 个，不在 tar.gz 里，需要单独创建）

| 包路径（在 site-packages 下） | 需要创建的文件 |
|------|------|
| `feffery_antd_charts\` | `feffery_antd_charts.min.js.map`（内容 `{}`） |
| `feffery_markdown_components\` | `feffery_markdown_components.min.js.map`（内容 `{}`） |
| `feffery_utils_components\` | `feffery_utils_components.min.js.map`（内容 `{}`） |

> 这三个 .map 文件**不会**出现在 tar.gz 里——它们是 site-packages 里的运行时文件，第五节会用 PowerShell 自动创建。

---

## 三、Linux 端打包命令

```bash
cd /root/.openclaw/workspace/dash-fastapi-admin

tar czf /tmp/auto-login-bundle.tar.gz \
  dash-fastapi-frontend/auto_login.py \
  dash-fastapi-frontend/views/layout/__init__.py \
  dash-fastapi-frontend/views/layout/components/aside.py \
  dash-fastapi-frontend/views/layout/components/head.py \
  dash-fastapi-frontend/callbacks/router_c.py \
  dash-fastapi-frontend/views/layout/components/productapp_topbar.py \
  dash-fastapi-frontend/callbacks/layout_c/productapp_topbar_c.py

ls -lh /tmp/auto-login-bundle.tar.gz
# 输出参考：-rw-r--r-- 1 root root 14K ...  /tmp/auto-login-bundle.tar.gz
```

如果文件 mtime 变了或想强制重新打包：
```bash
rm -f /tmp/auto-login-bundle.tar.gz
tar czf /tmp/auto-login-bundle.tar.gz [上面 7 个路径]
```

---

## 四、传到 Windows

**方法 A：scp**（Linux/macOS 终端）

```bash
scp /tmp/auto-login-bundle.tar.gz administrator@<windows-ip>:/c/upgrade/
```

**方法 B：WinSCP**（图形化）
1. 打开 WinSCP，连到目标 Windows
2. 左本地 = `/tmp/auto-login-bundle.tar.gz`，右远程 = `C:\upgrade\`
3. 拖过去

**方法 C：共享文件夹 / U 盘 / 远程桌面剪贴板**

把 `auto-login-bundle.tar.gz` 拷到 Windows 的 `C:\upgrade\` 下。

---

## 五、Windows 端一条龙升级（管理员 PowerShell）

把下面这段贴到 PowerShell，按需修改 `$dst` 和 `$bundle`：

```powershell
# ================== 配置 ==================
$dst      = "C:\path\to\dash-fastapi-admin"   # ← 改成你的项目根目录
$bundle   = "C:\upgrade\auto-login-bundle.tar.gz"
# 自动定位 Python site-packages（先尝试 python -c 检测，失败 fallback 到默认路径）
$sitePkgs = python -c "import site; print(site.getsitepackages()[0])" 2>$null
if (-not $sitePkgs -or -not (Test-Path $sitePkgs)) {
    $sitePkgs = "C:\Users\admin\AppData\Local\Programs\Python\Python313\Lib\site-packages"
    Write-Host "  ⚠️ python 检测失败，使用默认路径: $sitePkgs" -ForegroundColor Yellow
}
$pyExe    = (Get-Command python).Source
Write-Host "  ✓ 使用 site-packages: $sitePkgs"
Write-Host "  ✓ 使用 Python: $pyExe"

# ================== 1. 停服 ==================
Write-Host "`n[1/6] 停服..." -ForegroundColor Cyan
try { nssm stop DashFrontend } catch { Write-Host "  nssm 跳过（如果不是 NSSM）" }
Start-Sleep -Seconds 2

# ================== 2. 备份 ==================
Write-Host "`n[2/6] 备份现有 7 个代码文件..." -ForegroundColor Cyan
$backup = "C:\backup\dash-frontend-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
New-Item -ItemType Directory -Path $backup -Force | Out-Null
$files = @(
    "dash-fastapi-frontend\auto_login.py",
    "dash-fastapi-frontend\views\layout\__init__.py",
    "dash-fastapi-frontend\views\layout\components\aside.py",
    "dash-fastapi-frontend\views\layout\components\head.py",
    "dash-fastapi-frontend\callbacks\router_c.py",
    "dash-fastapi-frontend\views\layout\components\productapp_topbar.py",
    "dash-fastapi-frontend\callbacks\layout_c\productapp_topbar_c.py"
)
foreach ($f in $files) {
    Copy-Item "$dst\$f" "$backup\$f" -Force
}
Write-Host "  备份到: $backup"

# ================== 3. 解压覆盖 ==================
Write-Host "`n[3/6] 解压覆盖..." -ForegroundColor Cyan
tar -xzf $bundle -C $dst
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 解压失败，请检查 tar.gz 是否损坏" -ForegroundColor Red
    exit 1
}
Write-Host "  ✓ 已覆盖 7 个代码文件"

# ================== 4. 清理 pycache ==================
Write-Host "`n[4/6] 清理 pycache..." -ForegroundColor Cyan
Get-ChildItem -Path "$dst\dash-fastapi-frontend" -Recurse -Filter "__pycache__" `
    | Remove-Item -Recurse -Force
Get-ChildItem -Path "$dst\dash-fastapi-frontend" -Recurse -Filter "*.pyc" `
    | Remove-Item -Force
Write-Host "  ✓ 已清理"

# ================== 5. 补 feffery 包的 .map 占位文件（全量扫描） ==================
Write-Host "`n[5/6] 补 feffery 包的 .map 占位文件..." -ForegroundColor Cyan
# 全量扫描所有 feffery 包的所有 .js 文件，自动找缺失的 sourcemap 占位
# 包括 .min.js 和 async-*.js（之前漏过 async-graphs.js / async-plots.js）
Get-ChildItem $sitePkgs -Directory -Filter "feffery_*" |
    Where-Object { $_.Name -notmatch "\.dist-info$" } |
    ForEach-Object {
        $pkgDir = $_.FullName
        Get-ChildItem $pkgDir -Filter "*.js" | ForEach-Object {
            $jsFile = $_.FullName
            $tail = Get-Content $jsFile -Tail 1
            if ($tail -match "sourceMappingURL=([^\s]+)") {
                $mapUrl = $matches[1]
                # 跳过内联 base64（data:application/json;base64,... 形式，不需要服务端文件）
                if ($mapUrl -notmatch "^data:") {
                    $mapFile = Join-Path $pkgDir $mapUrl
                    if (-not (Test-Path $mapFile)) {
                        "{}" | Out-File -FilePath $mapFile -Encoding ASCII -NoNewline
                        Write-Host "  ✓ 创建 $((Split-Path $pkgDir -Leaf))/$((Split-Path $mapFile -Leaf))"
                    }
                }
            }
        }
    }

# ================== 6. 语法校验 + 重启 + 验证 ==================
Write-Host "`n[6/6] 语法校验 + 重启 + 验证..." -ForegroundColor Cyan
& $pyExe -m py_compile `
    "$dst\dash-fastapi-frontend\auto_login.py" `
    "$dst\dash-fastapi-frontend\views\layout\__init__.py" `
    "$dst\dash-fastapi-frontend\views\layout\components\aside.py" `
    "$dst\dash-fastapi-frontend\views\layout\components\head.py" `
    "$dst\dash-fastapi-frontend\callbacks\router_c.py"

if ($LASTEXITCODE -ne 0) {
    Write-Host "  ✗ 语法错误！从备份回滚后再排查" -ForegroundColor Red
    exit 1
}

try { nssm start DashFrontend } catch { Write-Host "  请手动启动 DashFrontend 服务" }
Start-Sleep -Seconds 3

# 监听检查
Get-NetTCPConnection -LocalPort 38039 -State Listen -ErrorAction SilentlyContinue `
    | Select-Object LocalAddress, LocalPort, State `
    | Format-Table -AutoSize

# SourceMap 验证（确认 .map 占位生效）
# 注意：PowerShell 里的 curl 是 Invoke-WebRequest 别名，要用真正的 curl 必须加 .exe 后缀
$mapTest = (curl.exe -s -o `$null -w "%{http_code}" "http://127.0.0.1:38039/_dash-component-suites/feffery_antd_charts/feffery_antd_charts.min.js.map")
if ($mapTest -eq "200") {
    Write-Host "  ✓ SourceMap 返回 200（修复 #9 生效）" -ForegroundColor Green
} else {
    Write-Host "  ⚠️ SourceMap 返回 $mapTest（可能需要重启 Dash 服务）" -ForegroundColor Yellow
}

Write-Host "`n✅ 升级完成，浏览器测试见下面" -ForegroundColor Green
```

> **重要提示**：如果你的项目用的是 `py -3.11` 启动（不是 `python`），把脚本里所有 `python` 和 `(Get-Command python).Source` 改成对应的命令。

---

## 六、浏览器验证（6 步必过，隐身窗口 Ctrl+Shift+N）

| # | 测试 | URL | 预期 |
|---|------|-----|------|
| ① | 正常登录 | `http://<server>:38039/login` | 手动登录后能看到 logo、title、头像、下拉 |
| ② | Auto-Login 首次 | `http://<server>:38039/auto-login?username=admin&password=admin123&redirect=/system/user` | 直接进用户管理，左侧 50px 占位（无 logo 无 title），右上无头像无下拉 |
| ③ | Auto-Login 二次（同一浏览器再访问） | 同上 | 仍进用户管理，不跳登录页 |
| ④ | 错密码（**修复 #6 验证**） | `http://<server>:38039/auto-login?username=admin&password=WRONG&redirect=/system/user` | 跳 `/login?error=密码错误` + **页面只有登录表单，没有左侧菜单** |
| ⑤ | 瞎 token（**修复 #7 验证**） | `http://<server>:38039/auto-login?token=BOGUS&redirect=/system/user` | 跳 `/login?error=用户token已失效，请重新登录` + **没有左侧菜单** |
| ⑥ | 根路径访问（**修复 #2 验证**） | `http://<server>:38039/` | 跳 `/system/user`（不再 404） |
| ⑦ | 360 浏览器折叠菜单（**修复 #8 验证**） | auto-login 进入后点折叠按钮 | 控制台无 "nonexistent object: logo-text" 报错 |
| ⑧ | DevTools 无 SourceMap 报错（**修复 #9 验证**） | 任意页面打开 DevTools | 控制台无 `feffery_antd_charts.min.js.map HTTP 500` 警告 |

任一项失败，看 Dash 进程的 stdout 日志，关键字：
- `[router] 检测到 auto-login 场景` — 正常
- `[router] 根路径跳转默认页` — 正常
- `[auto-login] 用户 admin 登录成功` — 正常

---

## 七、回滚（一键）

```powershell
nssm stop DashFrontend

$backup = "C:\backup\dash-frontend-20260629-xxxxxx"   # ← 改成实际备份目录名
$dst    = "C:\path\to\dash-fastapi-admin"

# 恢复 7 个文件
Copy-Item "$backup\*" "$dst\dash-fastapi-frontend\" -Recurse -Force

# 删缓存（必做）
Get-ChildItem "$dst\dash-fastapi-frontend" -Recurse -Filter "__pycache__" | Remove-Item -Recurse -Force

nssm start DashFrontend
```

---

## 八、注意事项

1. **后端不需要重启** —— 这次只动前端
2. **多台 Windows 服务器**：每台都要重复上述步骤，建议先升一台验证 30 分钟再批量
3. **`.map` 占位文件被覆盖后要补回来**：
   - `pip install --upgrade feffery_antd_charts` 会把 `feffery_antd_charts.min.js.map` 删掉
   - `pip install --force-reinstall` 会清掉所有 .map 占位
   - 跑 `pip install` 后**必须再跑一次第五节的步骤 5**，否则浏览器 DevTools 又会报 500
4. **本机 Python site-packages 在全局位置**：`C:\Users\admin\AppData\Local\Programs\Python\Python313\Lib\site-packages\`（不是 venv）
5. **备份不要丢**：保留至少一周再删
6. **第一次访问 auto-login URL 还是要硬刷新一次浏览器**（或隐身窗口），避免 JS 缓存

---

## 九、TL;DR（30 秒看完）

```bash
# Linux: 打包
cd /root/.openclaw/workspace/dash-fastapi-admin && tar czf /tmp/auto-login-bundle.tar.gz \
  dash-fastapi-frontend/auto_login.py \
  dash-fastapi-frontend/views/layout/__init__.py \
  dash-fastapi-frontend/views/layout/components/aside.py \
  dash-fastapi-frontend/views/layout/components/head.py \
  dash-fastapi-frontend/callbacks/router_c.py \
  dash-fastapi-frontend/views/layout/components/productapp_topbar.py \
  dash-fastapi-frontend/callbacks/layout_c/productapp_topbar_c.py
```

```powershell
# Windows: 一条龙（管理员 PowerShell）
# 修改 $dst 和 $bundle 后跑第五节脚本
```

---

**文档版本**：2026-06-29
**变更作者**：诸葛（zhuge）
**对应代码版本**：dash-fastapi-frontend（含 6/26-6/29 全部 auto-login 改动）
