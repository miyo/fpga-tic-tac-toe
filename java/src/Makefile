SYNTHESIJER=${HOME}/tools/synthesijer_20191116

all: IO.java RS232C_RX_Wrapper.java RS232C_TX_Wrapper.java TicTacToe.java rs232c.java 
	${SYNTHESIJER} --chaining --bb2 $^

clean:
	-rm -f *.ir
	-rm -f *.dot
	-rm -f *.tmp_info
	-rm -f *.v
	-rm -f *.vhd
	-rm -f *.class
