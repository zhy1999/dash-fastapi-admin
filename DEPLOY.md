# 情绪管理后台系统 - 部署手册

## 一、项目信息

| 项目 | 值 |
|------|-----|
| 应用名称 | 情绪管理后台系统 |
| 前端地址 | `http://0.0.0.0:38039` |
| 后端地址 | `http://127.0.0.1:38038` |
| 数据库 | MySQL 10.11, 库名 `dash_fastapi` |
| 代码仓库 | https://gitee.com/insistence2022/dash-fastapi-admin.git |

## 二、机器要求

- **系统**: Debian/Ubuntu Linux (x86_64)
- **网络**: 能访问 Gitee + MySQL 服务器
- **端口**: 38038（后端）、38039（前端）需开放

## 三、新机器初始环境

```bash
# 1. 安装 Python 3.10+
apt update && apt install -y python3 python3-pip python3-venv

# 2. 安装 Node.js 18+（前端静态资源构建）
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs

# 3. 安装 MySQL 客户端（可选，用于连接数据库）
apt install -y default-mysql-client
```

## 四、项目部署步骤

### 4.1 获取代码

```bash
cd /opt
git clone https://gitee.com/insistence2022/dash-fastapi-admin.git
cd dash-fastapi-admin
```

### 4.2 初始化数据库

```bash
# 连接 MySQL 服务器（10.10.30.34）并执行 SQL
mysql -h 10.10.30.34 -P 3306 -u root -p'root123' < dash-fastapi-backend/sql/dash-fastapi.sql
```

**注意**: `dash-fastapi.sql` 中包含所有表结构和初始数据（权限、角色、用户等），需在部署时执行。如果数据库已有数据，可只执行建表语句或手动比对。

### 4.3 配置后端

```bash
cd dash-fastapi-admin/dash-fastapi-backend

# 安装依赖
pip install -r requirements.txt

# 修改配置文件（数据库地址等）
# 配置参考: .env.example 或直接修改 config.py
```

### 4.4 启动后端

```bash
cd dash-fastapi-admin/dash-fastapi-backend
nohup python3 -m uvicorn app:app --host 0.0.0.0 --port 38038 > logs/backend.log 2>&1 &
echo $! > logs/backend.pid
```

验证后端启动:
```bash
curl http://127.0.0.1:38038/api/system/user/list
```

### 4.5 配置并启动前端

**⚠️ 重要：首次部署必须修改 `.env.prod` 中的 `APP_BASE_URL`**

```bash
# 编辑 .env.prod，修改 APP_BASE_URL 为实际机器IP
# 前端浏览器能访问到的地址，不能用 127.0.0.1 或 0.0.0.0
# 示例：APP_BASE_URL = 'http://10.10.30.31:38038'

cd dash-fastapi-admin/dash-fastapi-frontend

# 安装依赖
pip install -r requirements.txt

# 启动前端（使用 prod 环境配置）
nohup env APP_ENV=prod python3 app.py > logs/frontend.log 2>&1 &
echo $! > logs/frontend.pid
```

**或手动指定所有参数（不依赖 .env.prod）：**
```bash
nohup env \
  APP_NAME='情绪管理后台系统' \
  APP_BASE_URL='http://<实际机器IP>:38038' \
  APP_IS_PROXY='false' \
  APP_HOST='0.0.0.0' \
  APP_PORT=38039 \
  APP_DEBUG='false' \
  python3 app.py > logs/frontend.log 2>&1 &
```

验证前端启动:
```bash
curl http://127.0.0.1:38039/
```

## 五、账号说明

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| admin | admin123 | 管理员 | 全部权限 |
| test | test123 | 普通用户 | 受限权限（无操作按钮） |

## 六、重要代码改动记录（部署后需同步）

以下改动不在 SQL 中，是 Python 代码逻辑，部署新机器需确保代码已是最新：

### 修复1: 无操作权限时隐藏操作列（dept/post/config）

**文件**: `dash-fastapi-frontend/callbacks/system_c/dept_c.py`
**文件**: `dash-fastapi-frontend/callbacks/system_c/post_c.py`
**文件**: `dash-fastapi-frontend/callbacks/system_c/config_c.py`

**改动**: `generate_*_table` 函数中，权限判断从 `else {}` 改为 `else None`，最后 filter 掉 None：

```python
# 改动前
item['operation'] = [
    {'content': '修改', 'type': 'link', 'icon': 'antd-edit'}
    if PermissionManager.check_perms('system:dept:edit')
    else {},
    ...
]

# 改动后
operations = [
    {'content': '修改', 'type': 'link', 'icon': 'antd-edit'}
    if PermissionManager.check_perms('system:dept:edit')
    else None,
    ...
]
item['operation'] = [op for op in operations if op]
```

**原因**: `else {}` 会产生空字典，feffery 渲染时显示为空白按钮占位。

### 修复2: 用户页面操作列无权限时隐藏（user）

**文件**: `dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py`

**新增回调**: `update_operation_column_visibility` - 无操作权限时隐藏操作列（user 页面用 `renderType: 'dropdown'`，需要整列隐藏）

### 修复3: 普通用户访问404

**文件**: `dash-fastapi-frontend/utils/router_util.py`

**改动**: 修复面包屑路径拼接时子菜单 path 缺少斜杠的问题。

## 七、常见问题

### Q1: 前端启动报 `NameError: app is not defined`
检查是否错误创建了 `callbacks.py` 文件（项目里不存在，应在 `callbacks/` 目录下）。如存在，删除：
```bash
rm -f dash-fastapi-frontend/callbacks.py
rm -f dash-fastapi-frontend/callbacks/dept_c.py
```

### Q2: 页面显示"找不到页面"
普通用户（test）因权限不足访问部分页面时显示404。这是已知行为（权限控制），管理员账号登录可解决。

### Q3: 数据库连接失败
确认 MySQL 服务器可达，且 `dash_fastapi` 库已创建：
```bash
mysql -h 10.10.30.34 -P 3306 -u root -p'root123' -e "SHOW DATABASES;"
```

## 八、日志位置

```
dash-fastapi-backend/logs/backend.log   # 后端日志
dash-fastapi-frontend/logs/frontend.log # 前端日志
```

## 九、停止服务

```bash
# 后端
kill $(cat dash-fastapi-backend/logs/backend.pid 2>/dev/null) 2>/dev/null

# 前端
kill $(cat dash-fastapi-frontend/logs/frontend.pid 2>/dev/null) 2>/dev/null
```
