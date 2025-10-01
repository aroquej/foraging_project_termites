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

sample_id_head <- dir(file.path("/../libraries/Reticulitermes_speratus/01_mapped", "head"))
kal_dirs_head <- file.path("/../libraries/Reticulitermes_speratus/01_mapped","head", sample_id_head, "kallisto")

s2c_head <- read.table(file.path("/../quantification/Reticulitermes_speratus", "metadata", "info_head.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c_head<- dplyr::select(s2c_head, sample = sample, sex, caste)


s2c_head <- dplyr::mutate(s2c_head, path = kal_dirs_head)
print(s2c_head)
s2c_head$caste <- factor(s2c_head$caste, levels = c("worker","soldier"))
s2c_head$sex <- factor(s2c_head$sex, levels = c("male","female"))

so_head <- sleuth_prep(s2c_head,read_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))

so_head <- sleuth_fit(so_head, ~sex + caste, 'full')
so_head <- sleuth_fit(so_head, ~sex, 'reduced')
so_head <- sleuth_lrt(so_head, 'reduced', 'full')
models(so_head)


sleuth_table_head <- sleuth_results(so_head, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant_head <- dplyr::filter(sleuth_table_head, qval <= 0.05)
head(sleuth_significant, 20)


#head -effect of sex#####
sleuth_live(so_head)

so_head <- sleuth_wt(so_head, which_beta = 'sexfemale',which_model = "full")

wt_caste_sex  <- sleuth_results(so_head, 'sexfemale', test_type = 'wt',which_model = "full", show_all = FALSE)
wt_caste_sex_significant <- dplyr::filter(wt_caste_sex, qval <= 0.05)
sleuth_live(so_head)


#head -effect of caste#####
so_head <- sleuth_wt(so_head, which_beta = 'castesoldier',which_model = "full")

head(so_head_caste)
wt_caste_head   <- sleuth_results(so_head, 'castesoldier', test_type = 'wt',which_model = "full", show_all = FALSE)
wt_caste_head_significant <- dplyr::filter(wt_caste_head, qval <= 0.05)
sleuth_live(so_head)


write.table(wt_caste_head, file = "wt_head_caste_effect.csv", sep = "\t", quote = FALSE, row.names = FALSE)




#body####

sample_id_body <- dir(file.path("/../libraries/Reticulitermes_speratus/01_mapped", "body"))
kal_dirs_body <- file.path("/../libraries/Reticulitermes_speratus/01_mapped","body", sample_id_body, "kallisto")

s2c_body <- read.table(file.path("/../quantification/Reticulitermes_speratus", "metadata", "info_body.txt"), header = TRUE, stringsAsFactors=FALSE)
s2c_body<- dplyr::select(s2c_body, sample = sample, sex, caste)


s2c_body <- dplyr::mutate(s2c_body, path = kal_dirs_body)
print(s2c_body)
s2c_body$caste <- factor(s2c_body$caste, levels = c("worker","soldier"))
s2c_body$sex <- factor(s2c_body$sex, levels = c("male","female"))

so_body <- sleuth_prep(s2c_body, read_bootstrap_tpm = TRUE, extra_bootstrap_summary = TRUE,transformation_function = function(x) log2(x + 0.5))

so_body <- sleuth_fit(so_body, ~sex + caste, 'full')
so_body <- sleuth_fit(so_body, ~sex, 'reduced')
so_body <- sleuth_lrt(so_body, 'reduced', 'full')
models(so_body)


sleuth_table_body <- sleuth_results(so_body, 'reduced:full', 'lrt', show_all = FALSE)
sleuth_significant_body <- dplyr::filter(sleuth_table_body, qval <= 0.05)
head(sleuth_significant_body, 20)


#body -effect of sex#####
sleuth_live(so_body)

so_body <- sleuth_wt(so_body, which_beta = 'sexfemale',which_model = "full")

wt_sex_body  <- sleuth_results(so_body, 'sexfemale', test_type = 'wt', which_model = "full",show_all = FALSE)
wt_sex_significant_body <- dplyr::filter(wt_sex_body, qval <= 0.05)
sleuth_live(so_body)


#head -effect of caste#####
so_body <- sleuth_wt(so_body, which_beta = 'castesoldier',which_model = "full")
tests(so_body)

head(so_head_caste)
wt_caste_body   <- sleuth_results(so_body, 'castesoldier', test_type = 'wt', which_model = "full",show_all = FALSE)
wt_caste_body_significant <- dplyr::filter(wt_caste_body, qval <= 0.05)
sleuth_live(so_body)


write.table(wt_caste_body, file = "wt_body_caste_effect.csv", sep = "\t", quote = FALSE, row.names = FALSE)

