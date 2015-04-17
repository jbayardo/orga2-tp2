; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion Merge 2                                    ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_merge2(uint32_t w, uint32_t h, uint8_t* data1, uint8_t* data2, float value)
global ASM_merge2
ASM_merge2:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14
  push r15

  ; TODO: PILA DESALINEADA
  ; xmm0 = value
  mov r12, rdi ; r12 = w
  mov r13, rsi ; r13 = h
  mov r14, rdx ; r14 = data1
  mov r15, rcx ; r15 = data2

  pop r15
  pop r14
  pop r13
  pop r12
  pop rbp
  ret
