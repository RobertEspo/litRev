##############################################################################
  ### Function to convert .bib files to a data frame and capture errors ###
##############################################################################

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
  ### Function to split summaries.txt ###
##############################################################################

split_summaries <- function(file_path, output_dir) {
  summaries <- readLines(file_path)
  key <- NULL
  title <- NULL
  author <- NULL
  summary_content <- NULL
  
  for (line in summaries) {
    if (startsWith(line, "#")) {  # Check if it's a heading
      if (!is.null(key)) {
        # Trim whitespace from each line of the summary content
        summary_content <- trimws(summary_content)
        # Remove empty lines
        summary_content <- summary_content[summary_content != ""]
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
    # Trim whitespace from each line of the summary content
    summary_content <- trimws(summary_content)
    # Remove empty lines
    summary_content <- summary_content[summary_content != ""]
    writeLines(summary_content, file.path(output_dir, paste0(key, ".txt")))
  }
}

##############################################################################
  ### Function to combine individual summaries and save them ###
##############################################################################

combine_summaries <- function(summary_dir, output_file) {
  summary_files <- list.files(file.path(summary_dir, "all_summaries"), full.names = TRUE)
  
  combined_summaries <- lapply(summary_files, function(file) {
    # Retrieve key from file name
    key <- gsub(".txt$", "", basename(file))
    
    # Retrieve title and author from lit_df
    title <- lit_df %>% filter(key == !!key) %>% pull(title)
    author <- lit_df %>% filter(key == !!key) %>% pull(author)
    
    # Handle cases where title or author is missing
    title <- ifelse(length(title) > 0, title, "Unknown Title")
    author <- ifelse(length(author) > 0, author, "Unknown Author")
    
    c(paste0("# ", key), paste0("Title: ", title), paste0("Author: ", author), readLines(file), "")
  })
  
  combined_summaries <- unlist(combined_summaries)
  writeLines(combined_summaries, file.path(summary_dir, output_file))
}

##############################################################################
  ### Function to split .bib files from .bib directory  ###
  ### into individual .bib files for each BibTeX entry  ###
##############################################################################

split_bib_files <- function(source_dir, dest_dir) {
  # Ensure the destination directory exists
  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }
  
  # Get all .bib files in the source directory
  bib_files <- list.files(source_dir, pattern = "\\.bib$", full.names = TRUE)
  
  # Create a list to keep track of entries and their source files
  entry_sources <- list()
  
  # Process each .bib file
  for (bib_file in bib_files) {
    # Read the .bib file as a text file
    bib_content <- readLines(bib_file, warn = FALSE)
    
    # Initialize variables to store entry data
    entry_lines <- c()
    entry_key <- NULL
    
    for (line in bib_content) {
      # Check if the line starts a new entry
      if (grepl("^@", line)) {
        # If there is an existing entry, add it to entry_sources and write it to a file
        if (!is.null(entry_key) && length(entry_lines) > 0) {
          # Add source file to the entry_sources list
          if (!is.null(entry_sources[[entry_key]])) {
            entry_sources[[entry_key]] <- c(entry_sources[[entry_key]], basename(bib_file))
          } else {
            entry_sources[[entry_key]] <- basename(bib_file)
          }
          
          # Create the individual .bib file
          individual_bib_file <- file.path(dest_dir, paste0(entry_key, ".bib"))
          
          # Add metadata about the source files
          metadata <- paste0("% ", paste(entry_sources[[entry_key]], collapse = ", "))
          entry_lines <- c(metadata, entry_lines)
          
          # Write the entry to the individual .bib file
          writeLines(entry_lines, con = individual_bib_file)
        }
        
        # Reset entry data for the new entry
        entry_lines <- c()
        entry_key <- NULL
        
        # Extract the key from the line
        if (grepl("@.*\\{.*,", line)) {
          entry_key <- sub("@.*\\{([^,]+),.*", "\\1", line)
        }
      }
      
      # Add the current line to the entry data
      entry_lines <- c(entry_lines, line)
    }
    
    # Write the last entry to a file
    if (!is.null(entry_key) && length(entry_lines) > 0) {
      # Add source file to the entry_sources list
      if (!is.null(entry_sources[[entry_key]])) {
        entry_sources[[entry_key]] <- c(entry_sources[[entry_key]], basename(bib_file))
      } else {
        entry_sources[[entry_key]] <- basename(bib_file)
      }
      
      # Create the individual .bib file
      individual_bib_file <- file.path(dest_dir, paste0(entry_key, ".bib"))
      
      # Add metadata about the source files
      metadata <- paste0("% ", paste(entry_sources[[entry_key]], collapse = ", "))
      entry_lines <- c(metadata, entry_lines)
      
      # Write the entry to the individual .bib file
      writeLines(entry_lines, con = individual_bib_file)
    }
  }
}

##############################################################################
  ### combine individual .bib files into project .bib ###
##############################################################################

combine_bib_files <- function(input_dir, output_dir) {
  # List all .bib files in the input directory
  bib_files <- list.files(input_dir, pattern = "\\.bib$", full.names = TRUE)
  
  # Create a list to store the content for each project
  project_contents <- list()
  
  # Read and process each .bib file
  for (file in bib_files) {
    # Read the content of the file
    bib_content <- readLines(file, warn = FALSE)
    
    # Extract the first line which contains the project names
    project_line <- bib_content[1]
    projects <- unlist(strsplit(sub("^% ", "", project_line), ", "))
    
    # Remove the first line from the bib content
    bib_content <- bib_content[-1]
    
    # Append the bib content to each project file
    for (project in projects) {
      if (!is.null(project_contents[[project]])) {
        project_contents[[project]] <- c(project_contents[[project]], bib_content)
      } else {
        project_contents[[project]] <- bib_content
      }
    }
  }
  
  # Write the combined content to the respective project files in the output directory
  for (project in names(project_contents)) {
    output_file <- file.path(output_dir, project)
    writeLines(project_contents[[project]], output_file)
  }
}

##############################################################################
### format keywords for .txt entries ###
##############################################################################

# Process and format the captured keywords text
format_keywords <- function(text) {
  # Extract keywords from the input text
  keywords <- unlist(strsplit(text, "\\s|,"))
  # Remove empty strings
  keywords <- keywords[keywords != ""]
  # Trim any leading or trailing whitespace from each keyword
  keywords <- trimws(keywords)
  # Join keywords with a comma and space
  formattedKeywords <- paste(keywords, collapse = ", ")
  formattedKeywords
}

##############################################################################
### split keywords.txt ###
##############################################################################

split_keywords <- function(file_path, output_dir) {
  keywords <- readLines(file_path)
  key <- NULL
  title <- NULL
  author <- NULL
  keywords_content <- NULL
  
  for (line in keywords) {
    if (startsWith(line, "#")) {  # Check if it's a heading
      if (!is.null(key)) {
        # Trim whitespace from each line of the summary content
        keywords_content <- trimws(keywords_content)
        # Remove empty lines
        keywords_content <- keywords_content[keywords_content != ""]
        # Save the previous summary content to a file (without title and author)
        writeLines(keywords_content, file.path(output_dir, paste0(key, ".txt")))
      }
      # Update key and reset summary_content
      key <- gsub("^#\\s*", "", line)
      keywords_content <- NULL
    } else if (startsWith(line, "Title:")) {
      # Extract title if line starts with "Title:"
      title <- gsub("^Title:\\s*", "", line)
    } else if (startsWith(line, "Author:")) {
      # Extract author if line starts with "Author:"
      author <- gsub("^Author:\\s*", "", line)
    } else {
      keywords_content <- c(keywords_content, line)
    }
  }
  
  # Save the last keywords
  if (!is.null(key)) {
    # Trim whitespace from each line of the summary content
    keywords_content <- trimws(keywords_content)
    # Remove empty lines
    keywords_content <- keywords_content[keywords_content != ""]
    writeLines(keywords_content, file.path(output_dir, paste0(key, ".txt")))
  }
}

##############################################################################
### combine individual keywords .txt files into keywords.txt ###
##############################################################################

combine_keywords <- function(keywords_dir, output_file) {
  keywords_files <- list.files(file.path(keywords_dir, "all_keywords"), full.names = TRUE)
  
  combined_keywords <- lapply(keywords_files, function(file) {
    # Retrieve key from file name
    key <- gsub(".txt$", "", basename(file))
    
    # Retrieve title and author from lit_df
    title <- lit_df %>% filter(key == !!key) %>% pull(title)
    author <- lit_df %>% filter(key == !!key) %>% pull(author)
    
    # Handle cases where title or author is missing
    title <- ifelse(length(title) > 0, title, "Unknown Title")
    author <- ifelse(length(author) > 0, author, "Unknown Author")
    
    c(paste0("# ", key), paste0("Title: ", title), paste0("Author: ", author), readLines(file), "")
  })
  
  combined_keywords <- unlist(combined_keywords)
  writeLines(combined_keywords, file.path(keywords_dir, output_file))
}