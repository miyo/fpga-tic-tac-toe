--
--  RS232C_RX
--  シリアル通信 受信モジュール
--  スタートビット(0), 8bitデータ(LSBからMSBの順に), ストップビット(1)の順に受信

-- おまじない(ライブラリ呼び出し)
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity rs232c_rx is
  -- 定数宣言
  generic(
    sys_clk : integer := 14000000; --クロック周波数
    rate : integer := 9600         --転送レート,単位はbps(ビット毎秒)
    );
  -- 入出力ポート宣言
  port(
    clk  : in  std_logic; -- クロック
    reset  : in  std_logic; -- リセット
    din  : in  std_logic; -- シリアル入力
    rd   : out std_logic; -- 受信完了を示す
    dout : out std_logic_vector( 7 downto 0 ) -- 受信データ
    );
end rs232c_rx;

architecture rtl of rs232c_rx is
  --クロック分周モジュールのインスタンス生成の準備
  component clk_div is
    port(
      clk     : in  std_logic;
      rst     : in  std_logic;
      div     : in  std_logic_vector(15 downto 0);
      clk_out : out std_logic
      );
  end component;
  --内部変数宣言
  signal buf    : std_logic_vector(7 downto 0) := (others => '0');   --受信データ系列の一時保存用レジスタ
  signal start  : std_logic := '0';               --受信しているかどうか
  signal cbit   : integer range 0 to 150 := 0;    --カウンタ,データを取り込むタイミングを決定するのに使用
  signal rx_en  : std_logic;                      --受信用クロック
  signal rx_div : std_logic_vector(15 downto 0);  --クロック分周の倍率

  signal din_d, din_dd : std_logic;

begin
  --クロック分周モジュールのインスタンス生成
  ----受信側は送信側の16倍の速度で値を取り込み処理を行う
  --rx_div <= conv_std_logic_vector(((sys_clk / rate) / 16) - 1, 16);
  --受信側は送信側の4倍の速度で値を取り込み処理を行う
  rx_div <= conv_std_logic_vector(((sys_clk / rate) / 4) - 1, 16);
  U0: clk_div port map (clk, reset, rx_div, rx_en);

  process(clk)
  begin
    if rising_edge(clk) then
      din_d <= din;
      din_dd <= din_d;
    end if;
  end process;

  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then              --リセット時の動作, 初期値の設定
        start <= '0';
        cbit  <= 0;
        buf   <= (others => '0');
        dout  <= (others => '0');
        rd    <= '0';
      elsif rx_en = '1' then             --受信用フラグ立ち上がり時の動作
        if(start = '0') then          --受信中でない場合
          rd <= '0';                  --受信完了のフラグをさげる
          if(din_dd = '0') then       --スタートビット0を受信したら
            start <= '1';
          end if;
        else                          --受信中の場合
          case cbit is                --カウンタに合わせてデータをラッチ
            --when 6 =>                 --start
            when 2 =>                 --start
              if(din_dd = '1') then
                start <= '0';
              else
                cbit <= cbit + 1;
              end if;
            when 6 | 10 | 14 | 18 | 22 | 26 | 30 | 34 =>  --data
              cbit <= cbit + 1;
              buf  <= din_dd & buf(7 downto 1);  -- シリアル入力と既に受信したデータを連結
            when 38 =>               --stop
              cbit  <= 0;
              dout  <= buf;
              start <= '0';
              rd    <= '1';
            when others =>
              cbit <= cbit + 1;
          end case;
        end if;
      end if;
    end if;
  end process;

end RTL;
