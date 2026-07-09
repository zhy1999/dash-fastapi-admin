# Windows 部署说明：2026-06-26 双修复

涵盖今天在 manager02（10.208.11.16）验证通过的两个改动：

- **Fix 1**：用户管理界面新建用户后，列表列头消失
- **Fix 2**：新增嵌入式自动登录端点 `/auto-login`

---

## 一、Patch 文件

`docs/2026-06-26-fixes.patch` —— 包含全部 4 个文件的改动：
1. `dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py`（改）
2. `dash-fastapi-frontend/callbacks/router_c.py`（改）
3. `dash-fastapi-frontend/server.py`（改）
4. `dash-fastapi-frontend/auto_login.py`（**新增**）

---

## 二、Windows 部署步骤（推荐用 patch）

### 方式 A：git apply（推荐）

```cmd
cd C:\你的路径\dash-fastapi-admin
git apply --check docs\2026-06-26-fixes.patch
git apply docs\2026-06-26-fixes.patch
```

`--check` 先 dry-run 确认能 apply。如果报"already applied"或冲突，跳到方式 B 手改。

### 方式 B：手动覆盖（patch apply 失败时）

1. 从 manager02 把 4 个文件复制过来覆盖：
   - `dash-fastapi-frontend\callbacks\system_c\user_c\user_c.py`
   - `dash-fastapi-frontend\callbacks\router_c.py`
   - `dash-fastapi-frontend\server.py`
   - `dash-fastapi-frontend\auto_login.py`（新建文件）

2. 重启前端服务（**只需重启前端**，后端不动）：
   ```cmd
   taskkill /F /IM python.exe
   cd C:\你的路径\dash-fastapi-admin\dash-fastapi-frontend
   .venv\Scripts\python.exe app.py
   ```

3. 浏览器硬刷一次（Ctrl+Shift+R）清缓存

---

## 三、改动详解（出问题回滚时对照）

### Fix 1：用户管理列表列头消失

**文件**：`dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py`（末尾，约 932 行起）

**根因**：原来的 callback 检查 `operations_data.menuItems`，但代码库**从来没人设置过 menuItems 字段**，判断永远 false → 返回 `[[{operation列 hidden:true}]]`（一个只有 1 列的完整 columns 数组），**覆盖并清空了其他所有列**。任何写 store 的操作（新增/编辑/删除/重置密码/状态切换/导入）都会触发它。

**修复**：改成 server-side callback，根据真实 `PermissionManager.check_perms('system:user:edit/remove/resetPwd')` 判断：
- 有任一权限 → PreventUpdate，**完全不动 columns**
- 无权限 → 只把操作列 `hidden=True`，其他列原样保留

### Fix 2：嵌入式自动登录 `/auto-login`

**新增文件**：`dash-fastapi-frontend/auto_login.py`（126 行）

**改的文件**：`server.py` 末尾加 `import auto_login`（4 行注册）

**新改的 router**：`dash-fastapi-frontend/callbacks/router_c.py`
- output 加 `token=Output('token-container', 'data', allow_duplicate=True)`
- 新增 sync 分支：首次加载且 server session 有 token 但前端 store 为空时，把 server token 同步到前端
- 其他 return 补 `token=no_update` 保持 schema 一致

**用法**：
```
GET /auto-login?username=admin&password=admin123&redirect=/system/user
GET /auto-login?token=<已有token>&redirect=/system/user
```

**安全机制**：
- redirect 必须在白名单前缀内（`/system/`, `/monitor/`, `/tool/`, `/`）→ 防 open redirect
- 拒绝带 scheme/netloc 的 URL（`//evil.com` / `http://x` 都过滤）
- 登录失败重定向到 `/login?error=...`

---

## 四、Windows 部署额外注意

1. **行尾符**：保持 LF（VSCode 右下角点 "CRLF" 切到 "LF"）。
2. **Python 版本**：用 `.venv\Scripts\python.exe`（项目自带虚拟环境）。
3. **后端不用动**：本次只改前端 4 个文件，后端 / 数据库 / .env / CORS 全部不动。
4. **依赖不需要装**：`auto_login.py` 只用了 `flask` / `urllib.parse` / 项目内已有模块（`api.login.LoginApi`, `config.exception.*`, `utils.log_util.logger`），都是已有依赖。

---

## 五、验证步骤

### Fix 1 验证
1. admin / admin123 登录
2. 进 `/system/user`
3. 点"新增" → 填必填项 → 确定
4. 模态框关闭，**用户列表 8 列全在**（用户编号/名称/昵称/部门/手机/状态/创建时间/操作）✅
5. 再编辑一个用户 → 列表依然完整 ✅

### Fix 2 验证（auto-login）
1. 浏览器访问：
   ```
   http://localhost:38039/auto-login?username=admin&password=admin123&redirect=/system/user
   ```
2. 浏览器自动跳转到 `/system/user` 并显示用户管理页面 ✅
3. DevTools → Application → Cookies 能看到 `session` cookie ✅
4. DevTools → Network → `/auto-login` 那条请求：
   - Status: 302
   - Set-Cookie: session=...
   - Location: /system/user

### 边界测试（可选）
- `?redirect=//evil.com` → 跳到 `/system/user`（被白名单过滤，不跳外部）
- `?password=wrongpass` → 跳到 `/login?error=密码错误`
- `?username=nonexist` → 跳到 `/login?error=用户不存在`
- 无参数 → 跳到 `/login?error=缺少参数`

---

## 六、回滚方法

如果出问题要回滚：

```cmd
cd C:\你的路径\dash-fastapi-admin
git checkout HEAD -- dash-fastapi-frontend\callbacks\system_c\user_c\user_c.py
git checkout HEAD -- dash-fastapi-frontend\callbacks\router_c.py
git checkout HEAD -- dash-fastapi-frontend\server.py
del dash-fastapi-frontend\auto_login.py
```

然后重启前端服务。

---

## 七、文件清单

```
dash-fastapi-admin/
├── dash-fastapi-frontend/
│   ├── auto_login.py                        # 【新增】126 行
│   ├── server.py                            # 【改】 末尾 +4 行
│   └── callbacks/
│       ├── router_c.py                      # 【改】 +47 行 / -1 行
│       └── system_c/
│           └── user_c/
│               └── user_c.py                # 【改】 末尾 callback 重写
└── docs/
    ├── 2026-06-26-fixes.patch               # git apply 用
    └── 2026-06-26-fixes-windows.md          # 本文档
```
