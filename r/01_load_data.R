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
    entry_df <- rownames_to_column(entry_df, var = "key")  # Add row names as a new column
    entry_df$project <- file_name  # Add the project (file name)
    return(entry_df)
  })
  
  # Combine the dfs
  bind_rows(entry_dfs)
}

# Process directory
all_entries <- lapply(bib_files, convert_to_df)

# Combine all dfs from all .bib files into one data frame
lit_df <- bind_rows(all_entries) %>%
  group_by(key) %>%  # Group by key instead of title
  mutate(project = paste(unique(project), collapse = ", ")) %>%
  ungroup() %>%
  distinct()

# Extract unique project names
all_projects <- lit_df %>%
  pull(project) %>%
  str_split(",\\s*") %>%  # Split by commas with optional spaces
  unlist() %>%  # Flatten the list
  unique() %>%  # Get unique values
  sort()  # Sort alphabetically