library(data.table)

# Import the ASV table
data_asvs <- fread("data/tara_data_asv_table.tsv.gz")

# Import description of unique V4 reference sequences
data_nodes <- fread("data/crypto_seq_unique_bis.tsv")

# Extract correspodence between MST ids and references id
data_nodes_tmp <- data_nodes[,list(Id,ids)]
setnames(data_nodes_tmp,c("id","ref"))
data_nodes_tmp <- data_nodes_tmp[,.(ref=strsplit(ref,split = ",") |> unlist()),
                                 by=id]

# Extract ndiif between ASVs and references
data_asvs_tmp <- data_asvs[,.(ref=strsplit(references,split = ",") |> unlist()),
                           by=list(amplicon,ndiff)]

# Merge the two table to have the ndiff between ASVs and MST ids
data_add_to_mst <- merge(data_asvs_tmp,data_nodes_tmp,by="ref")
data_add_to_mst <- data_add_to_mst[,list(amplicon,id,ndiff)] |> unique()

# add a column in the description of references
# which ones are strictly identitcals to ASVs
tmp <- data_add_to_mst[ndiff==0]
perfect_match <- tmp[,amplicon]
names(perfect_match) <- tmp[,id]
data_nodes[,env_seq:=perfect_match[Id]]

# keep only ndiff > 0 to add to the MST
data_add_to_mst <- data_add_to_mst[ndiff>0]

# export
fwrite(data_add_to_mst,
       file = "outputs/add_to_MST.tsv",
       sep="\t",
       quote=FALSE,
       col.names = FALSE)

fwrite(data_nodes,
       file = "outputs/crypto_seq_unique_with_envseq.tsv",
       sep="\t",
       quote=FALSE)