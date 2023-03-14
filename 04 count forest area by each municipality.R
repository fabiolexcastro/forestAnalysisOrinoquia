
# Clases Jhoan Martinez
# Marzo 13 2023
# Objetivo, conteo de area de bosque y no bosque desde 
# el año 2000 hasta el año 2021 por cada municipio

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, sf, fs, tidyverse, glue, crayon, gfcanalysis)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

# Function ----------------------------------------------------------------
make_count <- function(cde){
  
  # cde <- cdes[1]
  
  cat('... Processing: ', cde, '\n')
  
  # Filter
  mpo <- mpio[mpio$MPIO_CCNCT == cde,] # mpo[,c('MPIO_CNMBR', 'DPTO_CNMBR')] #columns
  
  # Extracción por máscara
  frs <- terra::crop(bqnb, mpo)
  frs <- terra::mask(frs, mpo)
  
  # To project
  mpo_prj <- terra::project(mpo, proj)
  frs_prj <- terra::project(frs, proj)
  
  # Resolucion espacial
  res <- terra::res(frs_prj)[1] * terra::res(frs_prj)[2]
  res <- res / 10000
  
  frqn <- purrr::map(.x = 1:nlyr(frs_prj), .f = function(i){
    
    cat('Processing: ', names(frs_prj[[i]]), '\t')
    rst <- frs_prj[[i]]
    frq <- freq(rst)
    frq <- inner_join(frq, tibble(value = c(0, 1), clase = c('Bosque', 'No bosque')))
    frq <- dplyr::select(frq, clase, count)
    frq <- mutate(frq, MPIO_CCNCT = cde)
    frq <- mutate(frq, area_frs_ha = count * res)
    frq <- mutate(frq, anio = parse_number(names(rst)))
    frq <- dplyr::select(frq, MPIO_CCNCT, anio, clase, area_frs_ha)
    cat('Finish!\n')
    return(frq)
    
  })
  
  frqn <- bind_rows(frqn)
  
  frqn <- frqn %>% 
    group_by(MPIO_CCNCT, anio) %>% 
    mutate(porc_frs = area_frs_ha / sum(area_frs_ha) * 100) %>% 
    ungroup()
  
  cat('Finish!!!\n')
  return(frqn)
  
}

# Cargar data -------------------------------------------------------------
bqnb <- terra::rast('data/tif/hansen/thr_2021/bqnb_2000_2021.tif')
dpto <- vect('data/gpk/dpto_zone.gpkg')
mpio <- vect('data/gpk/mpio_zone.gpkg')

cdes <- mpio$MPIO_CCNCT

# Sistema de coordenadas plano
proj <- '+proj=tmerc +lat_0=4.59620041666667 +lon_0=-77.0775079166667 +k=1 +x_0=1000000 +y_0=1000000 +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs +type=crs'

# Contar area bsoque no bosque por anio -----------------------------------
rslt <- map(cdes, make_count)
rslt <- bind_rows(rslt)

write.csv(rslt, 'data/tbl/hansen/forest_noforest_mpio.csv', row.names = FALSE)




