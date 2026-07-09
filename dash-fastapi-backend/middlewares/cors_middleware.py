from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware


def add_cors_middleware(app: FastAPI):
    """
    添加跨域中间件

    :param app: FastAPI对象
    :return:
    """
    # 前端页面url
    origins = [
        'http://localhost:8088',
        'http://10.10.30.31:8088',
        'http://10.10.30.31:38039',
        'http://10.208.11.16:38039',
        'http://10.100.1.254:38039',
    ]

    # 后台api允许跨域
    app.add_middleware(
        CORSMiddleware,
        allow_origins=origins,
        allow_credentials=True,
        allow_methods=['*'],
        allow_headers=['*'],
    )
