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

### Check coding rules / コーディング規約にしたがっているかチェック
```docker-compose exec app bundle exec rubocop```

Please execute the following command together with minitest.  
テスト実行とまとめて以下のコマンドで行うことができます。  
```docker-compose exec app ./test.sh```

### Execute minitest / テスト(minitest)実行
```docker-compose exec app bundle exec rails test```
