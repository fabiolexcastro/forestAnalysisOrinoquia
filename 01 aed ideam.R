
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
dpto <- vect('G:/D/data/IGAC/MGN2018_MPIO_POLITICO/MGN_MPIO_POLITICO.shp')
mpio <- vect('G:/D/data/IGAC/MGN2018_DPTO_POLITICO/MGN_DPTO_POLITICO.shp')

# Study area
dpto.zone <- dpto[dpto$DPTO_CNMBR %in% c('VICHADA', 'META', 'CASANARE', 'ARAUCA'),]
mpio.zone <- mpio[mpio$DPTO_CNMBR %in% c('VICHADA', 'META', 'CASANARE', 'ARAUCA'),]

# Write the study area
dir_create('data/gpk')
writeVector(dpto.zone, 'data/gpk/dpto_zone.gpkg')
writeVector(mpio.zone, 'data/gpk/mpio_zone.gpkg')

# IDEAM Data













