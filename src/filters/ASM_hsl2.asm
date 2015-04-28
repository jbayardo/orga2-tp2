; ************************************************************************* ;
; Organizacion del Computador II                                            ;
;                                                                           ;
;   Implementacion de la funcion HSL 2                                      ;
;                                                                           ;
; ************************************************************************* ;

%define TAMANIO_PIXEL_HSL 16

extern rgbTOhsl
extern hslTOrgb
extern malloc
extern free


; void ASM_hsl2(uint32_t w, uint32_t h, uint8_t* data, float hh, float ss, float ll)
global ASM_hsl2
ASM_hsl2:
  push rbp
  mov rbp, rsp
  push rbx
  push r12
  push r13
  push r14
  push r15
  sub rsp, 8

  ; xmm0 = hh
  ; xmm1 = ss
  ; xmm2 = ll
  mov r12d, edi ; r12 = w
  mov r13d, esi ; r13 = h
  mov r14, rdx  ; r14 = data

  mov r12d, r12d ; limpio la parte alta
  mov r13d, r13d ; de estos registros

  mov rdi, TAMANIO_PIXEL_HSL
  call malloc

  mov rbx, rax   ; rbx = puntero a float
                 ; lo voy a usar para llamar a las funciones conversoras



  mov rax, r12
  mul r13        ; rax = h*w (suponiendo que no hay overflow)
  mov r15, rax   ; r15 = h*w

  mov rcx, 0     ; iterador

;;;; genero el vector que le voy a sumar, que tiene que ser de la pinta
;;;; [ll | ss | hh | 00]
  pxor xmm4, xmm4
  movss xmm4, xmm2
  pslldq xmm4, 4
  addss xmm4, xmm1
  pslldq xmm4, 4
  addss xmm4, xmm0
  pslldq xmm4, 4
  sub rsp, 16
  movdqu [rsp], xmm4
;;;; xmm4 = [ll | ss | hh | 00]



.loop:
  cmp rcx, r15   ; si iterador = h*w, listo, terminamos
  je .fin

  lea rdi, [r14 + 4*rcx] ; rdi = r14 + rcx
  mov rsi, rbx         ; rsi = puntero a float
  push rcx
  sub rsp, 8
  call rgbTOhsl
  add rsp, 8
  pop rcx
  ; ahora en rbx tengo 4 floats, que representan la transparencia, H, S, L


  ;;;; recupero xmm4 = [ll | ss | hh | 00]
  movdqu xmm4, [rsp]

  movups xmm7, [_1111]   ; xmm7 = [1 | 1 | 1 | 1]
  pxor xmm8, xmm8      ; xmm8 = 0
  movss xmm9, [_360]   ; xmm9 = [ x | x | x | 360.0]
  movss xmm10, [_n360]   ; xmm10 = [ x | x | x | -360.0]
  movss xmm11, [_256]   ; xmm11 = [ x | x | x | 256.0]


  movups xmm3, [rbx]   ; xmn3 = [L|L|L|L | S|S|S|S | H|H|H|H | A|A|A|A]
  addps xmm3, xmm4     ; xmm3 = [l + LL | s + SS | h + HH | a + 00]

  ;; Ahora tengo que hacer los if's. Para eso voy a usar dos registros
  ;; xmm5 = [ 1-(l+LL) | 1-(s+SS) | -360 | 0]
  ;; xmm6 = [ -(l+LL)  | -(s+SS)  | 360  | 0]
  ;; notar que basta seleccionar cuales quiero usar (haciendo and) y sumandolos

  ;; construyo xmm5
  movaps xmm5, xmm7    ; xmm5 = [1 | 1 | 1 | 1]
  subps xmm5, xmm3     ; xmm5 = [1-(l+LL) | 1-(s+SS) | 1-(h+HH) | 1-(a+00)]
  psrldq xmm5, 4       ; xmm5 = [0        | 1-(l+LL) | 1-(s+SS) | 1-(h+HH)]
  movss xmm5, xmm10    ; xmm5 = [0        | 1-(l+LL) | 1-(s+SS) | 360     ]
  pslldq xmm5, 4       ; xmm5 = [1-(l+LL) | 1-(s+SS) | 360      | 0       ]


  ;; construyo xmm6
  pxor xmm6, xmm6      ; xmm6 = [0 | 0 | 0 | 0]
  subps xmm6, xmm3     ; xmm5 = [-(l+LL)  | -(s+SS)  | -(h+HH)  | -(a+00) ]
  psrldq xmm6, 4       ; xmm5 = [0        | -(l+LL)  | -(s+SS)  | -(h+HH) ]
  movss xmm6, xmm9     ; xmm5 = [0        | -(l+LL)  | -(s+SS)  | -360    ]
  pslldq xmm6, 4       ; xmm5 = [-(l+LL)  | -(s+SS)  | -360     | 0       ]

  ;; ahora tengo que comparar con los vectores
  ;; [1 | 1 | 360 | 256] = xmm12
  ;; [0 | 0 | 0   | 0  ] = xmm13

  movaps xmm12, xmm7   ; xmm7 = [1 | 1 | 1 | 1]
  movss xmm12, xmm9    ; xmm7 = [1 | 1 | 1 | 360]
  pslldq xmm12, 4      ; xmm7 = [1 | 1 | 360 | 0]
  movss xmm12, xmm11   ; xmm7 = [1 | 1 | 360 | 256]

  pxor xmm13, xmm13    ; xmm13 = [0 | 0 | 0 | 0]


  cmpltps xmm12, xmm3 ; xmm12 = 1 o 0 dependiendo
  movdqa xmm14, xmm13
  movdqa xmm13, xmm3   ; los doy vuelta porque necesito greater than
  cmpltps xmm13, xmm14  ; xmm13 = 1 o 0 dependiendo

  pand xmm5, xmm12
  pand xmm6, xmm13

  addps xmm3, xmm5
  addps xmm3, xmm6


  movups [rbx], xmm3  ; lo guardo en mi posicion de memoria
  mov rdi, rbx
  lea rsi, [r14 + 4*rcx]

  jmp hslTOrgb
.hslTOrgbBack

  inc rcx
  jmp .loop


.fin:
  add rsp, 16
  mov rdi, rbx
  call free    ; libero la memoria que pedi
  add rsp, 8
  pop r15
  pop r14
  pop r13
  pop r12
  pop rbx
  pop rbp
  ret

_1111: dd 1.0, 1.0, 1.0, 1.0
_360: dd 360.0
_n360: dd -360.0
_256: dd 256.0



;puedo romper todos los registros
;tengo que devolver el resultado en xmm0, xmm1, xmm2, xmm3
_rgbTOhsl:

  ; xmm3 va a ser [L|S|H|A]
  movss xmm12, [rdi]
  pxor xmm13, xmm13

  punpcklbw xmm12, xmm13  ; xmm12 = [x|x|x|x|x|x|x|x|0|R|0|G|0|B|0|A]
  punpcklwd xmm12, xmm13  ; xmm12 = [0|0|0|R|0|0|0|G|0|0|0|B|0|0|0|A]

  cvtdq2ps xmm12, xmm12   ; (float) xmm12 = [0|0|0|R|0|0|0|G|0|0|0|B|0|0|0|A]
  movaps xmm0, xmm12
  movaps xmm1, xmm12
  movaps xmm2, xmm12

  psrldq xmm0, 4
  psrldq xmm1, 8
  psrldq xmm2, 12

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; CALCULO DE H ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  maxss xmm0, xmm1
  maxss xmm0, xmm2    ; xmm0 = max

  minss xmm1, xmm14
  minss xmm1, xmm2    ; xmm1 = min

  movaps xmm14, xmm0  ; xmm14 = max
  subps xmm14, xmm1   ; xmm14 = max - min


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; CALCULO DE L ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  pxor xmm3, xmm3

	movaps xmm8, [_510]

  addss xmm3, xmm1
  addss xmm3, xmm0
  divss xmm3, xmm2    ; xmm3 = [ 0 | 0 | 0 | L = (cmax+cmin)/510]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; CALCULO DE S ;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; pasa los pixeles hsl por xmm0, xmm1, xmm2, xmm3
; hay que devolver los 4 pixeles rgb por $r14 + 4*$rcx
_hslTOrgb:
  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; calculo de c -> xmm0 ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;
	movaps xmm0, xmm3
	psrldq xmm0, 12  ; xmm0 = [0|0|0|L]
  movps xmm1, [_2]
	mulps xmm0, xmm1 ; xmm0 = [0|0|0|2*L]
  movups xmm15, [_1111]
	subps xmm0, xmm15 ; xmm0 = [0|0|0|2*L-1]
	pxor xmm2, xmm2  ; xmm2 = 0
	movps xmm1, xmm0 ; xmm1 = [0|0|0|2*L-1]
	subps xmm2, xmm1 ; xmm2 = [0|0|0|1-2*L]
	maxps xmm0, xmm2 ; xmm0 = [0|0|0|fabs(2*L-1)]
	movups xmm1, xmm15
	subps xmm1, xmm0 ; xmm1 = [x|x|x|1-fabs(2*L-1)]
  movaps xmm0, xmm3
	psrldq xmm0, 8
	mulps xmm0, xmm1 ; xmm0 = [x|x|x|c = ( 1 - fabs( 2*L - 1 )) * s]


  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; calculo de x -> xmm1 ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;

	movaps xmm1, xmm3
	psrldq xmm1, 4
	movps xmm15, [_60]
	divps xmm1, xmm15 ; xmm1 = [x|x|x|H/60]
	movaps xmm12, xmm1; xmm12 = [x|x|x|H/60]
	movps xmm13, [_2] ; xmm13 = [x|x|x|2]
	divps xmm12, xmm13
	roundps xmm12, xmm12, 0 ;; CONSULTAR : modo de redondeo
	mulps xmm12, xmm13
	subps xmm1, xmm12  ; xmm1 = [x|x|x|n-trunc(n/d)*d = fmod(H/60, 2)]
	movps xmm13, [_1111]
	subps xmm1, xmm13; xmm1 = [x|x|x|fmod(H/60,2)-1]
  pxor xmm2, xmm2  ; xmm2 = 0
	subps xmm2, xmm1 ; xmm2 = [0|0|0|-(fmod(H/60,2)-1)]
	maxps xmm1, xmm2 ; xmm0 = [0|0|0|fabs(fmod(H/60, 2)-1)]
	subps xmm13, xmm1; xmm13= [x|x|x|1-fabs(fmod(H/60, 2)-1)]
	mulps xmm13, xmm0
	movaps xmm1, xmm13  ; xmm1 = [x|x|x|x = C*(1-fabs(fmod(H/60,2)-1))]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; calculo de m -> xmm2 ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;

  movps xmm13, [_2]
	movps xmm2, xmm0
	divps xmm2, xmm13
	movps xmm14, xmm2
	movps xmm2, xmm3
	subps xmm2, xmm14 ; xmm2 = [x|x|x|m = L-C/2]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;; calculo RGB           ;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;

  movaps xmm15, [_255] ; xmm15 = 255.0

  addps xmm0, xmm2
  addps xmm1, xmm2 ; Le sumo m a todos los x y todos los c

  mulps xmm0, xmm15 ; Registro con los c
  mulps xmm1, xmm15 ; Registro con los x
  mulps xmm2, xmm15 ; Registro con los 0

  cvtps2dq xmm0, xmm0
  cvtps2dq xmm1, xmm1
  cvtps2dq xmm2, xmm2 ; Los convierto todos a enteros de 32 bits

  pxor xmm15, xmm15 ; xmm15 = 0

  packusdw xmm0, xmm15 ; xmm0 = [0|0|(c1 + m1)*255 | 0|0|(c2 + m2)*255 | 0|0|(c3 + m3)*255 | 0|0|(c4 + m4)*255]
  packusdw xmm1, xmm15 ; xmm1 = [0|0|(x1 + m1)*255 | 0|0|(x2 + m2)*255 | 0|0|(x3 + m3)*255 | 0|0|(x4 + m4)*255]
  packusdw xmm2, xmm15 ; xmm2 = [0|0|m1 | 0|0|m2 | 0|0|m3 | 0|0|m4]
  ; Los convierto todos a enteros de 16 bits

  packuswb xmm0, xmm15
  packuswb xmm1, xmm15
  packuswb xmm2, xmm15
  ; Los convierto todos a enteros de 8 bits

  psrldq xmm0, 2
  psrldq xmm1, 1
  ; Shifteamos a la izquierda para que nos quede tipo escalera

  paddb xmm0, xmm1
  paddb xmm0, xmm2
  ; [0|c1|x1|m1 | 0|c2|x2|m2 | 0|c3|x3|m3 | 0|c4|x4|m4]



  jmp .hslTOrgbBack

align 16
_2: dd 2.0, 2.0, 2.0, 2.0
_60: dd 60.0, 60.0, 60.0, 60.0
_120: dd 120.0, 120.0, 120.0, 120.0
_180: dd 180.0, 180.0, 180.0, 180.0
_240: dd 240.0, 240.0, 240.0, 240.0
_255: dd 255.0, 255.0, 255.0, 255.0
_300: dd 300.0, 300.0, 300.0, 300.0
_360: dd 360.0, 360.0, 360.0, 360.0

_510: dd 510.0, 510.0, 510.0, 510.0




