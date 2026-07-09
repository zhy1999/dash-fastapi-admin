import feffery_antd_components as fac
from dash import html


def render_main_content():
    """右侧主体内容区，tabs 初始为空，登录后由回调动态创建"""
    return [
        fac.AntdCol(
            [
                html.Div(
                    fac.AntdTabs(
                        # 初始为空，由 index_c.py 的回调在登录后/菜单点击时注入
                        items=[],
                        id='tabs-container',
                        type='editable-card',
                        style={
                            'width': '100%',
                            'paddingLeft': '15px',
                            'paddingRight': '15px',
                        },
                    ),
                    style={
                        'width': '100%',
                        'height': '100%',
                        'backgroundColor': 'white',
                    },
                )
            ],
            flex='auto',
        )
    ]
