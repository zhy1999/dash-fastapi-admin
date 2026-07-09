import feffery_antd_components as fac
from dash import html
from callbacks.layout_c import head_c  # noqa: F401
from config.env import AppConfig
from utils.cache_util import CacheManager


def render_head_content(is_auto_login=False):
    cols = [
        # 页首左侧折叠按钮区域
        fac.AntdCol(
            html.Div(
                fac.AntdButton(
                    fac.AntdIcon(
                        id='fold-side-menu-icon', icon='antd-menu-fold'
                    ),
                    id='fold-side-menu',
                    type='text',
                    shape='circle',
                    size='large',
                    style={'marginLeft': '5px', 'background': 'white'},
                ),
                style={
                    'height': '100%',
                    'display': 'flex',
                    'alignItems': 'center',
                },
            ),
            id='fold-side-menu-col',
            flex='1',
        ),
        # 页首面包屑区域
        fac.AntdCol(
            fac.AntdBreadcrumb(
                items=[

                ],
                id='header-breadcrumb',
                style={
                    'height': '100%',
                    'display': 'flex',
                    'alignItems': 'center',
                },
            ),
            id='header-breadcrumb-col',
            flex='21',
        ),
    ]

    # auto-login 场景：隐藏用户头像与用户名下拉菜单（嵌入式场景不需要这些导航操作）
    if not is_auto_login:
        cols.append(
            fac.AntdCol(
                fac.AntdSpace(
                    [
                        fac.AntdAvatar(
                            id='avatar-info',
                            mode='image',
                            src=(
                                f'{AppConfig.app_base_url}{CacheManager.get("user_info").get("avatar")}'
                                if CacheManager.get('user_info') and CacheManager.get('user_info').get('avatar')
                                else '/assets/imgs/profile.jpg'
                            ),
                            size=36,
                        ),
                        fac.AntdDropdown(
                            id='index-header-dropdown',
                            title=CacheManager.get('user_info').get('user_name'),
                            arrow=True,
                            menuItems=[
                                {
                                    'title': '个人资料',
                                    'key': '个人资料',
                                    'icon': 'antd-idcard',
                                },
                                {
                                    'title': '布局设置',
                                    'key': '布局设置',
                                    'icon': 'antd-layout',
                                },
                                {'isDivider': True},
                                {
                                    'title': '退出登录',
                                    'key': '退出登录',
                                    'icon': 'antd-logout',
                                },
                            ],
                            placement='bottomRight',
                        ),
                    ],
                    style={
                        'height': '100%',
                        'float': 'right',
                        'display': 'flex',
                        'alignItems': 'center',
                    },
                ),
                flex='3',
            ),
        )

    # 全局刷新按钮（始终保留；auto-login 时让它靠右）
    cols.append(
        fac.AntdCol(
            html.Div(
                fac.AntdTooltip(
                    fac.AntdButton(
                        fac.AntdIcon(
                            id='index-reload-icon', icon='fc-synchronize'
                        ),
                        id='index-reload',
                        type='text',
                        shape='circle',
                        size='large',
                        style={
                            'backgroundColor': 'rgb(255 255 255 / 0%)',
                        },
                    ),
                    title='刷新',
                    placement='bottom',
                )
            ),
            style={
                'height': '100%',
                'paddingRight': '3px',
                'display': 'flex',
                'alignItems': 'center',
                'marginLeft': 'auto' if is_auto_login else None,
            },
            flex='1',
        ),
    )

    return cols
