# Explicación teórica de la función de normalización

A continuación se explica mediante un ejemplo la función "ai_normalize". Esta función sirve para identificar qué indicadores destacan positivamente o negativamente en un país, con respecto a otros países con el mismo indicador.

Para ello, la función pone a cero el valor de la media y normaliza a partir de ahí el resto de valores, dando valores negativos a indicadores por debajo de la media.

## Ejemplo
Veamos un ejemplo para el indicador de tasa de desempleo: 

| País     	| Año  	| Valor 	|
|----------	|------	|-------	|
| Colombia 	| 2010 	| 0.1   	|
| Perú     	| 2010 	| 0.11  	|
| Honduras 	| 2010 	| 0.25  	|
| Suecia   	| 2010 	| 0.02  	|

### 1 Primero calculamos la media y la desviación por año:
M = (0.1+0.11+0.25+0.02) / 4 = 0.12
STD = 0.10

### 2 Ahora calculamos el valor normalizado para cada país/año

| País     	| X - 2010|(M-X)/ STD|
|----------	|---------|----------|
| Colombia 	| 0.1 	  | -0.209 	 |
| Perú     	| 0.11 	  | -0.104   |
| Honduras 	| 0.25 	  | 1.36	   |
| Suecia   	| 0.02 	  | -1.04  	 |

### 3 Como el indicador es negativo, multiplicamos por ‘-1’

| País     	| X - 2010|Multiplicador|
|----------	|---------|-------------|
| Colombia 	| 0.1 	  | 0.209 	    |
| Perú     	| 0.11 	  | 0.104       |
| Honduras 	| 0.25 	  | -1.36	      |
| Suecia   	| 0.02 	  | 1.04  	    |

### 4 Cómo se interpreta

Sucia tiene el mejor indicador, Colombia está por encima de Perú y  Honduras es el peor en el ranking.

Al poner muchos indicadores en la misma escala (**la media en cero**) los podemos comparar. Esa es la ventaja de la normalización. 

Si tomamos un subconjunto de indicadores cómo los de género la normalización nos ayuda a saber para cada país:

1. En cuáles indicadores está peor con respecto a los otros países
2. En cuáles indicadores está mejor  con respecto a los otros países

Esto sirve para enfocar el análisis. Si vemos que Honduras está 'mal' en general en temas de empleo, la normalización nos ayuda a determinar en cuál área está peor, en cuál a mejorado o empeorado con respecto a los otros países.
