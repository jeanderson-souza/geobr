% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/lookup_muni.R
\name{lookup_muni}
\alias{lookup_muni}
\title{Lookup geographies information from a given municipality}
\usage{
lookup_muni(name_muni = NULL, code_muni = NULL)
}
\arguments{
\item{name_muni}{The municipality name to be looked up}

\item{code_muni}{The municipality code to be looked up}
}
\value{
A data.frame with 13 columns identifying the geographies information of that municipality
}
\description{
Input a municipality \strong{name} \emph{or} \strong{code} and get municipality information from referent state, meso, micro, intermediate, and immediate regions
}
\details{
Only available from 2010 Census data so far
}
\examples{
\donttest{
library(geobr)

# Get lookup table for municipality Rio de Janeiro
mun <- lookup_muni(name_muni = "Rio de Janeiro")

# Or you can get a lookup table for the same municipality searching for its code
mun <- lookup_muni(code_muni = 3304557)

}
}
