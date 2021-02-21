
#include <stdio.h>
#include <stdlib.h>
#include "platform.h"
#include "xil_printf.h"

int make_turn(int rows, int cols, int board_a, int board_b, int turn_a){
	int board = board_a | board_b;
	int id = 0;
	for(; id < 9; id++){
		if((board & 0x00000001) == 0) break;
		board >>= 1;
	}
	if(turn_a){
		return board_a | (1 << id);
	}else{
		return board_b | (1 << id);
	}
}

int recv_turn(int rows, int cols, int board_a, int board_b, int turn_a){
	int c;
	int col, row;
	do{
		print("?");
		setvbuf(stdin, NULL, _IONBF, 0);
		c = getchar();
	}while(c < 0x30 || (0x30+cols) < c);
	col = c - 0x30;
	do{
		print("?");
		setvbuf(stdin, NULL, _IONBF, 0);
		c = getchar();
	}while(c < 0x30 || (0x30+rows) < c);
	row = c - 0x30;
	int id = row*cols + col;
	if(turn_a){
		return board_a | (1 << id);
	}else{
		return board_b | (1 << id);
	}
}

int is_win_3(int board){
#define BIT0(x) ((board >> 0) & 0x00000001)
#define BIT1(x) ((board >> 1) & 0x00000001)
#define BIT2(x) ((board >> 2) & 0x00000001)
#define BIT3(x) ((board >> 3) & 0x00000001)
#define BIT4(x) ((board >> 4) & 0x00000001)
#define BIT5(x) ((board >> 5) & 0x00000001)
#define BIT6(x) ((board >> 6) & 0x00000001)
#define BIT7(x) ((board >> 7) & 0x00000001)
#define BIT8(x) ((board >> 8) & 0x00000001)
	if(BIT0(board) && BIT1(board) && BIT2(board)) return 1;
	if(BIT3(board) && BIT4(board) && BIT5(board)) return 1;
	if(BIT6(board) && BIT7(board) && BIT8(board)) return 1;
	if(BIT0(board) && BIT3(board) && BIT6(board)) return 1;
	if(BIT1(board) && BIT4(board) && BIT7(board)) return 1;
	if(BIT2(board) && BIT5(board) && BIT8(board)) return 1;
	if(BIT0(board) && BIT4(board) && BIT8(board)) return 1;
	if(BIT2(board) && BIT4(board) && BIT6(board)) return 1;
	return 0;
}

int is_full_3(int board_a, int board_b){
	int board = board_a | board_b;
	if((board & 0x000001FF) == 0x000001FF){
		return 1;
	}else{
		return 0;
	}
}

int make_judge_3x3(int board_a, int board_b, int *win_a, int *win_b){
	if(is_win_3(board_a)){
		*win_a = 1;
		*win_b = 0;
		return 1;
	}
	if(is_win_3(board_b)){
		*win_a = 0;
		*win_b = 1;
		return 1;
	}
	if(is_full_3(board_a, board_b)){
		*win_a = 0;
		*win_b = 0;
		return 1;
	}
	return 0;
}

void print_board(int rows, int cols, int board_a, int board_b){
    for(int i = 0; i < 2*rows+1; i++){
    	for(int j = 0; j < 2*cols+1; j++){
    		if(i % 2 == 0){ // border
    			if(j % 2 == 0){
    				print("+");
    			}else{
    				print("-");
    			}
    		}else{
    			if(j % 2 == 0){
    				print("|");
    			}else{
    				if(board_a & 0x00000001){
        				print("o");
    				}else if(board_b & 0x00000001){
    					print("x");
    				}else{
    					print(" ");
    				}
    				board_a >>= 1;
    				board_b >>= 1;
    			}
    		}
    	}
    	print("\r\n");
    }
}

void game_manager(){
	int board_a = 0;
	int board_b = 0;
	int win_a = 0;
	int win_b = 0;
	for(;;){
		print_board(3, 3, board_a, board_b);
		if(make_judge_3x3(board_a, board_b, &win_a, &win_b)){
			break;
		}
		board_a = make_turn(3, 3, board_a, board_b, 1);
		print_board(3, 3, board_a, board_b);
		if(make_judge_3x3(board_a, board_b, &win_a, &win_b)){
			break;
		}
		board_b = recv_turn(3, 3, board_a, board_b, 0);
	}
	if(win_a == 1){
		print("Game End: 1 Player Win\r\n");
	}else if(win_b == 1){
		print("Game End: 2 Player Win\r\n");
	}else{
		print("Game End: Draw\r\n");
	}
}


int main()
{
    init_platform();

    game_manager();

    cleanup_platform();
    return 0;
}
