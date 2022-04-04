library(data.table)
data <- seqinr::read.fasta("crypto_seq.fasta")
data<-data.table(ID=names(data),
                 Sequence=seqinr::getSequence(data,as.string = TRUE)|>unlist(),
                 Taxo=seqinr::getAnnot(data)|>unlist())
data[,Taxo:=sub("^.+Cryptophyceae\\|","",Taxo)]
datasequence<-data[,.(paste(ID,collapse = ","),
                      paste(unique(Taxo),collapse=" , ")),by=Sequence]

seqinr::write.fasta(sequences = as.list(datasequence$Sequence),
                    names = datasequence$ID,
                    file.out = "crypto_seq_unique.fasta")

