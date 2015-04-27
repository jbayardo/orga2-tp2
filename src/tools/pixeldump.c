#include "../bmp/bmp.h"

void print_help(char* name);

int main(int argc, char* argv[]){

	if (argc != 2) {
		print_help(argv[0]);
		return 0;
	}

	char* fileName = argv[1];

	BMP* bmp = bmp_read(fileName);

	if (bmp == 0) {
		printf("Invalid filename.\n");
		return 0;
	}

	uint8_t *data = bmp_get_data(bmp);
	uint32_t h    = *bmp_get_h(bmp);
	uint32_t w    = *bmp_get_w(bmp);
	int c1 = ((BMPIH*)(bmp->ih))->biBitCount;

	if(c1 == 32) {
		for (int i = 0; i < h; i++) {
			for (int j = 0; j < w; j++) {
				int pos   = (i*w+j)*4;
				uint8_t r = data[pos+3];
				uint8_t g = data[pos+2];
				uint8_t b = data[pos+1];
				uint8_t a = data[pos+0];
				printf("[%u,%u,%u,%u]\n", (int) r, (int) g, (int) b, (int) a);
			}
		}
	}

	if(c1 == 24) {
		for (int i = 0; i < h; i++) {
			for (int j = 0; j < w; j++) {
				int pos   = (i*w+j)*3;
				uint8_t r = data[pos+2];
				uint8_t g = data[pos+1];
				uint8_t b = data[pos+0];
				printf("[%u,%u,%u]\n", (int) r, (int) g, (int) b);
			}
		}
	}

}

void print_help(char* name) {
	printf("Usage: %s <file.bmp>\n", name);
}