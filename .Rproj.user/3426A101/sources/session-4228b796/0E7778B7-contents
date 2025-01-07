##############################################################################

# Function to convert .bib files to a data frame and capture errors
process_bib_files <- function(bib_files) {
  all_entries <- data.frame()
  all_errors <- data.frame(
    project = character(),
    line = integer(),
    key = character(),
    error = character(),
    stringsAsFactors = FALSE
  )
  
  for (bib_file in bib_files) {
    errors <- data.frame(
      project = character(),
      line = integer(),
      key = character(),
      error = character(),
      stringsAsFactors = FALSE
    )
    
    # Function to capture warnings and messages
    capture_warnings <- function(w) {
      # Extract the message
      message_text <- conditionMessage(w)
      
      # Regular expression to capture the key, line number, and error message
      regex <- "Ignoring entry '([^']+)'\\s*\\(line(\\d+)\\)\\s*because:\\s*(.+)"
      
      if (grepl(regex, message_text)) {
        key <- sub(regex, "\\1", message_text)
        line <- as.integer(sub(regex, "\\2", message_text))
        error_message <- sub(regex, "\\3", message_text)
        
        # Add to the errors data frame
        errors <<- rbind(errors, data.frame(
          project = basename(bib_file),  # Add the project column with the file name
          line = line,
          key = key,
          error = error_message,
          stringsAsFactors = FALSE
        ))
      }
    }
    
    # Use tryCatch and withCallingHandlers to capture warnings and errors
    tryCatch({
      withCallingHandlers({
        # Attempt to read the BibTeX file
        bib_entries <- ReadBib(bib_file)
        
        # Convert each entry to a df and add file name as a new column
        entry_dfs <- lapply(bib_entries, function(entry) {
          entry_df <- as.data.frame(as.list(entry), stringsAsFactors = FALSE)
          entry_df <- rownames_to_column(entry_df, var = "key")  # Add row names as a new column
          entry_df$project <- basename(bib_file)  # Add the project (file name)
          return(entry_df)
        })
        
        # Combine the entry data frames
        if (length(entry_dfs) > 0) {
          all_entries <- bind_rows(all_entries, bind_rows(entry_dfs))
        }
      }, warning = capture_warnings, message = capture_warnings)
    }, error = function(e) {
      # Capture any errors during reading the BibTeX file
      errors <<- rbind(errors, data.frame(
        project = basename(bib_file),  # Add the project column with the file name
        line = NA,
        key = "N/A",
        error = conditionMessage(e),
        stringsAsFactors = FALSE
      ))
    })
    
    # Combine the errors data frame
    all_errors <- bind_rows(all_errors, errors)
  }
  
  return(list(entries = all_entries, errors = all_errors))
}

##############################################################################

# Function to load and split summaries.txt
split_summaries <- function(file_path, output_dir) {
  summaries <- readLines(file_path)
  key <- NULL
  title <- NULL
  author <- NULL
  summary_content <- NULL
  
  for (line in summaries) {
    if (startsWith(line, "#")) {  # Check if it's a heading
      if (!is.null(key)) {
        # Save the previous summary content to a file (without title and author)
        writeLines(summary_content, file.path(output_dir, paste0(key, ".txt")))
      }
      # Update key and reset summary_content
      key <- gsub("^#\\s*", "", line)
      summary_content <- NULL
    } else if (startsWith(line, "Title:")) {
      # Extract title if line starts with "Title:"
      title <- gsub("^Title:\\s*", "", line)
    } else if (startsWith(line, "Author:")) {
      # Extract author if line starts with "Author:"
      author <- gsub("^Author:\\s*", "", line)
    } else {
      summary_content <- c(summary_content, line)
    }
  }
  
  # Save the last summary
  if (!is.null(key)) {
    writeLines(summary_content, file.path(output_dir, paste0(key, ".txt")))
  }
}

##############################################################################