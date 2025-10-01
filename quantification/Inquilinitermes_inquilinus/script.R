#getting started####
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install()
BiocManager::install("devtools")    # only if devtools not yet installed
BiocManager::install("pachterlab/sleuth")
install.packages("cowplot")

suppressMessages({
  library('cowplot')
  library('sleuth')
})

#foraging transcript: GKIC01059660.1.p1

sample_id_head <- dir(file.path("/../libraries/Inquilinitermes_inquilinus/01_mapped", "head"))
kal_dirs_head <- file.path("/../libraries/Inquilinitermes_inquilinus/01_mapped","head", sample_id_head, "kallisto")

s2c_head <- read.table(file.path("/../quantification/Inquilinitermes_inquilinus", "metadata", "info_head.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c_head<- dplyr::select(s2c_head, sample = sample, caste)


s2c_head <- dplyr::mutate(s2c_head, path = kal_dirs_head)
print(s2c_head)

s2c_head$caste <- factor(s2c_head$caste, levels = c("worker", "soldier"))

so_head <- sleuth_prep(s2c_head,read_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))

so_head <- sleuth_fit(so_head, ~ caste, 'full')

so_head <- sleuth_fit(so_head, ~1, 'reduced')
so_head <- sleuth_lrt(so_head, 'reduced', 'full')
models(so_head)


sleuth_table_head <- sleuth_results(so_head, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant_head <- dplyr::filter(sleuth_table_head, qval <= 0.05)
head(sleuth_significant, 20)


#head -effect of caste#####
sleuth_live(so_head)
tests(so_head)

so_head <- sleuth_wt(so_head, which_beta = 'castesoldier',which_model = "full")
wt_head <- sleuth_results(so_head, 'castesoldier', test_type = 'wt',which_model = "full", show_all = FALSE)

wt_head_significant <- dplyr::filter(wt_head, qval <= 0.05)
write.csv2(wt_head, "sleuth_inquilinitermes_head.csv")
sleuth_live(so_head)


#abdomen####
sample_id_abdomen <- dir(file.path("/../libraries/Inquilinitermes_inquilinus/01_mapped", "abdomen"))
kal_dirs_abdomen <- file.path("/../libraries/Inquilinitermes_inquilinus/01_mapped","abdomen", sample_id_abdomen, "kallisto")

s2c_abdomen <- read.table(file.path("/../quantification/Inquilinitermes_inquilinus", "metadata", "info_abdomen.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c_abdomen<- dplyr::select(s2c_abdomen, sample = sample, caste)


s2c_abdomen <- dplyr::mutate(s2c_abdomen, path = kal_dirs_abdomen)
print(s2c_abdomen)

s2c_abdomen$caste <- factor(s2c_abdomen$caste, levels = c("worker", "soldier"))
so_abdomen <- sleuth_prep(s2c_abdomen, read_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))

so_abdomen <- sleuth_fit(so_abdomen, ~ caste, 'full')
so_abdomen <- sleuth_fit(so_abdomen, ~1, 'reduced')
so_abdomen <- sleuth_lrt(so_abdomen, 'reduced', 'full')
models(so_abdomen)


sleuth_table_abdomen <- sleuth_results(so_abdomen, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant_abdomen <- dplyr::filter(sleuth_table_abdomen, qval <= 0.05)
head(sleuth_significant, 20)


#abdomen -effect of caste#####
sleuth_live(so_abdomen)

so_abdomen <- sleuth_wt(so_abdomen, which_beta = 'castesoldier',which_model = "full")

wt_abdomen <- sleuth_results(so_abdomen, 'castesoldier', test_type = 'wt',which_model = "full", show_all = FALSE)

wt_abdomen_significant <- dplyr::filter(wt_abdomen, qval <= 0.05)
write.csv2(wt_abdomen, "sleuth_inquilinitermes_abdomen.csv")
sleuth_live(so_abdomen)
