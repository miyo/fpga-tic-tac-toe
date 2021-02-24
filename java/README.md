# ○×ゲームでFPGA開発をはじめてみよう(Java編)

Synthesijerを使って，Javaで書いた○×ゲームをFPGA上で動かします．

文中の，`$WORK`は，アーカイブを展開したディレクトリ(たとえば`$HOME/work`)を想定します．


## 準備

- https://synthesijer.github.io/web/dl/index.html から新シいリソースをダウンロード

## ビルド

```
cd $WORK/fpga-tic-tac-toe-main/java
cd src
make
cd ..
vivado -mode batch -source ./create_prj.tcl
```

これで，`$WORK/fpga-tic-tac-toe-main/java/prj/top.runs/impl_1/top.bit`ができあがります．

## FPGA上で動かす

[RTL編](../verilog/README.md)同様に実行してください．





