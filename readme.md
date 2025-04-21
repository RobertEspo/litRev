
# litRev

Author: Robert Esposito

Last updated: April 21, 2025

This shiny app helps to aggregate and organize references and summaries
for literature reviews across various projects.

# Setting up litRev

## bibtex

Place your `.bib` files in this folder. It is best to name your `.bib`
file for the project you’re working on, as you will be able to see which
references you used in which projects in the app. If there are repeated
references across projects, the app will list all of project names in
which they appear.

## pdfs

Put `.pdf` files of your references into the “pdfs” folder. Make sure it
is named after your citation/entry key. For example, if your BibTeX
citation is:

    @book{esposito2025citations,
      title={Citations and Summaries},
      author={Esposito, Robert},
      year={2025},
      publisher={R Studio Press}
    }

your `.pdf` file must be named `esposito2025citations.pdf`.

## summaries

All summaries are stored in the file `summaries.txt`. If you manually
enter a summary into `summaries.txt`, it is obligatory to add the
citation/entry key as a header with `#`:

    # esposito2025citations

    Here is the summary of the selected article.

If you add a summary through the litRev app, the citation/entry key,
title, and author(s) will be automatically added:

    # esposito2025citations
    Title: Citations and Summaries
    Author: Robert Esposito
    Here is the summary of the selected article.

### all_summaries

Stores individual `.txt` files of all summaries. You SHOULD NOT update
these files. Changes to any `.txt` files in `all_summaries` will be
rewritten from `summaries.txt` as soon as you open the app.

## keywords

All keywords are stored in the file keywords.txt. Identical to
`summaries.txt`, you may update `keywords.txt` outside of the app. You
must include the citation/entry key as a header preceded by `#`.
Keywords must be separated by commas.

    # esposito2025citations
    here, are, some, keywords

### all_keywords

Stores individual `.txt` files of all keywords. You SHOULD NOT update
these files. Changes to any `.txt` files in `all_keywords` will be
rewritten from `keywords.txt` as soon as you open the app.

# Running litRev

Open litRev.R from the main directory and run the two lines of code. The
app will launch. You should not open this in your browser, as many of
the functionalities will be lost.

## Home

The Home page has four panels and is meant to be where you work most
often.

The top-left summary panel has a textbox to enter the summary for each
reference, as well as add keywords.

The bottom-left panel filters the references.

The top-left panel allows you to add BibTeX entries to a specified
project.

The bottom-right entry is your database of referneces. Click on the
title of the reference to open the PDF. Click on a reference’s row to
open the summary and keywords in the top-left Summary panel.

## Summaries

This page lists all of your references and allows you to view, but not
edit, the summaries for them. You can filter by project.

## BibTeX Errors

If any BibTeX entries did not load into the program, you can view them
here and what the issue is. If you click on a row, it will pull up the
BibTeX entry, which you can then correct.

## BibTeX Editor

You can use this page to update BibTeX entries.

## Output

This page allows you to select a project and output a folder that will
hold all files associated with the project. It will output a `.bib`
file, a folder of `.pdf` files, and a `.txt` file of summaries.

# Updating LitRev

Place your `pdfs`, `bibtex`, `summaries` and `keywords` folders
somewhere else (e.g., your desktop). Update litRev repository. Replace
your original folders into the updated repo.

## Basic organization

    .
    ├── bibtex
    ├── keywords
    ├── litRev.R
    ├── litRev.Rproj
    ├── pdfs
    ├── r
    ├── readme.md
    ├── readme.Rmd
    └── summaries

    r
    ├── 00_libs.R
    ├── 01_functions.R
    ├── 02_load_data.R
    ├── app.R
    ├── modules
    │   ├── bibtex_editor_page
    │   │   ├── bibtex_editor_page_server.R
    │   │   └── bibtex_editor_page_ui.R
    │   ├── bibtex_errors_page
    │   │   ├── bibtex_errors_page_server.R
    │   │   └── bibtex_errors_page_ui.R
    │   ├── home_page
    │   │   ├── home_page_server.R
    │   │   └── home_page_ui.R
    │   ├── output_page
    │   │   ├── output_page_server.R
    │   │   └── output_page_ui.R
    │   └── summaries_page
    │       ├── summaries_page_server.R
    │       └── summaries_page_ui.R
    └── www
        ├── custom.css
        ├── custom.js
        └── styles.css
