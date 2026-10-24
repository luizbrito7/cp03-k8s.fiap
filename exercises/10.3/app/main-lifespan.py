from contextlib import asynccontextmanager

from fastapi import FastAPI, Response
import os, socket

PRONTO = True


@asynccontextmanager
async def lifespan(app):
    yield
    # shutdown (e): /ready passa a responder 503
    global PRONTO
    PRONTO = False
    print("lifespan shutdown: PRONTO=False", flush=True)


app = FastAPI(title="FIAP Store API", lifespan=lifespan)
VERSAO = os.getenv("APP_VERSION", "1.0")


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
