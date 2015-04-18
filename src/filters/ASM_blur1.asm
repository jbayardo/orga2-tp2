; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1
ASM_blur1:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14

  mov r12, rdi  ; r12 = w
  mov r13, rsi  ; r13 = h
  mov r14, rdx  ; r14 = data

  mov rcx, 0x1  ; rcx = columna. Salteamos la primer columna porque es borde.
  mov rdx, 0x1  ; rdx = fila. Salteamos la primer fila porque es borde.

  .loop1:
    ; Terminamos de recorrer columnas?
    ; Salteamos la última porque es borde
    cmp rcx, r13
    je .end

    .loop2:
      ; Terminamos de recorrer filas?
      ; Salteamos la última porque es borde
      cmp rdx, r12
      je .endloop2

      pxor xmm15, xmm15

      ; TODO: Arreglar este cansur de indexación, debuggear.

      movdqu xmm1, [r14 + r12 * (rdx - 1) + (rcx - 1)*4]
      ; xmm1 = 3 pixeles de arriba, con basura en los primeros 4 bytes
      ; xmm1 = [A|B|G|R | A|B|G|R | A|B|G|R | x|x|x|x]
      psrldq xmm1, 8
      ; xmm1 = [0|0|0|0 | A|B|G|R | A|B|G|R | A|B|G|R]

      movdqu xmm2, [r14 + r12 * rdx + (rcx - 1)*4]
      ; xmm2 = 3 pixeles de arriba, con basura en los primeros 4 bytes
      ; xmm2 = [A|B|G|R | A|B|G|R | A|B|G|R | x|x|x|x]
      psrldq xmm2, 8
      ; xmm2 = [0|0|0|0 | A|B|G|R | A|B|G|R | A|B|G|R]

      movdqu xmm3, [r14 + r12 * (rdx + 1) + (rcx - 1)*4]
      ; xmm2 = 3 pixeles de arriba, con basura en los primeros 4 bytes
      ; xmm2 = [A|B|G|R | A|B|G|R | A|B|G|R | x|x|x|x]
      psrldq xmm3, 8
      ; xmm2 = [0|0|0|0 | A|B|G|R | A|B|G|R | A|B|G|R]

      movdqu xmm4, xmm1
      punpckhbw xmm4, xmm15
      punpcklbw xmm1, xmm15
      ; xmm1 = [0|A|0|B|0|G|0|R | 0|A|0|B|0|G|0|R]
      ; xmm4 = [0|0|0|0|0|0|0|0 | 0|A|0|B|0|G|0|R] <- Columna 1 Fila 1

      movdqu xmm5, xmm2
      punpckhbw xmm5, xmm15
      punpcklbw xmm2, xmm15
      ; xmm2 = [0|A|0|B|0|G|0|R | 0|A|0|B|0|G|0|R]
      ; xmm5 = [0|0|0|0|0|0|0|0 | 0|A|0|B|0|G|0|R] <- Columna 1 Fila 2

      movdqu xmm6, xmm3
      punpckhbw xmm6, xmm15
      punpcklbw xmm3, xmm15
      ; xmm3 = [0|A|0|B|0|G|0|R | 0|A|0|B|0|G|0|R]
      ; xmm6 = [0|0|0|0|0|0|0|0 | 0|A|0|B|0|G|0|R] <- Columna 1 Fila 3

      paddw xmm1, xmm2
      paddw xmm1, xmm3
      ; xmm1 = xmm1 + xmm2 + xmm3
      ; xmm1 = [A|A|B|B|G|G|R|R | A|A|B|B|G|G|R|R] <- Acumulado Columna 2 y 3

      paddw xmm4, xmm5
      paddw xmm4, xmm6
      ; xmm4 = xmm4 + xmm5 + xmm6
      ; xmm4 = [0|0|0|0|0|0|0|0 | A|A|B|B|G|G|R|R] <- Acumulado Columna 1

      movdqu xmm2, xmm1
      psrldq xmm2, 8
      ; xmm2 = [0|0|0|0|0|0|0|0 | A|A|B|B|G|G|R|R] <- Acumulado Columna 2

      pslldq xmm1, 8
      psrldq xmm1, 8
      ; xmm1 = [0|0|0|0|0|0|0|0 | A|A|B|B|G|G|R|R] <- Acumulado Columna 3

      paddw xmm1, xmm2
      paddw xmm1, xmm4
      ; xmm1 = [0|0|0|0|0|0|0|0 | A|A|B|B|G|G|R|R] <- Suma total

      ; OJO: No tenemos problemas de precisión porque la suma como mucho agrega
      ; 1 bit por suma, y tenemos un total de 6 sumas, que es menos de 8 bits.

      punpcklwd xmm1, xmm15
      ; xmm1 = [0|0|A|A|0|0|B|B | 0|0|G|G|0|0|R|R]

      cvtdq2pd xmm1, xmm1
      ; xmm1 = "float[4](xmm1)"

      pxor xmm2, xmm2
      movss xmm2, [_9]
      pslldq xmm2, 4
      movss xmm2, [_9]
      pslldq xmm2, 4
      movss xmm2, [_9]
      pslldq xmm2, 4
      movss xmm2, [_9]
      pslldq xmm2, 4
      ; xmm2 = [9.0 | 9.0 | 9.0 | 9.0]

      divps xmm1, xmm2
      ; xmm1 = xmm1 / 9.0 en bache

      cvtps2dq xmm1, xmm1
      ; xmm1 = "uint16_t[4](xmm1)"

      packusdw xmm1, xmm15
      ; xmm1 = [0|0|0|0|0|0|0|0 | A|A|B|B|G|G|R|R] (saturado)

      packuswb xmm1, xmm15
      ; xmm1 = [0|0|0|0|0|0|0|0 | 0|0|0|0|A|B|G|R] (saturado)

      ; Guardar en memoria el valor que acabamos de procesar
      movss [r14 + r12 * rdx + rcx*4], xmm1

      inc rdx
      jmp loop2

  .endloop2:
    inc rcx
    jmp loop1

.end:
  pop r14
  pop r13
  pop r12
  pop rbp
  ret

_9: dd 9.0
