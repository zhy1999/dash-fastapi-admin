from dash.dependencies import Input, Output, State
from server import app


# 侧边栏折叠回调
app.clientside_callback(
    """
    (nClicks, collapsed, responsive, isAutoLogin) => {
            if (nClicks) {
                // === 2026-06-29 修复 auto-login 时 logo-text 显示问题 ===
                // auto-login 模式下不修改 logo-text 的 style（aside.py 已渲染为 display:none）
                const logoTextStyle = isAutoLogin
                    ? window.dash_clientside.no_update
                    : (collapsed ? {fontSize: '22px', color: 'rgb(255, 255, 255)'} : {display: 'none'});
                return [
                        collapsed ? {width: 256} : (!responsive?.sm ? {display: 'none'} : {width: 64}),
                        !collapsed,
                        logoTextStyle,
                        collapsed ? 'antd-menu-fold' : 'antd-menu-unfold',
                    ];
            }
            throw window.dash_clientside.PreventUpdate;
    }
    """,
    [
        Output('left-side-menu-container', 'style', allow_duplicate=True),
        Output('menu-collapse-sider-custom', 'collapsed', allow_duplicate=True),
        Output('logo-text', 'style', allow_duplicate=True),
        Output('fold-side-menu-icon', 'icon', allow_duplicate=True),
    ],
    Input('fold-side-menu', 'nClicks'),
    [
        State('menu-collapse-sider-custom', 'collapsed'),
        State('responsive-layout-container', 'responsive'),
        State('is-auto-login-store', 'data'),
    ],
    prevent_initial_call=True,
)


# 页面响应式监听自动折叠侧边栏
app.clientside_callback(
    """
    (responsive, isAutoLogin) => {
        // === 2026-06-29 修复 auto-login 时 logo-text 显示问题 ===
        // auto-login 模式下不修改 logo-text 的 style（aside.py 已渲染为 display:none）
        const logoTextStyle = isAutoLogin ? window.dash_clientside.no_update : null;
        if (!responsive?.sm) {
            return [
                {display: 'none'},
                true,
                logoTextStyle ?? {display: 'none'},
                'antd-menu-unfold',
                {display: 'none'},
                '6',
                'none',
            ];
        } else if (!responsive?.lg) {
            return [
                {width: 64},
                true,
                logoTextStyle ?? {display: 'none'},
                'antd-menu-unfold',
                {display: 'none'},
                '12',
                '12',
            ];
        } else {
            return [
                {width: 256},
                false,
                logoTextStyle ?? {fontSize: '22px', color: 'rgb(255, 255, 255)'},
                'antd-menu-fold',
                {},
                '1',
                '21',
            ];
        }
    }
    """,
    [
        Output('left-side-menu-container', 'style', allow_duplicate=True),
        Output('menu-collapse-sider-custom', 'collapsed', allow_duplicate=True),
        Output('logo-text', 'style', allow_duplicate=True),
        Output('fold-side-menu-icon', 'icon', allow_duplicate=True),
        Output('header-breadcrumb-col', 'style'),
        Output('fold-side-menu-col', 'flex'),
        Output('header-breadcrumb-col', 'flex'),
    ],
    [
        Input('responsive-layout-container', 'responsive'),
        State('is-auto-login-store', 'data'),
    ],
    prevent_initial_call=True,
)
