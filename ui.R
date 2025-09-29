library(shiny)

fluidPage(
  titlePanel("Excel Export Tool"),
  
  # Original 4 files
  downloadButton("download1", "Export Genome Sequencing"),
  br(), br(),
  
  downloadButton("download2", "Export CACT Genotyping"),
  br(), br(),
  
  downloadButton("download3", "Export Custom Genotyping Powerplex"),
  br(), br(),
  
  downloadButton("download4", "Export PacBio Sequencing"),
  br(), br(),
  
  # New CAB_Genomics sheets
  downloadButton("download5", "Export CAB Genomics - WGS WES Somatic"),
  br(), br(),
  
  downloadButton("download6", "Export CAB Genomics - WGS WES Germline"),
  br(), br(),
  
  downloadButton("download7", "Export CAB Genomics - Amplicon"),
  br(), br(),
  
  downloadButton("download8", "Export CAB Genomics - Metagenomics"),
  br(), br(),
  
  # CAB_Epigenetics sheets
  downloadButton("download9", "Export CAB Epigenetics - CHIPSEQ,CutRun,CutTag"),
  br(), br(),
  
  downloadButton("download10", "Export CAB Epigenetics - ATACSEQ")
)
