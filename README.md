# char-line-bot / おチャーbot

<img src="https://github.com/Yuchan4342/char-line-bot/blob/master/public/image/logo.png" width="300">

## Desctiption / おチャー bot とは?
LINE bot replying message + "チャー".  
You can append favorite string by 「文字列切替」 menu below.  

このLINE botはあなたのメッセージの後ろに"チャー"をつけて返します。
トーク画面下の「文字列切替」メニューから後ろにつける文字に好きな文字を設定できます。

## Site(Japanese) / 紹介サイト
https://linebot.o-char.com

## Use Image / イメージ
<img src="https://github.com/Yuchan4342/char-line-bot/blob/master/app/assets/images/o-char2.0.png" width="320">

## How to start with docker / Docker での起動方法
If you haven't installed Docker and Docker Compose, please install them.  
Docker, Docker Compose をインストールしていない場合は下記よりインストールしてください。

* [Docker Desktop for Windows](https://hub.docker.com/editions/community/docker-ce-desktop-windows)
* [Docker Desktop for Mac](https://hub.docker.com/editions/community/docker-ce-desktop-mac)
* [Install Docker Compose](https://docs.docker.com/compose/install/)

### Build an Docker image / Docker image をビルド
```docker-compose build```

### Create containers and start them / Docker コンテナの作成＆起動
```docker-compose up```

### Stop containers / コンテナの停止
```docker-compose stop```

### Remove containers / コンテナの削除
Data on database are not removed.  
データベースのデータは永続化されているため, 削除されません。  
```docker-compose rm```

### Stop and remove containers / コンテナの停止＆削除
```docker-compose down```

### Create database / データベースの作成
Execute only in the first start.  
初回起動時にのみ行います。  
```docker-compose exec app bundle exec rails db:create```

### Migrate database / データベースのマイグレーション
```docker-compose exec app bundle exec rails db:migrate```

## For Developers / 開発者向け
### Check coding style and minitest / コーディング規約・テスト(minitest)
Please execute the following commands while the containers are running.  
以下のコマンドは Docker コンテナが起動している状態で実行してください。  

Execute the following command to check coding style and test together.  
コーディング規約チェックとテスト実行をまとめて以下のコマンドで行うことができます。  
```docker-compose exec app ./test.sh```

Execute the following command to check coding style.
コーディング規約をチェックするには以下のコマンドを実行します。  
```docker-compose exec app bundle exec rubocop```

Execute the following command to take minitest.  
テスト(minitest)を実行するには以下のコマンドを実行します。  
```docker-compose exec app bundle exec rails test```

### Update gems / Gem のアップデート
First, execute the following command.  
まず、以下のコマンドを実行します。  
```bundle update```

Then, build an Docker image and start.  
Please check coding rules by rubocop and execute minitest.  
その後、Docker image をビルドして起動します。  
rubocop でのコーディング規約チェックとテスト実行も行ってください。
