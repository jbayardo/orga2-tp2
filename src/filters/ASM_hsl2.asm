; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

; void ASM_hsl2(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl2
ASM_hsl2:
  push rbp
  mov rbp, rsp
  push r12
  push r13
  push r14
  sub rsp, 8

  ; xmm0 = hh
  ; xmm1 = ss
  ; xmm2 = ll
  mov r12, rdi ; r12 = w
  mov r13, rsi ; r13 = h
  mov r14, rdx ; r14 = data

  add rsp, 8
  pop r14
  pop r13
  pop r12
  pop rbp
  ret


