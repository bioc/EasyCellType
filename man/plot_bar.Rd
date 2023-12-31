% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_bar.R
\name{plot_bar}
\alias{plot_bar}
\title{Create bar plots for each cluster}
\usage{
plot_bar(test = "GSEA", data, cluster = NULL)
}
\arguments{
\item{test}{"GSEA" or "fisher"}

\item{data}{Annotation results}

\item{cluster}{Cluster can be specified to print plots.}
}
\value{
Bar plots showing show up to 10 candidate cell types for each cluster.
}
\description{
This function is used to generate set of bar plots presenting up 
to 10 candidate cell types for each cluster.
}
\examples{
data(gene_pbmc)
result <- easyct(gene_pbmc, db="cellmarker", species="Human", 
tissue=c("Blood", "Peripheral blood", "Blood vessel",
"Umbilical cord blood", "Venous blood"), p_cut=0.3, test="GSEA", scoretype="pos")
plot_bar("GSEA", result)

}
