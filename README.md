# Local im@sparql

ローカル環境で im@sparql のデータを利用するための Docker コンテナ環境です。

## 必要要件

- Docker
- Docker Compose
- Git

## セットアップ

1. このリポジトリをクローンし、サブモジュールを初期化します：

   ```bash
   git clone https://github.com/OHMORIYUSUKE/local-imasparql.git
   cd local-imasparql
   git submodule update --init --recursive
   ```

2. Docker コンテナをビルドして起動します：

   ```bash
   docker compose up -d
   ```

3. ブラウザで以下の URL にアクセスして動作確認ができます：

   - SPARQL エンドポイント: http://localhost:3030/sparql
   - 管理画面: http://localhost:3030/

4. ブラウザで取得できるか試すことができます

   - クエリ実行画面: http://localhost:3030/#/dataset/imasparql/query
   - クエリ例:
     8 月 18 日生まれのメンバーの名前とメンバーカラーを取得

     ```sparql
     PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX schema: <http://schema.org/>
      PREFIX imas: <https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#>

      SELECT (sample(?o) as ?date) (sample(?n) as ?name) (sample(?c) as ?color)
      WHERE {
      ?sub schema:birthDate ?o;
          rdfs:label ?n;
      OPTIONAL {
          ?sub imas:Color ?c.
      }
      FILTER(regex(str(?o), "--08-18"))
      }
      GROUP BY (?n)
      ORDER BY (?name)
     ```

     「矢吹可奈」と「首藤葵」が表示されたら成功です。

## 使用方法

1. SPARQL クエリの実行:

   - ブラウザで SPARQL エンドポイントにアクセスし、クエリを入力して実行できます
   - または、HTTP POST リクエストで直接クエリを実行することも可能です
   - 実行例:
     ```sh
     curl -X POST \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -H "Accept: application/json" \
      --data-urlencode "query=PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
     PREFIX schema: <http://schema.org/>
     PREFIX imas: <https://sparql.crssnky.xyz/imasrdf/URIs/imas-schema.ttl#>
     SELECT (sample(?o) as ?date) (sample(?n) as ?name) (sample(?c) as ?color)
     WHERE {
     ?sub schema:birthDate ?o;
     rdfs:label ?n;
     OPTIONAL {
     ?sub imas:Color ?c.
     }
     FILTER(regex(str(?o), '--08-18'))
     }
     GROUP BY (?n)
     ORDER BY (?name)" \
     http://localhost:3030/imasparql/query
     ```

2. データの更新:
   - `data/` ディレクトリ内の TTL ファイルや RDF ファイルを編集することでデータを更新できます
   - データを更新した場合は、以下のコマンドでコンテナを再起動してください：
   ```bash
   docker compose down
   docker compose up -d --build
   ```

## トラブルシューティング

- コンテナが正常に起動しない場合：

  ```bash
  docker compose logs
  ```

  でログを確認してください

- データが正しく読み込まれない場合：
  1. コンテナを停止: `docker compose down`
  2. ボリュームを削除: `docker compose down -v`
  3. 再度ビルドして起動: `docker compose up -d --build`

## ライセンス

このプロジェクトは [MIT License](LICENSE) の下で公開されています。

## 謝辞

このプロジェクトは [im@sparql](https://sparql.crssnky.xyz/imas/) のデータを使用しています。
