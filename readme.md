# LitRev
Author: Robert Esposito
Date: `r Sys.Date()` 

This shiny app helps to aggregate and organize references and summaries for literature reviews across various projects.

# Setting up LitRev

## bibtex

Place your .bib files in this folder. It is best to name your .bib file for the project you're working on, as you will be able to see which references you used in which projects in the app. If there are repeated references across projects, the app will list all of project names in which they appear.

## pdfs

Put PDF files of your references into the "pdfs" folder. Make sure it is named after your citation/entry key. For example, if your BibTeX citation is:

@book{esposito2025citations,
  title={Citations and Summaries},
  author={Esposito, Robert},
  year={2025},
  publisher={R Studio Press}
}

your PDF file must be named esposito2025citations.pdf.

## summaries

All summaries are stored in the file summaries.txt. All summaries must be structured with a header, indicated by #, named after the citation/entry key e.g., esposito2025citations.

You can update summaries.txt outside of the app. You SHOULD NOT update the .txt files in all_summaries outside of the app. Changes to any .txt files in all_summaries will be rewritten from summaries.txt when you open app.

### all_summaries

Stores individual .txt files of all summaries. You SHOULD NOT update these files, as any changes will be rewritten when you open the app.

## r

### 00_libs.R

Stores libaries used.

### 01_functions.R

Stores functions used.

### 02_load_data.R

Loads and processes .bib files for shiny app from bibtex folder.

### 03_app.R

Shiny app. Feel free to modify as you see fit.

## Running litRev

Open litRev.R from the main directory and run the two lines of code. The app will launch. You should not open this in your browser, as many of the functionalities will be lost.

### Home

There are four panels on the home page.

The bottom right quadrant is a table of all references used across all projects. You can change the column visibility to include all information extracted from the BibTeX entries. The "project" column displays the .bib file(s) in which the reference was found. You can filter by title, author, and project in the bottom left quadrant.

If you click on a row in the References table, the summary for it will display in the top left quadrant. To save the summary, click "Save Summary" or simply click on a different row. When you have finished adding all of your summaries and saving them, click "Combine Summaries" and then "Download Summaries". When you use "Combine Summaries", the title and author(s) of the references are automatically added to the combined .txt file, summaries.txt.

The top right column is used to add a BibTeX entry to a specified .bib file.

### Summaries

This page displays all summaries in summaries.txt. It can be filtered by project.

### BibTeX Errors

If a BibTeX entry failed to load for some reason, it will be displayed in the table here.