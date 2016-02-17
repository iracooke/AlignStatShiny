
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
    
    conditionalPanel(
      condition = "!output.comparison_done",
      mainPanel(
        h3("Upload your two alignments to make a comparison"),
        p("Alignments must be in fast format. Both alignments should contain the same sequences in the same order."),
        p("If you are unsure how to format your inputs please take a look at the example data"),
        a(href="https://dl.dropboxusercontent.com/u/226794/AlignStatShiny/example.zip",tags$button("Example Data")),
        # downloadButton("example_data_download",label="Download Example Data"),
        br(),br(),
        fileInput("align_a","Alignment A in FASTA format"),
        fileInput("align_b","Alignment B in FASTA format"),
        checkboxInput("stack_category_proportions","Stack Category Proportions",value = TRUE),
        checkboxInput("show_prop_cys","Show Cysteine Proportions")
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
))
