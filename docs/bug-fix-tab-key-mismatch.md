# Bug 修复：Tab 重复创建导致操作列渲染异常

## 问题

部署环境下，切换到其他 Tab 再切回用户管理，**操作列消失**。
本地环境不复现（仅在部署机器出现）。

## 根因

`handle_tab_switch_and_create` 和 `init_first_tab` 用了**不一致**的 tab key：

| 路径 | key 来源 | 示例 |
|------|---------|------|
| `init_first_tab`（首次创建）| `currentItem.get('props', {}).get('key')` | 可能是 None 或 pathname |
| `handle_tab_switch_and_create`（菜单点击）| `currentKey`（来自 aside_c.py）| `'User/system/user'` |

由于 key 不匹配，匹配检查 `if currentKey in [...]` 永远为 False，**每次切回都 append 一个新 tab**。

结果：DOM 里同时存在多个 `id='user-list-table'` 的 table 实例，React 渲染冲突，**操作列渲染失败**。

## 修复

两处都改为**统一使用 `currentItem.props.href`（pathname 格式）作为 tab key**：

- `init_first_tab`：用 `href` 作 key
- `handle_tab_switch_and_create`：用 `href` 作 key + 增加 lenient 兜底匹配（key 不一致时也能识别已有 tab）

## 应用 patch

在部署机器的 `dash-fastapi-frontend` 目录下：

```powershell
# 备份
Copy-Item callbacks\layout_c\index_c.py callbacks\layout_c\index_c.py.bak

# 应用 patch（PowerShell）
# 把 docs/bug-fix-tab-key-mismatch.patch 的内容贴到 Git 中手动应用：
# 或者用 git apply（如果项目用 git 管理）
git apply docs/bug-fix-tab-key-mismatch.patch
```

应用后**重启服务 + 浏览器硬刷新**。

## 验证

切回用户管理 Tab，操作列应该正常显示。
