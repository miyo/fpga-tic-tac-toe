# ○×ゲームでFPGA開発をはじめてみよう

○×ゲームの開発を題材にFPGA開発の一通りの流れを体験しましょう。お仕着せのプロジェクトのビルドからはじめて、いくつかの機能拡張を通してFPGAデザインをする感覚に慣れてもらうのが目的です。

## 想定環境

- Digilent Arty
- Vivado 2020.2

ACRiの開発環境を使って試せます

## 事前準備

ACRiの環境を使って作業することを想定しています。ACRiの環境を利用できるように以下の事前準備をお願いします。

1. [ACRi登録ページ](https://gw.acri.c.titech.ac.jp/wp/registration)にアクセスしてアカウント登録をしてください。アカウント作成には１週間程度かかります。
1. [ACRiルームにログインしよう](https://www.youtube.com/watch?v=TKKqUrbmVr4)と[ACRi ルームの FPGA 利用環境の予約・使用方法](https://gw.acri.c.titech.ac.jp/wp/manual/how-to-reserve)をご覧いただき、サーバーにログインできることを確認しておいてください。
1. <推奨> [ACRiルームでArtyを使ってみよう](https://www.youtube.com/watch?v=PcvWGNl7ZGY)と[サーバで Vivado と Vitis (または SDK) を使用する](https://gw.acri.c.titech.ac.jp/wp/manual/vivado-vitis)をご覧いただきツールの基本的な動作を確認してみてください（ここから、当日取り組んでいただいても構いません）。

## FPGA開発の一通りの流れを体験

FPGAを動かすまでの一通りの手順を体験しましょう。

- 開発ツールの立ち上げ
- 開発ツールの使い方
- 動作確認

## 動作中の様子をみてみよう

- ILAとVIOで中身を見てみる

## 機能拡張をしてみよう

- 3マスx3マスを5マスx5マスに拡張してみる
- 3マスx3マスを19マスx19マスに拡張してみる(BlockRAMを使う)

## VivadoHLSを使ってCで実装してみよう

## MicroBlazeを使ってソフトウェアで実装してみよう

## もっといろいろやってみよう

- モンテカルロなプレーヤを実装してみる
- ディープラーニングっぽい実装にしてみる
- 自分でプロセッサ(RISC-Vとか)つくって動かしてみる

など
