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

sample_id <- dir(file.path("/../libraries/Zootermopsis_nevadensis", "01_mapped"))
kal_dirs <- file.path("/../libraries/Zootermopsis_nevadensis","01_mapped", sample_id, "kallisto")

s2c <- read.table(file.path("/../quantification/Zootermopsis_nevadensis", "metadata", "info.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c<- dplyr::select(s2c, sample = sample, caste)

s2c <- dplyr::mutate(s2c, path = kal_dirs)
print(s2c)
s2c$caste <- factor(s2c$caste, levels = c("worker", "soldier"))

so <- sleuth_prep(s2c,read_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))
so <- sleuth_fit(so, ~caste, 'full')

so <- sleuth_fit(so, ~1, 'reduced')
so <- sleuth_lrt(so, 'reduced', 'full')

sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)
head(sleuth_significant, 20)


models(so)
so <- sleuth_wt(so, which_beta = 'castesoldier',which_model = 'full')
sleuth_live(so)

wt_caste  <- sleuth_results(so, 'castesoldier', test_type = 'wt',which_model = 'full', show_all = FALSE)
wt_caste_significant <- dplyr::filter(wt_caste, qval <= 0.05)

write.table(wt_caste, file = "sleuth_wt.csv", sep = "\t", quote = FALSE, row.names = FALSE)

