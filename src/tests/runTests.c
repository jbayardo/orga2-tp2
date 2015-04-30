#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include "../bmp/bmp.h"
#include "../filters/filters.h"
#include "../rdtsc.h"

#define MAXOPSPARAM 6

typedef struct s_options {
  char* program_name;
  int help;
  int c_asm;
  char* filter;
  char* ops[6];
  int valid;
} options;

void print_help(char* name);
int read_options(int argc, char* argv[], options* opt);
unsigned long run_blur(int c, char* src, char* dst);
unsigned long run_merge(int c, char* src1, char* src2, char* dst, float value);
unsigned long run_hsl(int c, char* src, char* dst, float hh, float ss, float ll);

int main(int argc, char* argv[]) {

  // (0) leer parametros
  options opt;
  if (argc == 1) {print_help(argv[0]); return 0;}
  if (read_options(argc, argv, &opt)) {printf("ERROR reading parameters\n"); return 1;}

  //(1) ejecutar filtro
  unsigned long result;
  if(!strcmp(opt.filter,"blur") && opt.valid==2) {
    result = run_blur(opt.c_asm, opt.ops[0], opt.ops[1]);
  } else if(!strcmp(opt.filter,"merge") && opt.valid==4) {
    result = run_merge(opt.c_asm, opt.ops[0], opt.ops[1], opt.ops[2], atof(opt.ops[3]));
  } else if(!strcmp(opt.filter,"hsl") && opt.valid==5) {
    result = run_hsl(opt.c_asm, opt.ops[0], opt.ops[1], atof(opt.ops[2]), atof(opt.ops[3]), atof(opt.ops[4]));
  } else {
    printf("Error: filtro desconocido (%s)\n",opt.filter);
    return 1;
  }

  printf("%lu\n", argv[1], argv[2], result);

  return 0;
}

void print_help(char* name) {
    printf ( "Uso: %s <c/asm1/asm2> <fitro> <parametros...>\n", name );
    printf ( "\n" );
    printf ( "Opcion C o ASM\n" );
    printf ( "         c : ejecuta el codigo C\n" );
    printf ( "      asm1 : ejecuta el codigo ASM version 1\n" );
    printf ( "      asm2 : ejecuta el codigo ASM version 2\n" );
    printf ( "\n" );
    printf ( "Filtro:\n" );
    printf ( "      <c/asm1/asm2> blur <src> <dst>\n");
    printf ( "      <c/asm1/asm2> merge <src1> <src2> <dst> <value>\n");
    printf ( "      <c/asm1/asm2> hsl <src> <dst> <h> <s> <l>\n");
    printf ( "\n" );
}

int read_options(int argc, char* argv[], options* opt) {
  opt->program_name = argv[0];
  opt->help = 0;
  opt->c_asm = -1;
  opt->filter = 0;
  int i;
  for(i=1;i<argc;i++) {
    if(!strcmp(argv[i],"-h")||!strcmp(argv[i],"-help"))
    {opt->help = 1; return 1;}
  }
  if(argc<1) {opt->help = 1; return 1;}
  if(!strcmp(argv[1],"c")||!strcmp(argv[1],"C")) {opt->c_asm = 0;}
  else if(!strcmp(argv[1],"a1")||!strcmp(argv[1],"asm1")||!strcmp(argv[1],"ASM1")) {opt->c_asm = 1;}
  else if(!strcmp(argv[1],"a2")||!strcmp(argv[1],"asm2")||!strcmp(argv[1],"ASM2")) {opt->c_asm = 2;}
  else {opt->help = 1; return 1;}
  if(argc<2) {opt->help = 1; return 1;}
  opt->filter = argv[2];
  int o=0;
  for(i=3;i<argc;i++) {
     opt->ops[o] = argv[i];
     o++; if(o>MAXOPSPARAM) break;
  }
  opt->valid = o;
  return 0;
}

unsigned long run_blur(int c, char* src, char* dst){
  BMP* bmp = bmp_read(src);
  if(bmp==0) { return -1;}  // open error

  uint8_t* data = bmp_get_data(bmp);
  uint32_t h = *(bmp_get_h(bmp));
  uint32_t w = *(bmp_get_w(bmp));
  if(w%4!=0) { return -1;}  // do not support padding

  uint8_t* dataC = 0;
  if(*(bmp_get_bitcount(bmp)) == 24) {
    dataC = malloc(sizeof(uint8_t)*4*h*w);
    to32(w,h,data,dataC);
  } else {
    dataC = data;
  }

  unsigned long start, end;
  RDTSC_START(start);
  if(c==0)         C_blur(w,h,dataC);
  else if(c==1) ASM_blur1(w,h,dataC);
  else if(c==2) ASM_blur2(w,h,dataC);
  else {return -1;}
  RDTSC_STOP(end);
  unsigned long delta = end - start;

  if(*(bmp_get_bitcount(bmp)) == 24) {
    to24(w,h,dataC,data);
    free(dataC);
  }
  // bmp_save(dst,bmp);
  bmp_delete(bmp);

  return delta;
}

unsigned long run_merge(int c, char* src1, char* src2, char* dst, float value){
  if(dst==0) { return -1;}  // non destine
  if(value>1) value=1; else if(value<0) value=0;
  BMP* bmp1 = bmp_read(src1);
  BMP* bmp2 = bmp_read(src2);
  if(bmp1==0 || bmp2==0) { return -1;}  // open error

  uint8_t* data1 = bmp_get_data(bmp1);
  uint8_t* data2 = bmp_get_data(bmp2);
  uint32_t h1 = *(bmp_get_h(bmp1));
  uint32_t w1 = *(bmp_get_w(bmp1));
  uint32_t h2 = *(bmp_get_h(bmp2));
  uint32_t w2 = *(bmp_get_w(bmp2));
  if(w1%4!=0 || w2%4!=0) { return -1;}  // do not support padding
  if( w1!=w2 || h1!=h2 ) { return -1;}  // different image size

  uint8_t* data1C = 0;
  uint8_t* data2C = 0;
  if(*(bmp_get_bitcount(bmp1)) == 24) {
    data1C = malloc(sizeof(uint8_t)*4*h1*w1);
    data2C = malloc(sizeof(uint8_t)*4*h2*w2);
    to32(w1,h1,data1,data1C);
    to32(w2,h2,data2,data2C);
  } else {
    data1C = data1;
    data2C = data2;
  }

  unsigned long start, end;
  RDTSC_START(start);
  if(c==0)         C_merge(w1,h1,data1C,data2C,value);
  else if(c==1) ASM_merge1(w1,h1,data1C,data2C,value);
  else if(c==2) ASM_merge2(w1,h1,data1C,data2C,value);
  else {return -1;}
  RDTSC_STOP(end);
  unsigned long delta = end - start;

  if(*(bmp_get_bitcount(bmp1)) == 24) {
    to24(w1,h1,data1C,data1);
    free(data1C);
    free(data2C);
  }
  // bmp_save(dst,bmp1);
  bmp_delete(bmp1);
  bmp_delete(bmp2);

  return delta;
}

unsigned long run_hsl(int c, char* src, char* dst, float hh, float ss, float ll) {
  BMP* bmp = bmp_read(src);
  if(bmp==0) { return -1;}  // open error
  if(ss>1) ss=1; else if(ss<-1) ss=-1;
  if(ll>1) ll=1; else if(ll<-1) ll=-1;
  uint8_t* data = bmp_get_data(bmp);
  uint32_t h = *(bmp_get_h(bmp));
  uint32_t w = *(bmp_get_w(bmp));
  if(w%4!=0) { return -1;}  // do not support padding

  uint8_t* dataC = 0;
  if(*(bmp_get_bitcount(bmp)) == 24) {
    dataC = malloc(sizeof(uint8_t)*4*h*w);
    to32(w,h,data,dataC);
  } else {
    dataC = data;
  }

  unsigned long start, end;
  RDTSC_START(start);
  if(c==0)         C_hsl(w,h,dataC,hh,ss,ll);
  else if(c==1) ASM_hsl1(w,h,dataC,hh,ss,ll);
  else if(c==2) ASM_hsl2(w,h,dataC,hh,ss,ll);
  else {return -1;}
  RDTSC_STOP(end);
  unsigned long delta = end - start;

  if(*(bmp_get_bitcount(bmp)) == 24) {
    to24(w,h,dataC,data);
    free(dataC);
  }
  // bmp_save(dst,bmp);
  bmp_delete(bmp);

  return delta;
}
