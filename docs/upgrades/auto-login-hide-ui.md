# Auto-Login 场景隐藏 Logo / 头像 — Windows 升级手册

> **适用版本**：dash-fastapi-admin（前端项目 `dash-fastapi-frontend`）
> **本次改动需求**：
> 1. `/auto-login` 嵌入式登录进来的用户，左侧菜单栏的 logo 和 title 隐藏；正常表单登录保留
> 2. 同一类用户，右上角的用户头像与用户名下拉菜单也隐藏；正常表单登录保留
> **改动文件数**：5 个（全部位于前端项目 `dash-fastapi-frontend/`）
> **后端 / 数据库 / 依赖**：均无变更

---

## 一、改动文件清单

| # | 文件路径 | 类型 | 说明 |
|---|---|---|---|
| 1 | `auto_login.py` | **修改**（已有文件） | 在两处 `session['Authorization'] = token` 后插入 `is_auto_login=True` 标记行 |
| 2 | `views/layout/__init__.py` | 修改 | `render()` 增加 `is_auto_login` 参数，向下透传给 `aside` 和 `head` |
| 3 | `views/layout/components/aside.py` | 修改 | auto-login 时把 logo + title 行换成 50px 暗色占位（避免菜单紧贴顶部） |
| 4 | `views/layout/components/head.py` | 修改 | auto-login 时跳过 `AntdAvatar` + `AntdDropdown` 那一列；刷新按钮自动靠右 |
| 5 | `callbacks/router_c.py` | 修改 | 两处 `views.layout.render(...)` 都从 Flask session 读取 `is_auto_login` 标记并传入 |

> 详细 diff 见同级目录 `auto-login-hide-ui.patch`（`git apply` 可直接打）。

---

## 二、改动核心逻辑

### 1. `auto_login.py`（已有文件，插入两行）

在 token 写入 session 后**多写一行标记**：

```python
session['Authorization'] = token
session['is_auto_login'] = True   # ← 新增，标记本次会话来自 auto-login
```

两处都要加（`token` 方式 + `username/password` 方式）。

### 2. `router_c.py`（渲染入口）

两处 `views.layout.render(...)` 调用，从 Flask session 读标记：

```python
app_mount=views.layout.render(
    user_menu_info,
    is_auto_login=bool(session.get('is_auto_login')),
),
```

正常登录时 `session.get('is_auto_login')` 返回 `None` → `bool(None) == False`，UI 不受影响。

### 3. `aside.py`（左侧菜单栏）

```python
def render_aside_content(menu_info, is_auto_login=False):
    if is_auto_login:
        header = html.Div(style={...50px 暗色占位...})
    else:
        header = fac.AntdRow([logo_image, title_text], ...)
    return [..., fac.AntdSider([header, menu])]
```

### 4. `head.py`（右上角用户区）

```python
def render_head_content(is_auto_login=False):
    cols = [折叠按钮, 面包屑]
    if not is_auto_login:
        cols.append(AntdAvatar + AntdDropdown)
    cols.append(刷新按钮)
    return cols
```

---

## 三、Windows 环境升级步骤

### 前置条件

- 已部署的 dash-fastapi-admin 服务**当前运行正常**
- 具备该服务安装目录的**写权限**
- 已安装 **Git for Windows**（推荐，便于打 patch；如未装请走"方案 B 手动替换"）
- 服务当前是**停止状态**或升级后允许短暂重启

### 方案 A：使用 patch 文件（推荐）

**第 1 步：停服**

如果服务是用 NSSM / 任务计划 / 直接命令行跑的，先停掉：

```powershell
# 例：NSSM 安装的服务
nssm stop DashFrontend

# 例：直接运行
# 在原命令行窗口按 Ctrl+C，或关掉对应 PowerShell 窗口
```

**第 2 步：备份（强烈建议）**

```powershell
$date = Get-Date -Format "yyyyMMdd-HHmmss"
$backup = "C:\backup\dash-frontend-$date"
New-Item -ItemType Directory -Path $backup -Force | Out-Null

Copy-Item -Path "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\*" `
          -Destination $backup -Recurse -Force

Write-Host "备份完成: $backup"
```

> 把 `C:\path\to\dash-fastapi-admin` 替换为实际安装路径。

**第 3 步：拷贝 patch 文件到服务器**

把仓库里的 `docs/upgrades/auto-login-hide-ui.patch` 拷到 Windows 服务器，例如：

```
C:\upgrade\auto-login-hide-ui.patch
```

**第 4 步：打 patch**

进入项目根目录（在 Git Bash 或 PowerShell 里都行）：

```bash
cd /c/path/to/dash-fastapi-admin
git apply --check C:/upgrade/auto-login-hide-ui.patch
git apply C:/upgrade/auto-login-hide-ui.patch
```

- `git apply --check` 先**干跑一遍**，确认无冲突再真打。
- 如果输出类似 `error: patch failed` 或 `error: ... does not exist in index`，说明当前文件版本与 patch 不匹配，**不要强打**，改走方案 B。

**第 5 步：清理 Python 缓存（避免旧字节码）**

```powershell
Get-ChildItem -Path ".\dash-fastapi-frontend" -Recurse -Filter "__pycache__" `
    | Remove-Item -Recurse -Force
Get-ChildItem -Path ".\dash-fastapi-frontend" -Recurse -Filter "*.pyc" `
    | Remove-Item -Force
```

**第 6 步：语法快速校验**

```powershell
cd "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend"
.\.venv-frontend\Scripts\python.exe -m py_compile `
    auto_login.py `
    views\layout\__init__.py `
    views\layout\components\aside.py `
    views\layout\components\head.py `
    callbacks\router_c.py
```

无输出 = 通过。如有报错，对照报错信息和文档第二节手改。

**第 7 步：重启服务**

```powershell
nssm start DashFrontend
# 或按你原来的启动方式重新跑
```

**第 8 步：验证**

打开浏览器，分别测试：

- ✅ 正常登录（`/login`）：左侧菜单有 logo + "情绪管理后台系统"；右上角有头像和用户名下拉
- ❌ auto-login（`/auto-login?username=admin&password=admin123&redirect=/dashboard`）：左侧菜单顶部只有暗色占位，无 logo 无 title；右上角没有头像和下拉

---

### 方案 B：手动替换（不装 Git 时）

把 5 个文件用文本编辑器逐个替换为新版本：

| 文件 | 新版本来源 |
|---|---|
| `auto_login.py` | 仓库里直接拿（这是新文件） |
| `views/layout/__init__.py` | 用编辑器按第二节第 2 条精确修改（替换 `def render` 签名和两处 `render_aside_content` / `render_head_content` 调用） |
| `views/layout/components/aside.py` | 直接整文件覆盖 |
| `views/layout/components/head.py` | 直接整文件覆盖 |
| `callbacks/router_c.py` | 用编辑器按第二节第 2 条精确修改（替换两处 `views.layout.render(...)` 调用） |

替换完成后，照上面**第 5、6、7、8 步**走。

> **不建议复制整文件覆盖 router_c.py 和 layout/__init__.py**，因为这俩文件还有本次需求以外的未提交改动，直接覆盖会丢上下文。**只对 `aside.py` / `head.py` / `auto_login.py` 三个文件做整文件替换是安全的。**

---

## 四、回滚方案

### 方案 A：用备份回滚

```powershell
nssm stop DashFrontend

# 把刚才备份目录里的 5 个文件拷回去
$backup = "C:\backup\dash-frontend-20260627-105000"   # 改成实际备份名
Copy-Item -Path "$backup\auto_login.py"          -Destination "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\auto_login.py" -Force
Copy-Item -Path "$backup\views\layout\__init__.py"          -Destination "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\views\layout\__init__.py" -Force
Copy-Item -Path "$backup\views\layout\components\aside.py"  -Destination "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\views\layout\components\aside.py" -Force
Copy-Item -Path "$backup\views\layout\components\head.py"   -Destination "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\views\layout\components\head.py" -Force
Copy-Item -Path "$backup\callbacks\router_c.py"             -Destination "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend\callbacks\router_c.py" -Force

Get-ChildItem -Path "C:\path\to\dash-fastapi-admin\dash-fastapi-frontend" -Recurse -Filter "__pycache__" | Remove-Item -Recurse -Force

nssm start DashFrontend
```

### 方案 B：用 patch 反向回滚

```bash
cd /c/path/to/dash-fastapi-admin
git apply -R C:/upgrade/auto-login-hide-ui.patch
```

---

## 五、风险与注意事项

1. **`session['is_auto_login']` 不会自动清除**
   - 用户通过 auto-login 进入后，**整个浏览器会话期间**该标记都在；刷新页面、按菜单跳转不会清除。
   - 只有当用户**主动退出登录**（清空 Flask session）或**关闭浏览器**后才会消失。
   - 现状符合需求语义"auto-login 过来的就隐藏"，如需调整请提前沟通。

2. **`auto_login.py` 昨天就已部署**
   - 这个文件**不是**今天的新文件，昨天装 auto-login 功能时已经放到服务器上了。
   - 今天的 patch 是"在已有文件上插入两行"的形式（不是整文件新增），`git apply` 应该能直接打。
   - 如果 patch 失败（极少见，多半是 Windows 换行符差异），把这两行手动补到对应位置即可：
     - 第一次出现 `session['Authorization'] = token`（12 空格缩进）下方
     - 第二次出现 `session['Authorization'] = token`（16 空格缩进）下方
     - 都要插入一行 `session['is_auto_login'] = True`（缩进跟上一行一致）

3. **顶栏 `productapp_topbar.py` 暂未改动**
   - 顶栏最左边的 logo + `您好，{user_name}` 文字在 auto-login 时**仍然显示**。
   - 本次需求只点名了"左侧菜单栏 logo/title"和"右上角头像/下拉"，未提顶栏，按字面执行。
   - 如需一并隐藏，告诉我，5 分钟内可加。

4. **前端项目无需重启 nginx / 反向代理**
   - 这是后端 Dash 进程内的渲染逻辑变更，不需要改 nginx 配置。
   - 但是**必须重启 Dash 进程**才能生效（Python 字节码缓存），详见第 1、7 步。

5. **多台服务器**
   - 如果前端是**多实例部署**，每台机器都要重复上述步骤。
   - 升级前确认 LB / 反向代理能容忍分批重启（先下掉一台再升，升完再加回）。

---

## 六、附：升级后日志关键字

升级成功后，在 Dash 进程的 stdout / 日志文件里能看到这条（auto-login 触发时）：

```
[router] 检测到 auto-login 场景，同步 server session token 到前端 dcc.Store
```

如果看不到，且 auto-login URL 也不报错，多半是 patch 没生效或没重启服务。

---

**文档版本**：2026-06-27
**变更作者**：诸葛（zhuge）
