
# Clases Jhoan Martinez
# Marzo 14 2023
# Objetivo, computar el área total agrícola para los mpios
# según EVA - Nacional

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, sf, fs, tidyverse, glue, crayon, gfcanalysis)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------
file <- dir_ls('data/tbl/eva', regexp = '.csv')
tble <- read_csv(file)
View(tble)

tble <- tble[,c(1:6, 9, 11)]
colnames(tble) <- c('cod_dpto', 'dpto', 'cod_mpio', 'mpio', 'crop', 'subgrupo', 'year', 'crop_ha')

write.csv(tble, 'data/tbl/eva_clean_col.csv', row.names = FALSE)

# Filtramos la tabla ------------------------------------------------------
sort(unique(tble$dpto))
subd <- filter(tble, dpto %in% c('ARAUCA', 'CASANARE', 'VICHADA', 'META'))
sort(unique(tble$year))




