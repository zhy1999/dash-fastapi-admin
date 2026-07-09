# Windows 部署补充说明：用户管理 Tab 切换操作列消失 Bug

## 一、本地已验证

bug 在 manager02（10.208.11.16）上修复并验证通过：admin 登录 → 切 Tab → 操作列稳定显示。

## 二、Windows 端需要改的文件

只动前端 `dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py`，把文件末尾（约 932-967 行）原来的服务端 callback 换成 clientside callback。

### 修改前（替换这个块）

```python
@app.callback(
    [
        Output('user-list-table', 'columns', allow_duplicate=True),
    ],
    [
        Input('user-operations-store', 'data'),
        Input('url-container', 'pathname'),     # ← 这行是 bug 根因
    ],
    [
        State('user-operations-store', 'data'),
        State('url-container', 'pathname'),
    ],
    prevent_initial_call=True,
)
def update_operation_column_visibility(operations_data, pathname, operations_state, pathname_state):
    """
    动态控制操作列的显示/隐藏
    当 operations 为空时隐藏操作列
    有操作权限时不更新（保持原状）
    """
    if operations_data and operations_data.get('menuItems'):
        raise PreventUpdate
    return [[
        {
            'title': '操作',
            'dataIndex': 'operation',
            'fixed': 'right',
            'width': 120,
            'hidden': True,
        }
    ]]
```

### 修改后

```python
# 动态控制操作列的显示/隐藏（无操作权限时隐藏）
# 使用 clientside callback，只在 user-operations-store 数据变化时触发，避免 Tab 切换时误触发
app.clientside_callback(
    """
    (operations_data) => {
        if (operations_data && operations_data.menuItems) {
            throw window.dash_clientside.PreventUpdate;
        }
        return [[{
            title: '操作',
            dataIndex: 'operation',
            fixed: 'right',
            width: 120,
            hidden: true,
        }]];
    }
    """,
    Output('user-list-table', 'columns', allow_duplicate=True),
    Input('user-operations-store', 'data'),
    prevent_initial_call=True,
)
```

## 三、根因一句话

原来的 callback 监听了 `url-container` 的 pathname，**Tab 切换 pathname 必变** → callback 必触发 → 但 `operations_data.get('menuItems')` 永远不命中 → 直接 `return [[{'hidden': True}]]` → 操作列被强制隐藏。

改成 clientside callback + 只监听 `user-operations-store`，就只在权限数据真变化时才判断。

## 四、Windows 部署额外注意

1. **行尾符**：文件改完保持 LF（不要让记事本/老版本编辑器改成 CRLF，Python 能跑但 git diff 会很难看）。VSCode 右下角点 "CRLF" 切到 "LF"。
2. **不用动数据库 SQL** — 这个 bug 是前端逻辑问题，跟后端权限数据无关。之前给 admin 加 `system:user:%` 权限那条 SQL 不用再执行（除非你的 admin 角色真没那个权限）。
3. **不用改 .env** / CORS — 那个是 manager02 跨网段访问才需要的，Windows 本机 `localhost:38038` ← `localhost:38039` 直接通。
4. **改完直接重启前端服务**（后端不用动）：
   ```cmd
   taskkill /F /IM python.exe
   cd C:\dash-fastapi-admin\dash-fastapi-frontend
   python app.py
   ```

## 五、验证步骤

1. admin / admin123 登录
2. 进用户管理 → 操作列正常显示
3. 切到部门管理 → 再切回用户管理
4. 操作列仍在 → ✅ 修复成功

如果用 test / test123（无操作权限）账号，操作列全程不显示才对，且切 Tab 不能闪烁。
