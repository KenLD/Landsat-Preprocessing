##
## Projekt Umweltwissenschaften - Ken Mauser
## Script to analyse Dataquality
## Landsat Data
##

# Set WD
setwd("C:/Users/Ken Mauser/Desktop/Studium Landau/Projekt Umweltwissenschaften")

# Load required packages
require(RStoolbox)
require(raster)



# read the Metadata
meta2013 <- readMeta("Landsat/LC81910242013304LGN00_MTL.txt")


# Summary of the Metadata
# optional str(meta2012)
summary(meta2013)

# stackMeta as Path and Row
p191r24_2013 <- stackMeta(meta2013)

# ----------------- Data Conversion -------------------

# Convert the DNs to top-Atmosphere-radiance

# Extraction

dn2rad <- meta2013$CALRAD
dn2rad

# Auf einzelne Bänder übertragen

p191r24_2013_rad <- p191r24_2013 * dn2rad$gain + dn2rad$offset

# Datatype changed

dataType(p191r24_2013[[1]])
dataType(p191r24_2013_rad[[1]])

p191r24_2013_rad

# Solar irradiation (apparent reflectance calculation)

p191r24_2013_ref <- radCor(p191r24_2013_rad, metaData = meta2013, method = "apref")
plot(p191r24_2013_ref)


# ----------------- Pre-Processing ---------------

#Atmospheric Correction

haze <- estimateHaze(p191r24_2013, darkProp = 0.01, hazeBand = c("B1_dn", "B2_dn", "B3_dn", "B4_dn"))

#sdos-Methode

p191r24_2013_sdos <- radCor(p191r24_2013, metaData = meta2013, hazeValues = haze, 
                               hazeBands = c("B1_dn", "B2_dn", "B3_dn", "B4_dn"), method = "sdos")
#DOS-Methode
c_dos <- radCor(p191r24_2013_ref, metaData = meta2013, darkProp = 0.01, method = "dos")

#Topographic Illumination Correction # DEM needed
#dem <- raster("Landsat/srtm_dem.tif")
#p191r24_2013_cdr_ilu <- topCor(p191r24_2013, dem = dem, metaData = meta2013, method = "C")

#Cloud-Masking
cmask <- cloudMask(p191r24_2013_sdos, threshold = 0.7, buffer = 3, blue = "B1_dn", tir = "B6_dn")
plot(cmask)

#Shadow-Masking
shadow <- cloudShadowMask(p191r24_2013_sdos, cmask)



