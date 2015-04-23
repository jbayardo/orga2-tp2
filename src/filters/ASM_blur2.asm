; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Blur 2                                     ;
;                                                                           ;
; ************************************************************************* ;

extern malloc

; void ASM_blur2( uint32_t w, uint32_t h, uint8_t* data )
global ASM_blur2
ASM_blur2:
  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14
  push r15
  sub rsp, 8

  mov r12d, edi ; r12 = w
  mov r13d, esi ; r13 = h
  mov r14, rdx ; r14 = data

  mov rax, r12
  mul r13
  shl rax, 2

  mov rdi, rax
  call malloc
  mov r15, rax ; r15 = data'

  mov r8, r12
  dec r8
  dec r8       ; r8 = w-2

  mov r9, r13
  dec r9
  dec r9       ; r9 = h-2

  pxor xmm15, xmm15
  movdqu xmm14, [_9]
  mov rax, r14
  mov rbx, r15

  mov rdi, 0x1 ; rdi = rows
  .loopRows:
    cmp rdi, r9
    jge .end

    mov rcx, rax ; Guardo rax porque lo voy a sobrescribir
    mov rax, rdi
    dec rax
    mul r12 ; rax = (rdi - 1)*r12*4 <- proxima fila, en la posición 0
    shl rax, 2 ; Calculo el offset de movimiento en rax

    mov rbx, r15
    add rbx, rax
    add rax, r14 ; Me corro a la proxima fila en rax y rbx

    mov rsi, 0x1 ; rsi = columns
    .loopColumns:
      cmp rsi, r8
      jge .endColumns

      movdqu xmm1, [rax] ; xmm1 = [P4 | P3 | P2 | P1]
      movsd xmm2, xmm1   ; xmm2 = xmm1
      punpckhbw xmm1, xmm15 ; xmm1 = [P4 | P3]
      punpcklbw xmm2, xmm15 ; xmm2 = [P2 | P1]
      movsd xmm3, [rax + 4*4] ; xmm3 = [P6 | P5 | x | x]
      punpckhbw xmm3, xmm15 ; xmm3 = [P6 | P5]

      movdqu xmm4, [rax + r12*4]
      movsd xmm5, xmm4
      punpckhbw xmm4, xmm15
      punpcklbw xmm5, xmm15
      movsd xmm6, [rax + r12*4 + 4*4]
      punpckhbw xmm6, xmm15

      movdqu xmm7, [rax + r12*8]
      movsd xmm8, xmm7
      punpckhbw xmm7, xmm15
      punpcklbw xmm8, xmm15
      movsd xmm9, [rax + r12*8 + 4*4]
      punpckhbw xmm9, xmm15

      ; xmm1, xmm2 y xmm3 tienen cargados los 6 pixeles de la fila anterior
      ; xmm4, xmm5 y xmm6 tienen cargados los 6 pixeles de la fila actual
      ; xmm7, xmm8 y xmm9 tienen cargados los 6 pixeles de la fila siguiente

      ; xmm1 = [P14 | P13]
      ; xmm2 = [P12 | P11]
      ; xmm3 = [P16 | P15]

      ; xmm4 = [P24 | P23]
      ; xmm5 = [P22 | P21]
      ; xmm6 = [P26 | P25]

      ; xmm7 = [P34 | P33]
      ; xmm8 = [P32 | P31]
      ; xmm9 = [P36 | P35]

      ; Quiero sumar las columnas:

      paddw xmm1, xmm4
      paddw xmm1, xmm7
      ; xmm1 = [P14 + P24 + P34 | P13 + P23 + P33] <- columna 4 y 3

      paddw xmm2, xmm5
      paddw xmm2, xmm8
      ; xmm2 = [P12 + P22 + P32 | P11 + P21 + P31] <- columna 2 y 1

      paddw xmm3, xmm6
      paddw xmm3, xmm9
      ; xmm3 = [P16 + P26 + P36 | P15 + P25 + P35] <- columnas 6 y 5

      movsd xmm5, xmm3
      psrlw xmm3, 8
      movsd xmm6, xmm3

      movsd xmm3, xmm1
      psrlw xmm1, 8
      movsd xmm4, xmm1

      movsd xmm1, xmm2
      psrlw xmm2, 8
      ; En cada xmmY tengo xmmY = [0 | CY] como enteros en words

      paddw xmm1, xmm2
      paddw xmm1, xmm3

      paddw xmm2, xmm3
      paddw xmm2, xmm4

      paddw xmm3, xmm4
      paddw xmm3, xmm5

      paddw xmm4, xmm5
      paddw xmm4, xmm6
      ; En cada xmmY tengo xmmY = [0 | Pixel Nuevo Y] como enteros en words
      ; Falta dividir

      punpcklwd xmm1, xmm15
      punpcklwd xmm2, xmm15
      punpcklwd xmm3, xmm15
      punpcklwd xmm4, xmm15
      ; Cada xmmY pasa a tener BGRA como enteros de 32 bits

      cvtdq2ps xmm1, xmm1
      cvtdq2ps xmm2, xmm2
      cvtdq2ps xmm3, xmm3
      cvtdq2ps xmm4, xmm4
      ; Convierto a float todos los BGRA

      divps xmm1, xmm14
      divps xmm2, xmm14
      divps xmm3, xmm14
      divps xmm4, xmm14
      ; Los dividi a todos por 9

      cvtps2dq xmm1, xmm1
      cvtps2dq xmm2, xmm2
      cvtps2dq xmm3, xmm3
      cvtps2dq xmm4, xmm4
      ; Convierto los floats a enteros

      packusdw xmm1, xmm15
      packuswb xmm1, xmm15

      packusdw xmm2, xmm15
      packuswb xmm2, xmm15

      packusdw xmm3, xmm15
      packuswb xmm3, xmm15

      packusdw xmm4, xmm15
      packuswb xmm4, xmm15
      ; Pasamos todos a ser 4 bytes de vuelta con saturación.

      vmovss [rbx + r12*4], xmm1
      vmovss [rbx + r12*4 + 4*1], xmm2
      vmovss [rbx + r12*4 + 4*2], xmm3
      vmovss [rbx + r12*4 + 4*3], xmm4
      ; Guardamos todo en memoria

      add rsi, 0x4
      add rax, 4*4
      add rbx, 4*4
       ; Me adelanto 4 elementos
      jmp .loopColumns

    ; NOTA: TODAVIA NO CONTEMPLE QUE PASA CUANDO NO PUEDO CARGAR ESA CANTIDAD
  .endColumns:
    inc rdi ; Incrementamos de fila
    jmp .loopRows

.end:

  ; Copiamos los datos a la matriz original
  mov rax, r12
  mul r13
  shl rax, 2

  mov rcx, 0x0
.copyLoop:
  cmp rcx, rax
  je .endF

  mov bl, [r15 + rcx]
  mov [r14 + rcx], bl

  inc rcx
  jmp .copyLoop

.endF:
  ; TODO: Liberamos memoria
  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

_9: dd 9.0, 9.0, 9.0, 9.0
