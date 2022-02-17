#devoir 1:
fichier_fasta <- seqinr::read.fasta("46345_EukRibo_V4_2020-10-27.fas") 


library(seqinr)
read1 <- read.fasta(file = "46345_EukRibo_V4_2020-10-27.fas", 
           seqtype = c("DNA"), as.string = TRUE, forceDNAtolower = FALSE,
           set.attributes = TRUE, legacy.mode = TRUE, seqonly = FALSE, strip.desc = FALSE,
           whole.header = TRUE, bfa = FALSE, sizeof.longlong = .Machine$sizeof.longlong,
           endian = .Platform$endian, apply.mask = TRUE)


new_data <- read1[grep("Cryptophyceae",names(read1))]
seqinr::write.fasta(names=names(new_data),sequence=new_data,file.out="crypto_seq.fasta")


input <- readLines("crypto_seq.fasta")
output <- file("cryptosequences.csv","w")

currentSeq <- 0
newLine <- 0

for(i in 1:length(input)) {
  if(strtrim(input[i], 1) == ">") {
    if(currentSeq == 0) {
      writeLines(paste(input[i],"\t"), output, sep="")
      currentSeq <- currentSeq + 1
    } else {
      writeLines(paste("\n",input[i],"\t", sep =""), output, sep="")
    }
  } else {
    writeLines(paste(input[i]), output, sep="")
  }
}

close(output)

library(tidyverse)


