"""
ProductApp 顶栏 active 状态控制 + 退出/全屏按钮回调
"""
from dash import no_update
from dash.dependencies import Input, Output
from dash.exceptions import PreventUpdate
from server import app
from views.layout.components.productapp_topbar import PRODUCTAPP_MENU


# ===== 1. active 状态切换 =====
@app.callback(
    [Output(f"productapp-nav-{it['key']}", 'className') for it in PRODUCTAPP_MENU],
    Input('current-pathname-container', 'data'),
    prevent_initial_call=True,
)
def update_productapp_nav_active(pathname):
    """根据 pathname 给对应菜单项加 active class"""
    if not pathname:
        raise PreventUpdate
    results = []
    for it in PRODUCTAPP_MENU:
        base = "productapp-nav-item"
        if it["path"] == pathname:
            base += " active"
        results.append(base)
    return results


# ===== 2. 退出按钮：复用现有 logout-modal =====
# 用 clientside_callback 而非 server-side callback（和 head_c.py 一致），
# 避免 allow_duplicate=True 导致 output 带 hash 的坑。
app.clientside_callback(
    """
    (nClicks) => {
        if (nClicks) {
            return true;
        }
        return window.dash_clientside.no_update;
    }
    """,
    Output('logout-modal', 'visible', allow_duplicate=True),
    Input('productapp-signout-btn', 'nClicks'),
    prevent_initial_call=True,
)