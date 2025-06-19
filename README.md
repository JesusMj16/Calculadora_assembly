# Calculadora_assembly
En este repositorio llevamos a cabo la implementación de una calculadora con algunas funciones sencillas, tales como la suma, resta, división y multiplicación con uso de bcd 
# 1. Suma con BCD 
Para realizar la suma con bcd, ocupamos una macro que hace el llenado de ceros en caso de que alguno de los numeros sea menor que el otro, una vez ajustados los dos numeros para que tengan los mismo digitos pasamos a lo  que es la macro que se utilizo,  llamada como BCD_SUM_STRINGS esta macro recibe como parametros los dos numeros y resultado. 
Durante la macro se posiciono los punteros como SI, DI y BX hasta el ultimo digito para realizar la suma de derecha izquierda, se mandejo el uso de la suma con carry en caso de que la suma exediera o fuera mayor a 10, sumando al digito siguiente, se hizo un bucle dentro de cual tambien se hizo el uso de la herramienta AAA la cual es una herramienta que nos sirve para el reajuste, finalmente se hizo el translado a codigo ASCII para su posterior impresion.

# 2. Resta con BCD 
Para llevar a cabo la resta, de igual forma ocupamos la misma macro para hacer el rellenado con ceros, debido a que podemos recibir como parametros un numero mayor que otro en algunos casos, despues del rellenado pasamos a lo que es la resta, donde tambien se hizo un recorrido de los digitos de izquierda a derecha el cual fue implementado en un bucle que retrocediera los puntero SI y DI, ocupamos como herramientas lo que fue el SBB y AAS, donde SBB nos sirvio para el proceso de hacer la resta con carry, mientras que AAS sirvio para el reajuste en binario de nuestra resta, finalmente pasamos de un formato digital a un ASCII el resultaod para la posterior impresion.

