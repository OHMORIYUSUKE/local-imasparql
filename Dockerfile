FROM eclipse-temurin:11-jre

# FusekiとJenaのバージョンを指定
ENV FUSEKI_VERSION=4.10.0
ENV JENA_VERSION=4.10.0
ENV FUSEKI_HOME=/opt/fuseki
ENV JENA_HOME=/opt/jena
ENV FUSEKI_BASE=/fuseki

# 必要なツールをインストール
RUN apt-get update && \
    apt-get install -y wget && \
    rm -rf /var/lib/apt/lists/*

# Apache Jenaをダウンロードして展開
RUN wget -q https://archive.apache.org/dist/jena/binaries/apache-jena-${JENA_VERSION}.tar.gz && \
    tar xzf apache-jena-${JENA_VERSION}.tar.gz && \
    mv apache-jena-${JENA_VERSION} ${JENA_HOME} && \
    rm apache-jena-${JENA_VERSION}.tar.gz

# Fusekiをダウンロードして展開
RUN wget -q https://archive.apache.org/dist/jena/binaries/apache-jena-fuseki-${FUSEKI_VERSION}.tar.gz && \
    tar xzf apache-jena-fuseki-${FUSEKI_VERSION}.tar.gz && \
    mv apache-jena-fuseki-${FUSEKI_VERSION} ${FUSEKI_HOME} && \
    rm apache-jena-fuseki-${FUSEKI_VERSION}.tar.gz

# 作業ディレクトリを作成
RUN mkdir -p ${FUSEKI_BASE}/databases/imasdb
RUN mkdir -p ${FUSEKI_BASE}/data

# 設定ファイルをコピー
COPY shiro.ini ${FUSEKI_BASE}/shiro.ini
COPY config.ttl ${FUSEKI_BASE}/config.ttl

# PATHを設定
ENV PATH="${JENA_HOME}/bin:${PATH}"

# データディレクトリをコピー
COPY ./data/imasparql /fuseki/data/imasparql

# 起動スクリプトをコピーして実行権限を付与
COPY convert.sh /convert.sh
RUN chmod +x /convert.sh

# データを変換
RUN sh /convert.sh

EXPOSE 3030

# Fusekiサーバーを起動
CMD ["/opt/fuseki/fuseki-server", "--update", "--loc=/fuseki/databases/imasdb", "/imasparql"]