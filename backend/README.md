# Mouni Backend

## Development

### Tools installation

to run this project you'll need `uv` and `make` (optional but referenced in this README)

- [uv](https://docs.astral.sh/uv/)
- [make](https://www.gnu.org/software/make/)

### Dependencies installation

```shell
make install
```

OR

```shell
uv sync --group dev
```

### Generation

Although generated code is versioned, if you make updates to the `swagger.yaml` spec you might want to regenerate the api server code.

I decided to use a spec first approach however when generating a server with `FastApi` backend FastApi generates again the `OpenApi` spec to serve as a doc. It's a bit of  chicken and egg problem but ok.

> [!NOTE]
> Make sure to run `make install` first

```shell
make generate
```

if you removed models and added new ones, you might need to clean generated code first

```shell
make clean && make generate
```

### Serve API

```shell
make serve
```

API doc should be accessible from `localhost:8080/docs`

### VS codium launch with debugger

Launch file entry

```javascript
{
    "name": "API",
    "type": "debugpy",
    "request": "launch",
    "module": "uvicorn",
    "args": [
        "src.api_server.wrapped_main:app",
        "--reload",
        "--reload-dir",
        "src/api_server",
        "--host",
        "0.0.0.0",
        "--port",
        "8080"
    ],
    "cwd": "${workspaceFolder}/backend",
    "env": {
        "CORS_ORIGINS": "*", // allow all origin for CORS otherwise use comma separated values
        "PASSWORD": "NO_AUTH", // means no auth middleware, replace with a value to debug auth
        "DB_PATH": "data/mouni.db",
        "PYTHONPATH": "${workspaceFolder}/backend/src"
    }
}
```

### Debug CLI

You can use a tiny debug CLI to quickly test endpoints (we don't write tests because ain't no body got time for that)

Seed

```shell
make seed
```

Update

```shell
make update
```

Delete

```shell
make clear
```
