# 2026-06-29 累积改动全量包 — 部署记录

> **打包时间**：2026-06-29 08:24 UTC
> **范围**：git HEAD (2026-06-08 commit `dbc363e`) 之后**工作区所有改动**
> **打包方式**：`git status` 全量 + 排除 `.venv`/`__pycache__`/`*.bak.*`/`docs/`/`test.*`/`backups/`
> **离线包**：`all-changes-since-2026-06-08.tar.gz`（1.2MB，23 个文件（已排除 4 个 .env））
> **MD5**：`45c14c8ca7835cf80209402a95a51c80`

---

## 一、改动范围说明

> **重要**：git 上一个 commit 是 `dbc363e`（2026-06-08），从那之后**没有任何 commit**，所有改动都在工作区。
> 用户问"23 号之后"——workspace 实际是**当前工作区 vs 6/8 commit** 之间的所有差异。

### 1.1 修改的文件 (19 个，相对于 HEAD)

| # | 文件路径 | 来源 |
|---|---|---|
| 1 | `dash-fastapi-backend/.env.dev` | 本地配置 |
| 2 | `dash-fastapi-backend/.env.prod` | 本地配置 |
| 3 | `dash-fastapi-backend/middlewares/cors_middleware.py` | CORS origins 调整 |
| 4 | `dash-fastapi-backend/module_admin/annotation/log_annotation.py` | **本次会话：IP 归属地改造** |
| 5 | `dash-fastapi-backend/module_admin/service/server_service.py` | 服务器服务 |
| 6 | `dash-fastapi-frontend/.env.dev` | 本地配置 |
| 7 | `dash-fastapi-frontend/.env.prod` | 本地配置 |
| 8 | `dash-fastapi-frontend/callbacks/layout_c/fold_side_menu.py` | 折叠菜单 |
| 9 | `dash-fastapi-frontend/callbacks/layout_c/index_c.py` | index 回调 |
| 10 | `dash-fastapi-frontend/callbacks/router_c.py` | 路由回调 |
| 11 | `dash-fastapi-frontend/callbacks/system_c/user_c/profile_c/avatar_c.py` | 头像上传 |
| 12 | `dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py` | 用户管理 |
| 13 | `dash-fastapi-frontend/server.py` | Flask server |
| 14 | `dash-fastapi-frontend/utils/request.py` | **本次会话：X-Login-Location 转发** |
| 15 | `dash-fastapi-frontend/views/dashboard/components/page_top.py` | 首页 |
| 16 | `dash-fastapi-frontend/views/layout/__init__.py` | layout |
| 17 | `dash-fastapi-frontend/views/layout/components/aside.py` | 左侧菜单 |
| 18 | `dash-fastapi-frontend/views/layout/components/head.py` | 顶部栏 |
| 19 | `dash-fastapi-frontend/views/system/user/profile/user_avatar.py` | 用户头像页 |

### 1.2 新增的文件 (8 个)

| # | 文件路径 | 来源 |
|---|---|---|
| 1 | `dash-fastapi-frontend/assets/css/productapp-topbar.css` | ProductApp 顶栏样式 |
| 2 | `dash-fastapi-frontend/assets/imgs/1.png` | 图片资源 |
| 3 | `dash-fastapi-frontend/assets/imgs/title-icon-exit.png` | 退出图标 |
| 4 | `dash-fastapi-frontend/assets/imgs/title-icon-fulllScreen.png` | 全屏图标 |
| 5 | `dash-fastapi-frontend/assets/js/login_location.js` | **本次会话：新建** |
| 6 | `dash-fastapi-frontend/auto_login.py` | auto-login 路由（上午已部署过） |
| 7 | `dash-fastapi-frontend/callbacks/layout_c/productapp_topbar_c.py` | 顶栏回调 |
| 8 | `dash-fastapi-frontend/views/layout/components/productapp_topbar.py` | 顶栏组件 |

### 1.3 排除的（不打包）

| 类型 | 原因 |
|---|---|
| `.venv-backend/` `.venv-frontend/` | 虚拟环境，不应跨机器部署 |
| `__pycache__/` `*.pyc` | Python 编译缓存，会自动生成 |
| `*.bak.*` | 本地备份，不属于生产代码 |
| `backups/` | 备份目录 |
| `docs/*` | 文档（除非你要部署到目标机器） |
| `test.py` `test_render.cjs` | 测试脚本 |
| `AVATAR_BUG_FIX.md` `DEPLOY_WINDOWS.md` | 本地笔记 |

---

## 二、目标机器部署步骤

### 2.1 上传离线包

```powershell
# 在 Windows PowerShell 里（包已放到 D:\webadmin\PythonServer\）
PS D:\webadmin\PythonServer> dir all-changes-since-2026-06-08.tar.gz
```

### 2.2 执行替换（按用户指定命令）

```powershell
PS D:\webadmin\PythonServer> $dst    = "D:\webadmin\PythonServer\dash-fastapi-admin\"
PS D:\webadmin\PythonServer> $bundle = "D:\webadmin\PythonServer\all-changes-since-2026-06-08.tar.gz"
PS D:\webadmin\PythonServer> tar -xzf $bundle -C $dst
```

### 2.3 验证文件已就位

```powershell
PS D:\webadmin\PythonServer> Get-ChildItem $dst -Recurse -File | Where-Object { $_.FullName -match "log_annotation\.py|request\.py|login_location\.js|auto_login\.py" } | Select-Object FullName, Length, LastWriteTime
```

### 2.4 清 pycache

```powershell
PS D:\webadmin\PythonServer> Get-ChildItem "$dst\dash-fastapi-backend", "$dst\dash-fastapi-frontend" -Recurse -Filter "__pycache__" -EA SilentlyContinue | Remove-Item -Recurse -Force
PS D:\webadmin\PythonServer> Get-ChildItem "$dst\dash-fastapi-backend", "$dst\dash-fastapi-frontend" -Recurse -Filter "*.pyc" -EA SilentlyContinue | Remove-Item -Force
```

### 2.5 重启服务

> **注意**：本次覆盖范围大（19 个修改 + 8 个新增），**两个服务都必须重启**。

```powershell
PS D:\webadmin\PythonServer> nssm restart DashBackend
PS D:\webadmin\PythonServer> nssm restart DashFrontend
PS D:\webadmin\PythonServer> Start-Sleep -Seconds 3
PS D:\webadmin\PythonServer> Get-NetTCPConnection -LocalPort 9099,38039 -State Listen | Format-Table LocalAddress, LocalPort, State
```

---

## 三、变更影响面

### 3.1 涉及的关键功能

| 功能模块 | 文件 | 改动 |
|---|---|---|
| **IP 归属地（本次会话新增）** | `log_annotation.py` / `request.py` / `login_location.js` | 数据源：百度 API → 客户端 header |
| **Auto-login 嵌入式** | `auto_login.py` / `router_c.py` / `layout/*` / `head.py` / `aside.py` | 上午已部署过的全套修复 |
| **用户管理** | `user_c.py` / `profile_c/avatar_c.py` / `user_avatar.py` | 头像上传、用户管理界面 |
| **布局** | `index_c.py` / `page_top.py` / `__init__.py` / `fold_side_menu.py` | layout 调整、tab 关闭逻辑 |
| **配置** | `.env.*` | 应用名、端口等本地配置 |
| **CORS** | `cors_middleware.py` | origins 白名单 |

### 3.2 风险等级

| 维度 | 评估 |
|---|---|
| 文件数 | 23 个 |
| 数据库 | 0 改动 |
| 依赖 | 0 新增 |
| 配置（.env） | 含敏感信息（密码/密钥），建议确认是否要覆盖 |
| API 接口 | 0 签名变更 |
| 兼容性 | 同版本 Python 3.11+ / 同浏览器版本 |

### 3.3 部署建议

| 步骤 | 建议 |
|---|---|
| 1. 先备份目标机器 | `Copy-Item -Recurse "$dst" "$dst.bak.20260629"` |
| 2. 检查 .env 改动 | diff 一下本地和目标的 .env，确认是否真要覆盖 |
| 3. 干跑一遍 | 用 `tar -tzf` 先看包内容 |
| 4. 解压覆盖 | `tar -xzf $bundle -C $dst` |
| 5. 清缓存 + 重启 | 见 2.4 / 2.5 |
| 6. 业务验证 | 见下方 |

---

## 四、业务验证清单

| # | 测试 | 预期 |
|---|---|---|
| ① | 正常登录 `http://<ip>:38039/login` | 表单登录成功，跳 `/system/user` |
| ② | Auto-login `http://<ip>:38039/auto-login?username=admin&password=admin123` | 直接进用户管理，左侧无 logo，右上无头像 |
| ③ | 错密码 auto-login | 跳 `/login?error=密码错误` |
| ④ | 浏览器 F12 → 任意 callback | `X-Login-Location: 北京市 海淀区` |
| ⑤ | 数据库查 `logininfor` 表 | `login_location` 是具体地址 |

---

## 五、回滚（如果出问题）

```powershell
# 1. 停服
nssm stop DashBackend
nssm stop DashFrontend

# 2. 从备份恢复（如果部署前备份过整个目录）
Rename-Item "$dst" "$dst.broken.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
Rename-Item "$dst.bak.20260629" "$dst"

# 3. 或者用 git 还原
cd $dst.TrimEnd('\')
git checkout HEAD -- dash-fastapi-backend dash-fastapi-frontend
# untracked 新文件需要手动删
Remove-Item dash-fastapi-frontend/auto_login.py -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/callbacks/layout_c/productapp_topbar_c.py -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/views/layout/components/productapp_topbar.py -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/assets/css/productapp-topbar.css -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/assets/js/login_location.js -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/assets/imgs/1.png -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/assets/imgs/title-icon-exit.png -EA SilentlyContinue
Remove-Item dash-fastapi-frontend/assets/imgs/title-icon-fulllScreen.png -EA SilentlyContinue

# 4. 清缓存
Get-ChildItem dash-fastapi-backend, dash-fastapi-frontend -Recurse -Filter "__pycache__" -EA SilentlyContinue | Remove-Item -Recurse -Force

# 5. 重启
nssm start DashBackend
nssm start DashFrontend
```

---

## 六、元数据

| 字段 | 值 |
|---|---|
| 打包命令 | `tar czf ... --transform 's|^|dash-fastapi-admin/|' -T /tmp/deploy_list.txt` |
| 包大小 | 1.2MB（含 3 张图片） |
| MD5 | `45c14c8ca7835cf80209402a95a51c80` |
| 包路径 | `docs/upgrades/dist/all-changes-since-2026-06-08.tar.gz` |
| 改动起点 | git commit `dbc363e` (2026-06-08) |
| 改动终点 | 当前工作区 (2026-06-29 08:24) |
| 时间跨度 | ~21 天 |
| 文件数 | 23 个（19 modified + 8 untracked - 4 .env） |

---

## 七、相关离线包对照

| 包名 | 大小 | 文件数 | 范围 | 用途 |
|---|---|---|---|---|
| `all-changes-since-2026-06-08.tar.gz` | **1.2MB** | **27** | 全量累积 | 首次部署 / 大版本升级 |
| `ip-location-from-client-2026-06-29.tar.gz` | 8.2KB | 5 | 仅本次会话 | 增量更新（小补丁） |
| `ip-location-bundle.tar.gz` | 7.8KB | 3 | 仅本次会话（无备份） | 极简增量 |
