#include <iostream>

int make_turn(int board_a, int board_b, int turn_a);

int main(int argc, char **argv){

	int ret;
	int error = 0;

	ret = make_turn(1, 2, 1);
	std::cout << "a=" << 1 << ", b=" << 2 << ", ret=" << ret << std::endl;
	if(ret != 5){
		error = -1;
	}

	return error;
}
