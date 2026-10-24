from fastapi import FastAPI, Response
import os, socket

app = FastAPI(title="FIAP Store API")
PRONTO = True
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
