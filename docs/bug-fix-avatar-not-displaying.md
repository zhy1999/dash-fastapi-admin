# Bug 修复记录：头部头像不显示

## 基本信息

| 项目 | 值 |
|------|-----|
| 日期 | 2026-06-12 |
| 文件 | `dash-fastapi-frontend/views/layout/components/head.py` |
|      | `dash-fastapi-frontend/views/dashboard/components/page_top.py` |

---

## 问题描述

### 现象
- 页面头部右侧的头像显示为空（空白）
- 浏览器开发者工具中看到 `<span class="ant-avatar-string"></span>` 内容为空

### 根因分析
原始代码：
```python
src=f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
if CacheManager.get('user_info').get('avatar')
else '/assets/imgs/profile.jpg'
```

问题在于：
1. `CacheManager.get('user_info')` 在登录信息未初始化时返回 `None`
2. 直接在三元表达式中调用 `.get('avatar')`，当 `user_info` 为 `None` 时会触发 `AttributeError`
3. Python 三元表达式中的错误会被静默处理，导致 `src` 最终为空或异常
4. `ApiConfig.BaseUrl` 配置为 `http://127.0.0.1:9099`（旧配置），即使拼接也连不上正确后端

---

## 修改内容

### head.py

**修改前：**
```python
fac.AntdAvatar(
    id='avatar-info',
    mode='image',
    src=f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
    if CacheManager.get('user_info').get('avatar')
    else '/assets/imgs/profile.jpg',
    size=36,
),
```

**修改后：**
```python
fac.AntdAvatar(
    id='avatar-info',
    mode='image',
    src=(
        f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
        if CacheManager.get('user_info') and CacheManager.get('user_info').get('avatar')
        else '/assets/imgs/profile.jpg'
    ),
    size=36,
),
```

### page_top.py（仪表盘页面头像）

**修改前：**
```python
fac.AntdAvatar(
    id='dashboard-avatar-info',
    mode='image',
    src=f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
    if CacheManager.get('user_info').get('avatar')
    else '/assets/imgs/profile.jpg',
    size='large',
),
```

**修改后：**
```python
fac.AntdAvatar(
    id='dashboard-avatar-info',
    mode='image',
    src=(
        f"{ApiConfig.BaseUrl}{CacheManager.get('user_info').get('avatar')}"
        if CacheManager.get('user_info') and CacheManager.get('user_info').get('avatar')
        else '/assets/imgs/profile.jpg'
    ),
    size='large',
),
```

---

## 关键变化

| | 修改前 | 修改后 |
|---|---|---|
| 判断条件 | `if CacheManager.get('user_info').get('avatar')` | `if CacheManager.get('user_info') and CacheManager.get('user_info').get('avatar')` |
| None 安全 | 无，先调用 `.get()` 再判断 | 先判断 `user_info` 存在，再取 `avatar` |
| 默认头像 | 当 avatar 为空时使用 `/assets/imgs/profile.jpg` | 相同 |

---

## 验证方法

1. 登录系统，头部右侧头像应正常显示（默认 `/assets/imgs/profile.jpg`）
2. 刷新页面，头像仍然正常显示
3. 进入仪表盘，仪表盘页面的头像也应正常显示
