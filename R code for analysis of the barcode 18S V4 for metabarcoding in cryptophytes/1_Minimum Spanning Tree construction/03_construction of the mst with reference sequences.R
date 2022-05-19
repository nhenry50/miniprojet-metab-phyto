library(ape)
library(data.table)
library(dplyr)
library(seqinr)
# Import the fasta file with aligned sequences
sequences <- read.FASTA("crypto_seq_unique_align.fst")
names(sequences)


# Count the number of sites that differ
n_mut <- dist.dna(sequences,pairwise.deletion = TRUE,model = "N",as.matrix = TRUE)

# Count the number of insertion deletions
n_indel <- dist.dna(sequences,model = "indel",as.matrix = TRUE)

# Sum both to have the total number of differences
crypto_mst <- n_mut + n_indel

#mst(crypto_mst)
# replace by NA the distance of edges not selected by the mst
crypto_mst[mst(crypto_mst) == 0] <- NA

# replace by NA the lower triangle of the matrix
crypto_mst[lower.tri(crypto_mst)] <- NA

# get long format table
crypto_mst <- data.table(crypto_mst,keep.rownames = TRUE)%>%melt(na.rm=TRUE,id.vars="rn")
# rename the table
setnames(crypto_mst,c("Source","Target","ndiff"))

# Compute weights
crypto_mst[,Weight:=ndiff]
crypto_mst[Weight>50,Weight:=50]
crypto_mst[,Weight:=((max(Weight)+1)-Weight)]
crypto_mst[,Weight:=sqrt(Weight)]
crypto_mst[,Weight:=Weight/max(Weight)]

# export
fwrite(crypto_mst,
       file = "MSTrefstest.tsv",
       sep = "\t",
       quote= FALSE)
