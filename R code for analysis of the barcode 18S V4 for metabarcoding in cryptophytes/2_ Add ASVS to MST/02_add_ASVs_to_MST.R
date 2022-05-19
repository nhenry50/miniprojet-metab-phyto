library(data.table)
library(dplyr)
library(tidyr)

# Extract correspodence between MST ids and references id
data_nodes_tmp <- data_nodes[,list(Id,ids)]
setnames(data_nodes_tmp,c("id","ref"))
data_nodes_tmp <- data_nodes_tmp[,.(ref=strsplit(ref,split = ",")%>%unlist()),
                                 by=id]

# Extract ndiff between ASVs and references
data_asvs_tmp <- data_asvs[,.(ref=strsplit(references,split = ",")%>%unlist()),by=list(amplicon,ndiff)]

# Merge the two table to have the ndiff between ASVs and MST ids
data_add_to_mst <- merge(data_asvs_tmp,data_nodes_tmp,by="ref")
data_add_to_mst <- data_add_to_mst[,list(amplicon,id,ndiff)]%>%unique()

# add a column in the description of references
# which ones are strictly identitcals to ASVs
tmp <- data_add_to_mst[ndiff==0]
perfect_match <- tmp[,amplicon]
names(perfect_match) <- tmp[,id]
data_nodes[,env_seq:=perfect_match[Id]]

# keep only ndiff > 0 to add to the MST
data_add_to_mst <- data_add_to_mst[ndiff>0]
#add the weight
data_add_to_mst[,Weight:=ndiff]
data_add_to_mst[Weight>50,Weight:=50]
data_add_to_mst[,Weight:=((max(Weight)+1)-Weight)]
data_add_to_mst[,Weight:=sqrt(Weight)]
data_add_to_mst[,Weight:=Weight/max(Weight)]

#import reference MST
mstrefs <- fread("MSTrefs.tsv", header = TRUE)
#merge reference file with metabarcoding file
MSTcomplete<- rbind(mstrefs, data_add_to_mst, use.names= FALSE)


#export the complete MST file
fwrite(MSTcomplete,
       file = "MSTcomplete.tsv",
       sep="\t",
       quote=FALSE,
       col.names = FALSE)


# export
fwrite(data_add_to_mst,
       file = "add_to_MST.tsv",
       sep="\t",
       quote=FALSE,
       col.names = FALSE)

#complete the informational table of the reference data with the infos of the added ASVs 

#complete the taxoplot column with the taxonomy assigned to the ASVs
data_asvs$taxoplot<-sub(pattern = "^.+Cryptophyceae\\|",replacement="",datatara$taxonomy) %>%
        sub(pattern = "Cryptomonadales\\|(g:)*|g:",replacement="") %>%
        sub(pattern = "\\|.+$",replacement="")

#build a new table with the number of sequences per node in the added ASVs (=1)
dataasvtmp<- select(data_asvs[ndiff !=0], c(amplicon,taxoplot))
dataasvtmp$n_taxos <- 1

dataasvtmp$taxolabel <- ""
setnames(dataasvtmp, "amplicon","Id")

#complete the column type with the found ASVs
dataasvtmp$type <- "env"
data_nodes[is.na(env_seq),type:="ref"]
data_nodes[!is.na(env_seq),type:="both"]
infocytoscape<- rbind(data_nodes[,list(Id, n_taxos, taxolabel, taxoplot, type)],
                      dataasvtmp) 


#export to tsv file -> use in cytoscape
fwrite(infocytoscape,
       file = "infoMSTcryptocomplete.tsv",
       sep="\t",
       quote=FALSE)



