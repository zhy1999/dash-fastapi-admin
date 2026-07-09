import feffery_antd_components as fac
import feffery_utils_components as fuc
from dash import dcc, html
from callbacks.layout_c import fold_side_menu  # noqa: F401
from callbacks.layout_c import index_c, productapp_topbar_c  # noqa: F401
from views.layout.components.aside import render_aside_content
from views.layout.components.content import render_main_content
from views.layout.components.head import render_head_content
from views.layout.components.productapp_topbar import render_productapp_topbar


def render(menu_info, current_path="/dashboard", is_auto_login=False):
    return fuc.FefferyTopProgress(
        html.Div(
            [
                # === 2026-06-29 修复 auto-login 时 logo-text 显示问题 ===
                # 把 is_auto_login 状态存到 Store，让 fold_side_menu.py 的 callback
                # 在 auto-login 模式下不修改 logo-text 的 style（保留 display: none）
                dcc.Store(id='is-auto-login-store', data=is_auto_login),
                # 全局重载
                fuc.FefferyReload(id='trigger-reload-output'),
                # 响应式监听组件
                fuc.FefferyResponsive(id='responsive-layout-container'),
                # 布局设置抽屉
                fac.AntdDrawer(
                    [
                        fac.AntdText(
                            '主题颜色',
                            style={'fontSize': 16, 'fontWeight': 500},
                        ),
                        fuc.FefferyHexColorPicker(
                            id='hex-color-picker',
                            color='#1890ff',
                            showAlpha=True,
                            style={'width': '100%', 'marginTop': '10px'},
                        ),
                        fac.AntdInput(
                            id='selected-color-input',
                            value='#1890ff',
                            readOnly=True,
                            style={
                                'marginTop': '15px',
                                'background': '#1890ff',
                            },
                        ),
                        fac.AntdSpace(
                            [
                                fac.AntdButton(
                                    [
                                        fac.AntdIcon(icon='antd-save'),
                                        '保存配置',
                                    ],
                                    id='save-setting',
                                    type='primary',
                                ),
                                fac.AntdButton(
                                    [
                                        fac.AntdIcon(icon='antd-sync'),
                                        '重置配置',
                                    ],
                                    id='reset-setting',
                                ),
                            ],
                            style={'marginTop': '15px'},
                        ),
                    ],
                    id='layout-setting-drawer',
                    visible=False,
                    title='布局设置',
                    width=320,
                ),
                # 退出登录对话框提示
                fac.AntdModal(
                    html.Div(
                        [
                            fac.AntdIcon(
                                icon='fc-info', style={'font-size': '28px'}
                            ),
                            fac.AntdText(
                                '确定注销并退出系统吗？',
                                style={'margin-left': '5px'},
                            ),
                        ]
                    ),
                    id='logout-modal',
                    visible=False,
                    title='提示',
                    renderFooter=True,
                    centered=True,
                ),
                # ProductApp 风格顶栏（横跨整个页面顶部）
                # === 2026-06-29 临时隐藏顶栏，保留代码以备后续恢复 ===
                # fac.AntdRow(
                #     render_productapp_topbar(current_path),
                #     style={
                #         'position': 'sticky',
                #         'top': 0,
                #         'zIndex': 1000,
                #     },
                # ),
                # 平台主页面
                fac.AntdRow(
                    [
                        # 左侧固定菜单区域
                        fac.AntdCol(
                            fac.AntdAffix(
                                html.Div(
                                    render_aside_content(menu_info, is_auto_login=is_auto_login),
                                    id='side-menu',
                                    style={
                                        'height': '100vh',
                                        'overflowX': 'hidden',
                                        'overflowY': 'auto',
                                        'transition': 'width 1s',
                                        'background': '#001529',
                                    },
                                ),
                            ),
                            id='left-side-menu-container',
                            flex='none',
                        ),
                        # 右侧区域
                        fac.AntdCol(
                            [
                                fac.AntdRow(
                                    render_head_content(is_auto_login=is_auto_login),
                                    style={
                                        'height': '50px',
                                        'boxShadow': 'rgb(240 241 242) 0px 2px 14px',
                                        'background': 'white',
                                        'marginBottom': '10px',
                                        'position': 'sticky',
                                        'top': '90px',
                                        'zIndex': 999,
                                    },
                                ),
                                fac.AntdRow(render_main_content(), wrap=False),
                            ],
                            flex='auto',
                            style={'width': 0},
                        ),
                    ],
                ),
            ],
            id='index-main-content-container',
        ),
        listenPropsMode='include',
        includeProps=['tabs-container.items'],
    )
