; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

%define SIZE_PIXEL 4

extern malloc

; rax, rbx*, rcx, rdx, rsi, rdi, rbp, rsp, r8 ...  R12*, R13*, R14*, R15*
; void ASM_blur1( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur1
ASM_blur1:

  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14
  push r15

  mov rbx, rdi ; rbx: w (in pixels), pixeles por fila
  mov r12, rsi ; r12: h (in pixels)
  mov r13, rdx ; r13: pointer to data

  ; reservar espacio para dos filas
  shl rdi, 2   ; rdi*4
  call malloc  ; rax: pointer to temp row 1
  mov r14, rax ; 

  mov rdi, rbx
  shl rdi, 2   ; rdi*4, cada pixel tiene 4 bytes
  call malloc  ; rax: pointer to temp row 0
  mov r15, rax

  ; variables
  xor rdi, rdi ; contador filas recorridas
  mov rdx, rdi ; limite columnas (w-1)
  dec rdx

  ; armar registro para dividir
  pxor   xmm7, xmm7 ; xmm7 = [9.0 | 9.0 | 9.0 | 9.0]
  movss  xmm7, [_9]
  pslldq xmm7, 4
  movss  xmm7, [_9]
  pslldq xmm7, 4
  movss  xmm7, [_9]
  pslldq xmm7, 4
  movss  xmm7, [_9]
  pslldq xmm7, 4

  pxor xmm6, xmm6  ; para desempaquetar

  ; copiar primera fila
.copy_row:
  xor r8, r8   ; columnas recorridas

  xor rax, rax
  mov rax, rdi
  mul rbx      ; rax = rax*rbx, offset en pixeles
  mov r9, rbx

.loop:
  movdqu xmm1, [r13 + r9*SIZE_PIXEL] ; en req a memoria recorro con offset
  movdqu [r14 + r8*SIZE_PIXEL], xmm1 ; en write a temp row recorro con columnas
  add r8, 4   ; los pixeles son multiplos de 4
  add r9, 4   ; update offset
  cmp r8, rbx
  jne .loop   ; si son iguales, ya recorri todos

  cmp rdi, 0  ; caso borde, donde al principio cargo la primera fila
  jne .loop_columns

.loop_rows:
  inc rdi      ; paso a la siguiente fila

  cmp rdi, r12 ; terminamos de iterar
  je .fin

  mov rsi, r14 ; m_tmp, copio puntero a la fila que recien copie
  mov r15, r14 ; m_row_0 points to m_row_1 (la vieja que copie)
  mov r14, rsi ; copiar nueva fila y mantener la anterior
               ; puntero a fila anterior: r15, puntero a fila actual: r14
  jmp .copy_row

  xor r8, r8  ; contador de columnas (lo reutilizo)
  
  xor rax, rax
  mov rax, rdi ; numero de pixeles recorridos en la siguiente fila
  mul rbx
  add rax, r8
  add rax, rdi ; siguiente fila
  dec rax      ; pido un pixel de menos y despues hago un shift,
               ; para no tener un segfault al procesar el ultimo pixel

.loop_columns:

  ; sumo la primera fila de pixeles (res: xmm1)
  movdqu xmm1, [r15 + r8*SIZE_PIXEL] ; xmm1 = [B|G|R|A B|G|R|A B|G|R|A x|x|x|x]
  psrldq xmm1, 4       ; xmm1 = [0|0|0|0 B3|G3|R3|A3 B2|G2|R2|A2 B1|G1|R1|A1]

  movdqu xmm2, xmm1    ; xmm2 = xmm1
  punpcklbw xmm1, xmm6 ; xmm1 = [0|B2|0|G2|0|R2|0|A2 0|B1|0|G1|0|R1|0|A1]

  punpckhbw xmm2, xmm6 ; xmm2 = [0|0|0|0|0|0|0|0 0|B3|0|G3|0|R3|0|A3]

  paddw xmm1, xmm2     ; xmm1 = [B2|G2|R2|A2 B1+B3|G1+G3|R1+R3|A1+A3]

  ; sumo la segunda fila de pixeles (res: xmm2)
  movdqu xmm2, [r14 + r8*SIZE_PIXEL]
  psrldq xmm2, 4       ; xmm2 = [0|0|0|0 B3|G3|R3|A3 B2|G2|R2|A2 B1|G1|R1|A1]

  movdqu xmm3, xmm2    ; xmm3 = xmm2
  punpcklbw xmm2, xmm6 ; xmm2 = [0|B2|0|G2|0|R2|0|A2 0|B1|0|G1|0|R1|0|A1]

  punpckhbw xmm3, xmm6 ; xmm3 = [0|0|0|0|0|0|0|0 0|B3|0|G3|0|R3|0|A3]

  paddw xmm2, xmm3     ; xmm1 = [B2|G2|R2|A2 B1+B3|G1+G3|R1+R3|A1+A3]

  ; sumo la tercera fila de pixeles (res: xmm3)
  movdqu xmm3, [r13 + rax*SIZE_PIXEL] ; xmm3 = [D|C|B|A], A es basura
  psrldq xmm3, 4       ; xmm3 = [0|0|0|0 B3|G3|R3|A3 B2|G2|R2|A2 B1|G1|R1|A1]
                       ; tiro pixel basura

  movdqu xmm4, xmm3    ; xmm4 = xmm3
  punpcklbw xmm3, xmm6 ; xmm3 = [0|B2|0|G2|0|R2|0|A2 0|B1|0|G1|0|R1|0|A1]

  punpckhbw xmm4, xmm6 ; xmm4 = [0|0|0|0|0|0|0|0 0|B3|0|G3|0|R3|0|A3]

  paddw xmm3, xmm4     ; xmm3 = [B2|G2|R2|A2 B1+B3|G1+G3|R1+R3|A1+A3]

  ; sumo todos los resultados (res: xmm1)
  paddw xmm1, xmm2
  paddw xmm1, xmm3     ; xmm1 = [3B|3G|3R|3A 6B|6G|6R|6A]
  movdqu xmm2, xmm1    ; xmm2 = [3B|3G|3R|3A 6B|6G|6R|6A]
  psrldq xmm2, 8       ; xmm2 = [0|0|0|0     3B|3G|3R|3A]
  paddw xmm1, xmm2     ; xmm1 = [3B|3G|3R|3A 9B|9G|9R|9A]
  
  ; asigno mas espacio tirando lo de arriba, convierto a float y divido
  punpcklwd xmm1, xmm6 ; xmm1 = [9B|9G|9R|9A] (dwords)
  cvtdq2ps xmm1, xmm1
  divps xmm1, xmm7     ; xmm1 / 9

  ; convierto a entero, empaqueto y escribo en memoria
  cvtps2dq xmm1, xmm1 ; xmm1 = [9B|9G|9R|9A] (int32), x[31:8] = 0, no hay overflow
  packusdw xmm1, xmm6 ; pack from dword to word
  packuswb xmm1, xmm6 ; pack from word to byte, (res: lower dword)

  add r8, 1 ; avanzo de a 1 pixel
  movd [r13 + rax*SIZE_PIXEL + 8], xmm1 ; sumo 8 porque cuando pido memoria, arranco
                                       ; un pixel antes en xmm3 para evitar el segfault del final
                                       ; e.g. XAAA   xmm1 = ZAAA
                                       ;      ZBOB   xmm2 = ZBOB
                                       ;      ZCCCS  xmm3 = SCCC
                                       ; entonces lo que hago es:
                                       ;             xmm1 = ZAAA
                                       ;             xmm2 = ZBOB
                                       ;             xmm3 = CCCZ y limpio con bitshift.

  cmp r8, rdx ; paro cuando llego a la anteultima columna
  jne .loop_columns

  jmp .loop_rows    ; si llegamos aca, terminamos de iterar las columnas

.fin:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

_9: dd 9.0
