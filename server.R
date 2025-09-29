library(shiny)
library(openxlsx)
library(DT)

function(input, output, session) {
  
  # --- File 1: Genome Sequencing ---
  df1 <- read.xlsx("SRM2 - Genome Sequencing - Excel Upload - Version 21.xlsx", sheet = 1)
  output$download1 <- downloadHandler(
    filename = function() {
      "SRM2 - Genome Sequencing - Excel Upload - Version 21_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df1, file, overwrite = TRUE)
    }
  )
  
  # --- File 2: CACT Genotyping ---
  df2 <- read.xlsx("SRM2 - CACT Genotyping - Excel Upload - Version 10.xlsx", sheet = 1)
  output$download2 <- downloadHandler(
    filename = function() {
      "SRM2 - CACT Genotyping - Excel Upload - Version 10_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df2, file, overwrite = TRUE)
    }
  )
  
  # --- File 3: Custom Genotyping Powerplex ---
  df3 <- read.xlsx("SRM2_CustomGenotyping_Powerplex_ExcelUploadTemplate_Version4.xlsx", sheet = 1)
  output$download3 <- downloadHandler(
    filename = function() {
      "SRM2_CustomGenotyping_Powerplex_ExcelUploadTemplate_Version4_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df3, file, overwrite = TRUE)
    }
  )
  
  # --- File 4: PacBio Sequencing ---
  df4 <- read.xlsx("SRM2 - PacBioSequencing - Excel Upload - Version 11.xlsx", sheet = 1)
  output$download4 <- downloadHandler(
    filename = function() {
      "SRM2 - PacBioSequencing - Excel Upload - Version 11_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df4, file, overwrite = TRUE)
    }
  )
  
  # --- File 5: CAB_Genomics_SampleInfo_edited - WGS WES somatic ---
  df5 <- read.xlsx("CAB_Genomics_SampleInfo_edited.xlsx", sheet = "WGS WES Somatic")
  output$download5 <- downloadHandler(
    filename = function() {
      "CAB_Genomics_SampleInfo_edited_WGS_WES_somatic_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df5, file, overwrite = TRUE)
    }
  )
  
  # --- File 6: CAB_Genomics_SampleInfo_edited - WGS WES germline ---
  df6 <- read.xlsx("CAB_Genomics_SampleInfo_edited.xlsx", sheet = "WGS WES Germline")
  output$download6 <- downloadHandler(
    filename = function() {
      "CAB_Genomics_SampleInfo_edited_WGS_WES_germline_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df6, file, overwrite = TRUE)
    }
  )
  
  # --- File 7: CAB_Genomics_SampleInfo_edited - Amplicon ---
  df7 <- read.xlsx("CAB_Genomics_SampleInfo_edited.xlsx", sheet = "Amplicon")
  output$download7 <- downloadHandler(
    filename = function() {
      "CAB_Genomics_SampleInfo_edited_Amplicon_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df7, file, overwrite = TRUE)
    }
  )
  
  # --- File 8: CAB_Genomics_SampleInfo_edited - Metagenomics ---
  df8 <- read.xlsx("CAB_Genomics_SampleInfo_edited.xlsx", sheet = "Metagenomics")
  output$download8 <- downloadHandler(
    filename = function() {
      "CAB_Genomics_SampleInfo_edited_Metagenomics_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df8, file, overwrite = TRUE)
    }
  )

  
  # --- File 9: CAB_Epigenetics_SampleInfo_edited - CHIPSEQ,CutRun,CutTag ---
  df9 <- read.xlsx("CAB_Epigenetics_SampleInfo_edited.xlsx", sheet = "CHIPSEQ,CutRun,CutTag")
  output$download9 <- downloadHandler(
    filename = function() {
      "CAB_Epigenetics_SampleInfo_edited_CHIPSEQ,CutRun,CutTag_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df9, file, overwrite = TRUE)
    }
  )
  
  # --- File 10: CAB_Epigenetics_SampleInfo_edited - ATACSEQ ---
  df10 <- read.xlsx("CAB_Epigenetics_SampleInfo_edited.xlsx", sheet = "ATACSEQ")
  output$download10 <- downloadHandler(
    filename = function() {
      "CAB_Epigenetics_SampleInfo_edited_ATACSEQ_output.xlsx"
    },
    content = function(file) {
      write.xlsx(df10, file, overwrite = TRUE)
    }
  )
}
