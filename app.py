from fastapi import FastAPI
from konlpy.tag import Okt
from dto import *

app = FastAPI()


@app.post("/tokenize")
async def tokenize(sentence: Sentence):
    okt = Okt()
    return okt.morphs(sentence.sentence)
