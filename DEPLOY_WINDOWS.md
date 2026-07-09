# 情绪管理后台系统 - Windows 部署手册

## 一、项目信息

| 项目 | 值 |
|------|-----|
| 应用名称 | 情绪管理后台系统 |
| 前端地址 | `http://localhost:38039` |
| 后端地址 | `http://127.0.0.1:38038` |
| 数据库 | MySQL 10.11, 库名 `dash_fastapi` |
| 代码仓库 | https://gitee.com/insistence2022/dash-fastapi-admin.git |

## 二、环境要求

- **系统**: Windows 10/11 (x64)
- **Python**: 3.10+（[下载地址](https://www.python.org/downloads/)）
- **数据库**: 需可访问 MySQL 服务器（10.10.30.34）或本地 MySQL
- **网络**: 能访问 Gitee + MySQL 服务器

## 三、部署步骤

### 3.1 安装 Python

1. 访问 [https://www.python.org/downloads/](https://www.python.org/downloads/) 下载 Python 3.10+
2. 安装时**务必勾选** `Add Python to PATH`
3. 验证安装：
   ```
   python --version
   pip --version
   ```

### 3.2 获取代码

方式一：Git 克隆
```
cd C:\
git clone https://gitee.com/insistence2022/dash-fastapi-admin.git
cd dash-fastapi-admin
```

方式二：直接下载 ZIP 包并解压

### 3.3 初始化数据库

确保 MySQL 服务器可访问后，执行：
```
mysql -h 10.10.30.34 -P 3306 -u root -p"root123" < dash-fastapi-backend\sql\dash-fastapi.sql
```

### 3.4 配置后端

```
cd dash-fastapi-admin\dash-fastapi-backend
pip install -r requirements.txt
```

**修改配置文件** `config\env.py`，或创建 `.env.dev` 文件：
```
# 数据库配置
DB_HOST=10.10.30.34
DB_PORT=3306
DB_USERNAME=root
DB_PASSWORD=root123
DB_DATABASE=dash_fastapi

# Redis配置（根据实际情况修改）
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_DATABASE=2
```

### 3.5 配置并启动前端

```
cd dash-fastapi-admin\dash-fastapi-frontend
pip install -r requirements.txt
```

**修改配置** `config\env.py` 或创建 `.env.dev`：
```
APP_NAME=情绪管理后台系统
APP_BASE_URL=http://127.0.0.1:38038
APP_IS_PROXY=false
APP_HOST=127.0.0.1
APP_PORT=38039
APP_DEBUG=false
```

## 四、后台运行方式

### 方式一：Windows 快捷方式（最简单）

1. 创建后端启动快捷方式：
   - 右键新建 → 快捷方式
   - 目标：`cmd /c "cd /d C:\dash-fastapi-admin\dash-fastapi-backend && python -m uvicorn app:app --host 0.0.0.0 --port 38038"`
   - 命名 `dash-backend.vbs`，内容：
     ```vbs
     Set WshShell = CreateObject("WScript.Shell")
     WshShell.Run "cmd /c python -m uvicorn app:app --host 0.0.0.0 --port 38038", 0, False
     ```
   - 放到 `shell:startup` 目录实现开机启动

2. 创建前端启动快捷方式：
   ```vbs
   Set WshShell = CreateObject("WScript.Shell")
   WshShell.Run "cmd /c python app.py", 0, False
   ```

### 方式二：Windows 服务（nssm）

1. 下载 [nssm](https://nssm.cc/download)，解压后将 `nssm.exe` 放到项目目录

2. 注册后端服务：
   ```
   nssm install DashBackend "C:\Python\python.exe" "-m uvicorn app:app --host 0.0.0.0 --port 38038"
   nssm set DashBackend AppDirectory "C:\dash-fastapi-admin\dash-fastapi-backend"
   nssm set DashBackend DisplayName "Dash FastAPI Backend"
   nssm set DashBackend Start SERVICE_AUTO_START
   nssm start DashBackend
   ```

3. 注册前端服务：
   ```
   nssm install DashFrontend "C:\Python\python.exe" "app.py"
   nssm set DashFrontend AppDirectory "C:\dash-fastapi-admin\dash-fastapi-frontend"
   nssm set DashFrontend DisplayName "Dash Frontend"
   nssm set DashFrontend Start SERVICE_AUTO_START
   nssm start DashFrontend
   ```

### 方式三：Task Scheduler 计划任务

```cmd
# 后端
schtasks /create /tn "DashBackend" /tr "python -m uvicorn app:app --host 0.0.0.0 --port 38038" /sc onstart /ru SYSTEM
schtasks /run /tn "DashBackend"

# 前端
schtasks /create /tn "DashFrontend" /tr "python app.py" /sc onstart /ru SYSTEM
schtasks /run /tn "DashFrontend"
```

### 方式四：PM2（需先安装 Node.js）

```cmd
npm install -g pm2

# 后端
pm2 start "python -m uvicorn app:app --host 0.0.0.0 --port 38038" --name dash-backend
pm2 save
pm2 startup

# 前端
pm2 start "python app.py" --name dash-frontend
pm2 save
pm2 startup
```

### 方式五：直接命令行后台启动

```cmd
# 后端
start /b python -m uvicorn app:app --host 0.0.0.0 --port 38038 > backend.log 2>&1

# 前端
start /b python app.py > frontend.log 2>&1
```

## 五、验证启动

```cmd
# 验证后端
curl http://127.0.0.1:38038/api/system/user/list

# 验证前端
curl http://127.0.0.1:38039/
```

## 六、常见问题

### Q1: pip 安装依赖失败
- 确认 Python 已加入 PATH
- 升级 pip：`python -m pip install --upgrade pip`
- 使用国内镜像：`pip install -r requirements.txt -i https://pypi.tuna.tsinghua.edu.cn/simple`

### Q2: 数据库连接失败
```
mysql -h 10.10.30.34 -P 3306 -u root -p"root123" -e "SHOW DATABASES;"
```

### Q3: 端口被占用
```cmd
netstat -ano | findstr :38038
netstat -ano | findstr :38039
taskkill /PID <PID> /F
```

## 七、账号说明

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| admin | admin123 | 管理员 | 全部权限 |
| test | test123 | 普通用户 | 受限权限 |

## 八、停止服务

| 方式 | 命令 |
|------|------|
| nssm | `nssm stop DashBackend` / `nssm stop DashFrontend` |
| PM2 | `pm2 stop dash-backend` / `pm2 stop dash-frontend` |
| Task Scheduler | `schtasks /end /tn DashBackend` |
| 直接启动 | `taskkill /F /IM python.exe` |

## 九、项目结构

```
dash-fastapi-admin/
├── DEPLOY.md              # Linux 部署文档
├── DEPLOY_WINDOWS.md      # Windows 部署文档（本文件）
├── dash-fastapi-backend/  # 后端（FastAPI）
│   ├── app.py
│   ├── config/            # 配置文件
│   ├── df_admin/          # 业务代码
│   └── sql/               # 数据库 SQL
└── dash-fastapi-frontend/ # 前端（Dash）
    ├── app.py             # 入口文件
    ├── callbacks/         # 回调逻辑
    ├── config/            # 配置文件
    └── views/             # 页面视图
```
