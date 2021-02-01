# CP7
Portuguese zip codes with coordinates  
_Códigos Postais de Portugal, georreferenciados_

* List of 9250 CP7 of Lisbon region, with Latitude and Longitude. [txt file separated with tab](https://github.com/temospena/CP7/blob/master/CP7%20Lisbon/CP7georreferenciadosLisboa.txt) || [shapefile](https://github.com/temospena/CP7/blob/master/CP7%20Lisbon/CP7LisboaGeorreferenciados_shapefile.rar)  
* List of __198.000__ CP7 of Portugal cleaned, with Latitude and Longitude. [txt file separated with tab](https://github.com/temospena/CP7/blob/master/CP7%20Portugal/CP7_CTT_PortugalNov2019.txt) || [shapefile](https://github.com/temospena/CP7/blob/master/CP7%20Portugal/CP7PortugalGeorreferenciados_shapefile.rar)   > _This one is more up to date._
* List of __316.129__ CP7, with all the adresses, but repeated CP7 [Rds file](https://github.com/temospena/CP7/blob/master/CP7%20Portugal/CP7_CTT_Portugal.Rds) > _This os from the CTT list_
* __CP4 polygons__ of their cover areas, estimated by their districts, sections and statistic sub-sections, for the Continent and Archipelagos. [shapefile](https://github.com/temospena/CP7/blob/master/CP4%20Portugal) || [R script](https://github.com/temospena/CP7/blob/master/CP4%20Portugal/CP4_poligonos.R) to produce them

## About
The portuguese CP (zip code) is made by a combination of 4 + 3 digits.  
The first 4 digits have a correspondence of an area, normaly equivalent to the old districts (Freguesias pré 2014), or districts together.
For example, Arroios can be 1000, 1150 or 1170. The Parque das Nações and Moscavide can be 1990 or 1998 :blush:

![Aproximation of CP4, for Lisbon](https://github.com/temospena/CP7/blob/master/CP4%20Lisbon/CP_Lisboa4_update.PNG)

All those who start with 1000 are from Lisbon and its surroundings. Those CP4 ending in 1, 6 or 9, are normally for commercial, institutional, or compannies addresses, and they do not hold an own area of influence.  
The last 3 digits (CP7) indicate a street or street segment (edge of a block), a __point__ in the middle of that street segment.  
The coordinates of this point that can be extracted, giving a very approximate location of the actual address.  

An aproximated influence area of Lisbon's CP7, using [Voronoi](https://en.wikipedia.org/wiki/Voronoi_diagram) for the CP7 point coordinates, is this:
![Voronoi with centroids](https://github.com/temospena/CP7/blob/master/CP7%20Lisbon/VoronoyCP7lisboa.jpg)

The estimated CP4 areas for Portugal, matched with administrative areas, looks like this:
![Matched areas](https://github.com/temospena/CP7/blob/master/CP4%20Portugal/CP4_EstimativaPoligonos.PNG)  
(_Altough some holes are pretty obvious, it would require some non-automatized process to fill them without redundance_)

## Sources
This compilation was made by [Rosa Félix](https://fenix.tecnico.ulisboa.pt/homepage/ist155593/gis).
The sources used were:
*  The Comercial database for Lisbon 2009 [Geodados](http://geodados.cm-lisboa.pt/datasets/recenseamento-comercial-2009), with the atitmetic average of lat and long for each CP7
*  A personal colection of insittutional CP7 - the ones that end with xx49, such as universities and companies
*  List of all CP7, fom the CTT website [CTT - registeration required](https://www.ctt.pt/feapl_2/app/restricted/postalCodeSearch/postalCodeDownloadFiles.jspx)
*  SQL file from [github.com/cusco/ctt](https://github.com/cusco/ctt) with lat/long computed :+1:

