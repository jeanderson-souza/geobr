library(RCurl)
library(stringr)
library(sf)
library(janitor)
library(dplyr)
library(readr)
library(parallel)
library(data.table)
library(xlsx)
library(magrittr)
library(devtools)
library(lwgeom)
library(stringi)

#> DATASET: Immediate Geographic Regions - 2017
#> Source: IBGE - https://www.ibge.gov.br/geociencias/organizacao-do-territorio/divisao-regional/15778-divisoes-regionais-do-brasil.html?=&t=o-que-e
#> scale 1:5.000.000 ?????????????
#> Metadata:
# Titulo: Regioes Geograficas Imediatas
# Titulo alternativo:
# Frequencia de atualizacao: decenal
#
# Forma de apresentacao: Shape
# Linguagem: Pt-BR
# Character set: Utf-8
#
# Resumo: Regioes Geograficas Imediadas foram criadas pelo IBGE em 2017 para substituir a micro-regioes
#
# Estado: Em desenvolvimento
# Palavras chaves descritivas:****
# Informacao do Sistema de Referencia: SIRGAS 2000

# Root directory
root_dir <- "L:////# DIRUR #//ASMEQ//geobr//data-raw"
setwd(root_dir)


# Directory to keep raw zipped files
setwd(root_dir)
dir.create("./immediate_regions")
setwd("./immediate_regions")


# Create folders to save clean sf.rds files
dir.create("./shapes_in_sf_cleaned", showWarnings = FALSE)




#### 0. Download original Immediate Regions data sets from IBGE ftp -----------------

ftp <- "ftp://geoftp.ibge.gov.br/organizacao_do_territorio/divisao_regional/divisao_regional_do_brasil/divisao_regional_do_brasil_em_regioes_geograficas_2017/shp/RG2017_rgi_20180911.zip"

download.file(url = ftp, destfile = "RG2017_rgi_20180911.zip")



########  1. Unzip original data sets downloaded from IBGE -----------------
unzip("RG2017_rgi_20180911.zip")





##### Rename columns -------------------------

# read data
temp_sf <- st_read("RG2017_rgi.shp", quiet = F, stringsAsFactors=F, options = "ENCODING=UTF8")

temp_sf <- dplyr::rename(temp_sf, code_immediate = rgi, name_immediate = nome_rgi) %>%
  dplyr::mutate(year = 2017,

                # code_state
                code_state = substr(code_immediate,1,2),

                # abbrev_state
                abbrev_state =  ifelse(code_state== 11, "RO",
                                ifelse(code_state== 12, "AC",
                                ifelse(code_state== 13, "AM",
                                ifelse(code_state== 14, "RR",
                                ifelse(code_state== 15, "PA",
                                ifelse(code_state== 16, "AP",
                                ifelse(code_state== 17, "TO",
                                ifelse(code_state== 21, "MA",
                                ifelse(code_state== 22, "PI",
                                ifelse(code_state== 23, "CE",
                                ifelse(code_state== 24, "RN",
                                ifelse(code_state== 25, "PB",
                                ifelse(code_state== 26, "PE",
                                ifelse(code_state== 27, "AL",
                                ifelse(code_state== 28, "SE",
                                ifelse(code_state== 29, "BA",
                                ifelse(code_state== 31, "MG",
                                ifelse(code_state== 32, "ES",
                                ifelse(code_state== 33, "RJ",
                                ifelse(code_state== 35, "SP",
                                ifelse(code_state== 41, "PR",
                                ifelse(code_state== 42, "SC",
                                ifelse(code_state== 43, "RS",
                                ifelse(code_state== 50, "MS",
                                ifelse(code_state== 51, "MT",
                                ifelse(code_state== 52, "GO",
                                ifelse(code_state== 53, "DF",NA))))))))))))))))))))))))))),
                # name_state
                name_state =  ifelse(code_state== 11, "Rondônia",
                              ifelse(code_state== 12, "Acre",
                              ifelse(code_state== 13, "Amazônia",
                              ifelse(code_state== 14, "Roraima",
                              ifelse(code_state== 15, "Pará",
                              ifelse(code_state== 16, "Amapá",
                              ifelse(code_state== 17, "Tocantins",
                              ifelse(code_state== 21, "Maranhão",
                              ifelse(code_state== 22, "Piauí",
                              ifelse(code_state== 23, "Ceará",
                              ifelse(code_state== 24, "Rio Grande do Norte",
                              ifelse(code_state== 25, "Paraíba",
                              ifelse(code_state== 26, "Pernambuco",
                              ifelse(code_state== 27, "Alagoas",
                              ifelse(code_state== 28, "Sergipe",
                              ifelse(code_state== 29, "Bahia",
                              ifelse(code_state== 31, "Minas Gerais",
                              ifelse(code_state== 32, "Espírito Santo",
                              ifelse(code_state== 33, "Rio de Janeiro",
                              ifelse(code_state== 35, "São Paulo",
                              ifelse(code_state== 41, "Paraná",
                              ifelse(code_state== 42, "Santa Catarina",
                              ifelse(code_state== 43, "Rio Grande do Sul",
                              ifelse(code_state== 50, "Mato Grosso do Sul",
                              ifelse(code_state== 51, "Mato Grosso",
                              ifelse(code_state== 52, "Goiás",
                              ifelse(code_state== 53, "Distrito Federal",NA))))))))))))))))))))))))))),
                # code_region
                code_region = substr(code_immediate,1,1),

                # name_region
                name_region = ifelse(code_region==1, 'Norte',
                              ifelse(code_region==2, 'Nordeste',
                              ifelse(code_region==3, 'Sudeste',
                              ifelse(code_region==4, 'Sul',
                              ifelse(code_region==5, 'Centro Oeste', NA))))))
# reorder columns
temp_sf <- dplyr::select(temp_sf, 'code_immediate', 'name_immediate','code_state', 'abbrev_state',
                         'name_state', 'code_region', 'name_region', 'geometry')

# Convert columns from factors to characters
temp_sf %>% dplyr::mutate_if(is.factor, as.character) -> temp_sf

# Harmonize spatial projection CRS, using SIRGAS 2000 epsg (SRID): 4674
temp_sf <- if( is.na(st_crs(temp_sf)) ){ st_set_crs(temp_sf, 4674) } else { st_transform(temp_sf, 4674) }
st_crs(temp_sf) <- 4674

# Make any invalid geometry valid # st_is_valid( sf)
temp_sf <- lwgeom::st_make_valid(temp_sf)

# keep code as.numeric()
temp_sf$code_state <- as.numeric(temp_sf$code_state)



##### Save data -------------------------
readr::write_rds(temp_sf, path = "./shapes_in_sf_cleaned/immediate_regions_2017.rds", compress="gz" )




