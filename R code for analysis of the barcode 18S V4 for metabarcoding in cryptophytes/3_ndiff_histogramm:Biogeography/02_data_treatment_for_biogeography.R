library(dplyr)
library(tidyr)

#sub the taxonomy 
datatara$taxoplot<-sub(pattern = "^.+Cryptophyceae\\|",replacement="",datatara$taxonomy) %>%
  sub(pattern = "Cryptomonadales\\|(g:)*|g:",replacement="") %>%
  sub(pattern = "\\|.+$",replacement="")

#pivot to have the variable "sample" in rows (we are kind of building a contingency table)
dataLONG <-pivot_longer(datatara,starts_with("BZ"), names_to = "sample", values_to = "nb_reads")
dataLONG<-dataLONG%>%
  group_by(sample,taxoplot)%>%
  summarise(nb_reads =sum(nb_reads))
#merge with the data that contains latitude and longitude of the sample stations
datamerge<- merge(datacontext,dataLONG)%>%subset(nb_reads !=0)
#get the taxonomy as columns
datawide <- spread(datamerge, taxoplot, nb_reads, fill = 0) %>% group_by(sample)
