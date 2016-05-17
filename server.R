
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

# library("devtools")
# devtools::install_github("TS404/AlignStat")

library("AlignStat") # <<<<------- restore once AlignStat updated on CRAN

library("shiny")
library("ggplot2")

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
    
    compare_alignments(aa_path,
                       ab_path)#, #remove )
#                       SP         = sum_of_pairs)
  })
  
  output$comparison_done <- reactive({
    return(!is.null(comparison()))
  })
  outputOptions(output, 'comparison_done', suspendWhenHidden=FALSE)
  
  #
  # Heatmap 
  #
  plot_heatmap <- function(){
    p <- plot_similarity_heatmap(comparison(),display = FALSE)
    p <- p + ggtitle("Similarity Heatmap") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns") + ylab("Alignment B columns")
    p
  }
  output$heatmap <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    p <- plot_heatmap()
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
  output$heatmap_download <- downloadHandler(filename = "heatmap.pdf",content = function(file){
    p <- plot_heatmap()
    ggsave(filename = file,plot = p,device = "pdf",width = 10,height = 6)
  })
  
  #
  # Matrix
  # 
  plot_matrix <- function(){
    p <- plot_dissimilarity_matrix(comparison(),display = FALSE)
    p <- p + ggtitle("Dissimilarity matrix") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns") + ylab("Sequence")
    p    
  }
  output$matrix <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    p <- plot_matrix()
    p
  })
  output$matrix_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Dissimilarity matrix plot. For each residue in alignment A, colour indicates the
    dissimilariyof alignment B (match, merge, split, shift, or conserved gap). This
    plot indicates of which sequence regions are most disagreed upon by the MSAs."
  })
  output$matrix_download <- downloadHandler(filename = "matrix.pdf",content = function(file){
    p <- plot_matrix()
    ggsave(filename = file,plot = p,device = "pdf",width = 10,height = 6)
  })  
  
  #
  # Match Summary
  #
  plot_match_summary <- function(){
    p <- plot_similarity_summary(comparison(),cys = input$show_prop_cys,display = FALSE)
    p <- p + ggtitle("Similarity Summary") + theme(title = element_text(size=20))
    p <- p + xlab("Alignment A columns")
    p    
  }
  output$match_summary <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    p <- plot_match_summary()
    p
  })
  output$match_summary_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)

    "Summary of the similarity between the multiple sequence alignments. For each
    column of alignment A, the proportion of identical characters to alignment B is
    plotted, normalised to the proportion of characters that are not conserved gaps."
    
    if (input$show_prop_cys)
      return(NULL)
    
    "Additionally, proportion of cysteines at each alignment column is shown."
  })
  output$match_summary_download <- downloadHandler(filename = "match_summary.pdf",content = function(file){
    p <- plot_match_summary()
    ggsave(filename = file,plot = p,device = "pdf",width = 10,height = 6)
  })  

  #
  # Dissimilarity Summary
  #
  plot_diss_sum <- function(){
    p <- plot_dissimilarity_summary(comparison(),stack = input$stack_category_proportions,display = FALSE)
    p <- p + ggtitle("Dissimilarity summary") + theme(title= element_text(size=20))
    p <- p + xlab("Alignment A columns")
    p    
  }  
  output$plot_dissimilarity_summary <- renderPlot({
    if (is.null(comparison()))
      return(NULL)
    p <- plot_diss_sum()
    p
  })
  output$plot_dissimilarity_caption <- renderText({
    if (is.null(comparison()))
      return(NULL)
    
    "Summary of the dissimilarities between the multiple sequence alignments. For
    each column of alignment A, the relative proportions of merges, splits and
    shifts is plotted, normalised to the proportion of characters that are not
    conserved gaps."
  })
  output$dissimilarity_summary_download <- downloadHandler(filename = "dissimilarity_summary.pdf",content = function(file){
    p <- plot_diss_sum()
    ggsave(filename = file,plot = p,device = "pdf",width = 10,height = 6)
  })  
  
  #
  # Sum of pairs
  #
  plot_SP_summary <- function(){
      if (!input$sum_of_pairs)
        return(NULL)
      p <- plot_SP_summary(comparison(),display = FALSE)
      p <- p + ggtitle("Sum of Pairs Summary") + theme(title = element_text(size=20))
      p <- p + xlab("Alignment B columns")
      p
    }
    output$SP_summary <- renderPlot({
      if (is.null(comparison()))
        return(NULL)
      if (!input$sum_of_pairs)
        return(NULL)
      p <- plot_SP_summary()
      p
    })
    output$SP_summary_caption <- renderText({
      if (is.null(comparison()))
        return(NULL)
      if (!input$sum_of_pairs)
        return(NULL)
  
    "Summary of the sum of pairs score and related scores between the multiple sequence
    alignments. The sum of pairs is the proportion of aligned pairs from alignment A
    that are retained in alignment B. The column score is the proportion of columns
    from alignment A that are fully retained in alignment B."
    })
    output$SP_summary_download <- downloadHandler(filename = "SP_summary.pdf",content = function(file){
      p <- plot_SP_summary()
      ggsave(filename = file,plot = p,device = "pdf",width = 10,height = 6)
    })  
    
  #
  # Download csv files
  #
  output$similarity_matrix_csv <- downloadHandler(filename = "similarity_matrix.csv", content = function(file){
    write.csv(file = file,comparison()$similarity_S)
  })
  output$dissimilarity_matrix_csv <- downloadHandler(filename = "dissimilarity_matrix.csv", content = function(file){
    write.csv(file = file,comparison()$dissimilarity_simple)
  })
  output$results_summary_csv <- downloadHandler(filename = "results_summary.csv", content = function(file){
    write.csv(file = file,comparison()$results_r)
  })
  
  
  
})
