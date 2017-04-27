##
## Projekt Umweltwissenschaften - Ken Mauser
## Script zur Analyse der Datenqualitaet
## Daten von Planet.Labs
##

# Arbeitsverzeichnis setzen
setwd("C:/Users/Ken Mauser/Desktop/Studium Landau/Projekt Umweltwissenschaften")

# Lade noetige Pakete
require(RStoolbox)
require(raster)



# Einlesen der Meta-Daten
meta2013 <- readMeta("Landsat/LC81910242013304LGN00_MTL.txt")


#Überblick über die Meta-Daten, 
#optional str(meta2012)
summary(meta2013)

# stackMeta nach Path und Row
p191r24_2013 <- stackMeta(meta2013)

# ----------------- Data Conversion -------------------

# Konvertieren der DNs zur top-Atmosphere-radiance

# Extraktion der Umkehrungsparameter

dn2rad <- meta2013$CALRAD
dn2rad

# Auf einzelne Bänder übertragen

p191r24_2013_rad <- p191r24_2013 * dn2rad$gain + dn2rad$offset

# Dateityp hat sich nun verändert

dataType(p191r24_2013[[1]])
dataType(p191r24_2013_rad[[1]])

p191r24_2013_rad

# Einbringen der solar irradiation (apparent reflectance berechnen)

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

#Topographic Illumination Correction # DEM deckt nicht kompletten Bereich ab
#dem <- raster("Landsat/srtm_dem.tif")
#p191r24_2013_cdr_ilu <- topCor(p191r24_2013, dem = dem, metaData = meta2013, method = "C")

#Cloud-Masking
cmask <- cloudMask(p191r24_2013_sdos, threshold = 0.7, buffer = 3, blue = "B1_dn", tir = "B6_dn")
plot(cmask)

#Shadow-Masking
shadow <- cloudShadowMask(p191r24_2013_sdos, cmask)



