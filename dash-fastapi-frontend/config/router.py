class RouterConfig:
    """
    路由配置

    WHITE_ROUTES_LIST: 白名单路由列表
    CONSTANT_ROUTES: 公共路由列表
    """

    WHITE_ROUTES_LIST = [
        {
            'path': '/login',
            'component': 'login',
        },
        {
            'path': '/forget',
            'component': 'forget',
        },
        {
            'path': '/register',
            'component': 'register',
        },
    ]

    CONSTANT_ROUTES = [
        {
            'path': '/login',
            'component': 'login',
            'name': 'Login',
            'hidden': True,
        },
        {
            'path': '/forget',
            'component': 'forget',
            'name': 'Forget',
            'hidden': True,
        },
        {
            'path': 'user',
            'component': 'Layout',
            'hidden': True,
            'name': 'UserProfile',
            'redirect': 'noredirect',
            'meta': {
                'title': '系统设置',
                'icon': 'antd-trophy',
            },
            'children': [
                {
                    'path': 'profile',
                    'component': 'system.user.profile',
                    'name': 'Profile',
                    'meta': {
                        'title': '个人资料',
                        'icon': 'antd-idcard',
                    },
                }
            ],
        },
    ]
