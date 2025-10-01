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

sample_id <- dir(file.path("/../libraries/Macrotermes_bellicosus", "01_mapped"))
kal_dirs <- file.path("/../libraries/Macrotermes_bellicosus/01_mapped", sample_id, "kallisto")


s2c <- read.table(file.path("/../quantification/Macrotermes_bellicosus", "metadata", "info.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c <- dplyr::select(s2c, sample = samples, task)
s2c

s2c <- dplyr::mutate(s2c, path = kal_dirs)
print(s2c)

#defining reference
s2c$task <- factor(s2c$task, levels = c("builder", "forager"))


so <- sleuth_prep(s2c, eread_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))
so

so <- sleuth_fit(so, ~1, 'reduced')
so <- sleuth_fit(so, ~task, 'full')
so <- sleuth_lrt(so, 'reduced', 'full')
models(so)
tests(so)

sleuth_table <- sleuth_results(so, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant <- dplyr::filter(sleuth_table, qval <= 0.05)
head(sleuth_significant, 20)

sleuth_live(so)

so <- sleuth_wt(so, which_beta = 'taskforager',which_model = "full")

wt  <- sleuth_results(so, 'taskforager', test_type = 'wt', which_model = "full",show_all = FALSE)
wt_significant <- dplyr::filter(wt, qval <= 0.05)

write.table(wt, file = "wt.csv", sep = "\t", quote = FALSE, row.names = FALSE)
