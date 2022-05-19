library(seqinr)
library(data.table)
library(dplyr)
library(seqinr)
library(magrittr)
##############################################################################
# functions
##############################################################################
# The input of this function is a vector of taxa
# If there is only one unique taxa, the function returns it
# Otherwise it returns *X_taxa*, X being the number
# of unique taxa

taxuniq <- function(Y){
  Y <- unique(Y)
  if(length(Y)>1){
    paste0("*",length(Y),"_taxa*")
  }else{
    Y
  }
}

##############################################################################
# Cryptophyta subset
##############################################################################

# import fasta file

read1 <- read.fasta(file = "46345_EukRibo_V4_2020-10-27.fas.gz")

# Transform to a table

refs_table <- data.table(id=names(read1),
                         sequence = unlist(getSequence(read1,as.string = TRUE)),
                         taxo = unlist(getAnnot(read1)))
                        

# select cryptophyceae

refs_table <- refs_table[grep("Cryptophyceae",taxo)]
refs_table[,taxo:=sub(pattern = "^.+\\|Cryptophyceae\\|",replacement = "",taxo)]

# export sequences

write.fasta(names=names(refs_table),sequence=refs_table,file.out="crypto_seq.fasta")

# export taxo

fwrite(refs_table,
       file = "crypto_seq.tsv",
       sep="\t",
       quote=F)


##############################################################################
# dereplication
##############################################################################

refs_table_derep <- refs_table[,.(ids=paste(id,collapse = ","),
                                  taxo=paste(lapply(tstrsplit(taxo,"\\|"),taxuniq),collapse = "|"),
                                  n_ids=.N,
                                  n_taxos=length(unique(taxo))),
                               by=sequence]

# sort table by taxo

refs_table_derep <- refs_table_derep[order(taxo)]

# add unique ids

refs_table_derep[,Id:=sprintf("ref_%03d", 1:.N)]

# add taxo categ for figures
# take first rank except for Cryptomonadales (2nd rank)

srefs_table_derep[,taxoplot:=sub(pattern = "Cryptomonadales\\|(g:)*|g:",replacement="",taxo) %>%
                   sub(pattern = "\\|.+$",replacement="")]

# add label for nodes
# first the strain or clone information is removed
# and then the last field is extracted

refs_table_derep[,taxolabel:=gsub(pattern = "\\|\\*.+$|\\|strain=.+$|\\|clone=.+$",replacement="",taxo) %>%
                   sub(pattern = "^.+\\|",replacement="")]

refs_table_derep[taxolabel==taxoplot,taxolabel:=""]

# export sequences as fasta

seqinr::write.fasta(sequences = as.list(refs_table_derep[,sequence]),
                    names = refs_table_derep[,Id],
                    file.out = "refs_fasta_cryptophytes_MST_sequences.fasta")

# export table

fwrite(refs_table_derep[,list(Id,sequence,taxo,n_ids,n_taxos,ids,taxoplot,taxolabel)],
       file = "refs_table_cryptophytes_MST.tsv",
       sep="\t",
       quote=F)

