#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../bmp/bmp.h"

void createRandomImage(int h, int w);

int main() {

  int x = 1;

  while(x <= 500) {
    createRandomImage(x*4,x*4);
    x++;
  }

  return 0;
}

void createRandomImage(int h, int w) {

  BMPV5H* imgh = get_BMPV5H(h,w);
  
  BMP* bmp = bmp_create(imgh,0);
  
  uint8_t* data = bmp_get_data(bmp);

  int i, j;
  for(j=0;j<h;j++) {
    for(i=0;i<w;i++) {
      data[j*w*4+i*4+0] = 0xff; //(uint8_t) rand() % 256; // A
      data[j*w*4+i*4+1] = (uint8_t) rand() % 256; // B
      data[j*w*4+i*4+2] = (uint8_t) rand() % 256; // G
      data[j*w*4+i*4+3] = (uint8_t) rand() % 256; // R
    }
  }
  
  char buf[256];
  snprintf(buf, sizeof buf, "images/%dx%d.bmp", h, w);

  bmp_save(buf, bmp);

  bmp_delete(bmp);

}