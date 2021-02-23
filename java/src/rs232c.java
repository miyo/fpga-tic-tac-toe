public class rs232c{
        RS232C_TX_Wrapper tx = new RS232C_TX_Wrapper("sys_clk", "100000000", "rate", "115200");
        RS232C_RX_Wrapper rx = new RS232C_RX_Wrapper("sys_clk", "100000000", "rate", "115200");

        public byte read(){
                while(rx.rd != false) ;
                while(rx.rd != true) ;
                return rx.dout;
        }
        
        public void write(byte data){
                while(tx.ready == false) ;
                tx.din = data;
                tx.wr = true;
                tx.wr = false;
        }
}
