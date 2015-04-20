; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 1                                     ;
;                                                                           ;
; ************************************************************************* ;

% define SIZE_PIXEL 4

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
  xor rdx, rdx ; contador columnas recorridas

  ; armar registro para dividir
  pxor xmm2, xmm2 ; xmm2 = [9.0 | 9.0 | 9.0 | 9.0]
  movss xmm2, [_9]
  pslldq xmm2, 4
  movss xmm2, [_9]
  pslldq xmm2, 4
  movss xmm2, [_9]
  pslldq xmm2, 4
  movss xmm2, [_9]
  pslldq xmm2, 4

  ; copiar primera fila
.copy_row:
  xor r8, r8   ; numero de pixeles en columnas recorridas
  mov r9, rdi  ; copio numero de filas recorridas
  mul r9, rbx  ; numero de pixeles en filas recorridas (actualizo fila)

.loop:
  movdqu xmm5, [r13 + r9*SIZE_PIXEL + r8*SIZE_PIXEL] ; [data + row_index + col_offset]
  movdqu [r14 + r8*SIZE_PIXEL], xmm5
  add r8, 4   ; los pixeles son multiplos de 4
  cmp r8, rbx
  jne .loop   ; si son iguales, ya recorri todos

  cmp rdi, 0  ; caso borde, donde al principio cargo la primera fila
  jne .loop_columns:

.loop_rows:
  inc rdi      ; paso a la siguiente fila

  cmp rdi, r12 ; terminamos de iterar
  je .fin

  mov rsi, r14 ; m_tmp, copio puntero a la fila que recien copie
  mov r15, r14 ; m_row_0 points to m_row_1 (la vieja que copie)
  mov r14, rsi ; copiar nueva fila y mantener la anterior
               ; puntero a fila anterior: r15, puntero a fila actual: r14
  jmp .copy_row

.loop_columns:
  ;TODO
  ;Iterar las filas que cree mas la siguiente
  ;Convertir de ints de 8 bits a floats de 32 desempaquetando.
  ;Dividir, luego sumar para evitar el overflow.
  ;Empaquetar y escribir en *data el nuevo valor.
  ;pasar a la siguiente fila con jmp .loop_rows
  ;VER: Tenemos las filas 1 2 y 3 copiadas. Por ahi se puede optimizarr
  ; para no tener que copiar esa fila denuevo.

.fin:
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

_9: dd 9.0
