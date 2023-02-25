

# Clases Jhoan Martinez
# Febrero 25 - 2023 
# Objetivo, cortar para los datos para el área de estudio del IDEAm

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, sf, fs, tidyverse, glue, crayon)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------

# Administrative data
mpio <- vect('G:/D/data/IGAC/MGN2018_MPIO_POLITICO/MGN_MPIO_POLITICO.shp')
dpto <- vect('G:/D/data/IGAC/MGN2018_DPTO_POLITICO/MGN_DPTO_POLITICO.shp')

# Study area
dpto.zone <- dpto[dpto$DPTO_CNMBR %in% c('VICHADA', 'META', 'CASANARE', 'ARAUCA'),]
mpio.zone <- mpio[mpio$DPTO_CNMBR %in% c('VICHADA', 'META', 'CASANARE', 'ARAUCA'),]

# Write the study area
dir_create('data/gpk')
writeVector(dpto.zone, 'data/gpk/dpto_zone.gpkg')
writeVector(mpio.zone, 'data/gpk/mpio_zone.gpkg')

# IDEAM Data
path <- 'data/tif/ideam/col'
fles <- dir_ls(path)
fles <- grep(paste0(c('.tif$', '.img$'), collapse = '|'), fles, value = T)
fles <- as.character(fles)

# Function to extract by mask  --------------------------------------------
extract_mask <- function(file, year){
  
  cat('... Start: ', year, '\n')
  
  # Start 
  rstr <- terra::rast(file)
  limt <- terra::project(dpto.zone, terra::crs(rstr))
  
  # Extract by mask 
  rstr <- terra::crop(rstr, limt)
  rstr <- terra::mask(rstr, limt)

  # Output folder 
  diro <- glue('data/tif/ideam/orinoquia')
  
  # To write 
  terra::writeRaster(x = rstr, filename = glue('{diro}/bqnbq_{year}.tif'), overwrite = TRUE)
  cat('Finish!\n')
  
}

# To apply the function extract by mask  ----------------------------------

# 2005
extract_mask(file = fles[3], year = 2005)

# 2010
extract_mask(file = fles[4], year = 2010)


















