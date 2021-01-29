# Match CP4 with Freguesias
library(tidyverse)
library(sf)
library(mapview)


#ler os ficheiros do github
u = "https://github.com/temospena/CP7/raw/master/CP7%20Portugal/CP7_CTT_Portugal.Rds"
CP7_CTT_PortugalNov2019 = readRDS(url(u, "rb"))
uu = "https://github.com/temospena/CP7/raw/master/CP4%20Portugal/CAOP2011.Rds"
CAOP2011 = readRDS(url(uu, "rb"))

colnames(CP7_CTT_PortugalNov2019)
#as coordenadas estão em WGS84

#transformar em shapefile de pontos
CTT_pontos = st_as_sf(CP7_CTT_PortugalNov2019, coords = c("Long", "Lat"), crs = 4326)

CTT_pontos$CP4 = factor(CTT_pontos$CP4) #colocar como variáve não-contínua
length(unique(CTT_pontos$CP4)) #737 CP4

#remover os CP7 de particulares/empresas (normalmente terminam em 1, 4 ou 9)
CTT_pontos = CTT_pontos %>% filter(is.na(Cliente))
length(unique(CTT_pontos$CP4)) #507 CP4 no país

#ver uma maostra
pal= RColorBrewer::brewer.pal(9,"Set1") #palete de corres divergente, para melhor visualização
mapview::mapview(CTT_pontos[CTT_pontos$Distrito=="Aveiro",], zcol="CP4", col.regions = pal) #ver como se agrupam os de Aveiro
#como se vê, há 2 pontos que ficaram mal georeferenciados


### Processo iterativo ###
# 1. Tentar polígonos de freguesias antigas (menores)
# 2. As que não forem inequívocas, tentar com secções estatísticas do INE
# 3. As que não forem inequívocas, tentar com as sub-secções estatísticas (BGRI)
# 4. Juntar todas no final e "dissolver" limites.


## 1. tentar com as antigas freguesias, com áreas menores: comparar com o CAOP anterior a 2013.
CAOP2011 = readRDS("CP7/CP4 Portugal/CAOP2011.Rds")
mapview(CTT_pontos[CTT_pontos$Concelho=="Aveiro",], zcol="CP4", col.regions = pal) + 
  mapview(CAOP2011[CAOP2011$MUNICIPIO=="AVEIRO",], zcol = "FREGUESIA")


#Fazer um join entre os CP4 e as Freguesias
CP4freg = CAOP2011 %>% st_join(CTT_pontos) %>%
  select(CP4, DICOFRE, FREGUESIA, MUNICIPIO, DISTRITO, geometry)

table(is.na(CP4freg$CP4)) #há 1142 que ficaram sem CP?

#summarize nas Freguesias cada CP4 e contar
class(CP4freg)
CP4freg$geometry = NULL #remover geometria das freguesias, para o processamento ser mais rápido
CP4freg = CP4freg %>% group_by(CP4, DICOFRE) %>% summarize(count = n())

#filtrar pelos as Freguesias com mais CP4 iguais
FREGmaisum = CP4freg %>% group_by(DICOFRE) %>% summarize(CPs = n())
table(FREGmaisum$CPs)
# 1     2     3     4    5    6 
# 3973  231   38   12    4    2 
#significa que há 287 freguesias com mais do que 1 código postal

#este exemplo mostra que uma freguesia pode ter mais que um CP4
mapview(CTT_pontos[CTT_pontos$CP4=="1050",], zcol = "CP4") + mapview(CAOP2011[CAOP2011$MUNICIPIO=="LISBOA",], zcol = "FREGUESIA")

###ficar com as freguesias com um só CP4
FREGuna = CP4freg %>% filter(DICOFRE %in% FREGmaisum$DICOFRE[FREGmaisum$CPs ==1])

#polígonos de CP4 com base nas antigas freguesias
CP4poligonos = CAOP2011 %>% filter(DICOFRE %in% FREGuna$DICOFRE) %>% left_join(FREGuna) %>% select(CP4, geometry)
mapview(CP4poligonos)

#dissolver as freguesias, ficando só com zonas
CP4zonas = CP4poligonos %>% group_by(CP4) %>% summarise(do_union = T) #457. faltam as restantes 50
mapview(CP4zonas, zcol="CP4")


##2. para as freguesias com mais de um CP4, comparar com as secções estatísticas do INE
FREGmulti = CP4freg %>% filter(DICOFRE %in% FREGmaisum$DICOFRE[FREGmaisum$CPs >1])

#INEbgri: ver como compilar as BGRI do INE2011 para todo o territorio, em "convert_CP4-Freguesias.R"

#Ficar com uma shp mais leve, só com as BGRI das Freguesias com CP4 >1
INEbgri$DICOFRE = paste0(INEbgri$DTMN11, INEbgri$FR11)
INEbgrimulti = INEbgri %>% filter(DICOFRE %in% FREGmulti$DICOFRE)

#voltar a fazer o interssect
CP4bgri = INEbgrimulti %>% st_join(CTT_pontos) %>% select(CP4, BGRI11, SEC11, DICOFRE, geometry)
#summarize nas SecoesEstatisticas cada CP4 e contar
class(CP4bgri)
CP4bgri$geometry = NULL #remover geometria 
CP4sec = CP4bgri %>% group_by(CP4, SEC11, DICOFRE) %>% summarize(count = n())
CP4sec$DICSEC = paste0(CP4sec$DICOFRE, CP4sec$SEC11) #para ter um campo unico entre o DICOFRE e o BGRI

#filtrar pelas SS com mais CP4 iguais
SSmaisum = CP4sec %>% group_by(DICSEC, SEC11, DICOFRE) %>% summarize(CPs = n())
table(SSmaisum$CPs)
# 1    2    3    4    5 
# 1560 3382  317   11    1 
#significa que só 1560 SS têm 1 código postal inequivoco

###ficar com as Secçõescom um só CP4
SECuna = CP4sec %>% filter(DICSEC %in% SSmaisum$DICSEC[SSmaisum$CPs ==1])

#polígonos de CP4 com base nas SecçõesEstatisticas
INEbgrimulti$DICSEC = paste0(INEbgrimulti$DICOFRE, INEbgrimulti$SEC11)
CP4poliSEC = INEbgrimulti %>% filter(DICSEC %in% SECuna$DICSEC )%>% left_join(SECuna) %>%
  select(CP4, geometry) %>% group_by(CP4) %>% summarise(do_union = T)
mapview(CP4poliSEC)


##3. por fim, tentar as BGRI
CP4bgri = CP4bgri %>% group_by(CP4, BGRI11, DICOFRE) %>% summarize(count = n())

#filtrar pelas SS com mais CP4 iguais
BGRImaisum = CP4bgri %>% group_by(BGRI11, DICOFRE) %>% summarize(CPs = n())
table(BGRImaisum$CPs)
# 1     2     3 
# 43884   338     1 
#significa que só 43884 BGRI têm 1 código postal inequivoco

###ficar com as BGRI um só CP4
BGRIuna = CP4bgri %>% filter(BGRI11 %in% BGRImaisum$BGRI11[BGRImaisum$CPs ==1])



#polígonos de CP4 com base nos BGRI
CP4poliBGRI = INEbgrimulti %>% filter(BGRI11 %in% BGRIuna$BGRI11 )%>% left_join(BGRIuna) %>%
  select(CP4, geometry) %>% group_by(CP4) %>% summarise(do_union = T)
mapview(CP4poliBGRI)


###4. juntar todas e "dissolver" as fronteiras
##juntar os BGRI às SS
CP4polismall = rbind(CP4poliSEC, CP4poliBGRI) %>% group_by(CP4) %>% summarise(do_union = T)

##juntar grandes com pequenos
CP4zonasALL = rbind(CP4zonas, CP4polismall) %>% group_by(CP4) %>% summarise(do_union = T)
CP4zonasALL= na.omit(CP4zonasALL)  #ficam 507! bate certo com o suposto.
mapview(CP4zonasALL, zcol="CP4")

#rewmover buracos
area_thresh <- units::set_units(5, km^2) #5km2 máx
CP4zonasALL = smoothr::fill_holes(CP4zonasALL, threshold = area_thresh)
mapview(CP4zonasALL, zcol="CP4")

#ainda assim há várias partes do ferritório que não estão cobertas.
# Talvez porque o CP seja uma espécie de centroide, que não calha em nenhuma freguesia menos populada.
# Ver o exemplo de Sagres ou de Sines, que é óbvio qual o CP4 da terra de ninguém.

###exportar para shapefile###
st_write(CP4zonasALL, "CP7/CP4 Portugal/CP4_EstimativaPoligonos.shp")
