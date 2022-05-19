library(data.table)
library(seqinr)
data <-read.fasta("crypto_seq.fasta")      #import fasta file in data
data<-data.table(ID=names(data),                    #make a data.table with data
                 Sequence=getSequence(data,as.string = TRUE)%>%unlist(),
                 Taxo=getAnnot(data)%>%unlist())
data[,Taxo:=sub("^.+Cryptophyceae\\|","",Taxo)]     #sub
datasequence<-data[,.(paste(ID,collapse = ","),     #associate the sequence with all correpsonding id and taxo
                      paste(unique(Taxo),collapse=" , ")),by=Sequence]

write.fasta(sequences = as.list(datasequence$Sequence), #export as fasta file to align (with an alignment software like seaview )
                    names = datasequence$ID,
                    file.out = "crypto_seq_unique.fasta")
