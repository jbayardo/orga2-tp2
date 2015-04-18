# orga2-tp2

Fecha de entrega: 5/5, hasta las 17 hrs.

El informe no puede exceder las 20 paginas, sin contar la caratula.

## Pitfalls/Hints

* Acuerdense de que en los registros esta todo dado vuelta!!!!!

* **movss**. Es el comando que mueve 32 bits (scalar single). Se usa para cargar la parte baja de un registo xmm o para mover a memoria. El tema es que no es lo mismo copiar desde un registro que copiar de memoria.
```asm
movss xmm1, xmm2        ; escribe los 32 bits menos significativos y deja el resto intacto
movss xmm1, [memoria]   ; lo mismo que antes, y ademas pone el resto de xmm1 en 0
```


