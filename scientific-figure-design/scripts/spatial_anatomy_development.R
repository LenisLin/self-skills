# 比较不同发育阶段的空间解剖结构。使用附带的模拟数据生成 PNG、PDF 和 RDS。
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[[1]] else "."
entry <- sub("^--file=", "", grep("^--file=", commandArgs(), value = TRUE)[1])
shared <- file.path(dirname(normalizePath(entry)), "_shared", "hesta_panels.R")
status <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(shared), "ext2a", shQuote(out)))
if (status != 0L) stop("Plotting failed with exit status ", status)
for (suffix in c(".png", ".pdf", "_simulated.rds")) {
  source <- file.path(out, paste0("ext2a", suffix))
  target <- file.path(out, paste0("spatial_anatomy_development", suffix))
  if (!file.rename(source, target)) stop("Could not rename ", source, " to ", target)
}
