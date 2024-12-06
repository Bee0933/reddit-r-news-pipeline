FROM python:3.9-slim-buster

WORKDIR /app
RUN apt-get update \
      && apt-get install -y --no-install-recommends \
      --no-install-suggests build-essential \
      && pip install --no-cache-dir --upgrade pip

RUN pip install --no-cache-dir -i https://pypi.cloud.soda.io soda-snowflake

COPY . /app

EXPOSE 8003

CMD ["python", "src/main.py"]