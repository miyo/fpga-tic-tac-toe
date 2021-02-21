
int make_turn(int board_a, int board_b, int turn_a)
{
#pragma HLS INTERFACE ap_vld register port=board_a
#pragma HLS INTERFACE ap_vld register port=board_b
#pragma HLS INTERFACE ap_vld register port=turn_a

	int board = board_a | board_b;
	int id = 0;
	for(; id < 9; id++){
		if((board & 0x00000001) == 0){
			break;
		}
		board >>= 1;
	}
	int ret_board;
	if(turn_a == 1){
		ret_board = board_a | (1 << id);
	}else{
		ret_board = board_b | (1 << id);
	}
	return ret_board;
}
