
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
      h3("Upload your two alignments to make a comparison"),
      p("Alignments contain the same sequences in the same order"),
      
      fileInput("align_a","Alignment A in FASTA format"),
      fileInput("align_b","Alignment B in FASTA format"),
      checkboxInput("show_prop_cys","Show Cysteine Proportions",value = TRUE),
      checkboxInput("stack_category_proportions","Stack Category Proportions")
    ),
        
    # Show a plot of the generated distribution
    plotOutput("match_summary"),
    textOutput("match_summary_caption"),
    br(),br(),

    plotOutput("heatmap"),
    textOutput("heatmap_caption"),
    br(),br(),
    
    plotOutput("category_proportions"),
    textOutput("category_proportions_caption"),
    br()
  )
))
