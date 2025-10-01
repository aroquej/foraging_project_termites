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

sample_id <- dir(file.path("/../libraries/Neotermes_binovatus", "01_mapped"))
kal_dirs <- file.path("/../libraries/Neotermes_binovatus","01_mapped", sample_id, "kallisto")


s2c <- read.table(file.path("/../quantification/Neotermes_binovatus", "metadata", "info.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c <- dplyr::select(s2c, sample = sample, caste)
s2c

s2c <- dplyr::mutate(s2c, path = kal_dirs)
print(s2c)

so <- sleuth_prep(s2c, extra_bootstrap_summary = TRUE)

so <- sleuth_fit(so, ~caste, 'full')
so <- sleuth_fit(so, ~1, 'reduced')
so <- sleuth_lrt(so, 'reduced', 'full')
models(so)

sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)
head(sleuth_significant, 20)


sleuth_live(so)

so <- sleuth_wt(so, which_beta = 'casteworker')

head(wt_worker)
wt_worker   <- sleuth_results(so, 'casteworker', test_type = 'wt', show_all = FALSE)
wt_worker_significant <- dplyr::filter(wt_worker, qval <= 0.05)

write.table(wt_worker, file = "wt.csv", sep = "\t", quote = FALSE, row.names = FALSE)
