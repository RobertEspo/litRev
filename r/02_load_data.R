# Load .bib directory
bib_directory <- here("bibtex")

# List .bib files in directory
bib_files <- list.files(bib_directory, pattern = ".bib$", full.names = TRUE)

# Extract file names with suffixes from paths
bib_file_names <- basename(bib_files)

# Process the BibTeX files and capture entries and errors
results <- process_bib_files(bib_files)

# Extract the entries and errors data frames
entries_df <- results$entries
errors_df <- results$errors

# Combine all dfs from all .bib files into one df
lit_df <- bind_rows(entries_df) %>%
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

# Run split_summaries() to split summaries.txt into individual files in the "all_summaries" folder
split_summaries(here("summaries", "summaries.txt"), here("summaries", "all_summaries"))

# Split .bib files in bibtex into individual .bib files for each entry
split_bib_files(bib_directory, here("bibtex","all_bibtex"))

# Split keywords.txt into individual .txt files for each entry
split_keywords(here("keywords", "keywords.txt"), here("keywords", "all_keywords"))