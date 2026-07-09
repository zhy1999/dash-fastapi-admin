import feffery_antd_components as fac
from dash import dcc, get_asset_url, html
from callbacks.layout_c import aside_c  # noqa: F401
from config.env import AppConfig


def render_aside_content(menu_info, is_auto_login=False):
    """
    渲染左侧菜单区域
    :param is_auto_login: 是否为 auto-login 场景，True 时隐藏 logo 和 title
    """
    if is_auto_login:
        # auto-login 场景：保留 50px 高度的暗色占位
        # === 2026-06-29 修复：仍然渲染 logo-text 节点（display: none 隐藏），
        # 让 fold_side_menu.py 的 callback 不会因为找不到 id 而报错
        header = fac.AntdRow(
            [
                fac.AntdCol(
                    fac.AntdImage(
                        width=32,
                        height=32,
                        src=get_asset_url('imgs/logo.png'),
                        preview=False,
                        style={'display': 'none'},
                    ),
                    style={
                        'height': '100%',
                        'display': 'flex',
                        'alignItems': 'center',
                        'flex': '0 0 auto',
                    },
                ),
                fac.AntdCol(
                    fac.AntdText(
                        AppConfig.app_name,
                        id='logo-text',
                        style={'display': 'none'},
                    ),
                    style={
                        'height': '100%',
                        'display': 'flex',
                        'alignItems': 'center',
                        'marginLeft': '2px',
                        'flex': '0 0 auto',
                    },
                ),
            ],
            style={
                'height': '50px',
                'background': '#001529',
                'position': 'sticky',
                'top': 0,
                'zIndex': 999,
                'paddingLeft': '18px',
            },
        )
    else:
        header = fac.AntdRow(
            [
                fac.AntdCol(
                    fac.AntdImage(
                        width=32,
                        height=32,
                        src=get_asset_url('imgs/logo.png'),
                        preview=False,
                    ),
                    style={
                        'height': '100%',
                        'display': 'flex',
                        'alignItems': 'center',
                        'flex': '0 0 auto',
                    },
                ),
                fac.AntdCol(
                    fac.AntdText(
                        AppConfig.app_name,
                        id='logo-text',
                        style={
                            'fontSize': '22px',
                            'color': 'rgb(255, 255, 255)',
                            'whiteSpace': 'nowrap',
                        },
                    ),
                    style={
                        'height': '100%',
                        'display': 'flex',
                        'alignItems': 'center',
                        'marginLeft': '2px',
                        'flex': '0 0 auto',
                    },
                ),
            ],
            style={
                'height': '50px',
                'background': '#001529',
                'position': 'sticky',
                'top': 0,
                'zIndex': 999,
                'paddingLeft': '18px',
            },
        )

    return [
        dcc.Store(id='current-key_path-store'),
        dcc.Store(id='current-item-store'),
        dcc.Store(id='current-item_path-store'),
        fac.AntdSider(
            [
                header,
                fac.AntdMenu(
                    id='index-side-menu',
                    menuItems=menu_info,
                    mode='inline',
                    theme='dark',
                    defaultSelectedKey='首页',
                    style={'width': '100%', 'height': 'calc(100vh - 50px)'},
                ),
            ],
            id='menu-collapse-sider-custom',
            collapsible=True,
            collapsedWidth=64,
            trigger=None,
            width=256,
        ),
    ]
