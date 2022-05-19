library(ggplot2)
library(maps)
library(scatterpie)

#import a world map 
world <- map_data('world')

#create the scatterpie plot overlaid on the map
mapphyto<- ggplot(world, aes(x = long, y = lat, group = group)) +
  geom_polygon(fill="lightgray", colour = "lightgray") +
  theme_classic()+
  coord_fixed()+
  geom_scatterpie(aes(x=longitude, y=latitude, group = sample),
                  data=datawide, cols=colnames(datawide)[5:10], color=NA, alpha=0.8)+
  coord_equal()+
  scale_y_continuous("latitude")+
  scale_x_continuous("longitude")+
  scale_fill_brewer(palette = "Set1")

#export to png
png("mapphyto2.png", units = "in",width=10, height=6, res = 600)
mapphyto
dev.off()