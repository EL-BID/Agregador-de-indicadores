% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ai.R
\name{ai}
\alias{ai}
\title{Download data from indicators of the from World Bank API, Numbers for Development API and No Celings}
\usage{
ai(country = "all", indicator, startdate = 2010, enddate = 2015,
  lang = c("en", "es", "fr", "ar", "zh"), meta = TRUE, cache)
}
\arguments{
\item{country}{List of countries. If \code{country} is unspecified,
'all' is the default.}

\item{startdate}{Start date of the requested date range of the indicator data}

\item{enddate}{End date of the requsted date range of the indicator data}

\item{lang}{Language in which to return the metadata of the indicators. If \code{lang} is unspecified,
english is the default.}

\item{cache}{Cache of the metadata of the indicators, countries and topics}
}
\value{
A data frame with the data of the indicator, countries and date range specified
}
\description{
Download data from indicators of the from World Bank API, Numbers for Development API and No Celings
}
\note{
Not all data returns have support for langauges other than english. Indicators from No Celings are only available in english. If the specific return
does not support your requested language by default it will return \code{NA}. For an enumeration of
supported languages by data source.
The options for \code{lang} are:
\itemize{
\item \code{en}: English
\item \code{es}: Spanish
}
}
\examples{
# Get the data for two indicators and all countries
ai(indicator = c("SOC_046","SL.UEM.TOTL.NE.ZS"))

#Get the data for two indicators and one country from 2000 until 2015
ai(indicator = c("CONTFEHQ","SOC_046","SL.UEM.TOTL.NE.ZS"),country = c("CO"),startdate = 2000,enddate = 2015)
}
