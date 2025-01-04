# Load .bib directory
bib_directory <- here("bibtex")

# List .bib files in directory
bib_files <- list.files(bib_directory, pattern = ".bib$", full.names = TRUE)

# Function to convert each entry to a data frame
convert_to_df <- function(bib_file) {
  # Read the .bib file
  bib_data <- ReadBib(bib_file)
  
  # Get the base name of the file
  file_name <- tools::file_path_sans_ext(basename(bib_file))
  
  # Convert each entry to a df and add file name as a new column
  entry_dfs <- lapply(bib_data, function(entry) {
    entry_df <- as.data.frame(as.list(entry), stringsAsFactors = FALSE)
    entry_df$project <- file_name  # Add the project (file name)
    return(entry_df)
  })
  
  # Combine the dfs
  bind_rows(entry_dfs)
}

# Process directory
all_entries <- lapply(bib_files, convert_to_df)

# Combine all dfs from all .bib files into one data frame
combined_df <- bind_rows(all_entries)

# Group by the reference and combine the project names
lit_df <- combined_df %>%
  group_by(title) %>%
  mutate(project = paste(unique(project), collapse = ", ")) %>%
  ungroup()