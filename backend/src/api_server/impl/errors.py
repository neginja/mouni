import traceback

from sqlite3 import DatabaseError, IntegrityError, OperationalError, ProgrammingError

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from api_server.impl.utils import logger_from_env

logger = logger_from_env("ErrorHandler")


class NotFoundError(Exception):
    """Raised when a resource is not found in the repository."""


class ForbiddenError(Exception):
    """Raised when attempting to perform an action that is not authorized."""


class ValidationError(Exception):
    """Raised when request payload or arguments are invalid."""


def register_error_handlers(app: FastAPI) -> None:
    @app.exception_handler(NotFoundError)
    async def not_found_handler(request: Request, exc: NotFoundError) -> JSONResponse:
        logger.warning(f"NotFoundError at {request.url}: {exc}")
        return JSONResponse(status_code=404, content={"detail": str(exc)})

    @app.exception_handler(ForbiddenError)
    async def forbidden_handler(request: Request, exc: ForbiddenError) -> JSONResponse:
        logger.warning(f"ForbiddenError at {request.url}: {exc}")
        return JSONResponse(status_code=403, content={"detail": str(exc)})

    @app.exception_handler(ValidationError)
    async def validation_handler(
        request: Request, exc: ValidationError
    ) -> JSONResponse:
        logger.info(f"ValidationError at {request.url}: {exc}")
        return JSONResponse(status_code=422, content={"detail": str(exc)})

    @app.exception_handler(DatabaseError)
    async def sqlite_handler(request: Request, exc: DatabaseError) -> JSONResponse:
        logger.error(
            f"DatabaseError at {request.method} {request.url}:\n{traceback.format_exc()}"
        )

        detail = "A database error occurred"
        status_code = 500

        if isinstance(exc, IntegrityError):
            msg = str(exc).lower()
            if "foreign key" in msg:
                detail = "Other resources depend on this"
                status_code = 400
            elif "unique" in msg:
                detail = "Resource already exists"
                status_code = 409
            elif "not null" in msg:
                detail = "Missing required field"
                status_code = 400
            else:
                detail = "Integrity constraint violation"
                status_code = 400

        elif isinstance(exc, ProgrammingError):
            detail = "Invalid database query"
            status_code = 400

        elif isinstance(exc, OperationalError):
            msg = str(exc).lower()
            if "locked" in msg or "busy" in msg:
                detail = "Database temporarily unavailable, please retry"
                status_code = 503
            else:
                detail = "Database operational error"
                status_code = 500

        return JSONResponse(status_code=status_code, content={"detail": detail})

    @app.exception_handler(Exception)
    async def unhandled_exception_handler(
        request: Request, exc: Exception
    ) -> JSONResponse:
        logger.error(
            f"Unhandled exception at {request.method} {request.url}:\n"
            f"{traceback.format_exc()}"
        )

        return JSONResponse(
            status_code=500,
            content={"detail": "Internal Server Error"},
        )
