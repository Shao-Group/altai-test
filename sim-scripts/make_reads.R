args <- commandArgs(TRUE)
fa <- args[1]                      # fa of di-transcriptme
num_tx <- as.numeric(args[2])      # 19885, not 2X yet, not used
num_sample <- 2  
total_read <- as.numeric(args[3])  # low, mid, high
exp_profile <- args[4]	       # expression profile
output_prefix <- args[5]
print("Simulate reads:")
print(paste("fa=", fa, ", #read=", total_read, " expression=" , exp_profile, " output=", output_prefix, sep=""))

suppressPackageStartupMessages(library(polyester))
suppressPackageStartupMessages(library(Biostrings))
#library(polyester)
#library(Biostrings)


# 1 replicate per sample
num_rep <- rep(1, num_sample)

# read per transcript
profile <- read.csv(exp_profile, sep = "\t")
lengths <- profile$"tx_len"
abd <- profile$"tx_exp"
abdxlen <- abd * lengths
sum_abdxlen <- sum(abdxlen)
read_of_tx <- total_read / sum_abdxlen * abdxlen

head(profile)
head(abd)
head(lengths)
head(read_of_tx)
for (i in read_of_tx){
	stopifnot(i < 2^31)
}
# make sure total # reads is not wrong
sumreads <- sum(read_of_tx)
stopifnot(sumreads < total_read * 1.01)
stopifnot(sumreads > total_read * 0.99) 
stopifnot(length(abd) == length(read_of_tx))
stopifnot(length(lengths) == length(read_of_tx))


# num_sample RNA-seq samples, no FC
fold_changes <- matrix(1, nrow = length(lengths), ncol = num_sample)

simulate_experiment(fa, reads_per_transcript = read_of_tx, 
    num_reps = num_rep, fold_changes = fold_changes,
    readlen = 110, paired = TRUE, fraglen = 400, strand_specific = TRUE,
    bias = 'rnaf', outdir = output_prefix) 

print(paste("fa=", fa, ", #read=", total_read, " expression=" , exp_profile, " output=", output_prefix, sep=""))
print("Simulate reads completed!")

