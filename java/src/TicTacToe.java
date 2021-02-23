
public class TicTacToe{

	private IO io = new IO();

	private int make_turn(int rows, int cols, int board_a, int board_b, boolean turn_a){
        int board = board_a | board_b;
        int id = 0;
        for(id = 0; id < 9; id++){
			if((board & 0x01) == 0) break;
			board = board >> 1;
        }
        if(turn_a){
			return board_a | (1 << id);
        }else{
			return board_b | (1 << id);
        }
	}

	private int recv_turn_prim(int num){
        byte c;
        do{
			io.putchar((byte) '?');
			c = io.getchar();
        }while(c < '0' || ('0'+num) < c);
        return (int)(c - '0');
	}
	
	private int recv_turn_id(int rows, int cols){
        int col = recv_turn_prim(cols);
        int row = recv_turn_prim(rows);
        return row * cols + col;
	}

	private int recv_turn(int rows, int cols, int board_a, int board_b, boolean turn_a){
        int id = 0;
        while(true){
			id = recv_turn_id(rows, cols);
			io.putchar((byte) '\r');
			io.putchar((byte) '\n');
			if(((board_a | board_b) & (1 << id)) == 0){
				break;
			}
        }
        if(turn_a){
			return board_a | (1 << id);
        }else{
			return board_b | (1 << id);
        }
	}

	private boolean is_win_3(int board){
		if((((board>>0)&0x01) & ((board>>1)&0x01) & ((board>>2)&0x01)) == 1) return true;
		if((((board>>3)&0x01) & ((board>>4)&0x01) & ((board>>5)&0x01)) == 1) return true;
		if((((board>>6)&0x01) & ((board>>7)&0x01) & ((board>>8)&0x01)) == 1) return true;
		
		if((((board>>0)&0x01) & ((board>>3)&0x01) & ((board>>6)&0x01)) == 1) return true;
		if((((board>>1)&0x01) & ((board>>4)&0x01) & ((board>>7)&0x01)) == 1) return true;
		if((((board>>2)&0x01) & ((board>>5)&0x01) & ((board>>8)&0x01)) == 1) return true;
		
		if((((board>>0)&0x01) & ((board>>4)&0x01) & ((board>>8)&0x01)) == 1) return true;
		if((((board>>2)&0x01) & ((board>>4)&0x01) & ((board>>6)&0x01)) == 1) return true;
		
        return false;
	}

	private boolean is_full_3(int board_a, int board_b){
        int board = board_a | board_b;
        if((board & 0x01FF) == 0x01FF){
			return true;
        }else{
			return false;
        }
	}

	/**
	 * @return 0: not end of game
	 * @return 1: end of game, no winner
	 * @return 2: end of game, 1 player win
	 * @return 3: end of game, 2 player win
	 */
	private int make_judge_3x3(int board_a, int board_b){
        if(is_win_3(board_a)){
			return 2;
        }
        if(is_win_3(board_b)){
			return 3;
        }
        if(is_full_3(board_a, board_b)){
			return 1;
        }
        return 0;
	}

	private void print_board(int rows, int cols, int board_a, int board_b){
		for(int i = 0; i < 2*rows+1; i++){
			for(int j = 0; j < 2*cols+1; j++){
                if((i & 0x01) == 0){ // border
					if((j & 0x01) == 0){
						io.putchar((byte) '+');
					}else{
						io.putchar((byte) '-');
					}
                }else{
					if((j & 0x01) == 0){
						io.putchar((byte) '|');
					}else{
						if((board_a & 0x01) == 1){
							io.putchar((byte) 'o');
						}else if((board_b & 0x01) == 1){
							io.putchar((byte) 'x');
						}else{
							io.putchar((byte) ' ');
						}
						board_a = board_a >> 1;
						board_b = board_b >> 1;
					}
                }
			}
			io.putchar((byte) '\r');
			io.putchar((byte) '\n');
		}
	}

	private void print_game_end_mesg(){
		io.putchar((byte) 'G');
		io.putchar((byte) 'a');
		io.putchar((byte) 'm');
		io.putchar((byte) 'e');
		io.putchar((byte) ' ');
		io.putchar((byte) 'E');
		io.putchar((byte) 'n');
		io.putchar((byte) 'd');
		io.putchar((byte) ':');
		io.putchar((byte) ' ');
	}
	private void print_draw(){
		io.putchar((byte) 'D');
		io.putchar((byte) 'r');
		io.putchar((byte) 'a');
		io.putchar((byte) 'w');
		io.putchar((byte) '\r');
		io.putchar((byte) '\n');
	}
	private void print_player_win(){
		io.putchar((byte) ' ');
		io.putchar((byte) 'P');
		io.putchar((byte) 'l');
		io.putchar((byte) 'a');
		io.putchar((byte) 'y');
		io.putchar((byte) 'e');
		io.putchar((byte) 'r');
		io.putchar((byte) ' ');
		io.putchar((byte) 'W');		
		io.putchar((byte) 'i');
		io.putchar((byte) 'n');
		io.putchar((byte) '\r');
		io.putchar((byte) '\n');
	}

	public void game_manager(){
        int board_a = 0;
        int board_b = 0;
        int win_a = 0;
        int win_b = 0;
		int ret = 0;
        while(true){
			print_board(3, 3, board_a, board_b);
			ret = make_judge_3x3(board_a, board_b);
			if(ret > 0){
				break;
			}
			board_a = make_turn(3, 3, board_a, board_b, true); // turn_a
			print_board(3, 3, board_a, board_b);
			ret = make_judge_3x3(board_a, board_b);
			if(ret > 0){
				break;
			}
			board_b = recv_turn(3, 3, board_a, board_b, false); // not turn_a
        }
		print_game_end_mesg();
        if(ret == 1){
			print_draw();
		}else{
			if(ret == 2){
				io.putchar((byte) '1');
			}else{
				io.putchar((byte) '2');
			}
			print_player_win();
        }
	}
	
}
