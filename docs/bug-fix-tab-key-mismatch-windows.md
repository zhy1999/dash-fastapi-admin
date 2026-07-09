# Windows 部署：Tab 重复创建 → 操作列消失 Bug

## 一、本地已验证

manager02 上已修复并验证通过：切 Tab 不再触发重复创建 tab，操作列稳定显示。

## 二、Windows 端需要改的文件

只动前端 `dash-fastapi-frontend/callbacks/layout_c/index_c.py`。

### 方式 A：git apply patch（最稳）

PowerShell 里：

```powershell
# 1. 备份
Copy-Item D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend\callbacks\layout_c\index_c.py D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend\callbacks\layout_c\index_c.py.bak

# 2. 应用 patch（项目根目录）
cd D:\webadmin\PythonServer\dash-fastapi-admin
git apply docs\bug-fix-tab-key-mismatch-current.patch

# 3. 验证 patch 应用成功
git diff --stat dash-fastapi-frontend\callbacks\layout_c\index_c.py
```

如果 `git apply` 报错 "patch does not apply"，说明你的本地文件已经被改过，**不要强推**，改用方式 B 手改。

### 方式 B：手改（patch 应用失败时）

文件 `dash-fastapi-frontend/callbacks/layout_c/index_c.py` 改两处：

#### 改点 1：`handle_tab_switch_and_create` 函数（约第 83-160 行）

把原来的：
```python
        # tab 已存在则只切换
        if currentKey in [item['key'] for item in origin_items]:
            return [dash.no_update, currentKey, breadcrumb_items, currentKeyPath or []]
```

替换为：
```python
        # 统一 tab key：优先 href（pathname），避免 init_first_tab 与这里格式不一致
        menu_href = (currentItem.get('props', {}) or {}).get('href') or ''
        if menu_href and not menu_href.startswith('/'):
            menu_href = '/' + menu_href
        tab_key = menu_href or currentKey

        # lenient 匹配：标准化 key 格式后比较（处理 '/system/user' vs 'system/user' vs 'User/system/user' 等差异）
        def _normalize_key(k):
            if not k:
                return ''
            k = k.lstrip('/')
            parts = k.split('/')
            if parts and parts[0] == 'User' and len(parts) > 1:
                k = '/'.join(parts[1:])
            return k

        def _tab_exists(items, target_key):
            target_norm = _normalize_key(target_key)
            for it in items:
                k = it.get('key', '') or ''
                if k == target_key:
                    return True
                if _normalize_key(k) == target_norm:
                    return True
            return False

        if _tab_exists(origin_items, tab_key):
            return [dash.no_update, tab_key, breadcrumb_items, currentKeyPath or []]
```

然后把下面两处 `'key': currentKey` 改成 `'key': tab_key`，最后一行 `return [new_items, currentKey, ...]` 改成 `return [new_items, tab_key, ...]`。

#### 改点 2：`init_first_tab` 函数（约第 334-360 行）

把原来的：
```python
    currentKey = currentItem.get('props', {}).get('key')
```

替换为：
```python
    # 统一用 href 作为 tab key（与 handle_tab_switch_and_create 一致，避免重复创建）
    menu_href = (currentItem.get('props', {}) or {}).get('href') or ''
    if menu_href and not menu_href.startswith('/'):
        menu_href = '/' + menu_href
    currentKey = menu_href or currentItem.get('props', {}).get('key')
```

## 三、根因（一句话）

`init_first_tab` 用 `props.key` 创建 tab，`handle_tab_switch_and_create` 用 `currentKey`（可能带 `'User/'` 前缀）查找已有 tab —— **两边 key 格式不一致**，匹配永远失败 → 每次切回都 append 一个新 tab → DOM 里同时存在多个 `id='user-list-table'` → React 渲染冲突 → 操作列不显示。

## 四、为什么之前 `user_c.py` 的 clientside callback 没修好

clientside callback 那个 fix **只是症状缓解**（操作列不显示时少触发一次 hide），**没解决 tab 重复创建的根因**。两者一起部署才完整：
- `index_c.py` 修根因（不再重复创建 tab）
- `user_c.py` 修防御（无操作权限时不显示操作列，Tab 切换不会误触发）

## 五、部署步骤

1. 备份（已在方式 A 第 1 步完成）
2. 应用 patch 或手改
3. 清 pycache + 重启前端：

```powershell
Get-ChildItem -Path "D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend" -Filter "__pycache__" -Recurse -Directory | Remove-Item -Recurse -Force
cd D:\webadmin\PythonServer\dash-fastapi-admin\dash-fastapi-frontend
python app.py
```

4. 浏览器**无痕窗口**（Ctrl+Shift+N）登录 admin 测试

## 六、验证

- 进用户管理 → 切到部门管理 → 切回用户管理
- 操作列还在 → ✅
- 切到别的菜单 → 操作列只在用户管理 tab 显示 → ✅
- 打开 DevTools，搜索 `id="user-list-table"`，整个页面应该只有 1 个匹配（之前 bug 时会有多个）

## 七、注意

- **行尾 LF**（VSCode 右下角点 CRLF 切 LF）
- **后端不用动**，**数据库不用动**
- 部署完成后如果之前已经放过 `user_c.py` 的 patch（clientside callback 那个），两个 fix 一起生效
