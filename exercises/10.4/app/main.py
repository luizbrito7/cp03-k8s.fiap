import json, time, uuid

from fastapi import FastAPI, Request, Response
from prometheus_client import make_asgi_app
import os, socket

app = FastAPI(title="FIAP Store API")
PRONTO = True
VERSAO = os.getenv("APP_VERSION", "1.0")
app.mount("/metrics", make_asgi_app())


@app.middleware("http")
async def log_json(request: Request, call_next):
    # um log JSON por requisicao, com request_id (reaproveita o do cliente, se vier)
    rid = request.headers.get("x-request-id") or uuid.uuid4().hex
    inicio = time.perf_counter()
    response = await call_next(request)
    response.headers["x-request-id"] = rid
    print(json.dumps({"request_id": rid, "metodo": request.method, "rota": request.url.path,
                      "status": response.status_code,
                      "ms": round((time.perf_counter() - inicio) * 1000, 1)}), flush=True)
    return response


@app.get("/health")
def health():
    return {"status": "ok", "host": socket.gethostname()}


@app.get("/ready")
def ready(response: Response):
    if not PRONTO:
        response.status_code = 503
        return {"status": "starting"}
    return {"status": "ready"}


@app.get("/produtos")
def produtos():
    return [{"id": 1, "nome": "Teclado", "preco": 199.9}]


@app.get("/info")
def info():
    return {"versao": VERSAO,
            "env": os.getenv("APP_ENV", "dev"),
            "db_host": os.getenv("DB_HOST", "nao-configurado"),
            "pod": socket.gethostname()}


@app.get("/versao")
def versao():
    return {"versao": VERSAO}


@app.get("/pesado")
def pesado():
    total = 0
    for i in range(3_000_000):
        total += i * i
    return {"resultado": total, "pod": socket.gethostname()}
