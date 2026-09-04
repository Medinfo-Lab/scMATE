# 🧬 scMATE Workflow Platform
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

- **Data Import:** Upload raw count matrices (`featureCounts` or `CellRanger` outputs).
- **QC & Normalization:** Filter low-quality cells/genes, and normalize via `LogNormalize`, `LogCPM`, or `TPM`.
- **Manifold Learning:** Identify Highly Variable Genes (HVG) and run fast PCA, t-SNE, or UMAP (`uwot`).
- **DEA:** Compute DEGs using fast sparse-matrix Wilcoxon tests and visualize via interactive Volcano plots.

### 🩸 Module 2: Epigenome Pipeline

- **Matrix Assembly:** Upload Region Annotations (`.csv`) and Single-cell methylation `.cov.gz` files. Automatically strips suffixes and aligns metadata.
- **Smart Imputation:** Handles extreme sparsity in single-cell epigenomes via Row-Mean or KNN imputation.
- **Global Landscape:** Visualizes dynamic epigenetic shifts across developmental stages using Joyplots (Ridge plots).
- **Differential Calling:** Identifies Differentially Methylated Regions (DMRs) using rigorous statistical models.

### 🧩 Module 3: Multi-Omics Integration & Systems Biology

- **Target Group Linking:** Define a global target group (e.g., `E4.5` or `Tumor`) to synchronize metadata across RNA and Epigenome datasets.
- **Threshold Filtering:** Apply strict `P-value` and `Log2FC` filters on DEGs/DMRs before integration to eliminate background noise.
- **Regulatory States Inference:** Automatically classifies genes into biological states (e.g., *Fully Silenced*, *Paradox Active*, *Poised*) based on Multi-Omics logic.
- **Multi-omics Driver Discovery:** Computes Joint Z-scores to identify master regulatory drivers, visualized through clustered heatmaps.

## 💻 System Requirements

| Requirement            | Specification                                                |
| :--------------------- | :----------------------------------------------------------- |
| **Operating System**   | Windows or Linux                                             |
| **Software**           | R (version ≥ 4.2.0)                                          |
| **Hardware (Basic)**   | Minimum 8 GB RAM                                             |
| **Hardware (Optimal)** | 16 GB+ RAM & Multi-core processors (for datasets > 400 cells & > 20000 Genes) |

## ⚙️ Installation

To run **scMATE** locally, ensure you have R (>= 4.2.0) installed.

### 1. Clone the repository
```bash
git clone https://github.com/Medinfo-lab/scMATE.git
cd scMATE
```

### 2. Install Required R Packages

Run the following script in your R console to automatically install all dependencies:

```R
# Install CRAN packages
install.packages(c("shiny", "dplyr", "ggplot2", "shinyjs", "Matrix", 
                   "shinydashboard", "data.table", "DT", "shinydashboardPlus", 
                   "plotly", "patchwork", "writexl", "shinycssloaders", 
                   "tidyr", "ggpubr", "GGally", "readxl", "stringr", 
                   "ggrepel", "ggridges", "tictoc", "future", 
                   "future.apply", "progressr", "rhdf5"))

# Install Bioconductor packages
if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install(c("clusterProfiler", "org.Mm.eg.db", "org.Hs.eg.db", 
                       "GenomicRanges", "IRanges", "impute", "mixOmics"))
```

### 3. Usage

To launch the scMATE application locally, set your working directory to the cloned repository folder and run the following command in the R console:

```R
library(shiny)
runApp("path/to/scMATE") # Replace with the actual folder path
```

