###Transformar os ficheiros da CAOP de 2011 num só geojson
###https://www.dgterritorio.gov.pt/cartografia/cartografia-tematica/caop?language=en

#Ir ao site da DGT e fazer download das áreas administrativas Continente, Madeira e Açores

#Importar shapefiles
CAOP2011continente = st_read("CAOP/2011/Cont_AAD_CAOP2011.shp", options = "ENCODING=WINDOWS-1252")
CAOP2011madeira = st_read("CAOP/2011/ArqMadeira_AAd_CAOP2011.shp", options = "ENCODING=WINDOWS-1252")
CAOP2011acores1 = st_read("CAOP/2011/ArqAcores_GOriental_AAd_CAOP2011.shp", options = "ENCODING=WINDOWS-1252")
CAOP2011acores2 = st_read("CAOP/2011/ArqAcores_GCentral_AAd_CAOP2011.shp", options = "ENCODING=WINDOWS-1252")
CAOP2011acores3 = st_read("CAOP/2011/ArqAcores_GOcidental_AAd_CAOP2011.shp", options = "ENCODING=WINDOWS-1252")

#mudar as colunas "Ilha" para "Distrito" para ficar uniforme
names(CAOP2011madeira)[1] = "DISTRITO"
names(CAOP2011acores1)[1] = "DISTRITO"
names(CAOP2011acores2)[1] = "DISTRITO"
names(CAOP2011acores3)[1] = "DISTRITO"

#variaveis Municipio e Freguesia em maiúsculas
names(CAOP2011madeira)[6] = "FREGUESIA"
names(CAOP2011madeira)[7] = "MUNICIPIO"
names(CAOP2011acores2)[6] = "FREGUESIA"
names(CAOP2011acores2)[7] = "MUNICIPIO"
names(CAOP2011acores3)[6] = "FREGUESIA"
names(CAOP2011acores3)[7] = "MUNICIPIO"


#Projectar tudo em WGS84
CAOP2011continente = st_transform(CAOP2011continente, 4326)
CAOP2011madeira = st_transform(CAOP2011madeira, 4326)
CAOP2011acores1 = st_transform(CAOP2011acores1, 4326)
CAOP2011acores2 = st_transform(CAOP2011acores2, 4326)
CAOP2011acores3 = st_transform(CAOP2011acores3, 4326)

#Unir num só ficheiro
CAOP2011 = rbind(CAOP2011continente, CAOP2011madeira, CAOP2011acores1, CAOP2011acores2, CAOP2011acores3)

#Exportar em GeoJSON
st_write(CAOP2011[,c(1:3,5,8)], "CP7/CP4 Portugal/CAOP2011.geojson")
saveRDS(CAOP2011[,c(1:3,5,8)], "CP7/CP4 Portugal/CAOP2011.Rds")

#Disponibilizar no github CP7/CP4 Portugal - teve de ser em Rds, porque o geojson tinha mais de 100MB (155MB)

rm(CAOP2011continente, CAOP2011madeira, CAOP2011acores1, CAOP2011acores2, CAOP2011acores3)
