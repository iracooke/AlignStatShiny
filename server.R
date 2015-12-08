
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

devtools::install_github("iracooke/AlignStat")

library(shiny)
library(AlignStat)
library(ggplot2)

shinyServer(function(input, output) {

  # Compute alignment comparison as a reactive object
  # This only gets run if a different alignment gets uploaded
  #
  comparison <- reactive({
    aa_file <- input$align_a
    ab_file <- input$align_b
    if (is.null(aa_file) | (is.null(ab_file)))
      return(NULL)
    
    aa_path <- aa_file$datapath
    ab_path <- ab_file$datapath
    
    compare_alignments(aa_path,ab_path)
  })
  
  
  
  output$match_summary <- renderPlot({
    if (is.null(comparison()))
      return(NULL)

    p <- plot_match_summary(comparison(),cys = input$show_prop_cys,display = FALSE)
    p <- p + ggtitle("Match Summary") + theme(title = element_text(size=20))
    p
  })
  
  output$match_summary_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)

    "Proportion of alignments with identical character matches (Identity) as
    a function of alignment position. Optionally also plots the proportion
    of cysteines (Cysteines) at each position."
  })

  
  output$heatmap <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    
    p <- plot_alignment_heatmap(comparison(),display = FALSE)
    p <- p + ggtitle("Agreement Heatmap") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A") + ylab("Alignment B")
    p
  })
  
  output$heatmap_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Agreement heatmap. The value at point (x,y) represents the agreement between 
    position x in alignment A and position y in alignment B. Agreement value is computed 
    as the proportion of identical matches not counting conserved gaps. Use this plot to 
    determine which positions are well agreed upon by the MSAs, and which are split by 
    one MSA relative to the other."
  })
  
  output$category_proportions <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    
    p <- plot_category_proportions(comparison(),stack = input$stack_category_proportions,display = FALSE)
    p <- p + ggtitle("Categorized Differences") + theme(title= element_text(size=20))
    p
  })
  
  output$category_proportions_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Detailed breakdown of the differences between the multiple 
    sequence alignments. For all characters that are neither identical residues, nor conserved 
    gaps, the relative proportions of insertions (I), deletions (D) and substitutions (S) is plotted."    
  })
  
})
