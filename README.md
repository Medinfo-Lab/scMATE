# 🧬 scMATE: Single-Cell Multi-omics Analysis Explorer
**An Interactive Framework for Single-Cell Transcriptome and Epigenome Integration**

[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![R Version](https://img.shields.io/badge/R-%3E%3D%204.2.0-blue)](https://www.r-project.org/)
[![Shiny](https://img.shields.io/badge/App-Shiny-success)](https://shiny.rstudio.com/)
[![Shiny](https://img.shields.io/badge/UI-Shiny_Dashboard-success.svg)](https://shiny.rstudio.com/)

**scMATE** is an interactive, Shiny-based bioinformatics software designed for the integration, analysis, and visualization of single-cell multi-omics data. It enables researchers to concurrently evaluate single-cell RNA sequencing (**e.g., scRNA-seq**), DNA methylation, and chromatin accessibility (**e.g., scBS-seq, scNOMe-seq, scM&T-seq, scNMT-seq**) data through a graphical user interface, eliminating the need for command-line programming. 

The software utilizes optimized sparse matrix infrastructures and parallel computing to directly process raw sequencing coverage files. It standardizes continuous data distributions across different molecular layers using a composite multi-omic Z-score, facilitating the quantitative identification of coordinately regulated genes.

---

## 🌟 Key Features

- 🚀 **Ultra-Fast Epigenome Assembly:** Instantly aggregates multi-metric single-cell tables (`.meth`, `.nonmeth`, `.level`) from raw `.cov.gz` files using optimized `data.table` non-equi joins.
- 🪶 **Transcriptome Module:** Executes data quality control, normalization, dimensionality reduction (PCA, t-SNE, UMAP), and differential expression analysis using sparse-matrix-accelerated statistical tests.
- 🎯 **Epigenome Module:** Directly processes raw Bismark coverage files (`.cov`). Performs regional mapping, addresses data sparsity via imputation algorithms (KNN/Row Mean), and identifies differentially methylated/accessible regions (DMRs/DARs).
- 🗺️ **Multi-omics Integration:** Merges RNA, methylation, and accessibility data based on genomic coordinates and gene identifiers. Calculates a quantitative Multi-Omic Score to classify gene regulatory states and identify multi-layer regulatory targets.
- 📊 **Publication-Ready Visualization:** Generates and exports high-resolution PDFs (Volcano plots, UMAPs, Global Heterogeneity Ridge Plots, and Joint Z-score Heatmaps) customized with `ggplot2` and `patchwork`.

---

## 🚀 Workflow Overview

scMATE consists of three deeply integrated, highly interactive modules:

### 🔬 Module 1: Transcriptome Pipeline

| Sub-module                   |                         Description                          |
| ---------------------------- | :----------------------------------------------------------: |
| **Object Creation & QC**     | Import count matrices (CSV/TSV/H5), matrix-level pre-filtering, mitochondrial & feature filtering, QC violin plots |
| **Normalization**            | LogNormalize, LogCPM, and TPM (with gene length) normalization; sparse matrix storage |
| **Dimensionality Reduction** |       High-performance PCA, t-SNE, and UMAP embeddings       |
| **Clustering**               | Graph-based Leiden community detection on k-NN graph, or hierarchical clustering (Ward.D2) |
| **Differential Expression**  | Exploratory cell-level Wilcoxon rank-sum test, or replicate-aware pseudobulk analysis via edgeR (TMM normalization, NB GLM, QL F-test, BH FDR) |
| **Pseudotime Analysis**      | Principal-curve-based or graph-based shortest-path trajectory inference from a user-defined root cluster |

### 🩸 Module 2: Epigenome Pipeline

| Sub-module                       |                         Description                          |
| -------------------------------- | :----------------------------------------------------------: |
| **Matrix Assembly & QC**         | Batch import `.cov` files, BED region annotation, ultra-fast non-equi join for methylation/accessibility quantification, missing-rate filtering |
| **Imputation**                   | Optional k-NN or mean-based imputation (applied only before dimensionality reduction; raw matrices preserved for QC and differential analysis) |
| **Epigenetic Landscape**         | Interactive ridge density plots for global and localized methylation/accessibility distributions |
| **Dimensionality Reduction**     |         PCA, UMAP, MDS, and NMF on imputed matrices          |
| **Differential Region Analysis** | Dual-testing framework (Fisher's exact test on aggregated counts + Welch's t-test fallback); reports mean difference, Hedges' g, odds ratio, log2 odds ratio; BH FDR correction; identifies DMRs and DARs |
| **scATAC-seq Converter**         | Optional adapter for 10x Genomics scATAC-seq H5/HDF5 peak matrices (binarization to level matrix format) |

### 🧩 Module 3: Multi-Omics Integration & Systems Biology

| Sub-module                          |                         Description                          |
| ----------------------------------- | :----------------------------------------------------------: |
| **Data Integration**                | High-fidelity coordinate-to-gene mapping; exact inner joins across modalities; supports four configurations: RNA+CpG+GpC, RNA+CpG, RNA+GpC, CpG+GpC |
| **Cross-Modality Correlation**      | Pairwise Spearman/Pearson association analysis between RNA, CpG, and GpC signals |
| **Chromosome Topology**             | LOESS-smoothed multi-omic signal visualization along chromosomal coordinates (midpoint in Mb) |
| **Regulatory State Classification** | Median-based descriptive state labeling + vector projection/cosine similarity approach (e.g., "Canonical active", "Primed/poised", "Expressed but closed") |
| **Multi-Omic Gene Ranking**         | Robust Z-score (MAD-based) transformation with clipping at ±3; composite DMCS score combining modalities; ranked gene heatmaps |
| **Functional Enrichment**           | GO and KEGG over-representation analysis with adaptive ID conversion, FDR correction, and dot/bar plot visualization |

## 💻 System Requirements

| Requirement            | Specification                                                |
| :--------------------- | :----------------------------------------------------------- |
| **CPU**                | Multi-core processor (≥ 4 cores recommended; up to 16 threads supported) |
| **Operating System**   | Windows or Linux                                             |
| **Software**           | R (version ≥ 4.2.0)                                          |
| **Hardware (Basic)**   | Minimum 8 GB RAM                                             |
| **Hardware (Optimal)** | ≥ 32 GB recommended for large datasets                       |

## ⚙️ Installation

To run **scMATE** locally, ensure you have R (>= 4.2.0) installed.

### 1. Clone the repository
```bash
git clone https://github.com/Medinfo-lab/scMATE.git
cd scMATE
```

### 2. Install dependencies

Run the following script in your R console to automatically install all dependencies:

```R
# Core Shiny packages
install.packages(c("shiny", "shinydashboard", "shinydashboardPlus", "shinyjs",
                   "shinycssloaders", "progressr", "DT", "dplyr", "markdown"))

# Data processing & visualization
install.packages(c("ggplot2", "Matrix", "data.table", "plotly", "patchwork",
                   "writexl", "tidyr", "ggridges", "ggrepel", "ggpubr",
                   "readxl", "stringr", "igraph", "FNN", "tictoc"))

# Bioconductor packages
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install(c("rhdf5", "edgeR"))
```

### 3. Usage

To launch the scMATE application locally, set your working directory to the cloned repository folder and run the following command in the R console:

```R
# Option 1: Run from source
shiny::runApp("path/to/scMATE")

# Option 2: In RStudio, open app.R and click "Run App"
```

## Team

**Medinfo-Lab**  
School of Medicine, Hebei University of Engineering  
Hebei Key Laboratory of Medical Data Science
