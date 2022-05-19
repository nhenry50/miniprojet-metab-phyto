library(ggplot2)
#create a column to reduce the factor n_diff terms to 6 : 0 mutations, 1, 2, 3, 4, and ≥ 5 : 
datatara$barplotndiff <- datatara$ndiff
datatara$barplotndiff[datatara$barplotndiff >5] <- 5

#build the barplot
histo <-ggplot(datatara, aes(x = barplotndiff, fill = taxoplot))+
  geom_bar(color = "black")+
  scale_fill_brewer(palette = "Set1", "Groupes")+
  scale_x_continuous(breaks = c(0:5), labels = c("0", "1", "2","3","4","≥5"), "number of mutations between the ASV and the assigned reference sequence")+
  scale_y_continuous("number of sequences of each lineage")+
  theme_bw()

#export to pdf
pdf("histodistrib1.pdf")
histo
dev.off()

#export to png
png("barplotmutation.png",units = "in", height = 3 , width =  4, res = 600)
histo
dev.off()