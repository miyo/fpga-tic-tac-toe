# ○×ゲームでFPGA開発をはじめてみよう

○×ゲームの開発を題材にFPGA開発の一通りの流れを体験しましょう。お仕着せのプロジェクトのビルドからはじめて、いくつかの機能拡張を通してFPGAデザインをする感覚に慣れてもらうのが目的です。

## 想定環境

- Digilent Arty
- Vivado 2020.2

ACRiの開発環境で試せる範囲で楽しめるように準備しています。もちろん、手元に同じ環境がある場合は手元で楽しんでいたくこともできます。

## 事前準備

ACRiの環境を使って作業することを想定しています。ACRiの環境を利用できるように以下の事前準備をお願いします。

1. [ACRi登録ページ](https://gw.acri.c.titech.ac.jp/wp/registration)にアクセスしてアカウント登録をしてください。アカウント作成には１週間程度かかります。
1. [ACRiルームにログインしよう](https://www.youtube.com/watch?v=TKKqUrbmVr4)と[ACRi ルームの FPGA 利用環境の予約・使用方法](https://gw.acri.c.titech.ac.jp/wp/manual/how-to-reserve)をご覧いただき、サーバーにログインできることを確認しておいてください。
1. <推奨> [ACRiルームでArtyを使ってみよう](https://www.youtube.com/watch?v=PcvWGNl7ZGY)と[サーバで Vivado と Vitis (または SDK) を使用する](https://gw.acri.c.titech.ac.jp/wp/manual/vivado-vitis)をご覧いただきツールの基本的な動作を確認してみてください（ここから、当日取り組んでいただいても構いません）。

## 準備

ACRiルームで作業する場合は，次のように作業するとよいでしょう．

1. ACRiルームの利用予約をする(https://gw.acri.c.titech.ac.jp/ にログインし，vsXXXの利用予約をする)．
2. vsXXXにログインして作業ディレクトリを作る．ここでは `$HOME/work` で作業します．
3. 自分のPCにプロジェクトのアーカイブをダウンロードする https://github.com/miyo/fpga-tic-tac-toe/archive/main.zip
4. `scp`やTeraTermの機能を使ってACRiルームに main.zip を転送する
5. vsXXXの作業ディレクトリの下で main.zip を解凍する

## FPGA開発の一通りの流れを体験

FPGAを動かすまでの一通りの手順を体験しましょう。詳細は[こちら](./verilog/README.md)．

- Vivadoの起動
- プロジェクトの作成
- ソースコードの追加
- シミュレーション
- ビルド
- 遊んでみる
- ILAで内部を見てみる

## VitisHLSを使ってCで実装してみよう

手を決める部分をVitisHLSで実装してみましょう．詳細は[こちら](./hls/README.md)．

- VitisHLSの起動
- プロジェクトの作成
- コードの追加
- シミュレーションと合成
- IPパッケージの作成
- Vivadoのプロジェクトの作成
- IPリポジトリの追加とIPのインスタンス生成
- コードの追加
- ビルドと実行

## MicroBlazeを使ってソフトウェアで実装してみよう

ソフトプロセッサを使ってソフトウェアで実装してみましょう．詳細は[こちら](./c/README.md)．

- Vitisの起動
- プロジェクトの作成
- ソースコードの修正
- ビルド
- 実行

## 機能拡張をしてみよう

- 3マスx3マスを5マスx5マスに拡張してみる
- 3目続きではなく5目続きを作るゲームに修正する

## もっと機能拡張してみよう

- モンテカルロなプレーヤを実装してみる
- ディープラーニングっぽい実装にしてみる
- 自分でプロセッサ(RISC-Vとか)つくって動かしてみる
