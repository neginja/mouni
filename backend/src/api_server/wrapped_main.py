# import handler to register them as subclasses of the base implementation (hook in implementations)
import os

from fastapi import Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from api_server.impl.errors import register_error_handlers
from api_server.impl.handlers import (
    activity_handler,  # noqa
    expense_handler,  # noqa
    group_handler,  # noqa
    member_handler,  # noqa
    settlement_handler,  # noqa
)
from api_server.impl.middlewares.auth import (
    COOKIE_MAX_AGE,
    COOKIE_NAME,
    PASSWORD,
    PasswordMiddleware,
    serializer,
)
from api_server.impl.utils import setup_uvicorn_logger
from api_server.main import app as gen_app

app = gen_app

logger = setup_uvicorn_logger()
register_error_handlers(app)

origins = os.getenv("CORS_ORIGINS", "").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],  # allow GET, POST, PUT, DELETE, OPTIONS
    allow_headers=["*"],  # allow headers like Content-Type
)

if PASSWORD != "NO_AUTH":
    app.add_middleware(PasswordMiddleware)

SCHEME = os.getenv("SCHEME", "http")


@app.post("/login", tags="auth", description="Authenticate through single password")
async def login(password: str = Form(...)) -> JSONResponse:
    if password != PASSWORD:
        return JSONResponse({"detail": "Invalid password"}, status_code=401)

    token = serializer.dumps(password)
    response = JSONResponse({"detail": "Login successful"})
    response.set_cookie(
        key=COOKIE_NAME,
        value=token,
        max_age=COOKIE_MAX_AGE,
        httponly=True,  # inaccessible to JS
        secure=True if SCHEME.lower() == "https" else False,
        samesite="lax",
    )
    return response
