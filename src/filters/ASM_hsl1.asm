; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 1                                      ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_hsl1(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl1
ASM_hsl1:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14

  ; xmm0 = hh
  ; xmm1 = ss
  ; xmm2 = ll
  mov r12, rdi ; r12 = w
  mov r13, rsi ; r13 = h
  mov r14, rdx ; r14 = data

  pop r14
  pop r13
  pop r12
  pop rbp
  ret
