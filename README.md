# トリコミ - リモートワーカー向けスケジュール共有サービス

https://www.torikomi.net

[![ogp.jpeg](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/adfcdaf2-03d1-9222-5f7c-3040e23bf76e.jpeg)](https://www.torikomi.net)

## サービス概要

LINE通知×Googleカレンダー連携で便利！　リモートワーカー向けスケジュール共有サービス「トリコミ」です。ファミリーにもカップルにも。自分用のリマインダーとしても使えます。

“オンラインミーティングがあるから、この時間は静かにしてね”
“夜はオンラインセミナーに参加するから、食事は先に食べてるね”

リモート勤務が当たり前になったこの時代、ちょっとしたスケジュールを、一緒に暮らす家族やパートナーと共有しておきたい、そんな思いはありませんか？

そこで開発されたのがこの「トリコミ」です。
Googleカレンダーと連携して、家族やパートナーのLINEにスケジュールを自動で通知してくれます。

[以前のREADME](/old/README.md)

## 主な機能

### Googleカレンダーからスケジュールを自動登録

![qiita用 (1).png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/8a69eb09-4dbb-4dc0-c912-9d4a5d2904b1.png)

アプリ上で手動でスケジュールを登録するか、Googleカレンダーと連携してスケジュールを登録します。Googleカレンダーと連携すると、毎日0時に自動でアプリがGoogleカレンダーからスケジュールを取得します。

![qiita用.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/99c6b5e1-1dee-8630-434d-3c34cafa3190.png)

さらに、スケジュールごとに、LINE通知するかどうかを選ぶことができます（デフォルトは送信予約状態）。

### LINEユーザー登録

![qiita用_3.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/11d1767b-3b88-cbd6-5395-52aeb8ec1bf7.png)


通知を送りたいLINEユーザーを何人でも登録できます。専用のURLを、通知を送りたいLINEユーザーに送り、LINEユーザーがそのURLからLINEログインすれば登録完了です。

### 通知メッセージのカスタマイズ

![qiita用_4.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/ac47c8ea-a904-7966-431e-c39b36278cb3.png)

スケジュール開始時間の何分前に通知を送るか、オリジナルのメッセージを含めるか、など通知メッセージのカスタマイズができます。

### スケジュールをLINEユーザーに自動通知

![qiita用_5.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/cceda292-229e-97ba-b3c0-363acb704d8e.png)

送信予約状態になっているスケジュールの開始時刻が近づくと、アプリが自動でLINEユーザーに通知メッセージを送信します。

## 使用技術

### バックエンド

- Ruby on Rails

### フロントエンド

- Vue.js
- TailwindCSS
- daisyUI

### 外部API

- Google Cloud APIs
- LINEログイン API
- LINE Messaging API

### インフラ・その他

- Sidekiq
- Redis
- Heroku

## ER図

![torikomi_er_1018.drawio.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/2730434/d8beac27-f60e-482f-3112-3e0d513f6633.png)

## 関連記事

- [【個人開発】地味に便利!? リモートワーカー向けスケジュール共有サービスを開発しました【LINE×Googleカレンダー】](https://qiita.com/yoiyoicho/items/21cbc56b7d7c1be92524)