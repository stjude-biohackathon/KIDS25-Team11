# Illumina Short Read Sequencing
illumina_short_read_sequencing_df <- data.frame(
  Well_Number_Well_Location = character(),
  Sample_Name = character(),
  Is_this_a_Human_Derived_Sample = character(),
  SJ_Tissue_Bank = character(),
  Sample_SJUID = character(),
  Alternative_ID = character(),
  Submission_Material = character(),
  Xenograft = character(),
  Application = character(),
  Illumina_Sequencer = character(),
  Run_Type = character(),
  Read_Length = character(),
  Molecules_Sequenced = character(),
  Reference_Genome = character(),
  Please_specify_Reference_Genome = character(),
  User_Comments = character(),
  stringsAsFactors = FALSE
)

# PacBio Long Read Sequencing
pacbio_long_read_sequencing_df <- data.frame(
  Well_Number_Well_Location = character(),
  Sample_Name = character(),
  Is_this_a_Human_Derived_Sample = character(),
  SJ_Tissue_Bank = character(),
  Sample_SJUID = character(),
  Alternative_ID = character(),
  Application = character(),
  Reference_Genome = character(),
  User_Comments = character(),
  Size_of_Amplicon_bp = character(),
  Input_Material = character(),
  Purification_Method = character(),
  stringsAsFactors = FALSE
)

# Custom Genotyping (PowerPlex STR)
custom_genotyping_powerplex_str_df <- data.frame(
  Well_Number_Well_Location = character(),
  Sample_Name = character(),
  Is_this_a_Human_Derived_Sample = character(),
  SJ_Tissue_Bank = character(),
  Sample_SJUID = character(),
  Alternative_ID = character(),
  User_Comments = character(),
  Analysis = character(),
  stringsAsFactors = FALSE
)

# Mapping and Methylation (CACT Genotyping)
mapping_methylation_cact_genotyping_df <- data.frame(
  Well_Number_Well_Location = character(),
  Sample_Name = character(),
  Is_this_a_Human_Derived_Sample = character(),
  SJ_Tissue_Bank = character(),
  Sample_SJUID = character(),
  Alternative_ID = character(),
  Array = character(),
  DNA_Sample_Type = character(),
  stringsAsFactors = FALSE
)

# Print structure of each dataframe
cat("Illumina Short Read Sequencing columns:\n")
print(names(illumina_short_read_sequencing_df))

cat("\nPacBio Long Read Sequencing columns:\n")
print(names(pacbio_long_read_sequencing_df))

cat("\nCustom Genotyping (PowerPlex STR) columns:\n")
print(names(custom_genotyping_powerplex_str_df))

cat("\nMapping and Methylation (CACT Genotyping) columns:\n")
print(names(mapping_methylation_cact_genotyping_df))