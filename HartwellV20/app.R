library(shiny)
library(writexl)
library(readxl)
library(DT)

# ==================== UI ====================
ui <- fluidPage(
  titlePanel("Hartwell Center Sample Submission Form"),
  
  # SECTION 1: Service Selection
  wellPanel(
    h3("Section 1: Select Service Type"),
    p("First, choose between Sequencing or CAB services:"),
    selectInput("service_category", "Service Category *",
                choices = c("Select category..." = "", 
                            "Sequencing Services" = "sequencing",
                            "CAB Services" = "cab")),
    
    # Show sequencing options if sequencing is selected
    conditionalPanel(
      condition = "input.service_category == 'sequencing'",
      checkboxGroupInput("sequencing_services", "Select Sequencing Service(s):",
                         choices = c("Illumina Sequencing (Most common for short-read)" = "illumina",
                                     "PacBio Long Read (RNA/DNA, special long-read cases)" = "pacbio",
                                     "Mapping and Methylation" = "methylation"))
    ),
    
    # Show CAB options if CAB is selected
    conditionalPanel(
      condition = "input.service_category == 'cab'",
      checkboxGroupInput("cab_services", "Select CAB Service(s):",
                         choices = c("CAB ChIPseq" = "chipseq",
                                     "CAB ATACseq" = "atacseq",
                                     "CAB Transcriptomics" = "transcriptomics",
                                     "CAB HiC/HiChIP" = "hichip"))
    )
  ),
  
  # SECTION 2: Order-Level Information
  conditionalPanel(
    condition = "input.service_category != ''",
    wellPanel(
      h3("Section 2: Order-Level Information"),
      p("These fields apply to ALL samples in this order:"),
      
      fluidRow(
        column(4,
               selectInput("species", "Species *",
                           choices = c("Select species..." = "", "Human", "Mouse", "Other"))
        ),
        column(4,
               conditionalPanel(
                 condition = "input.species == 'Other'",
                 textInput("species_other", "Specify Species *", placeholder = "Enter species name")
               )
        ),
        column(4,
               selectInput("xenograft", "Xenograft? *",
                           choices = c("Select..." = "", "Yes", "No"))
        )
      ),
      
      fluidRow(
        column(6,
               selectInput("reference_genome", "Reference Genome *",
                           choices = c("Default (based on species)" = "default",
                                       "hg38 (Human)", "hg19 (Human)", 
                                       "mm10 (Mouse)", "mm39 (Mouse)",
                                       "Custom" = "custom"))
        ),
        column(6,
               conditionalPanel(
                 condition = "input.reference_genome == 'custom'",
                 textInput("reference_genome_custom", "Custom Genome *", 
                           placeholder = "e.g., rn6")
               )
        )
      ),
      
      # Show CAB-specific fields only if CAB service category is selected
      conditionalPanel(
        condition = "input.service_category == 'cab'",
        fluidRow(
          column(6,
                 textInput("project_space", "Project Space Path *",
                           placeholder = "HPCF: /research_jude/rgs01_jude/groups/<pigrp>/projects/<project>/")
          ),
          column(6,
                 textInput("protocol_enzyme", "Protocol/Enzyme *",
                           placeholder = "e.g., HiC-Mbol, HiChIP:Arima")
          )
        )
      ),
      
      # Amplicon field for Illumina (sequencing category)
      conditionalPanel(
        condition = "input.service_category == 'sequencing' && input.sequencing_services && input.sequencing_services.indexOf('illumina') > -1",
        textInput("amplicon_size", "Size of Amplicon (if applicable)",
                  placeholder = "Enter size in bp")
      )
    )
  ),
  
  # SECTION 3: Sample Entry
  conditionalPanel(
    condition = "(input.service_category == 'sequencing' && input.sequencing_services && input.sequencing_services.length > 0) || (input.service_category == 'cab' && input.cab_services && input.cab_services.length > 0)",
    conditionalPanel(
      condition = "input.species != ''",
      wellPanel(
        h3("Section 3: Sample Entry"),
        p("Choose how you want to enter your samples:"),
        
        tabsetPanel(id = "input_method",
                    # Method 1: Manual Single Entry
                    tabPanel("Single Entry",
                             br(),
                             uiOutput("single_entry_fields"),
                             actionButton("add_sample", "Add Sample to Table", class = "btn-primary")
                    ),
                    
                    # Method 2: Bulk List
                    tabPanel("Bulk List",
                             br(),
                             p("Paste sample IDs (one per line or comma-separated):"),
                             textAreaInput("bulk_list", NULL, rows = 10, 
                                           placeholder = "SAMPLE001\nSAMPLE002\nSAMPLE003\nor\nSAMPLE001, SAMPLE002, SAMPLE003"),
                             actionButton("process_bulk", "Add All to Table", class = "btn-primary")
                    ),
                    
                    # Method 3: File Upload
                    tabPanel("File Upload",
                             br(),
                             fileInput("file_upload", "Upload CSV or Excel file",
                                       accept = c(".csv", ".xlsx", ".xls")),
                             p("File can contain just Sample IDs or include other columns (Species, Group, etc.)"),
                             actionButton("process_file", "Add File to Table", class = "btn-primary")
                    ),
                    
                    # Method 4: Direct Table Entry
                    tabPanel("Table Entry",
                             br(),
                             p("Edit the table directly (click cells to type):"),
                             numericInput("num_rows", "Number of rows to add:", value = 5, min = 1, max = 100),
                             actionButton("create_table", "Create Empty Table", class = "btn-primary"),
                             br(), br(),
                             uiOutput("editable_tables_ui")
                    )
        )
      )
    )
  ),
  
  # Display Current Samples by Service
  conditionalPanel(
    condition = "(input.service_category == 'sequencing' && input.sequencing_services && input.sequencing_services.length > 0) || (input.service_category == 'cab' && input.cab_services && input.cab_services.length > 0)",
    wellPanel(
      h3("Current Samples in Order"),
      uiOutput("all_service_tables"),
      br(),
      fluidRow(
        column(6,
               actionButton("clear_samples", "Clear All Samples", class = "btn-warning")
        ),
        column(6,
               downloadButton("download_order", "Download Order", class = "btn-success")
        )
      )
    )
  )
)

# ==================== SERVER ====================
server <- function(input, output, session) {
  
  # Store samples for each service separately
  samples_by_service <- reactiveValues()
  
  # Reactive to get all selected services
  selected_services <- reactive({
    if (input$service_category == "sequencing") {
      return(input$sequencing_services)
    } else if (input$service_category == "cab") {
      return(input$cab_services)
    }
    return(NULL)
  })
  
  # Function to generate well location
  get_next_well <- function(sample_number) {
    if (sample_number > 94) {
      return(paste0("OVERFLOW_", sample_number))
    }
    row <- ((sample_number - 1) %% 8) + 1
    col <- ceiling(sample_number / 8)
    row_letter <- LETTERS[row]
    col_number <- sprintf("%02d", col)
    return(paste0(row_letter, col_number))
  }
  
  # Get columns for specific service
  get_service_columns <- function(service_type, species) {
    base_cols <- c("Sample_ID", "Well_Location", "Species")
    
    # Human-specific columns
    if (species == "Human") {
      base_cols <- c(base_cols, "Human_Derived", "Tissue_Bank_Number", "SJUID", "Alternative_Number")
    }
    
    # Service-specific columns
    if (service_type == "chipseq") {
      base_cols <- c(base_cols, "LabID_ChIPseq", "Group", "Group_Diff2", "PeakCaller", "INPUT")
    } else if (service_type == "atacseq") {
      base_cols <- c(base_cols, "LabID_ATACseq", "Group")
    } else if (service_type == "transcriptomics") {
      base_cols <- c(base_cols, "LabID_Transcriptomics", "Group", "Analysis_Type")
    } else if (service_type == "hichip") {
      base_cols <- c(base_cols, "LabID_HiChIP", "Group", "Bait_Region_Coordinates")
    }
    
    # Common optional columns
    base_cols <- c(base_cols, "Genotype", "Treatment", "Condition", "Description")
    
    return(base_cols)
  }
  
  # Generate single entry fields dynamically
  output$single_entry_fields <- renderUI({
    services <- selected_services()
    req(services, input$species)
    
    fields <- list(
      textInput("sample_id", "Sample ID *", placeholder = "e.g., MYSEQ101")
    )
    
    # Human-derived questions
    if (input$species == "Human") {
      fields <- c(fields, list(
        radioButtons("human_derived", "Is this a Human Derived Sample? *",
                     choices = c("Yes - Tissue Bank #" = "tissue_bank",
                                 "Yes - SJUID/Alt #" = "sjuid",
                                 "No" = "no"),
                     selected = character(0)),
        conditionalPanel(
          condition = "input.human_derived == 'tissue_bank'",
          textInput("tissue_bank_num", "Tissue Bank Number *")
        ),
        conditionalPanel(
          condition = "input.human_derived == 'sjuid'",
          textInput("sjuid", "SJUID *"),
          textInput("alt_num", "Alternative Number")
        )
      ))
    }
    
    # Add fields for each selected service
    if ("chipseq" %in% services) {
      fields <- c(fields, list(
        hr(),
        h5("ChIPseq Fields"),
        textInput("labid_chipseq", "LabID (ChIPseq) *", 
                  placeholder = "Use antibody name as prefix"),
        textInput("group_chipseq", "Group *", 
                  placeholder = "Use unique names (e.g., HEK293_noTreatment)"),
        textInput("group_diff2_chipseq", "Group_Diff2 (optional)"),
        selectInput("peakcaller", "PeakCaller *",
                    choices = c("auto (default)" = "auto", "sharp", "broad"),
                    selected = "auto"),
        selectInput("input_type", "INPUT *",
                    choices = c("auto (best in current batch)" = "auto",
                                "archive (best in all batches)" = "archive",
                                "Specific Sample ID" = "specific"),
                    selected = "auto"),
        conditionalPanel(
          condition = "input.input_type == 'specific'",
          textInput("input_sample_id", "INPUT Sample ID *")
        )
      ))
    }
    
    if ("atacseq" %in% services) {
      fields <- c(fields, list(
        hr(),
        h5("ATACseq Fields"),
        textInput("labid_atacseq", "LabID (ATACseq) *"),
        textInput("group_atacseq", "Group *")
      ))
    }
    
    if ("transcriptomics" %in% services) {
      fields <- c(fields, list(
        hr(),
        h5("Transcriptomics Fields"),
        textInput("labid_transcriptomics", "LabID (Transcriptomics) *"),
        textInput("group_transcriptomics", "Group *"),
        selectInput("analysis_type", "Analysis Type *",
                    choices = c("One variable", "Paired design", "Multiple batch",
                                "Multiple factor", "Longitudinal study", 
                                "Not sure - need assistance"))
      ))
    }
    
    if ("hichip" %in% services) {
      fields <- c(fields, list(
        hr(),
        h5("HiC/HiChIP Fields"),
        textInput("labid_hichip", "LabID (HiC/HiChIP) *",
                  placeholder = "Use antibody name as prefix for HiChIP/PLACSeq"),
        textInput("group_hichip", "Group *"),
        textInput("bait_coordinates", "Bait Region Coordinates *",
                  placeholder = "Coordinates and genome version (e.g., Hg38)")
      ))
    }
    
    # Common fields
    fields <- c(fields, list(
      hr(),
      h5("Common Fields (Optional)"),
      textInput("genotype", "Genotype"),
      textInput("treatment", "Treatment"),
      textInput("condition", "Condition"),
      textInput("description", "Description")
    ))
    
    do.call(tagList, fields)
  })
  
  # Add single sample
  observeEvent(input$add_sample, {
    services <- selected_services()
    req(services, input$species, input$sample_id)
    
    # Basic validation
    if (input$species == "Human" && is.null(input$human_derived)) {
      showNotification("Please specify if this is a human-derived sample", type = "error")
      return()
    }
    
    # Add sample to each selected service
    for (service in services) {
      
      # Initialize service data if needed
      if (is.null(samples_by_service[[service]])) {
        samples_by_service[[service]] <- data.frame()
      }
      
      # Get current count for well assignment
      current_count <- nrow(samples_by_service[[service]])
      well_location <- get_next_well(current_count + 1)
      
      # Create new row with basic info
      new_row <- data.frame(
        Sample_ID = input$sample_id,
        Well_Location = well_location,
        Species = input$species,
        stringsAsFactors = FALSE
      )
      
      # Add human-specific data
      if (input$species == "Human") {
        new_row$Human_Derived <- input$human_derived
        new_row$Tissue_Bank_Number <- if(!is.null(input$tissue_bank_num) && input$human_derived == "tissue_bank") input$tissue_bank_num else NA
        new_row$SJUID <- if(!is.null(input$sjuid) && input$human_derived == "sjuid") input$sjuid else NA
        new_row$Alternative_Number <- if(!is.null(input$alt_num) && input$human_derived == "sjuid") input$alt_num else NA
      }
      
      # Add service-specific data
      if (service == "chipseq") {
        new_row$LabID_ChIPseq <- input$labid_chipseq
        new_row$Group <- input$group_chipseq
        new_row$Group_Diff2 <- input$group_diff2_chipseq
        new_row$PeakCaller <- input$peakcaller
        new_row$INPUT <- if(input$input_type == "specific") input$input_sample_id else input$input_type
      } else if (service == "atacseq") {
        new_row$LabID_ATACseq <- input$labid_atacseq
        new_row$Group <- input$group_atacseq
      } else if (service == "transcriptomics") {
        new_row$LabID_Transcriptomics <- input$labid_transcriptomics
        new_row$Group <- input$group_transcriptomics
        new_row$Analysis_Type <- input$analysis_type
      } else if (service == "hichip") {
        new_row$LabID_HiChIP <- input$labid_hichip
        new_row$Group <- input$group_hichip
        new_row$Bait_Region_Coordinates <- input$bait_coordinates
      }
      
      # Add common fields
      new_row$Genotype <- input$genotype
      new_row$Treatment <- input$treatment
      new_row$Condition <- input$condition
      new_row$Description <- input$description
      
      # Add to service data
      samples_by_service[[service]] <- rbind(samples_by_service[[service]], new_row)
    }
    
    showNotification(paste("Sample added to", length(services), "service(s)!"), type = "message")
    
    # Clear sample ID
    updateTextInput(session, "sample_id", value = "")
  })
  
  # Process bulk list
  observeEvent(input$process_bulk, {
    services <- selected_services()
    req(input$bulk_list, services, input$species)
    
    sample_ids <- unlist(strsplit(input$bulk_list, "[,\n]"))
    sample_ids <- trimws(sample_ids)
    sample_ids <- sample_ids[sample_ids != ""]
    
    if (length(sample_ids) == 0) {
      showNotification("No sample IDs found", type = "error")
      return()
    }
    
    # Add to each selected service
    for (service in services) {
      if (is.null(samples_by_service[[service]])) {
        samples_by_service[[service]] <- data.frame()
      }
      
      current_count <- nrow(samples_by_service[[service]])
      
      new_samples <- data.frame(
        Sample_ID = sample_ids,
        Well_Location = sapply(seq_along(sample_ids), function(i) get_next_well(current_count + i)),
        Species = input$species,
        stringsAsFactors = FALSE
      )
      
      # Add placeholder columns
      cols <- get_service_columns(service, input$species)
      for (col in cols) {
        if (!col %in% names(new_samples)) {
          new_samples[[col]] <- NA
        }
      }
      
      samples_by_service[[service]] <- rbind(samples_by_service[[service]], new_samples)
    }
    
    showNotification(paste(length(sample_ids), "samples added to", length(services), "service(s)!"), 
                     type = "message")
    updateTextAreaInput(session, "bulk_list", value = "")
  })
  
  # Process file upload
  observeEvent(input$process_file, {
    services <- selected_services()
    req(input$file_upload, services)
    
    file_path <- input$file_upload$datapath
    file_ext <- tools::file_ext(input$file_upload$name)
    
    tryCatch({
      if (file_ext == "csv") {
        uploaded <- read.csv(file_path, stringsAsFactors = FALSE)
      } else if (file_ext %in% c("xlsx", "xls")) {
        uploaded <- as.data.frame(read_excel(file_path))
      } else {
        showNotification("Unsupported file type", type = "error")
        return()
      }
      
      # Add to each selected service
      for (service in services) {
        if (is.null(samples_by_service[[service]])) {
          samples_by_service[[service]] <- data.frame()
        }
        
        current_count <- nrow(samples_by_service[[service]])
        uploaded_copy <- uploaded
        
        if (!"Well_Location" %in% names(uploaded_copy)) {
          uploaded_copy$Well_Location <- sapply(1:nrow(uploaded_copy), 
                                                function(i) get_next_well(current_count + i))
        }
        
        samples_by_service[[service]] <- rbind(samples_by_service[[service]], uploaded_copy)
      }
      
      showNotification(paste(nrow(uploaded), "samples uploaded to", length(services), "service(s)!"), 
                       type = "message")
    }, error = function(e) {
      showNotification(paste("Error reading file:", e$message), type = "error")
    })
  })
  
  # Display tables for each service
  output$all_service_tables <- renderUI({
    services <- selected_services()
    req(services)
    
    tables <- lapply(services, function(service) {
      service_name <- switch(service,
                             "illumina" = "Illumina Sequencing",
                             "pacbio" = "PacBio Long Read",
                             "methylation" = "Mapping and Methylation",
                             "chipseq" = "CAB ChIPseq",
                             "atacseq" = "CAB ATACseq",
                             "transcriptomics" = "CAB Transcriptomics",
                             "hichip" = "CAB HiC/HiChIP",
                             service
      )
      
      data <- samples_by_service[[service]]
      if (is.null(data) || nrow(data) == 0) {
        data <- data.frame(Message = paste("No samples for", service_name))
      }
      
      tagList(
        h4(service_name),
        DTOutput(paste0("table_", service)),
        p(paste("Samples:", if(is.null(samples_by_service[[service]])) 0 else nrow(samples_by_service[[service]]))),
        hr()
      )
    })
    
    do.call(tagList, tables)
  })
  
  # Render individual service tables
  observe({
    services <- selected_services()
    req(services)
    
    for (service in services) {
      local({
        srv <- service
        output[[paste0("table_", srv)]] <- renderDT({
          data <- samples_by_service[[srv]]
          if (is.null(data) || nrow(data) == 0) {
            return(data.frame(Message = "No samples yet"))
          }
          datatable(data, options = list(pageLength = 5))
        })
      })
    }
  })
  
  # Clear all samples
  observeEvent(input$clear_samples, {
    services <- selected_services()
    for (service in services) {
      samples_by_service[[service]] <- data.frame()
    }
    showNotification("All samples cleared", type = "warning")
  })
  
  # Download order
  output$download_order <- downloadHandler(
    filename = function() {
      services <- selected_services()
      paste0("Hartwell_Order_", paste(services, collapse = "_"), "_", Sys.Date(), ".xlsx")
    },
    content = function(file) {
      services <- selected_services()
      order_data <- list(
        Order_Info = data.frame(
          Service_Category = input$service_category,
          Services = paste(services, collapse = ", "),
          Species = input$species,
          Reference_Genome = input$reference_genome,
          Xenograft = input$xenograft,
          Submission_Date = Sys.Date()
        )
      )
      
      # Add each service's samples as a separate sheet
      for (service in services) {
        if (!is.null(samples_by_service[[service]]) && nrow(samples_by_service[[service]]) > 0) {
          order_data[[service]] <- samples_by_service[[service]]
        }
      }
      
      write_xlsx(order_data, file)
    }
  )
}

shinyApp(ui, server)