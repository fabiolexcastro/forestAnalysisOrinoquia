

# Clases Jhoan Martinez
# Febrero 25 - 2023 
# Objetivo, computar el área de bosque y no bosque para los municipios de la Orinoquia

# Load libraries ----------------------------------------------------------
require(pacman)
pacman::p_load(terra, sf, fs, tidyverse, glue, crayon)

g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

# Load data ---------------------------------------------------------------
path <- 'data/tif/ideam/orinoquia'
fles <- dir_ls(path, regexp = '.tif$')

# Administrative data
dpto <- vect('data/gpk/dpto_zone.gpkg')
mpio <- vect('data/gpk/mpio_zone.gpkg')

# Function to get the statistics (count) ----------------------------------
make_count <- function(fle){
  
  # Proof 
  # fle <- fles[1]
  
  cat('... Processing: ', basename(fle), '\n')
  rst <- terra::rast(fle)
  yea <- parse_number(basename(fle))
  
  # Process to get the frequency for each municipality
  rsl <- purrr::map_dfr(.x = 1:nrow(mpio), .f = function(i){
    
    # Select and project the municipality shapefile
    mpo <- mpio[i,]
    mpo <- terra::project(mpo, crs(rst))
    
    # Extract by mask
    trr <- terra::crop(rst, mpo)
    trr <- terra::mask(trr, mpo)
    
    # Get the frequency
    frq <- freq(trr)
    frq <- as_tibble(frq)
    
    # Resolution 
    res <- res(trr)
    are <- res[1] * res[2]
    are <- are / 10000
    
    # Add the hectares field
    frq <- mutate(frq, has = count * are)
    frq <- mutate(frq, MPIO_CCNCT = mpo$MPIO_CCNCT)
    frq <- dplyr::select(frq, MPIO_CCNCT, category = value, has)
    
    # Finish
    cat('Finish!\n')
    Sys.sleep(3)
    return(frq)
    
  })
  
  # To write the table
  out <- 'data/tbl/ideam'
  rsl <- mutate(rsl, category = gsub('Sin Informaci\xf3', 'Sin informacion', category))
  rsl <- mutate(rsl, year = yea)
  nme <- gsub('.tif', '.csv', basename(fle))
  rsl <- relocate(rsl, MPIO_CCNCT, year, category, has)
  write.csv(rsl, file = glue('{out}/freq_{nme}'), row.names = FALSE)
  
  # Finish
  cat('Finish all-----\n')
  return(rsl)
  
}

# Apply the function make_count -------------------------------------------
rslt <- map(.x = fles, .f = make_count)

# Apply the function make_count -------------------------------------------
rslt <- map(.x = fles, .f = make_count)
rslt <- bind_rows(rslt)
write.csv(rslt, 'data/tbl/ideam/freq_bqnbq_allyears.csv', row.names = FALSE)




