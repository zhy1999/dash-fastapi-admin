"""
ProductApp 风格顶栏
参考原 ProductApp/UI_MngFrame/index.html 头部结构
位置：在 dash-fastapi-admin 现有 head 行上方
"""
from dash import dcc, get_asset_url, html
from utils.cache_util import CacheManager


# 菜单配置（路径占位，用户后续调整）
PRODUCTAPP_MENU = [
    # 左菜单
    {"key": "dashboard", "label": "数据展板", "path": "/dashboard", "location": "left"},
    {"key": "warning",   "label": "预警列表", "path": "/warning",   "location": "left"},
    # 右菜单
    {"key": "profile",   "label": "人员档案", "path": "/person_profile", "location": "right"},
    # 系统管理 → 新窗口打开 dash-fastapi-admin/login（按原 ProductApp 行为）
    {
        "key": "system_mng",
        "label": "系统管理",
        "path": "/system/user",
        "location": "right",
        "external": False,  # 暂时同窗口；如需新窗口改 True
    },
]


def _nav_item(item, current_path):
    """单个菜单项"""
    active_class = "active" if item["path"] == current_path else ""
    cls = f"productapp-nav-item {active_class}".strip()
    inner = html.Span(item["label"])

    if item.get("external"):
        # 外链/新窗口打开（如原 ProductApp 的"系统管理"）
        return html.A(
            id=f"productapp-nav-{item['key']}",
            className=cls,
            href=item["path"],
            target="_blank",
            children=inner,
        )
    return dcc.Link(
        id=f"productapp-nav-{item['key']}",
        className=cls,
        href=item["path"],
        children=inner,
    )


def render_productapp_topbar(current_path="/dashboard"):
    """
    渲染 ProductApp 风格顶栏
    :param current_path: 当前 pathname，用于高亮 active 项
    """
    user_name = "Guest"
    try:
        user_info = CacheManager.get('user_info')
        if user_info:
            user_name = user_info.get('user_name') or user_info.get('nick_name') or 'Guest'
    except Exception:
        pass

    left_menus = [
        _nav_item(it, current_path)
        for it in PRODUCTAPP_MENU if it["location"] == "left"
    ]
    right_menus = [
        _nav_item(it, current_path)
        for it in PRODUCTAPP_MENU if it["location"] == "right"
    ]

    return html.Div(
        className="productapp-header",
        children=[
            # ===== 左 nav：logo + 您好 + 用户名 =====
            html.Div(
                className="productapp-left-nav",
                children=[
                    html.Img(
                        src=get_asset_url('imgs/logo.png'),
                        className="logo-img",
                    ),
                    html.Span(
                        f"您好，{user_name}",
                        className="login-txt",
                    ),
                ],
            ),

            # ===== 中 nav：左菜单 + 标题 + 右菜单 =====
            html.Div(
                className="productapp-center-nav",
                children=[
                    html.Div(className="left-menus", children=left_menus),
                    html.H4(
                        className="productapp-header-title",
                        children=html.Span(
                            "转龙湾煤矿心理安全监测系统",
                            className="productapp-header-title-text",
                        ),
                    ),
                    html.Div(className="right-menus", children=right_menus),
                ],
            ),

            # ===== 右 nav：全屏 + 退出 =====
            html.Div(
                className="productapp-right-nav",
                children=[
                    # 全屏按钮
                    html.I(
                        id="productapp-fullscreen-btn",
                        title="全屏",
                        className="productapp-icon-btn",
                        children=html.Img(
                            src=get_asset_url('imgs/title-icon-fulllScreen.png'),
                            alt="全屏",
                            className="productapp-icon-img",
                        ),
                    ),
                    # 退出按钮（图标 + 文字）
                    html.Button(
                        id="productapp-signout-btn",
                        className="signout-btn",
                        n_clicks=0,
                        children=[
                            html.Img(
                                src=get_asset_url('imgs/title-icon-exit.png'),
                                alt="退出",
                                className="productapp-icon-img",
                            ),
                            html.Span("退出登录"),
                        ],
                    ),
                ],
            ),
        ],
        id="productapp-topbar-container",
    )
