# LitRev
Author: Robert Esposito

A Shiny App to help aggregate and organize summaries for literature reviews across various projects.

# Setting up LitRev

## bibtex

Place your .bib files in this folder. It is best to name your .bib file for the project you're working on, as you will be able to see which references you used in which projects in the app. If there are repeated references across projects, the app will list all of project names in which they appear.

## pdfs

Put PDF files of your references into the "pdfs" folder. Make sure it is named after your citation/entry key. For example, if your bibtex citation is:

@book{cruttenden1997intonation,
  title={Intonation},
  author={Cruttenden, Alan},
  year={1997},
  publisher={Cambridge University Press}
}

your pdf file must be named cruttenden1997intonation.pdf.

## summaries

All summaries are stored in the file summaries.txt. All summaries must be structured with a header, indicated by #, named after the citation/entry key e.g., cruttenden1997intonation. You can update this file outside of the app.

### all_summaries

Stores individual .txt files of all summaries. You can update these files outside of the app.

## r

### 00_libs.R

Stores libs used.

### 01_load_data.R

Loads .bib and .pdf files for Shiny app from folders bibtex and pdfs.

### 02_app.R

Shiny app. Feel free to modify as you see fit.

## Running litRev

Open litRev.R and run the two lines of code. The app will launch. It is advised to not open it in your browser.

Search the References table by title, author, or project.

You can change visibility of columns, which includes all information pulled from the bibtex entries.





