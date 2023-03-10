

# Clases Jhoan Martinez
# Marzo 9 2023
# Objetivo, descarga datos de Hansen

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, sf, fs, tidyverse, glue, crayon, gfcanalysis)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------

# Administrative data
dpto <- vect('data/gpk/dpto_zone.gpkg')
mpio <- vect('data/gpk/mpio_zone.gpkg')

# To download -------------------------------------------------------------
dpto <- st_as_sf(dpto)
tles <- calc_gfc_tiles(aoi = dpto)
download_tiles(tiles = tles, output_folder = 'data/tif/hasen/raw_2021', dataset = 'GFC-2021-v1.9')
?download_tiles

# To extract by mask ------------------------------------------------------
extr <- extract_gfc(aoi = dpto, data_folder = 'data/tif/hansen/raw_2021', dataset = 'GFC-2021-v1.9')

# Binarization (Forest/No Forest)
thrs <- threshold_gfc(gfc = extr)









