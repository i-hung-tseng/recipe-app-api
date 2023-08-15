# alpin3 是輕量級 linux 系統，這是一個基本的 images，通常在 dockerfile 一開始，會先指定一個基礎的印象
FROM python:3.9-alpine3.13
LABEL maintainer="i hung tseng"

# for log ，使輸出可以立即的在終端上顯示
ENV PYTHONUNBUFFERED 1 

# 把 local 的 requirement.txt 跟 python 腳本複製到 image 上
COPY ./requirements.txt /tmp/requirements.txt
COPY ./requirements.dev.txt /tmp/requirements.dev.txt
COPY ./app /app
WORKDIR /app
EXPOSE 8000



ARG DEV=false
# 建立一個虛擬 python 環境，並安裝在 /py 下面
RUN python -m venv /py && \
    # 升級虛擬環境的 pip 版本
    /py/bin/pip install --upgrade pip && \
    apk add --update --no-cache postgresql-client && \
    apk add --update --no-cache --virtual .tmp-build-deps \
        build-base postgresql-dev musl-dev && \
    # 安裝 requirements 上的套件
    /py/bin/pip install -r /tmp/requirements.txt && \
    if [ $DEV = "true" ]; \
        then /py/bin/pip install -r /tmp/requirements.dev.txt ; \
    fi && \
    
    # 刪除 tmp 的資料，以節省空間
    rm -rf /tmp && \
    apk del .tmp-build-deps && \
    adduser \
        --disabled-password \
        --no-create-home \
        django-user

ENV PATH="/py/bin:$PATH"

USER django-user
