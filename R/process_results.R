#' Title Annotate cell types for single cell RNA data
#' 
#' @description This function is used to process the annotation test results. 
#' Processed data will be used to generate plots. 
#'
#' @param test Test used to annotation cell types: "GSEA" or "fisher"
#' @param data Annotation results.
#' 
#' @importFrom dplyr bind_rows slice_min group_by mutate 
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom stats na.omit
#'
#' @return A data frame used to generate plots. 
#'
process_results <- function(test, data){
  stopifnot("The test should be specified as GSEA or fisher." =
            test %in% c("GSEA", "fisher"))
  stopifnot("Annotation results should be specified." = length(data) > 0)
  
  if(test == "GSEA"){
    enrich.re.l <- lapply(data, function(x) x[seq(dim(x)[1]), drop=FALSE])
    enrich.re.d <- do.call(rbind, enrich.re.l)
    enrich.re.d$cluster <- rep(names(enrich.re.l), 
                               lapply(enrich.re.l, nrow))
    enrich.d <- enrich.re.d[, c("ID", "pvalue", "cluster", "core_enrichment"), drop=FALSE]
    rownames(enrich.d) <- NULL
    enrich.hard <- enrich.d %>% 
      group_by(.data$cluster) %>%
      slice_min(n = 1, order_by = .data$pvalue) %>%
      mutate(method = "hard_enrich")
    
    enrich.soft <- enrich.d %>% 
      group_by(.data$cluster) %>%
      slice_min(n = 5, order_by = .data$pvalue) %>%
      mutate(method = "soft_enrich")
    
    out <- rbind(enrich.hard, enrich.soft) %>% 
      group_by(.data$cluster) %>%
      distinct(ID, .keep_all=TRUE)
    
  }else if(test == "fisher"){
    fisher.hard <- lapply(data, 
                          function(x) x[order(-x$p_adjust, abs(x$score),
                                              decreasing = TRUE, 
                                              na.last = TRUE), ][1, ]) %>%
      bind_rows(.id = "cluster") %>%
      mutate(method = "hard_fisher") 
    
    fisher.soft <- lapply(data, 
                          function(x) x[order(-x$p_adjust, abs(x$score), 
                                              decreasing = TRUE,
                                              na.last = TRUE), ][seq.int(5), ]) %>% 
      bind_rows(.id = "cluster")
    
    fisher.d <- merge(fisher.soft, fisher.hard, by = c("cluster", "cellName", "p_value", "score"), all.x = TRUE)
    fisher.d$method[is.na(fisher.d$method)] <- "soft_fisher"
    out <- data.frame(ID=fisher.d$cellName, pvalue_unadjust=fisher.d$p_value,
                      pvalue=fisher.d$p_adjust.x, 
                      cluster=fisher.d$cluster, method=fisher.d$method,
                      core_enrichment=fisher.d$core_enrichment.x)
    out <- na.omit(out)
  }
  return(out)
}
