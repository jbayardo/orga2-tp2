#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../bmp/bmp.h"

void print_help(char* name);
void createImageFromRGB(int h, int w, uint8_t r, uint8_t g, uint8_t b, uint8_t a);
void createRandomImage(int h, int w);
void createUniformRandomImage(int h, int w);

int main(int argc, char* argv[]) {

  if (argc < 4) { print_help(argv[0]); printf("a"); return 0; }
  if (!strcmp(argv[1], "rgb")     && argc < 8)  { print_help(argv[0]); printf("b"); return 0; } // ./generate rgb     quantity mode height width r g b a 
  if (!strcmp(argv[1], "random")  && argc < 4)  { print_help(argv[0]); printf("c"); return 0; } // ./generate random  quantity mode height width
  if (!strcmp(argv[1], "uniform") && argc < 4)  { print_help(argv[0]); printf("d"); return 0; } // ./generate uniform quantity mode height width

  char* type = argv[1];
  int quantity = atoi(argv[2]);
  char* mode = argv[3];

  uint8_t r, g, b, a;

  if (!strcmp(type, "rgb")) {
    if (!strcmp(mode, "-v")) {
      r = atoi(argv[4]);
      g = atoi(argv[5]);
      b = atoi(argv[6]);
      a = atoi(argv[7]);
    } else {
      r = atoi(argv[6]);
      g = atoi(argv[7]);
      b = atoi(argv[8]);
      a = atoi(argv[9]);
    }
  }

  if (!strcmp(mode, "-v")) { // variable size
    int x = 1;
    while(x <= quantity) {
      if(!strcmp(type, "rgb"))     createImageFromRGB(x*4, x*4, r, g, b, a);
      if(!strcmp(type, "random"))  createRandomImage(x*4, x*4);
      if(!strcmp(type, "uniform")) createUniformRandomImage(x*4, x*4);
      x++;
    }

  } else { // fixed size
    int h = atoi(argv[4]);
    int w = atoi(argv[5]);

    if(w % 4 != 0) { printf("Error: w is not a multiple of 4.\n"); return 0; }

    int x = 1;
    while(x <= quantity) {
      if(!strcmp(type, "rgb"))     createImageFromRGB(h, w, r, g, b, a);
      if(!strcmp(type, "random"))  createRandomImage(h, w);
      if(!strcmp(type, "uniform")) createUniformRandomImage(h, w);
      x++;
    }
  }

  return 0;
}

void print_help(char* name) {
  printf("Use:\n");
  printf("createImageFromRGB:\n");
  printf("e.g. %s rgb quantity mode height width r g b a\n\n", name);
  printf("createUniformRandomImage: Creates a random image with a uniform color (all pixels with the same RGB)\n");
  printf("e.g. %s random quantity mode height width\n\n", name);
  printf("createRandomImage: Creates image with random pixels.\n");
  printf("e.g. %s uniform quantity mode height width\n\n", name);
  printf("Variables:\n");
  printf("quantity: amount of images to be created.\n");
  printf("mode: -f or -v\n\n");
  printf("Modes: All options support mode -f, which defines a fixed image size. Use mode -v (variable size) to ignore the size parameters.\n\n");
  printf("Warning: A segfault means you didn't execute a valid command.\n");
}

void createImageFromRGB(int h, int w, uint8_t r, uint8_t g, uint8_t b, uint8_t a) {

  BMPV5H* imgh = get_BMPV5H(w,h);
  
  BMP* bmp = bmp_create(imgh,0);
  
  uint8_t* data = bmp_get_data(bmp);

  int i, j;
  for(j=0;j<h;j++) {
    for(i=0;i<w;i++) {
      data[j*w*4+i*4+0] = a; // A
      data[j*w*4+i*4+1] = b; // B
      data[j*w*4+i*4+2] = g; // G
      data[j*w*4+i*4+3] = r; // R
    }
  }
  
  char buf[256];
  snprintf(buf, sizeof buf, "images/%dx%d (%d)", h, w, rand());

  bmp_save(buf, bmp);

  bmp_delete(bmp);

}

void createRandomImage(int h, int w) {

  BMPV5H* imgh = get_BMPV5H(w,h);
  
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
  snprintf(buf, sizeof buf, "images/%dx%d (%d)", h, w, rand());

  bmp_save(buf, bmp);

  bmp_delete(bmp);

}

void createUniformRandomImage(int h, int w) {

  uint8_t r, g, b, a;
  r = (uint8_t) rand() % 256;
  g = (uint8_t) rand() % 256;
  b = (uint8_t) rand() % 256;
  a = 0xff;

  createImageFromRGB(h, w, r, g, b, a);

}