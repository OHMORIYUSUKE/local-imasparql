#!/bin/bash

# データベースディレクトリが空の場合のみデータをロード
if [ -z "$(ls -A /fuseki/databases/imasdb)" ]; then
    echo "Loading initial data..."
    cd /opt/jena/bin
    
    # データベースディレクトリをクリア
    rm -rf /fuseki/databases/imasdb/*
    
    # スキーマをロード（もしTTL形式で存在する場合）
    if [ -f "/fuseki/data/imasparql/URIs/imas-schema.ttl" ]; then
        echo "Loading schema file..."
        ./tdb2.tdbloader --loc=/fuseki/databases/imasdb /fuseki/data/imasparql/URIs/imas-schema.ttl
    fi
    
    # RDFファイルをTurtleに変換してロード
    find /fuseki/data/imasparql/RDFs -name "*.rdf" | while read file; do
        echo "Converting and loading: $file"
        # RDFファイルをTurtleに変換
        ./riot --output=Turtle "$file" > "${file%.rdf}.ttl"
        # 変換したTurtleファイルをロード
        ./tdb2.tdbloader --loc=/fuseki/databases/imasdb "${file%.rdf}.ttl"
        # 一時的なTTLファイルを削除
        rm "${file%.rdf}.ttl"
    done
    
    # ロードされたデータの数を確認
    echo "Checking loaded data count..."
    ./tdb2.tdbquery --loc=/fuseki/databases/imasdb 'SELECT (count(*) as ?total) WHERE { ?s ?p ?o }'
fi

# サーバーを起動
echo "Starting Fuseki server..."

# Fusekiサーバーを起動
exec /opt/fuseki/fuseki-server --update --loc=/fuseki/databases/imasdb /imasparql