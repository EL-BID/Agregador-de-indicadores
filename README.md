---
# Agregador-de-indicadores

## Descripción y contexto
---
El “Agregador de Indicadores” permite a académicos, multilaterales y otras organizaciones con interés en analizar indicadores de desarrollo, analizar y comparar indicadores de diferentes fuentes y con diversas unidades de medida. 
Con el esta herramienta es posible buscar con una función los indicadores del [Banco Mundial](https://data.worldbank.org/data-catalog), [Numbers for Development,  N4D](https://data.iadb.org/NumbersForDevelopment/NumbersForDevelopment) del Banco Interamericano de Desarrollo  y de [No Ceilings](http://www.noceilings.org)

## Guía de instalación
---
Para utilizar la librería en R se debe ejecutar el siguiente codigo:

```r
install.packages('devtools')
library(devtools)
install_github('EL-BID/Libreria-R-Numeros-para-el-Desarrollo')
install_github("arcuellar88/govdata360R")
install_github('EL-BID/Agregador-de-indicadores')
library(agregadorindicadores)
```

## Guía de usuario
---

### 1. Cargar la libreria
```r
library(agregadorindicadores)
```

### 2. Buscar indicadores 
En este caso buscaremos indicadores relacionados con desempleo.

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
Verificar las distintas fuentes de informacion

```r
unique(df$api)
[1] "World Bank"              "Numbers for Development" "No Ceilings"   
```
Con una misma funciono obtuvimos datos de 3 fuentes distintas de informacion.

Para mayor información sobre la buúsqueda de indicadores ejecuta en R:
```r
?ind_search
```

### 3. Descargar informacion de los indicadores

En este ejemplo vamos a descargar los datos de dos indicadores para dos países entre el 2014 y el 2015

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

Para mayor información sobre la descarga de datos de los indicadores ejecuta en R:
```r
?ai
```
### 4. Ejemplo de visualización:

*Usaremos la librera plotly para los ejemplos*

```r
library(plotly)
```

##### Plot one indicator "Agricultural land (% of land area)" for 4 countries in 2014
```r
df<-ai(indicator = "AG.LND.AGRI.ZS", country = c("CO", "PE","ZA","US"), startdate = 2014)
```
```r
df$fCountry <- factor(df$country)
p <- ggplot(df, aes(x=fCountry, y=value,colour=fCountry,hover = indicator))  +
  geom_point(shape=1) 
p <- ggplotly(p)
p
```

![](https://plot.ly/~arcuellar88/11.png)

##### Plot two indicators from two different sources for one country and five years

```r
df<-ai(indicator = c("NV.AGR.TOTL.ZS","LMW_403"), country = c("PE"), startdate = 2010)

ay <- list(
    tickfont = list(color = "red"),
    overlaying = "y",
    side = "right",
    title = "% of GDP"
  )
  p <- plot_ly() %>%
    add_lines(x = df[df$src_id_ind=="LMW_403",]$year, y = df[df$src_id_ind=="LMW_403",]$value, name = "GDP: (US$ mill.) - Numbers for Development") %>%
    add_lines(x = df[df$src_id_ind=="NV.AGR.TOTL.ZS",]$year, y = df[df$src_id_ind=="NV.AGR.TOTL.ZS",]$value, name = "Agriculture, value added (% of GDP) -  World Bank", yaxis = "y2") %>%
    layout(
      title = "Comparación de dos indicadores", yaxis2 = ay,
      xaxis = list(title="Year")
    )
    
   p
```
&nbsp;


![](https://plot.ly/~arcuellar88/13.png)


### 5. Ranking de indicadores

El agregador de indicadores ofrece una funcionalidad adicional para normalizar los indicadores y hacer un raking por país y por año. La normalización consiste en comparar el valor del indicador de cada país contra la media y la desviación de ese mismo indicador para todos los países para cada año. Para cada indicador, país y año se calcula el zscore de la siguiente manera:

&nbsp;
![](https://github.com/EL-BID/Agregador-de-indicadores/blob/master/zscore.png?raw=true)

&nbsp;
Una de las aplicaciones de esta normalizacion es comparar un conjunto de indicadores en un mismo gráfico. En el siguiente ejemplo se gráfico se muestran más de 1500 indicadores relacionados con género para 8 países para el 2014. En el gráfico se puede ver que Somalia e iraq tienen muchos más indicadores debajo de la media que el resto de países.

&nbsp;
![](https://plot.ly/~arcuellar88/9.png)
&nbsp;

Puedes ver una explicación más detallada de esta función en el [/ejemplos/normalización](https://github.com/EL-BID/Agregador-de-indicadores/blob/master/examples/Normalizacion.md)
El paso a paso de este ejemplo lo pueden ver en [/ejemplos/ranking_plot.R](https://github.com/EL-BID/Agregador-de-indicadores/blob/master/examples/ranking_plot.R)

Para mayor información sobre la normalizacioón de datos ejecuta en R:
```r
?ai_normalize
```

### 6. Cache

Para mejorar el desempeño de la herramienta, esta cuenta con una pequeña base de datos de los metadatos de los indicadores que llamamos caché. Esta fue actualizada por última vez el 1 de Noviembre del 2017. Para utilizar una versión más reciente se puede utilizar el siguiente código:

```r
library(agregadorindicadores)

# Descargamos un nuevo cache en inglés
cache <- ai_cache(lang='en') 

# Buscamos indicadores utilizando el cache
df<-ind_search(pattern="poverty", cache=cache)
```
Para ver los datos disponibles en el caché se utiliza el siguiente código

```r
library(agregadorindicadores)
str(ai_cachelist, max.level = 1)
List of 3
 $ countries_wb :'data.frame':	304 obs. of  14 variables:
 $ countries_idb:'data.frame':	26 obs. of  11 variables:
 $ indicators   :'data.frame':	19496 obs. of  11 variables:
```

## Dependencias
El agregador de indicadores utiliza las siguientes librerias de R:

   + **dplyr**, **tidyr** , **sqldf** y **gdata** se utilizan para manipular los datos (merge, join, agregar   columnas, filtrar, etc.)
   + **wbstats** , **WDI** se utilizan para conectarse con el API del Banco Mundial 
   + **httr** , **jsonlite** se utilizan para leer los resultados del llamodo a los distintos APIs    

Adicionalmente se utiliza otras librerias de github: 

   + 'EL-BID/Libreria-R-Numeros-para-el-Desarrollo' para conectarse con el [API del Banco Interamericano de Desarrollo](https://github.com/EL-BID/Libreria-R-Numeros-para-el-Desarrollo)
   + 'arcuellar88/govdata360R' para conectarse con el [API govdata360 del Banco Mundial](https://github.com/arcuellar88/govdata360R)

## Cómo contribuir y Código de conducta 

A este repositorio no se le está dando actualmente mantenimiento. Si estás interesado en contribuir al repositorio, ya sea agregando fuentes de datos nuevas, dando mantenimiento o solucionando bugs, escríbenos a code.iadb.org.

[CONTRIBUTING link](https://github.com/EL-BID/Agregador-de-indicadores/blob/master/CONTRIBUTING.md)

Algunas áreas de mejora de esta librería son:
1. Agregar filtros a la búsqueda de indicadores
2. Verificar duplicados entre distintas fuentes de información
3. Mejorar el tiempo de carga par World Bank (reduciendo el número de llamadas al api)[link](https://groups.google.com/forum/#!topic/world-bank-api/n0gOPdoh64o) 

## Autor/es
---
[Alejandro Rodríguez Cuéllar](https://github.com/arcuellar88)

## Licencia 
---
El software de este repositorio está licenciado bajo una licencia [GNU General Public License v3.0](https://github.com/EL-BID/Agregador-de-indicadores/blob/master/LICENSE).

La documentación de soporte y uso, incluyendo este archivo README.md y el contenido en la carpeta "examples" está licenciado bajo la licencia Creative Commons. 

## Referencias

Esta herramienta está basada en las siguientes dos herramientas:

+ [wbstats](https://github.com/GIST-ORNL/wbstats) de Jesse Piburn
+ [WDI](https://github.com/vincentarelbundock/WDI) de Vincent Arel-Bundock
