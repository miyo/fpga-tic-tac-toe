// UART_TX
// シリアル通信送信モジュール
// スタートビット(0), 8bitデータ(LSBからMSBの順に), ストップビット(1)の順に送信

`default_nettype none

module uart_tx
  #(parameter SYS_CLK = 14000000, // クロック周波数
    parameter RATE = 9600 // 転送レート,単位はbps(ビット毎秒)
    )
    (
     input wire clk,   // クロック
     input wire reset, // リセット
     input wire wr,    // 送信要求
     input wire [7:0] din, // 送信データ
     output reg dout, // シリアル出力
     output wire ready // 送信要求を受け付けることができるかどうか
     );

    // 内部変数定義
    logic [7:0] in_din; // 送信データ一時保存用レジスタ
    logic [7:0] cbuf; // 一時的にしようするバッファ
    logic load; // 送信データを読み込んだかどうか
    logic [2:0] cbit; // 何ビット目を送信しているか

    logic run; // 送信状態にあるかどうか

    logic tx_en; // 送信用クロック
    logic tx_en_d; // 送信用クロックの立ち上がり検出用
  
    logic [15:0] tx_div = (SYS_CLK / RATE) - 1; // クロック分周の倍率

    logic [1:0] status; // 状態遷移用レジスタ (not recommended)

    // クロック分周モジュールの呼び出し
    clk_div clk_div_i(.clk(clk), .rst(reset), .div(tx_div), .clk_out(tx_en));
    // readyへの代入, 常時値を更新している
    assign ready = (wr == 0 && run == 0 && load == 0) ? 1 : 0;

    always @(posedge clk) begin // クロックの立ち上がり時の動作
	if(reset == 1) begin // リセット時の動作, 初期値の設定
          load <= 0;
	end else begin
            if(wr == 1 && run == 0) begin // 送信要求があり，かつ送信中でない場合
		load <= 1;      // データを取り込んだことを示すフラグを立てる
		in_din <= din;  // 一時保存用レジスタに値を格納
            end
            if(load == 1 && run == 1) begin // 送信中で，かつデータを取り込んだ
		                            // ことを示すフラグが立っている場合
		load <= 0;                  // データを取り込んだことを示すフラグを下げる
            end
	end
    end

    always @(posedge clk) begin
	if (reset == 1) begin // リセット時の動作, 初期値の設定
            dout <= 1;
            cbit <= 0;
            status <= 0;
            run <= 0;
            tx_en_d <= 0;
	end else begin
            tx_en_d <= tx_en;
            if (tx_en == 1 && tx_en_d == 0) begin // tx_enの立ち上がりで動作
		case(status) // statusの値に応じて動作が異なる
		    0: begin // 初期状態
			cbit <= 0; // カウンタをクリア
			if(load == 1) begin // データを取り込んでいる場合
			    dout <= 0; // スタートビット0を出力
			    status <= status + 1; //次の状態へ
			    cbuf <= in_din; // 送信データを一時バッファに退避
			    run <= 1; // 送信中の状態へ遷移
			end else begin // なにもしない状態へ遷移
			    dout <= 1;
			    run  <= 0; // 送信要求受付可能状態へ
			end
		    end
		    1: begin // データをLSBから順番に送信
			cbit <= cbit + 1; // カウンタをインクリメント
			dout <= cbuf[0];  // 一時バッファから0bit目を抽出し出力する
			cbuf <= {1'b1,cbuf[7:1]}; // 次の送信データを0bit目にセットする
			if(cbit == 7) begin // データの8ビット目を送信したら,
                                            // ストップビットを送る状態へ遷移
			    status <= status + 1;
			end
		    end
		    2: begin // ストップビットを送信
			dout <= 1; // ストップビット1
			status <= 0; // 初期状態へ
		    end
		    default: // その他の状態の場合
		      status <= 0; // 初期状態へ遷移
		endcase // case (status)
	    end
	end
    end // always @ (posedge clk)

endmodule // uart_tx

`default_nettype wire
