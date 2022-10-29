# KoNLPy tokenizer
## Usage
- `docker build -t konlpy-image .`
  - build docker image.
- `docker run -it -p 8080:8000 konlpy-image`
  - run docker container from `konlpy-image`.
- Reference `127.0.0.1:8080/docs` swagger UI.
- Request to `127.0.0.1:8080/tokenize` (Post)