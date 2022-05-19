library(data.table)
# Import the ASV table
data_asvs <- fread("tara_data_asv_table_ndiff.tsv")

# Import description of unique V4 reference sequences
data_nodes <-fread("crypto_seq_unique_bis.tsv")
