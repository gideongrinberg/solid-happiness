FROM python:3.12-alpine

COPY . /app
WORKDIR /app

RUN apk add --no-cache bash curl coreutils parallel aria2 && \
    python -m pip install -r ./requirements.txt && \
    chmod +x ./_entrypoint.sh

RUN wget https://github.com/duckdb/duckdb/releases/download/v1.2.0/duckdb_cli-linux-amd64.zip \
    && unzip duckdb_cli-linux-amd64.zip -d /usr/local/bin \
    && rm duckdb_cli-linux-amd64.zip

ENTRYPOINT [ "./_entrypoint.sh" ]