# CAB Epigenetics - CHIPSEQ, CutRUN, CutTag
epigenetics_chipseq_df <- data.frame(
  Type = character(),
  ID = character(),
  Group = character(),
  PkCallerUser = character(),
  INPUTUser = character(),
  LabID = character(),
  Species = character(),
  SRM_Order = character(),
  Description = character(),
  Project = character(),
  stringsAsFactors = FALSE
)

# CAB Epigenetics - ATACSEQ
epigenetics_atacseq_df <- data.frame(
  ID = character(),
  Group = character(),
  LabID = character(),
  Species = character(),
  SRM_Order = character(),
  Description = character(),
  Project = character(),
  stringsAsFactors = FALSE
)

# CAB Epigenetics - WGBS
epigenetics_wgbs_df <- data.frame(
  ID = character(),
  Group = character(),
  LabID = character(),
  Species = character(),
  SRM_Order = character(),
  Description = character(),
  Project = character(),
  stringsAsFactors = FALSE
)

# CAB Epigenetics - DiffPeak
epigenetics_diffpeak_df <- data.frame(
  ID = character(),
  LabID = character(),
  Project = character(),
  Group_Diff = character(),
  Group_Diff2 = character(),
  Target = character(),
  Control = character(),
  stringsAsFactors = FALSE
)

# CAB Epigenetics - HiC, HiCHIP, PLACSeq, CaptureC
epigenetics_hic_df <- data.frame(
  ID = character(),
  Group = character(),
  LabID = character(),
  Species = character(),
  Description = character(),
  Project = character(),
  Protocol_Enzyme = character(),
  stringsAsFactors = FALSE
)

# CAB Epigenetics - MethylationArray
epigenetics_methylation_df <- data.frame(
  Group = character(),
  LabID = character(),
  SRM_Order = character(),
  Project = character(),
  Sample_Name = character(),
  Sample_Type = character(),
  Sentrix_ID = character(),
  Array = character(),
  File_Location = character(),
  SJ_Tissue_Bank = character(),
  Sample_SJUID = character(),
  stringsAsFactors = FALSE
)

# CAB Transcriptomics - one variable
transcriptomics_one_var_df <- data.frame(
  LabID = character(),
  Species = character(),
  SRM_sample_number = character(),
  Genotype = character(),
  Hartwell_Center_SRM_order = character(),
  PDX = character(),
  Comparisons = character(),
  stringsAsFactors = FALSE
)

# CAB Transcriptomics - paired design
transcriptomics_paired_df <- data.frame(
  LabID = character(),
  Species = character(),
    SRM_sample_number = character(),
    Hartwell_Center_SRM_order = character(),
    PDX = character(),
    Comparisons = character(),
  Subject_ID = character(),
  Treatment = character(),
  stringsAsFactors = FALSE
)

# CAB Transcriptomics - multiple-Batch
transcriptomics_multi_batch_df <- data.frame(
  LabID = character(),
  Species = character(),
    SRM_sample_number = character(),
    Genotype = character(),
    Hartwell_Center_SRM_order = character(),
    PDX = character(),
    Comparisons = character(),
  Batch = character(),
  stringsAsFactors = FALSE
)

# CAB Transcriptomics - multi-factor
transcriptomics_multi_factor_df <- data.frame(
  LabID = character(),
  Species = character(),
    SRM_sample_number = character(),
    Genotype = character(),
    Hartwell_Center_SRM_order = character(),
    PDX = character(),
    Comparisons = character(),
  Condition = character(),
  stringsAsFactors = FALSE
)

# CAB Transcriptomics - longitudinal study
transcriptomics_longitudinal_df <- data.frame(
  LabID = character(),
  Species = character(),
    SRM_sample_number = character(),
    Genotype = character(),
    Hartwell_Center_SRM_order = character(),
    PDX = character(),
    Comparisons = character(),
  Subject_ID = character(),
  Hours = character(),
  stringsAsFactors = FALSE
)

# Print structure of each dataframe
cat("CHIPSEQ/CutRUN/CutTag columns:\n")
print(names(epigenetics_chipseq_df))

cat("\nATACSEQ columns:\n")
print(names(epigenetics_atacseq_df))

cat("\nWGBS columns:\n")
print(names(epigenetics_wgbs_df))

cat("\nDiffPeak columns:\n")
print(names(epigenetics_diffpeak_df))

cat("\nHiC/HiCHIP/PLACSeq/CaptureC columns:\n")
print(names(epigenetics_hic_df))

cat("\nMethylationArray columns:\n")
print(names(epigenetics_methylation_df))

cat("\nTranscriptomics (one variable) columns:\n")
print(names(transcriptomics_one_var_df))

cat("\nTranscriptomics (paired design) columns:\n")
print(names(transcriptomics_paired_df))

cat("\nTranscriptomics (multiple-Batch) columns:\n")
print(names(transcriptomics_multi_batch_df))

cat("\nTranscriptomics (multi-factor) columns:\n")
print(names(transcriptomics_multi_factor_df))

cat("\nTranscriptomics (longitudinal study) columns:\n")
print(names(transcriptomics_longitudinal_df))