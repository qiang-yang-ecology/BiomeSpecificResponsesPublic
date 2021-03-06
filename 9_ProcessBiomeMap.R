outDir <- "9_ProcessBiomeMap/"

dataDir <- "0_data"
dummyRasDir <- "7_CalculateClimateDeltas/"

sink(file = paste0(outDir,"log.txt"))

t.start <- Sys.time()

print(t.start)

suppressMessages(suppressWarnings(library(sp)))
suppressMessages(suppressWarnings(library(rgdal)))
suppressMessages(suppressWarnings(library(maptools)))
suppressMessages(suppressWarnings(library(raster)))

print(sessionInfo())

behrCRS <- CRS('+proj=cea +lon_0=0 +lat_ts=30 +x_0=0 +y_0=0 +datum=WGS84 +ellps=WGS84 +units=m +no_defs')

dummyRas <- raster(paste0(dummyRasDir,"DeltaTemp_85_2070.tif"))

projection(dummyRas) <- behrCRS

ecoregionMap <- rgdal::readOGR(dsn = dataDir,layer = "tnc_terr_ecoregions",verbose = FALSE)

biomeMap <- maptools::unionSpatialPolygons(SpP = ecoregionMap,IDs = ecoregionMap$WWF_MHTNUM)

biomeMap <- sp::spTransform(x = biomeMap,CRSobj = behrCRS)

biomeRas <- raster::rasterize(
  x = biomeMap,y = dummyRas,
  field = as.numeric(names(biomeMap)))

raster::writeRaster(
  x = biomeRas,filename = paste0(outDir,"BiomeRaster.tif"),
  format="GTiff")

t.end <- Sys.time()

print(round(t.end - t.start,0))

sink()