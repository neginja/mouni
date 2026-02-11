# Mouni Backend

## Development

### Tools installation

1. to re-generate API code you'll need to install Java and the openapi generator

    ```console
    pip install openapi-generator-cli==7.14.0
    ```

2. to serve the API locally, you'll need to first install a web-server utility `uvicorn`

    ```console
    pip install uvicorn==0.35.0
    ```

### Generation

Although generated code is versioned, if you make updates to the `swagger.yaml` spec you might want to regenerate the api server code.

I decided top use a spec first approach however when generating a server with `FastApi` backend FastApi generates again the `OpenApi` spec to serve as a doc. It's a bit of weird flex but ok.

> [!NOTE]
> Make sure to have installed the tools as instructed above

```shell
make generate
```

if you removed models and added new ones, you might need to clean generated code first

```shell
make clean && make generate
```

### Dependencies installation

```shell
make install
```

OR

```shell
pip install -r requirements.txt
```

### Serve API

```shell
make serve
```

API doc should be accessible from `localhost:8080/docs`

### VS code launch with debugger

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

You can use a tiny debug CLI to quickly test endpoints (we don't write tests because lol)

```shell
pip install -r requirements_dev.txt
```

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
