# Bug 修复记录：用户管理 Tab 切换后操作列消失

## 基本信息

| 项目 | 值 |
|------|-----|
| 日期 | 2026-06-12 |
| 文件 | `dash-fastapi-frontend/callbacks/system_c/user_c/user_c.py` |
| 备份 | `callbacks/system_c/user_c/user_c.py.bak4` |

---

## 问题描述

### 现象
- 用户管理 Tab 刷新页面后正常显示
- 切换到其他 Tab（如部门管理），再切回用户管理后，操作列消失

### 根因分析
`update_operation_column_visibility` 回调监听了两类 Input：

1. `user-operations-store` 的 data 变化
2. `url-container` 的 pathname 变化（每次 Tab 切换都会变化）

回调逻辑：
```python
if operations_data and operations_data.get('menuItems'):
    raise PreventUpdate  # 有权限，不隐藏
return [[{'hidden': True}]]  # 其他情况，隐藏操作列
```

问题在于 `operations_data.get('menuItems')` 从不命中（menuItems 是其他 store 的属性，不在 user-operations-store 中）。因此：
- Tab 切换 → pathname 变化 → 回调触发
- `operations_data` 为空 → 直接执行 `return [[{'hidden': True}]]` → 操作列消失

---

## 修改内容

### 修改前

```python
@app.callback(
    [
        Output('user-list-table', 'columns', allow_duplicate=True),
    ],
    [
        Input('user-operations-store', 'data'),
        Input('url-container', 'pathname'),   # ← 问题：Tab 切换触发
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
    # 有操作权限，不更新
    if operations_data and operations_data.get('menuItems'):
        raise PreventUpdate
    # 无操作权限，隐藏操作列
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
        // 如果 store 有数据且包含 menuItems，说明有操作权限，不隐藏
        if (operations_data && operations_data.menuItems) {
            throw window.dash_clientside.PreventUpdate;
        }
        // 无操作权限，隐藏操作列
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
    Input('user-operations-store', 'data'),   # ← 只监听 store 变化
    prevent_initial_call=True,
)
```

---

## 关键变化

| | 修改前 | 修改后 |
|---|---|---|
| 回调类型 | `@app.callback`（服务端） | `app.clientside_callback`（客户端） |
| 触发条件 | pathname 变化 + store 变化 | 仅 store 变化 |
| 问题 | Tab 切换 pathname 必触发，误判隐藏 | 只在权限数据真实变化时触发 |

---

## 验证方法

1. 用 `test` 账号登录（无操作权限）
2. 进入用户管理 Tab，确认操作列不显示
3. 切换到其他 Tab
4. 切回用户管理，确认操作列仍然不显示（不再闪烁消失）
5. 用 `admin` 账号登录，确认操作列正常显示
