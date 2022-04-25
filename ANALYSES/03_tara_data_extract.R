library(data.table)

# load eukbank cryptophyceae data

data <- fread(here::here("data","eukbank_18SV4_asv.table_rarefied_10000.gz"))


# load contextual data

context <- fread(here::here("data","eukbank_18SV4_asv.metadata20211123.gz"))

# select Tara samples

context_tara <- context[project=="Tara_Oceans" &
                          depth_categ == "[SRF] surface water layer (ENVO_00010504)" &
                          size_fraction_lower_threshold == "0.8" &
                          size_fraction_upper_threshold == ">0.8" &
                          !is.na(temperature),
                        list(sample,latitude,longitude,temperature)]

# load taxo

taxo <- fread(here::here("data","eukbank_18SV4_asv.taxo.gz"))

# add taxo to the asv table

data <- merge(data,
              taxo[,.(amplicon,similarity,taxonomy,references)],
              by="amplicon")

# subset the asv table
data_tara <- data[,.SD,.SDcols=c(context_tara[,sample])]
x <- apply(data_tara,1,sum)
y <- apply(data_tara,1,function(X) sum(X>0))

data[,ndiff:=round((100-similarity)*3.75)]

data_tara <- data.table(data[,.(amplicon,similarity,ndiff,taxonomy,references)],
                        total=x,
                        spread=y,
                        data_tara)

data_tara <- data_tara[total >= 10 & spread >= 2]



fwrite(data_tara,
       file = here::here("outputs","tara_data_asv_table.tsv.gz"),
       sep="\t",
       quote=FALSE)

fwrite(context_tara,
       file = here::here("outputs","tara_data_context.tsv.gz"),
       sep="\t",
       quote=FALSE)