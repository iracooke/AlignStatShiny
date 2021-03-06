# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library("AlignStat") 
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
    
    aa_path <- import_alignment2(aa_file$datapath,tools::file_ext(aa_file$name))
    ab_path <- import_alignment2(ab_file$datapath,tools::file_ext(ab_file$name))
    
    compare_alignments(aa_path,
                       ab_path,
                       SP = input$calculate_sum_of_pairs)
  })
  
  output$comparison_done <- reactive({
    return(!is.null(comparison()))
  })
  outputOptions(output, 'comparison_done', suspendWhenHidden=FALSE)

  output$comparison_has_sum_of_pairs <- reactive({
    result <- comparison()
    return(!is.null(result$sum_of_pairs))
  })
  outputOptions(output, 'comparison_has_sum_of_pairs', suspendWhenHidden=FALSE)
  
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
    p <- plot_similarity_summary(comparison(),cys = input$show_prop_cys, CS = input$calculate_column_score, display = FALSE)
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
  plot_SP_sum <- function(){
      if (!input$calculate_sum_of_pairs)
        return(NULL)
      p <- plot_SP_summary(comparison(), CS = input$calculate_column_score, display = FALSE)
      p <- p + ggtitle("Sum of Pairs Summary") + theme(title = element_text(size=20))
      p <- p + xlab("Alignment B columns")
      p
    }
    output$SP_summary <- renderPlot({
      if (is.null(comparison()))
        return(NULL)
      if (!input$calculate_sum_of_pairs)
        return(NULL)
      p <- plot_SP_sum()
      p
    })
    output$SP_summary_caption <- renderText({
      if (is.null(comparison()))
        return(NULL)
      if (!input$calculate_sum_of_pairs)
        return("Unable to compute sum of pairs score for this alignment")
  
    "Summary of the sum of pairs score and related scores between the multiple sequence
    alignments. The sum of pairs is the proportion of aligned pairs from alignment A
    that are retained in alignment B. The column score is the proportion of columns 
      that contribute to the column score. "
    })
    output$SP_summary_download <- downloadHandler(filename = "SP_summary.pdf",content = function(file){
      p <- plot_SP_sum()
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
    write.csv(file = file,comparison()$results_R)
  })
  
  output$SP_ref_txt <- downloadHandler(filename = "sum_of_pairs_reference.txt", content = function(file){
    lapply(comparison()$sum_of_pairs$ref.pairs, write, file, append=TRUE)
  })
  output$SP_com_txt <- downloadHandler(filename = "sum_of_pairs_comparison.txt", content = function(file){
    lapply(comparison()$sum_of_pairs$com.pairs, write, file, append=TRUE)
  })
  output$SP_scores_csv <- downloadHandler(filename = "SPS_summary.csv", content = function(file){
    write.csv(file = file,comparison()$sum_of_pairs$columnwise.SPS)
  })  
})


import_alignment2 <- function(alignment,format=NULL){
  
  # default fmt
  fmt <- "fasta"
  
  # if clustal
  if( format=="clustal"
      |format=="CLUSTAL"
      |format=="aln"
      |format=="ALN"
      |format=="clust"
      |format=="clus"){
    fmt <- "clustal"
  }
  
  # if msf
  if( format=="msf"
      |format=="MSF"){
    fmt <- "msf"
  }
  
  # if mase
  if( format=="mase"
      |format=="MASE"){
    fmt <- "mase"
  }
  
  # if phylip
  if( format=="phylip"
      |format=="PHYLIP"
      |format=="phy"
      |format=="PHY"
      |format=="ph"
      |format=="PH"){
    fmt <- "phylip"
  }  
  
  # import
  temp <- seqinr::read.alignment(alignment,format=fmt)
  # fix names
  temp$nam <- do.call("rbind", lapply(strsplit(temp$nam," "),"[[", 1))
  # reformat to data frame
  output <- data.frame(strsplit(gsub("[\r\n]","",unlist(temp$seq)),split = ""))
  colnames(output) <- temp$nam
  
  output
}

