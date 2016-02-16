
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#
library(devtools)

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
  
  
  
  output$heatmap <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    
    p <- plot_similarity_heatmap(comparison(),display = FALSE)
    p <- p + ggtitle("Similarity Heatmap") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns") + ylab("Alignment B columns")
    p
  })
  output$heatmap_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Similarity heatmap. The value at point (x,y) represents the similarity between 
    column x in alignment A and column y in alignment B. Similarity value is computed 
    as the proportion of identical characters (excluding conserved gaps). This plot
    indicates which positions are well agreed upon by the MSAs, and which are split
    by one MSA relative to the other."
  })
  
  
  
  output$matrix <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    
    p <- plot_similarity_heatmap(comparison(),display = FALSE)
    p <- p + ggtitle("Dissimilarity matrix") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns") + ylab("Sequence")
    p
  })
  output$matrix_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Dissimilarity matrix plot. For each residue in alignment A, colour indicates the
    dissimilariyof alignment B (match, merge, split, shift, or conserved gap). This
    plot indicates of which sequence regions are most disagreed upon by the MSAs."
  })
  
  
  
  output$match_summary <- renderPlot({
    if (is.null(comparison()))
      return(NULL)

    p <- plot_similarity_summary(comparison(),cys = input$show_prop_cys,display = FALSE)
    p <- p + ggtitle("Similarity Summary") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns")
    p
  })
  output$match_summary_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)

    "Summary of the similarity between the multiple sequence alignments. For each
    column of alignment A, the proportion of identical characters to alignment B is
    plotted, normalised to the proportion of characters that are not conserved gaps."
    
    if (is.null(show_prop_cys()))
      return(NULL)
    
    "Additionally, proportion of cysteines at each alignment column is shown."
  })


  
  output$plot_dissimilarity_summary <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    
    p <- plot_category_proportions(comparison(),stack = input$stack_category_proportions,display = FALSE)
    p <- p + ggtitle("Dissimilarity summary") + theme(title= element_text(size=20))
    p <- p + xlab("Alignment A columns")
    p
  })
  output$category_proportions_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Summary of the dissimilarities between the multiple sequence alignments. For
    each column of alignment A, the relative proportions of merges, splits and
    shifts is plotted, normalised to the proportion of characters that are not
    conserved gaps."
  })
  
})
