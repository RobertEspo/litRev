# LitRev
Author: Robert Esposito
Last updated: Feb 2, 2025

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

## keywords

All keywords are stored in the file keywords.txt. All keywords must be structured with a header, indicated by #, named after the citation/entry key e.g., esposito2025citations.

You can update keywords.txt outside of the app. You SHOULD NOT update the .txt files in all_keywords outside of the app. Changes to any .txt files in all_keywords will be rewritten from keywords.txt when you open app.

## Running litRev

Open litRev.R from the main directory and run the two lines of code. The app will launch. You should not open this in your browser, as many of the functionalities will be lost.

### Home

The Home page has four panels and is meant to be where you work most often.

The top-left summary panel has a textbox to enter the summary for each reference, as well as add keywords.

The bottom-left panel filters the references.

The top-left panel allows you to add BibTeX entries to a specified project.

The bottom-right entry is your database of referneces. Click on the title of the reference to open the PDF. Click on a reference's row to open the summary and keywords in the top-left Summary panel.

### Summaries

This page lists all of your references and allows you to view, but not edit, the summaries for them. You can filter by project.

### BibTeX Errors

If any BibTeX entries did not load into the program, you can view them here and what the issue is. If you click on a row, it will pull up the BibTeX entry, which you can then correct.

### BibTeX Editor

You can use this page to update BibTeX entries.

### Visualizations

Not yet functional. Will update in future.

# Updating LitRev

Place your pdf, BibTeX, summaries and keywords folders somewhere else (e.g., your desktop). Update LitRev repository. Replace your original folders into the updated repo.

# Future goals

- Think of nice visualizations for the visualization panel.
- Try to add functionalities from something like rscopus, R-citations.
- Add functionality to add projects from the GUI.