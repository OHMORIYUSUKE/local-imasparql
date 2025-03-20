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

# shiro.iniファイルを作成して認証を無効化
RUN echo "[main]" > ${FUSEKI_BASE}/shiro.ini && \
    echo "ssl.enabled = false" >> ${FUSEKI_BASE}/shiro.ini && \
    echo "[urls]" >> ${FUSEKI_BASE}/shiro.ini && \
    echo "/** = anon" >> ${FUSEKI_BASE}/shiro.ini

# PATHを設定
ENV PATH="${JENA_HOME}/bin:${PATH}"

# 設定ファイルを作成
RUN echo '@prefix fuseki:  <http://jena.apache.org/fuseki#> .' > ${FUSEKI_BASE}/config.ttl && \
    echo '@prefix rdf:     <http://www.w3.org/1999/02/22-rdf-syntax-ns#> .' >> ${FUSEKI_BASE}/config.ttl && \
    echo '@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .' >> ${FUSEKI_BASE}/config.ttl && \
    echo '@prefix tdb2:    <http://jena.apache.org/2016/tdb#> .' >> ${FUSEKI_BASE}/config.ttl && \
    echo '@prefix ja:      <http://jena.hpl.hp.com/2005/11/Assembler#> .' >> ${FUSEKI_BASE}/config.ttl && \
    echo '' >> ${FUSEKI_BASE}/config.ttl && \
    echo '[] rdf:type fuseki:Server ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '   fuseki:services (' >> ${FUSEKI_BASE}/config.ttl && \
    echo '     [] rdf:type fuseki:Service ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:name                     "imasparql" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:serviceQuery             "query" , "sparql" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:serviceUpdate            "update" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:serviceReadWriteGraphStore "data" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:serviceReadGraphStore    "get" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        fuseki:dataset [' >> ${FUSEKI_BASE}/config.ttl && \
    echo '            rdf:type tdb2:DatasetTDB2 ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '            tdb2:location "/fuseki/databases/imasdb" ;' >> ${FUSEKI_BASE}/config.ttl && \
    echo '        ]' >> ${FUSEKI_BASE}/config.ttl && \
    echo '   ) .' >> ${FUSEKI_BASE}/config.ttl

EXPOSE 3030

# 起動スクリプトをコピーして実行権限を付与
COPY start.sh /start.sh
RUN chmod +x /start.sh

CMD ["/start.sh"]