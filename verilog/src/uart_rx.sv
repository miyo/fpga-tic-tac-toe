// UART_RX
// シリアル通信 受信モジュール
// スタートビット(0), 8bitデータ(LSBからMSBの順に), ストップビット(1)の順に受信

`default_nettype none

module uart_rx
  #(
    parameter SYS_CLK = 14000000, // クロック周波数
    parameter RATE = 9600 // 転送レート,単位はbps(ビット毎秒)
    )
    (
     input wire clk,        // クロック
     input wire reset,      // リセット
     input wire din,        // シリアル入力
     output reg rd,        // 受信完了を示す
     output reg [7:0] dout // 受信データ
     );
    
    // 内部変数宣言
    logic [7:0]  cbuf;      // 受信データ系列の一時保存用レジスタ
    logic        receiving; // 受信しているかどうか
    logic [7:0]  cbit;      // カウンタ,データを取り込むタイミングを決定するのに使用
    logic        rx_en;     // 受信用クロック
    logic        rx_en_d;   // 受信用クロック立ち上がり判定用レジスタ
    logic [15:0] rx_div = ((SYS_CLK / RATE) / 16) - 1; // クロック分周の倍率
    
    // クロック分周モジュールのインスタンス生成
    // 受信側は送信側の16倍の速度で値を取り込み処理を行う
    clk_div clk_div_i(.clk(clk), .rst(reset), .div(rx_div), .clk_out(rx_en));
    
    always @(posedge clk) begin
	if (reset == 1) begin // リセット時の動作, 初期値の設定
            receiving <= 0;
            cbit      <= 0;
	    cbuf      <= 0;
            dout      <= 0;
            rd        <= 0;
            rx_en_d   <= 0;
	end else begin
            rx_en_d <= rx_en;
            if (rx_en == 1 && rx_en_d == 0) begin // 受信用クロック立ち上がり時の動作
		if (receiving == 0) begin // 受信中でない場合
		    if (din == 0) begin // スタートビット0を受信したら
			receiving <= 1;
		    end
		    rd <= 0; // 受信完了のフラグをさげる
		end else begin // 受信中の場合
		    case (cbit) // カウンタに合わせてデータをラッチ
			6: begin // スタートビットのチェック
			    if (din == 1) begin // スタートビットが中途半端．入力をキャンセル
				receiving <= 0;
				cbit      <= 0;
			    end else begin
				cbit <= cbit + 1;
			    end
			end
			22,38,54,70,86,102,118,134: begin // data
			    cbit <= cbit + 1;
			    cbuf <= {din, cbuf[7:1]}; // シリアル入力と既に受信したデータを連結
			end
			150: begin // stop
			    rd        <= 1;
			    dout      <= cbuf;
			    receiving <= 0; // 受信完了
			    cbit      <= 0;
			end
			default: begin
			    cbit <= cbit + 1;
			end
		    endcase
		end
            end
	end // else: !if(reset == 1)
    end // always @ (posedge clk)

endmodule // uart_rx

`default_nettype wire
