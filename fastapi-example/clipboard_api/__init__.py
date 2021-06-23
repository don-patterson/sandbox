from fastapi import FastAPI
from pydantic import BaseModel


class Clipboard(BaseModel):
    text: str


app = FastAPI()
app.state.clipboard = {"text": ""}


@app.get("/")
def paste():
    return app.state.clipboard


@app.post("/")
def copy(body: Clipboard):
    app.state.clipboard = body.dict()
    return app.state.clipboard
