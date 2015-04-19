# orga2-tp2

Fecha de entrega: 5/5, hasta las 17 hrs.

El informe no puede exceder las 20 paginas, sin contar la caratula.

## Pitfalls/Hints

* Acuerdense de que en los registros esta todo dado vuelta!!!!! Los pixeles se cargan  ->  BGRA


* **movss**. Es el comando que mueve 32 bits (scalar single). Se usa para cargar la parte baja de un registo xmm o para mover a memoria. El tema es que no es lo mismo copiar desde un registro que copiar de memoria.
```asm
movss xmm1, xmm2        ; escribe los 32 bits menos significativos y deja el resto intacto
movss xmm1, [memoria]   ; lo mismo que antes, y ademas pone el resto de xmm1 en 0
```

## Actualizacion de blur

No se si vieron, pero actualizaron como hay que hacer blur. Le mande un mail a David preguntando instrucciones explicitas y me contesto:
>El algoritmo es el mismo. Solo que ahora van a tener que mantener las dos lineas superiores actualizadas por cada ciclo y leer los datos de ahi.

>En si cambia el lugar desde donde se leen los datos. La parte importante es que no necesariamente tienen que respetar este algoritmo. Pueden programarlo como gusten. Por ejemplo copiando toda la matriz a un buffer. El problema es que seguramente resulte mas ineficiente.

>Parte de la complejidad que deben resolver es como van a decidir hacerlo en función de buscar una solución eficiente.

>Saludos!

>D!


