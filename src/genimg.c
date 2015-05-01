/* ************************************************************************* */
/* Organizacion del Computador II                                            */
/*                                                                           */
/*             Biblioteca de funciones para operar imagenes BMP              */
/*                                                                           */
/*   Esta biblioteca permite crear, abrir, modificar y guardar archivos en   */
/*   formato bmp de forma sencilla. Soporta solamente archivos con header de */
/*   versiones info_header (40 bytes) y info_v5_header (124 bytes). Para la  */
/*   primera imagenes de 24 bits (BGR) y la segunda imagenes de 32 (ABGR).   */
/*                                                                           */
/*   bmp.h : headers de la biblioteca                                        */
/*   bmp.c : codigo fuente de la biblioteca                                  */
/* ************************************************************************* */

#include <stdio.h>
#include <stdlib.h>
#include <malloc.h>
#include <stdlib.h> /* atoi */
#include "bmp/bmp.h"
#include <stdio.h>


int main(int argc, char *argv[]){

  /* parametros
   * h (=w) alto de la imagen, hace imagenes cuadradas
   * r
   * g
   * b
   * nombre del archivo de salida
   */

  if (argc != 6){
    printf("Uso: ./genimg h r g b file.bmp\n h es la altura y el ancho\n");
    return -1;
  }
  int h = atoi(argv[1]);
  uint8_t r = atoi(argv[2]);
  uint8_t g = atoi(argv[3]);
  uint8_t b = atoi(argv[4]);
  

  BMPIH* imgh1 = get_BMPIH(h,h);

  // crea una imagen bmp inicializada
  BMP* bmp1 = bmp_create(imgh1,1);
  
  uint8_t* data1 = bmp_get_data(bmp1);
  int i,j;
  for(j=0;j<h;j++) {
    for(i=0;i<h;i++) {
      data1[j*3*h + i*3 + 2] = r;
      data1[j*3*h + i*3 + 1] = g;
      data1[j*3*h + i*3 + 0] = b;
    }
  }
 
  bmp_save(argv[5], bmp1);
  
  return 0;
}
