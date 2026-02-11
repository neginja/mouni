import os
import random
import string

from fastapi import Request
from fastapi.responses import JSONResponse
from itsdangerous import BadSignature, URLSafeTimedSerializer
from starlette.middleware.base import BaseHTTPMiddleware

# default is hard to guess (in case)
PASSWORD = os.getenv("PASSWORD", "".join(random.choices(string.ascii_letters, k=24)))

COOKIE_NAME = "bipboopboopbap"
COOKIE_MAX_AGE = 14 * 24 * 60 * 60  # 2 weeks in seconds

serializer = URLSafeTimedSerializer(secret_key=PASSWORD)


class PasswordMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        # Skip /login route
        if request.url.path == "/login":
            return await call_next(request)

        token = request.cookies.get(COOKIE_NAME)
        if not token:
            return JSONResponse({"detail": "Unauthorized"}, status_code=401)

        try:
            password = serializer.loads(token, max_age=14 * 24 * 3600)
        except BadSignature:
            return JSONResponse({"detail": "Unauthorized"}, status_code=401)

        if password != PASSWORD:
            return JSONResponse({"detail": "Unauthorized"}, status_code=401)

        return await call_next(request)
