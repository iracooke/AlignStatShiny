
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

  

  # Sidebar with a slider input for number of bins
  verticalLayout(
    titlePanel("AlignStat: A tool for the statistical comparison of alternative multiple sequence alignments"),

    wellPanel(
      div(class="header",
        p("This webtool compares two alternative multiple sequence alignments (MSAs) to determine how well 
          they align homologous residues in the same columns as one another. It classifies similarities 
          and differences into conserved sequence, conserved gaps, splits, merges and shifts. 
          Summarising these categories for each column yields information on which columns are agreed 
          upon by both MSAs, and which differ. Output graphs visualise the comparison data for analysis."),
        p("AlignStat was developed by Thomas Shafee, Ira Cooke and Marylin Anderson at ",
          a(href="http://www.latrobe.edu.au/lims","La Trobe Institute of Molecular Science (LIMS)")," and ",
            a(href="http://hexima.com.au/","Hexima")),
        img(src="http://cysbar.science.latrobe.edu.au/img/hexima.png",width="200px"),
        img(src="http://cysbar.science.latrobe.edu.au/img/lims.png",width="200px")
        )
    ),
        
    conditionalPanel(
      condition = "!output.comparison_done",
      mainPanel(
        h3("Upload your two alignments to make a comparison"),
        p("Alignments must be in fasta, clustal, or phylip formats. Both alignments should contain the same sequences in any order."),
        p("If you are unsure how to format your inputs or simply want some data to try the app please take a look at the example data"),
        a(href="https://dl.dropboxusercontent.com/u/226794/AlignStatShiny/example.zip",class="btn btn-default shiny-download-link",
          list(tags$em(class="fa fa-download"),"Example Data")),
        br(),br(),
        wellPanel(
          fileInput("align_a","Alignment A in fasta, clustal, or phylip format"),
          fileInput("align_b","Alignment B in fasta, clustal, or phylip format"),
          checkboxInput("stack_category_proportions","Stack Category Proportions",value = TRUE),
          checkboxInput("show_prop_cys","Show Cysteine Proportions")
          checkboxInput("sum_of_pairs","Show Cysteine Proportions")
        )
      )      
    ),

    conditionalPanel(
      condition = "output.comparison_done",
      h3("Your AlignStat results are shown below. To run a new comparison simply refresh this page in your browser")
    ),
    
    conditionalPanel(
      condition = "output.comparison_done",
      wellPanel(
        # Show a plot of the generated distribution
        plotOutput("heatmap"),
        textOutput("heatmap_caption"),
        downloadButton("heatmap_download",label = "Download")
      )
    ),

    conditionalPanel(
      condition = "output.comparison_done",
      wellPanel(
        plotOutput("matrix"),
        textOutput("matrix_caption"),
        downloadButton("matrix_download",label = "Download")
      )
    ),
    
    conditionalPanel(
      condition = "output.comparison_done",
      wellPanel(
        plotOutput("match_summary"),
        textOutput("match_summary_caption"),
        downloadButton("match_summary_download",label = "Download")
      )
    ),

    conditionalPanel(
      condition = "output.comparison_done",
      wellPanel(
        plotOutput("plot_dissimilarity_summary"),
        textOutput("plot_dissimilarity_caption"),
        downloadButton("dissimilarity_summary_download",label = "Download")
      )
    ),
    
    conditionalPanel(   
      condition = "output.comparison_done",   
      wellPanel(    
        plotOutput("SP_summary"),   
        textOutput("SP_summary_caption"),   
        downloadButton("SP_summary_download",label = "Download")    
      )   
    ),    
    
    conditionalPanel(
      condition = "output.comparison_done",
        wellPanel(
        p("When comparing the positions of two MSAs:
          A ‘match’ is when both alignments contain an identical characters that is not a gap.
          A ‘merge’ is when alignment A contains a gap, but alignment B contains any other character.
          A ‘split’ is when alignment B contains a gap, but alignment A contains any other character.
          A ‘shift’ is when two alignments contain a non-identical character, neither of which are gaps.
          A ‘conserved gap’ is when the both alignments contain a gap"),
        p("For further information see https://github.com/TS404/AlignStat")
        ),
        wellPanel(
        h5("Download results in csv format"),
        downloadButton("similarity_matrix_csv","Similarity Matrix"),
        downloadButton("dissimilarity_matrix_csv","Dissimilarity Matrix"),
        downloadButton("results_summary_csv","Results Summary")
      )
    )
    
  )
))
