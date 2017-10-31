# Agregador-de-indicadores

### Nombre
agregadorindicadores

### Descripción y contexto
---
El “Agregador de Indicadores” permite a académicos, multilaterales y otras organizaciones con interés en analizar indicadores de desarrollo, analizar y comparar indicadores de diferentes fuentes y con diversas unidades de medida. 
Con el esta herramienta es posible buscar con una función los indicadores del Banco Mundial (https://data.worldbank.org/data-catalog), Numbers for Development (N4D) del Banco Interamericano de Desarrollo (https://data.iadb.org/NumbersForDevelopment/NumbersForDevelopment) y de No Ceilings (http://www.noceilings.org)

### Guía de usuario
---

#### Cargar la libreria
```r
library(agregadorindicadores)
```

#### Buscar un indicadores de deseempleo
```r
df<-ind_search(pattern="unemployment")
df[1:5,1:3]

src_id_ind                                                             indicator        api
1220       SL.UEM.TOTL.ZS   Unemployment, total (% of total labor force) (modeled ILO estimate) World Bank
1221    SL.UEM.TOTL.NE.ZS      Unemployment, total (% of total labor force) (national estimate) World Bank
1222    SL.UEM.TOTL.MA.ZS     Unemployment, male (% of male labor force) (modeled ILO estimate) World Bank
1223 SL.UEM.TOTL.MA.NE.ZS        Unemployment, male (% of male labor force) (national estimate) World Bank
1224    SL.UEM.TOTL.FE.ZS Unemployment, female (% of female labor force) (modeled ILO estimate) World Bank
```
#### Verificar las distintas fuentes de informacion

```r
unique(df$api)
[1] "World Bank"              "Numbers for Development" "No Ceilings"   
```
Con una misma funciono obtuvimos datos de 3 fuentes distintas de informacion.

#### Descargar informacion de dos indicadores para dos países entre el 2014 y el 2015
```r
data<-ai(indicator = c("SL.UEM.TOTL.FE.ZS","SOC_6562"), country = c("CO","PE"),startdate = 2014, enddate=2015)
 data[1:8,1:6]
  iso2  country year        src_id_ind  value                                                             indicator
1   CO Colombia 2015 SL.UEM.TOTL.FE.ZS 11.843 Unemployment, female (% of female labor force) (modeled ILO estimate)
2   CO Colombia 2014 SL.UEM.TOTL.FE.ZS 11.971 Unemployment, female (% of female labor force) (modeled ILO estimate)
3   PE     Peru 2015 SL.UEM.TOTL.FE.ZS  5.004 Unemployment, female (% of female labor force) (modeled ILO estimate)
4   PE     Peru 2014 SL.UEM.TOTL.FE.ZS  4.731 Unemployment, female (% of female labor force) (modeled ILO estimate)
5   CO Colombia 2014          SOC_6562 10.253                  Unemployment Rate, Female, No quint data, 25-49 age 
6   CO Colombia 2015          SOC_6562 10.285                  Unemployment Rate, Female, No quint data, 25-49 age 
7   PE     Peru 2014          SOC_6562  2.845                  Unemployment Rate, Female, No quint data, 25-49 age 
8   PE     Peru 2015          SOC_6562  2.926                  Unemployment Rate, Female, No quint data, 25-49 age 
```
### Guía de instalación
---
Para utilizar la libreria en R se debe ejecutar el siguiente codigo:

```r
install.packages('devtools')
library(devtools)
install_github('arcuellar88/iadbstats')
install_github('arcuellar88/govdata360R')
install_github('EL-BID/Agregador-de-indicadores')
library(agregadorindicadores)
```

#### Dependencias
El agregador de indicadores utiliza las siguientes librerias de R:

    dplyr, tidyr, sqldf gdata y son para manipular los datos (merge, join, agregar columnas, filtrar, etc.)
    wbstats,WDI para conectarse con el API del Banco Mundial 
    httr, jsonlite se utilizan para leer los resultados del llamo a los distintos APIs    

Adicionalmente se utiliza otras librerias de github: 

    'arcuellar88/iadbstats' para conectarse con el API del Banco Interamericano de Desarrollo   https://github.com/arcuellar88/iadbstats
       'arcuellar88/govdata360R' para conectarse con el API govdata360 del banco Mundial   https://github.com/arcuellar88/govdata360R


### Cómo contribuir
---
TO-DO
Esta sección explica a desarrolladores cuáles son las maneras habituales de enviar una solicitud de adhesión de nuevo código (“pull requests”), cómo declarar fallos en la herramienta y qué guías de estilo se deben usar al escribir más líneas de código.

### Código de conducta 
---
TO-DO
El código de conducta establece las normas sociales, reglas y responsabilidades que los individuos y organizaciones deben seguir al interactuar de alguna manera con la herramienta digital o su comunidad. Es una buena práctica para crear un ambiente de respeto e inclusión en las contribuciones al proyecto. La plataforma Github premia y ayuda a los repositorios dispongan de este archivo. Al crear CODE_OF_CONDUCT.md puedes empezar desde una plantilla sugerida por ellos. 

### Autor/es
---
Alejandro Rodríguez Cuéllar (https://github.com/arcuellar88)

### Licencia 
---
GNU General Public License v3.0

### TO-DO
1. Topics
2. GovData360
3. ggplot examples
4. Documentation
