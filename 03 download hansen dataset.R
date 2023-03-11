
# Clases Jhoan Martinez
# Marzo 9 2023
# Objetivo, descarga datos de Hansen y creacion de capas
# de bosque no bosque desde el anio 2000 hasta el 2021

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

loss <- extr[[2]]

# Binarization (Forest/No Forest)
thrs <- threshold_gfc(gfc = extr)
raster::writeRaster(x = thrs, filename = 'data/tif/hansen/thr_2021/threshold_v1.tif', overwrite = T)

# Masking -----------------------------------------------------------------
thrs <- terra::rast(thrs)
thrs <- terra::mask(thrs, vect(dpto))

terra::writeRaster(x = thrs, filename = 'data/tif/hansen/thr_2021/threshold_v2.tif') ## rall <- c(r1, r2, r3) # Make a stack (IDEAM, i.e.,)

# Read the results --------------------------------------------------------
thrs <- terra::rast('data/tif/hansen/thr_2021/threshold_v2.tif')

loss <- thrs[[2]]
bqnb <- list()

# thrs_crop <- thrs
# thrs_crop <- terra::crop(thrs, mpio[mpio$MPIO_CNMBR == 'ACACÍAS',])
# thrs_crop <- terra::mask(thrs_crop, mpio[mpio$MPIO_CNMBR == 'ACACÍAS',])

# loss <- thrs_crop[[2]]

loss <- thrs[[2]]
bqnb <- list()
bqnb[[1]] <- thrs[[1]]
bqnb[[1]][which.lyr(loss == 1)] <- 0
names(bqnb[[1]]) <- 'bqnb_2001'

for(i in 2:21){
  
  cat('Processing: ', i + 2000, '\n')
  bqnb[[i]] <- bqnb[[i-1]]
  bqnb[[i]][which.lyr(loss == i)] <- 0
  
}

class(bqnb)
bqnb <- do.call('c', bqnb)
names(bqnb) <- glue('bqnb_{2001:2021}')
plot(bqnb)
animate(bqnb, pause=0.25)

bqnb <- c(thrs[[1]], bqnb)
names(bqnb[[1]]) <- 'bqnb_2000'

terra::writeRater(x = bqnb, filename = 'ha')


