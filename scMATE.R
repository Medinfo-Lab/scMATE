library(shiny)
library(shinydashboard)
library(shinydashboardPlus)
library(shinyjs)
library(shinycssloaders)
library(progressr)
library(DT)
library(dplyr)
library(markdown)




# ---- UI Logic ----
# UI Design: Scientific & Academic Style
ui <- shinydashboardPlus::dashboardPage(
  skin = "blue-light", # 使用浅色皮肤基础
  # Header
  dashboardHeader(
    title = span(icon("dna"), "scMATE Workflow"),
    titleWidth = 250
  ),
  # Sidebar ----
  dashboardSidebar(
    width = 250,
    collapsed = T, # 设置默认收缩
    sidebarMenu(
      id = "sidebar_menu_id",
      style = "margin-top: 10px;",
      menuItem("Home", tabName = "Home", icon = icon("house")),
      menuItem("Transcriptome Module", tabName = "Transcriptome_Analysis", icon = icon("microscope")),
      menuItem("Epigenome Module", tabName = "Epigenome_Analysis", icon = icon("align-left")),
      menuItem("Multi-omics Integration", tabName = "Integration_Analysis", icon = icon("layer-group")),
      menuItem("User Guide", tabName = "User_Guide", icon = icon("book"))
      # menuItem("Tools", tabName = "tools", icon = icon("toolbox"))
    )
  ),
  # Body ----
  dashboardBody(
    shinyjs::useShinyjs(),
    # 全局自定义 CSS 样式 (整合归一)
    tags$head(
      tags$style(HTML("
        @import url('https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap');
        /* 1. 基础全局样式 */
        body, .content-wrapper, .right-side, .main-footer {
          font-family: 'Roboto', sans-serif;
          background-color: #f4f6f9;
        }
        /* 2. 标题栏与导航栏 */
        .skin-blue-light .main-header .logo {
          background-color: #2c3e50;
          color: #fff;
          font-weight: 700;
        }
        .skin-blue-light .main-header .navbar {
          background-color: #34495e;
        }
        /* 3. 模块标题样式 */
        .module-header {
          border-bottom: 2px solid #3c8dbc;
          margin-bottom: 20px;
          padding-bottom: 10px;
          color: #2c3e50;
        }
        .module-header h2 { font-size: 24px; font-weight: 600; margin: 0; }
        .module-header p { color: #7f8c8d; font-size: 14px; margin-top: 5px; }
        /* 4. Box 容器样式优化 (科研风) */
        .box {
          border-top: 3px solid #d2d6de;
          box-shadow: 0 1px 3px rgba(0,0,0,0.1);
          border-radius: 3px;
        }
        .box.box-primary { border-top-color: #3c8dbc; }
        .box.box-info { border-top-color: #00c0ef; }
        .box.box-danger { border-top-color: #dd4b39; }
        .box.box-success { border-top-color: #00a65a; }
        .box-header.with-border {
          background-color: #fff;
          border-bottom: 1px solid #f4f4f4;
        }
        .box-title { font-size: 16px; font-weight: 600; color: #2c3e50; }
        .guide-box { background-color: #e8f0f8 !important; border: 1px solid #b8c7ce; color: #2c3e50; }
        /* 5. 按钮与控件样式 */
        .btn-custom-primary { background-color: #3c8dbc; border-color: #367fa9; color: white; }
        .btn-custom-primary:hover { background-color: #367fa9; color: white; }
        .control-panel { background-color: #fff; padding: 15px; border-radius: 5px; border: 1px solid #d2d6de; }
        .dataTables_wrapper { font-size: 13px; }
        .step-badge {
          background-color: #3c8dbc; color: white; padding: 2px 8px;
          border-radius: 10px; font-size: 12px; margin-right: 5px; vertical-align: middle;
        }
        .nav-tabs-custom > .nav-tabs > li.active { border-top-color: #3c8dbc; }
        /* 6. ValueBox (概览卡片) 极度美化 */
        .small-box {
          border-radius: 12px !important;
          overflow: hidden;
          box-shadow: 0 4px 15px rgba(0,0,0,0.1);
          transition: all 0.3s ease-in-out;
        }
        .small-box:hover {
          transform: translateY(-5px);
          box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .small-box .icon-large {
          font-size: 70px; top: 10px; right: 15px; opacity: 0.2;
        }
        .small-box .inner h3 {
          font-size: 24px !important; font-weight: 700 !important; margin-bottom: 5px;
        }
        .small-box .inner p {
          font-size: 14px !important; opacity: 0.9;
        }
        .small-box-footer { display: none !important; } /* 隐藏底部的 More info 栏 */
        /* ==================== 专属 HOME 页高级样式 (丰富版) ==================== */
        /* Hero Banner 英雄横幅 */
        .home-hero {
          background: linear-gradient(135deg, #0f172a 0%, #1e3a8a 100%);
          color: white; padding: 60px 50px; border-radius: 12px;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2); margin-bottom: 30px;
          position: relative; overflow: hidden;
        }
        .home-hero::after {
          content: '\f471'; font-family: Font Awesome 5 Free; font-weight: 900;
          position: absolute; font-size: 300px; color: rgba(255,255,255,0.03);
          top: -50px; right: -50px; transform: rotate(15deg);
        }
        .home-hero h1 { font-weight: 800; font-size: 46px; margin-top: 0; letter-spacing: 1px; }
        .home-hero p { font-size: 18px; font-weight: 300; line-height: 1.7; max-width: 850px; color: #cbd5e1; margin-bottom: 25px;}
        .badge-version { background: #3b82f6; color: white; padding: 4px 10px; border-radius: 20px; font-size: 14px; font-weight: bold; vertical-align: middle; margin-left: 15px; }
        /* 现代悬浮卡片 (详细导航) */
        .module-card {
          background: #ffffff; border-radius: 12px; padding: 30px 25px;
          box-shadow: 0 4px 15px rgba(0,0,0,0.05); border-top: 5px solid transparent;
          transition: all 0.3s ease; height: 100%; position: relative;
        }
        .module-card:hover { transform: translateY(-8px); box-shadow: 0 15px 35px rgba(0,0,0,0.1); }
        .card-rna { border-top-color: #3b82f6; }
        .card-epi { border-top-color: #8b5cf6; }
        .card-int { border-top-color: #10b981; }
        .module-card .icon-wrapper {
          width: 70px; height: 70px; border-radius: 12px;
          display: inline-flex; align-items: center; justify-content: center;
          font-size: 30px; margin-bottom: 20px;
        }
        .card-rna .icon-wrapper { background: #eff6ff; color: #3b82f6; }
        .card-epi .icon-wrapper { background: #f5f3ff; color: #8b5cf6; }
        .card-int .icon-wrapper { background: #ecfdf5; color: #10b981; }
        .module-card h3 { font-size: 24px; font-weight: 700; color: #1e293b; margin-top: 0; margin-bottom: 15px;}
        .module-card ul { padding-left: 20px; color: #475569; font-size: 15px; line-height: 1.8; margin-bottom: 20px;}
        .module-card ul li { margin-bottom: 8px; }
        /* Workflow 流程图 */
        .workflow-container { display: flex; justify-content: space-between; align-items: flex-start; margin: 40px 0; position: relative; }
        .workflow-step { flex: 1; text-align: center; position: relative; z-index: 2; padding: 0 15px;}
        .workflow-step .step-icon {
          width: 70px; height: 70px; background: #fff; border: 3px solid #e2e8f0;
          border-radius: 50%; display: inline-flex; align-items: center; justify-content: center;
          font-size: 28px; color: #475569; margin-bottom: 15px; transition: all 0.3s ease;
        }
        .workflow-step:hover .step-icon { border-color: #3b82f6; color: #3b82f6; transform: scale(1.1); }
        .workflow-step h4 { font-weight: 700; color: #1e293b; font-size: 17px; margin-bottom: 10px;}
        .workflow-step p { font-size: 14px; color: #64748b; line-height: 1.5;}
        .workflow-line { position: absolute; top: 35px; left: 12%; right: 12%; height: 3px; background: #e2e8f0; z-index: 1; }
        /* 数据格式与新闻面板 */
        .info-panel { background: #f8fafc; border-radius: 10px; padding: 25px; border: 1px solid #e2e8f0; height: 100%;}
        .info-panel h4 { font-weight: 700; color: #0f172a; margin-top: 0; margin-bottom: 20px; border-bottom: 2px solid #cbd5e1; padding-bottom: 10px; display: inline-block;}
        .data-format-list { list-style: none; padding: 0; margin: 0; }
        .data-format-list li { padding: 12px 0; border-bottom: 1px dashed #cbd5e1; font-size: 15px; color: #334155; display: flex; align-items: flex-start; }
        .data-format-list li:last-child { border-bottom: none; }
        .data-format-list i { color: #3b82f6; margin-right: 12px; margin-top: 3px; font-size: 18px; }
        /* 引用框 */
        .citation-box { background: #1e293b; color: #f8fafc; padding: 20px; border-radius: 8px; font-family: 'Courier New', Courier, monospace; font-size: 14px; line-height: 1.6; position: relative; margin-top: 15px; }
        .citation-box i { position: absolute; top: 20px; right: 20px; color: #64748b; font-size: 20px; }
        /* 时间线更新日志 */
        .timeline { border-left: 3px solid #3b82f6; padding-left: 20px; margin-left: 10px; }
        .timeline-item { margin-bottom: 20px; position: relative; }
        .timeline-item::before { content: ''; position: absolute; left: -27px; top: 5px; width: 12px; height: 12px; background: #fff; border: 3px solid #3b82f6; border-radius: 50%; }
        .timeline-date { font-size: 12px; font-weight: bold; color: #8b5cf6; margin-bottom: 5px; }
        .timeline-content { font-size: 14px; color: #475569; line-height: 1.5; }
        /* ==================== 融合版 Hero 样式 (白底左右分栏) ==================== */
        .hero-combined {
          background: #ffffff;
          border-radius: 16px;
          box-shadow: 0 15px 40px rgba(0,0,0,0.06); /* 高级柔和阴影 */
          border: 1px solid #f1f5f9;
          display: flex;         /* 关键：开启Flex左右布局 */
          align-items: center;   /* 上下垂直居中 */
          padding: 60px 50px;
          margin-bottom: 40px;
          overflow: hidden;
        }
        /* 左侧文字与按钮区 */
        .hero-combined-left {
          flex: 1.2; /* 左侧文字占位稍大 */
          padding-right: 50px;
          z-index: 2;
        }
        .hero-combined-left h1 { font-weight: 800; font-size: 44px; margin-top: 0; color: #0f172a; }
        .badge-version { background: #3b82f6; color: white; padding: 4px 12px; border-radius: 20px; font-size: 14px; font-weight: bold; vertical-align: middle; margin-left: 15px; }
        .hero-combined-left h3 { font-weight: 600; color: #3b82f6; margin-bottom: 20px; font-size: 20px; }
        .hero-combined-left p { font-size: 17px; font-weight: 400; line-height: 1.7; color: #475569; margin-bottom: 15px;}
        .hero-combined-left b { color: #1e293b; }
        /* 右侧多组学 3D 艺术图 */
        .hero-combined-right {
          flex: 0.8; /* 右侧占位 */
          position: relative;
          height: 320px;
          display: flex; justify-content: center; align-items: center;
          z-index: 2;
        }
        .layer {
          position: absolute; width: 280px; height: 110px; border-radius: 16px; backdrop-filter: blur(5px);
          display: flex; align-items: center; justify-content: center; font-size: 22px; font-weight: bold; color: white;
          box-shadow: 0 15px 30px rgba(0,0,0,0.15); transition: all 0.5s cubic-bezier(0.25, 0.8, 0.25, 1);
        }
        .layer-1 { background: rgba(59, 130, 246, 0.9); transform: translateY(-50px) rotateX(60deg) rotateZ(-30deg); z-index: 3; }
        .layer-2 { background: rgba(139, 92, 246, 0.9); transform: translateY(0px) rotateX(60deg) rotateZ(-30deg); z-index: 2; }
        .layer-3 { background: rgba(16, 185, 129, 0.9); transform: translateY(50px) rotateX(60deg) rotateZ(-30deg); z-index: 1; }
        /* 鼠标悬浮拉开动画 */
        .hero-combined-right:hover .layer-1 { transform: translateY(-80px) rotateX(60deg) rotateZ(-30deg); }
        .hero-combined-right:hover .layer-3 { transform: translateY(80px) rotateX(60deg) rotateZ(-30deg); }
      "))
    ),
    # Tab 内容区
    tabItems(
      # Tab 1: HOME ----
      tabItem(
        tabName = "Home",
        # 1. 横幅 (Banner)
        fluidRow(
          column(12,
                 div(class = "hero-combined",
                     # 左侧：保留你代码1的丰富文案
                     div(class = "hero-combined-left",
                         h1(icon("atom", style="color:#3b82f6;"), " scMATE Platform"),
                         h3("Single-Cell Multi-omics Analysis Explorer for Transcriptomics, DNA Methylation, and Chromatin Accessibility"),
                         p("scMATE is a comprehensive, zero-code interactive web framework designed to decipher complex regulatory mechanisms from highly sparse single-cell multi-omics data. By deeply integrating ",
                           tags$b("Transcriptome "), "(e.g., scRNA-seq), ", tags$b("CpG Methylation"), ", and ", tags$b("GpC Chromatin Accessibility"),
                           " (e.g., scBS-seq, scM&T-seq, scNOMe-seq, scNMT-seq), scMATE bridges the gap between epigenetic landscape and transcriptional output at single-cell resolution."),
                         p("Powered by optimized C++ sparse matrix operations, scMATE effortlessly handles large-scale datasets while providing publication-ready visualizations."),
                         br(),
                         # 主按钮：保持绿色，白色文字
                         actionButton("btn_hero_start", "Launch Analysis", icon = icon("play-circle"),
                                      class = "btn-lg",
                                      style = "background-color: #10b981; color: white; border: none; border-radius: 30px; padding: 12px 35px; font-size: 18px; font-weight: bold; box-shadow: 0 6px 15px rgba(16, 185, 129, 0.3); margin-right: 15px;",
                                      onclick = "Shiny.setInputValue('goto_tab', 'Transcriptome_Analysis', {priority: 'event'});")
                         # 副按钮：为适配白底，改为浅灰底色+深色文字+灰色边框
                         # actionButton("btn_hero_demo", "View Tutorial", icon = icon("book"),
                         #              class = "btn-lg",
                         #              style = "background-color: #f8fafc; color: #0f172a; border: 2px solid #e2e8f0; border-radius: 30px; padding: 10px 35px; font-size: 18px; font-weight: bold; transition: all 0.3s;")
                     ),
                     # 右侧：保留你代码2的多组学艺术图
                     div(class = "hero-combined-right",
                         div(class = "layer layer-1", icon("microscope"), span(style="margin-left:10px;", "Transcriptome")),
                         div(class = "layer layer-2", icon("dna"), span(style="margin-left:10px;", "Methylation")),
                         div(class = "layer layer-3", icon("cubes"), span(style="margin-left:10px;", "Accessibility"))
                     )
                 )
          )
        ),
        # 2. 核心模块详解 (Detailed Module Breakdown)
        fluidRow(
          column(4,
                 div(class = "module-card card-rna",
                     div(class = "icon-wrapper", icon("microscope")),
                     h3("1. Transcriptomics"),
                     p("End-to-end pipeline for single-cell RNA sequencing data. Uncover cellular heterogeneity with precision."),
                     tags$ul(
                       tags$li(tags$b("Quality Control:"), " Mitochondria & feature filtering."),
                       tags$li(tags$b("Manifold Learning:"), " High-performance PCA, t-SNE, and UMAP embeddings."),
                       tags$li(tags$b("Marker Discovery:"), " Rapid Wilcoxon rank-sum test for cluster specific DGEs."),
                       tags$li(tags$b("Trajectory Inference:"), " Pseudotime analysis to trace developmental lineages.")
                     ),
                     actionButton("btn_go_rna", "Go to Module →", class="btn-sm", style="background:#eff6ff; color:#3b82f6; border:none; font-weight:bold; width:100%;", onclick = "Shiny.setInputValue('goto_tab', 'Transcriptome_Analysis', {priority: 'event'});")
                 )
          ),
          column(4,
                 div(class = "module-card card-epi",
                     div(class = "icon-wrapper", icon("dna")),
                     h3("2. Epigenomics"),
                     p("Tailored for scNOMe-seq. Overcome severe sparsity to reveal robust epigenetic landscapes."),
                     tags$ul(
                       tags$li(tags$b("Sparsity Mitigation:"), " Advanced k-NN based imputation for dropout recovery."),
                       tags$li(tags$b("Landscape Profiling:"), " Visualizing global & localized methylation/accessibility ridge plots."),
                       tags$li(tags$b("Differential Analysis:"), " Dual-testing (Fisher's exact + Variance) for DMRs and DARs."),
                       tags$li(tags$b("Promoter/Enhancer:"), " Genomic region specific signal aggregation.")
                     ),
                     actionButton("btn_go_epi", "Go to Module →", class="btn-sm", style="background:#f5f3ff; color:#8b5cf6; border:none; font-weight:bold; width:100%;", onclick = "Shiny.setInputValue('goto_tab', 'Epigenome_Analysis', {priority: 'event'});")
                 )
          ),
          column(4,
                 div(class = "module-card card-int",
                     div(class = "icon-wrapper", icon("cubes")),
                     h3("3. Multi-Omics Integration"),
                     p("Cross-modality alignment to elucidate how epigenetics drives transcriptomic output."),
                     tags$ul(
                       tags$li(tags$b("Signal Mapping:"), " Non-equi join linking epigenetic marks to specific gene coordinates."),
                       tags$li(tags$b("Composite Z-Score:"), " A novel metric combining Met, Acc, and Exp layers."),
                       tags$li(tags$b("Regulatory States:"), " Classifying genes into 'Poised', 'Active', or 'Repressed' states."),
                       tags$li(tags$b("Pathway Enrichment:"), " GO/KEGG mapping of master regulatory drivers.")
                     ),
                     actionButton("btn_go_int", "Go to Module →", class="btn-sm", style="background:#ecfdf5; color:#10b981; border:none; font-weight:bold; width:100%;", onclick = "Shiny.setInputValue('goto_tab', 'Integration_Analysis', {priority: 'event'});")
                 )
          )
        ),
        br(),
        # 3. 平台工作流 (Visual Workflow)
        fluidRow(
          column(12,
                 box(
                   title = span(icon("project-diagram"), " scMATE Analytical Workflow"),
                   status = "primary", solidHeader = TRUE, width = 12,
                   div(class = "workflow-container",
                       div(class = "workflow-line"),
                       div(class = "workflow-step",
                           div(class = "step-icon", icon("cloud-upload-alt")),
                           h4("1. Data Ingestion"),
                           p("Upload sparse count matrices, cell metadata, and genomic interval files (.bed/.cov).")
                       ),
                       div(class = "workflow-step",
                           div(class = "step-icon", icon("cogs")),
                           h4("2. Preprocessing & QC"),
                           p("Filter low-quality cells, normalize matrices, and perform k-NN based epigenetic imputation.")
                       ),
                       div(class = "workflow-step",
                           div(class = "step-icon", icon("project-diagram")),
                           h4("3. Dimensionality & Clustering & Differential Analysis"),
                           p("Identify cell sub-populations via PCA/UMAP and discover modality-specific markers.")
                       ),
                       div(class = "workflow-step",
                           div(class = "step-icon", icon("network-wired")),
                           h4("4. Multi-Omic Cross-Mapping"),
                           p("Align DNA methylation and accessibility peaks to gene promoters/bodies.")
                       ),
                       div(class = "workflow-step",
                           div(class = "step-icon", icon("lightbulb")),
                           h4("5. Biological Discovery"),
                           p("Calculate Composite Z-scores, define regulatory states, and export publication-ready plots.")
                       )
                   )
                 )
          )
        ),
        # 4. 数据格式指南 与 新闻/引用 (Data Requirements & Meta info)
        fluidRow(
          # 左侧：数据输入要求
          column(7,
                 div(class = "info-panel",
                     h4(icon("file-alt"), " Data Input Guidelines"),
                     p("To ensure successful analysis, please format your data according to the following specifications before uploading:"),
                     tags$ul(class = "data-format-list",
                             tags$li(icon("file-csv"),
                                     div(tags$b("Transcriptome (scRNA-seq): "),
                                         "Requires a raw count matrix (.csv, .txt, .rds). Rows = Genes, Columns = Cells. A separate metadata file containing cell annotations is highly recommended.")),
                             tags$li(icon("file-code"),
                                     div(tags$b("Epigenome (CpG/GpC): "),
                                         "Requires methylation/accessibility rate matrices. Supported formats include binarized site-level matrices, aggregated promoter/gene-body matrices.")),
                             tags$li(icon("align-left"),
                                     div(tags$b("Genomic Intervals (Optional): "),
                                         "For custom integration, standard .bed or .csv files mapping genomic regions to genes are supported.")),
                             tags$li(icon("tachometer-alt"),
                                     div(tags$b("Performance Note: "),
                                         "For datasets exceeding 50,000 cells, uploading pre-processed sparse matrices (.rds dgCMatrix) is strongly advised to reduce memory overhead."))
                     )
                 )
          ),
          # 右侧：更新日志与引用
          column(5,
                 div(class = "info-panel",
                     h4(icon("bullhorn"), " Updates & Citation"),
                     # 简单的更新时间线
                     div(class = "timeline",
                         div(class = "timeline-item",
                             div(class = "timeline-date", "Apr 2026 - v1.2.6"),
                             div(class = "timeline-content",
                                 "• Add a feature for enhancer-promoter interactions.", br(),
                                 "• Add a feature for atac format converter.")
                         ),
                         div(class = "timeline-item",
                             div(class = "timeline-date", "Apr 2026 - v1.2.5"),
                             div(class = "timeline-content",
                                 "• Introduced dynamic visual effects and interactive animations.", br(),
                                 "• Refined overall UI layout for better readability.")
                         ),
                         div(class = "timeline-item",
                             div(class = "timeline-date", "Jan 2026 - v1.1.0"),
                             div(class = "timeline-content",
                                 "• Boosted computation speed for epigenome integration.", br(),
                                 "• Improved multi-omics integration pipeline.", br(),
                                 "• Upgraded graphical interface styling.")
                         ),
                         div(class = "timeline-item",
                             div(class = "timeline-date", "Nov 2025 - v1.0.0"),
                             div(class = "timeline-content",
                                 "• Public release of the scMATE system.")
                         )
                     ),
                     hr(style="margin: 15px 0; border-top: 1px dashed #cbd5e1;"),
                     # 引用框
                     tags$b(icon("quote-right"), " How to cite scMATE:"),
                     div(class = "citation-box",
                         icon("bookmark")
                         # "Doe, J., Smith, A., et al. (2026). scMATE: an interactive Shiny-based workflow for the integration and visualization of single-cell transcriptome, DNA methylation, and chromatin accessibility. ",
                         # # tags$i("Nucleic Acids Research"),
                         # ", 54(1), e12. doi: 10.1093/nar/gkab123"
                     )
                 )
          )
        ),
        # 5. 页脚及版权信息 (Footer)
        fluidRow(
          column(12,
                 tags$div(
                   style = "display: flex; justify-content: center; align-items: center; margin-top: 40px; margin-bottom: 20px; padding-top: 25px; border-top: 1px solid #e2e8f0;",
                   # 左侧：文字信息
                   tags$div(
                     style = "text-align: left; color: #64748b; font-size: 14px; margin-right: 50px;",
                     # tags$p(style = "margin-bottom: 5px; font-weight: 800; color: #1e293b; font-size: 16px;", "scMATE Platform"),
                     tags$p(style = "margin-bottom: 5px;",
                            "Copyright © 2026 ",
                            tags$a(href = "https://medinfo.hebeu.edu.cn", target = "_blank", "Medinfo-Lab", style = "color: #64748b; font-weight: bold; text-decoration: none; border-bottom: 1px dotted #94a3b8;"),
                            ". All Rights Reserved."),
                     tags$p(style = "margin-bottom: 5px;", "School of Medicine, Hebei University of Engineering"),
                     tags$p(style = "margin-bottom: 0;", "Hebei Key Laboratory of Medical Data Science"),
                     tags$div(style = "margin-top: 10px;",
                              # tags$a(href="#", icon("github"), " GitHub", style="color:#3b82f6; text-decoration:none; margin-right:15px;"),
                              tags$a(href="#", icon("envelope"), " Contact Support", style="color:#3b82f6; text-decoration:none;")
                     )
                   ),
                   # 右侧：Logo 图片
                   tags$div(
                     tags$img(src = "IBI.png", style = "width: 240px; height: auto; mix-blend-mode: multiply; object-fit: contain; filter: grayscale(15%); transition: all 0.4s ease;",
                              onmouseover="this.style.filter='grayscale(0%)'; this.style.transform='scale(1.05)';",
                              onmouseout="this.style.filter='grayscale(15%)'; this.style.transform='scale(1)';")
                   )
                 )
          )
        )
      ),
      # Tab 2: Transcriptome Analysis ----
      tabItem(
        tabName = "Transcriptome_Analysis",
        div(class = "module-header",
            h2(icon("microscope"), " Transcriptome Analysis"),
            p("scRNA-seq: Memory-Efficient Object Construction, Rigorous QC, Manifold Learning, and Ultra-Fast Marker Discovery.")
        ),
        box(
          title = "User Guide: Transcriptomics Module", width = 12, collapsible = TRUE, collapsed = FALSE, class = "guide-box",
          tags$ul(
            tags$li(strong("Create Object & Quality Control:"),
                    " Automatically extract Highly Variable Genes (HVGs) to define the optimal feature space. Execute high-performance manifold learning—including PCA, t-SNE, and UMAP—coupled with robust community detection algorithms to dissect cellular heterogeneity and map topological structures."),
            tags$li(strong("Dimension Reduction & Cluster Analysis:"),
                    " Automatically extract Highly Variable Genes (HVGs) to define the optimal feature space. Execute high-performance manifold learning—including PCA, t-SNE, and UMAP—coupled with robust community detection algorithms to dissect cellular heterogeneity and map topological structures."),
            tags$li(strong("Differential Expression Analysis (DEA):"),
                    " Leverage a highly optimized, sparse-matrix-accelerated Wilcoxon rank-sum framework to execute rapid statistical testing. Efficiently profile global or cluster-specific transcriptomic signatures, visualized instantly through interactive and fully annotated Volcano plots."),
            tags$li(strong("Pseudotime Analysis:"),
                    " Elucidate developmental trajectories and transitional cellular states. Implement sophisticated modeling techniques—selecting 'Cluster-based' routing for macroscopic state progressions or 'Graph-based' topologies for high-resolution continuous gradients—to accurately infer developmental pseudotime.")
          )
        ),
        fluidRow(
          valueBoxOutput("cell_count_box", width = 4),
          valueBoxOutput("gene_count_box", width = 4),
          valueBoxOutput("group_status_box", width = 4)
        ),
        tabsetPanel(
          id = "rna_analysis_tabs",
          type = "tabs",
          tabPanel(
            title = "1. Create Object & QC",
            value = "tab_rna_preprocess",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("database"), " 1. Data Import & Object Creation"), width = NULL, status = "primary", solidHeader = TRUE,
                       h5(tags$b("Step 1: Expression Matrix"), style = "color: #2c3e50;"),
                       fileInput("RNA_data_input1", "Upload Matrix (CSV/TXT/H5):", accept = c(".csv", ".txt", ".tsv", ".h5", ".hdf5")),
                       uiOutput("rna_id_selector_ui"),
                       # --- 新增: 底层矩阵级别的“死细胞”与“垃圾基因”初筛 ---
                       div(style = "background-color: #f4f6f9; padding: 10px; border-radius: 5px; margin-bottom: 10px; border: 1px solid #d2d6de;",
                           tags$b(icon("filter"), " Matrix Pre-filter:", style = "color: #34495e; font-size: 13px;"),
                           fluidRow(
                             column(6, numericInput("min_cells_raw", "min.cells:", value = 3, min = 0, step = 1)),
                             column(6, numericInput("min_features_raw", "min.features:", value = 200, min = 0, step = 10))
                           )
                       ),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       h5(tags$b("Step 2: Metadata (Optional)"), style = "color: #2c3e50;"),
                       fileInput("RNA_data_input2", "Upload Metadata (CSV/TXT/Excel):", accept = c(".csv", ".txt", ".xlsx")),
                       uiOutput("rna_sheet_selector_ui"), # 专门选 Sheet
                       uiOutput("rna_col_mapping_ui"),    # 专门选列,
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       # actionButton("runButton2", " Build RDS Object", icon = icon("cogs"), class = "btn-info btn-lg", style = "width: 100%; font-weight: bold; border-radius: 5px;")
                       div(style = "display: flex; gap: 10px; width: 100%;",
                           actionButton("runButton2", " Build Object", icon = icon("cogs"), class = "btn-info btn-lg",
                                        style = "flex: 2; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           actionButton("reset_rna_all", " Reset & Clear", icon = icon("trash-alt"), class = "btn-warning btn-lg",
                                        style = "flex: 1; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                       ),
                       div(style = "display: flex; gap: 10px; width: 100%; margin-top: 10px;",
                           actionButton("use_example_rna", " Use Example", icon = icon("lightbulb"), class = "btn-success",
                                        style = "flex: 1; font-weight: bold; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);"),
                           downloadButton("dl_example_rna", " Download Example", class = "btn-default",
                                          style = "flex: 1; font-weight: bold; border-radius: 5px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); color: #333;")
                           # tags$a(
                           #   href = "Integration_example_data.zip", # 直接指向 www 下的文件名
                           #   "Download Example",
                           #   class = "btn btn-default",
                           #   style = "font-weight: bold;",
                           #   download = "scMATE_MultiOmics_Example.zip" # 提示浏览器下载时的默认文件名
                           # )
                       )
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("table"), " Object Metadata Preview"), width = NULL, status = "info", solidHeader = F,
                       div(style = "text-align: center; margin-bottom: 15px; background-color: #e8f4f8; padding: 10px; border-radius: 5px;",
                           tags$b("Data View Toggle:  ", style="font-size: 15px; color: #2980b9;"),
                           radioButtons("view_data_type", NULL,
                                        choices = c("Raw Data (Step 1)" = "raw", "Quality Control Data (Step 3)" = "qc"),
                                        selected = "raw", inline = TRUE)
                       ),
                       p("This table strictly displays the metadata slots from the custom ", tags$code("sciET_Object"), ", proving that categorical/continuous group vectors have been successfully injected via C-level pointer bindings.", style = "color: #7f8c8d; font-size: 13px;"),
                       DT::DTOutput("data_table1"),
                       # %>% withSpinner(color = "#3c8dbc", type = 4),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       uiOutput("download_ui")
                     )
              )
            ),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("sliders-h"), " 2. QC & Filter Parameters"), width = NULL, status = "primary", solidHeader = TRUE,
                       h5(tags$b("Step A: Calculate & Group Plot"), style = "color: #e67e22;"),
                       radioButtons("species_mt", "Mitochondrial Pattern:", choices = c("Human (^MT-)" = "^MT-", "Mouse (^mt-)" = "^mt-", "Custom" = "custom"), inline = TRUE),
                       conditionalPanel(condition = "input.species_mt == 'custom'", textInput("custom_mt", "Enter Custom Pattern:", value = "^MT-")),
                       uiOutput("qc_group_selector_ui"),
                       actionButton("runQC", " Calculate & Plot", icon = icon("chart-bar"), class = "btn-warning btn-sm", style = "width: 100%;"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       h5(tags$b("Step B: Filter Cells"), style = "color: #e67e22;"),
                       numericInput("min_nFeature", "Min nFeature_RNA:", value = 200, min = 0),
                       numericInput("max_nFeature", "Max nFeature_RNA:", value = 6000, min = 0),
                       numericInput("min_nCount", "Min nCount_RNA:", value = 500, min = 0),
                       numericInput("max_nCount", "Max nCount_RNA:", value = 500000, min = 0),
                       numericInput("max_mt", "Max percent.mt (%):", value = 10, min = 0, max = 100),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       h5(tags$b("Step C: Normalization Method"), style = "color: #e67e22;"),
                       selectInput("rna_norm_method", NULL, choices = c("LogNormalize (10X UMI)" = "LogNormalize", "LogCPM (Smart-seq2 / Bulk Counts)" = "LogCPM", "TPM" = "TPM"), selected = "LogCPM"),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       actionButton("runFilter", " Apply Filter", icon = icon("filter"), class = "btn-info btn-lg",
                                    style = "width: 100%; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("chart-area"), " Quality Control Violin Plots"), width = NULL, status = "success", solidHeader = F,
                       div(style = "text-align: right; margin-bottom: 10px;",
                           downloadButton("dl_qc_plot_pdf", " Download PDF", class = "btn-default btn-sm")
                       ),
                       plotOutput("qc_plot", height = "550px")
                       # %>% withSpinner(color = "#00a65a", type = 5)
                     )
              )
            )
          ),
          tabPanel(
            title = "2. Dimension Reduction & Clustering",
            value = "tab_rna_dimred",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("cogs"), " Algorithm Settings"), status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("dr_data_status_ui"),
                       actionButton("btn_reset_dr", " Reset Data & Settings", icon = icon("sync"),
                                    class = "btn-warning btn-sm", style = "width: 100%; margin-top: 10px; font-weight: bold;"),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       # 1. 分组与降维设置
                       h5(icon("project-diagram"), tags$b(" Dimension Reduction")),
                       uiOutput("dr_group_col_ui"), # 这里选择的是左图的映射列 (如 Sample, Group)
                       uiOutput("dr_layer_select_ui"),
                       selectInput("dr_method_rna", "Select Method:", choices = c("PCA" = "PCA", "t-SNE" = "t-SNE", "UMAP" = "UMAP"), selected = "PCA"),
                       uiOutput("dr_params_ui"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       # 2. [新增] 聚类设置
                       h5(icon("users"), tags$b(" Cell Clustering")),
                       checkboxInput("do_clustering", tags$b("Perform Auto-Clustering?"), value = FALSE),
                       # 当勾选聚类时，展示硬核参数面板
                       conditionalPanel(
                         condition = "input.do_clustering == true",
                         div(style = "padding: 10px; background-color: #f9f9f9; border-radius: 5px; border: 1px solid #e3e3e3;",
                             radioButtons("cluster_method", "Clustering Engine:",
                                          choices = c("Graph-based (Leiden)" = "graph",
                                                      "Hierarchical (Ward.D2)" = "hclust"),
                                          selected = "graph"),
                             # 图聚类专属参数：分辨率
                             conditionalPanel(
                               condition = "input.cluster_method == 'graph'",
                               sliderInput("cluster_res", "Resolution (Higher = More clusters):",
                                           min = 0.1, max = 2.0, value = 0.5, step = 0.1)
                             ),
                             # 层次聚类专属参数：K值
                             conditionalPanel(
                               condition = "input.cluster_method == 'hclust'",
                               sliderInput("cluster_k", "Number of Clusters (K):",
                                           min = 2, max = 30, value = 8, step = 1)
                             )
                         )
                       ),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       actionButton("run_dr", " Run Reduction & Cluster", icon = icon("play"), class = "btn-info btn-lg",
                                    style = "width: 100%; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("chart-area"), " Manifold & Cluster Visualization"), status = "primary", width = NULL,
                       div(style = "text-align: right; margin-bottom: 10px;",
                           downloadButton("dl_dr_plot_pdf", " Download PDF", class = "btn-default btn-sm")
                       ),
                       # 调大画图区域的高度以适应并排的两张图
                       shinycssloaders::withSpinner(plotOutput("dr_plot", height = "550px"), type = 4, color = "#3c8dbc"),
                       br(),
                       downloadButton("download_dr_data", "Download Coordinates & Clusters", class="btn-default btn-sm")
                     )
              )
            )
          ),
          tabPanel(
            title = "3. Differential Gene Analysis",
            value = "tab_rna_dea",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("cogs"), " DEA Configuration"), status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("dea_data_status_ui"),
                       actionButton("btn_reset_dea", " Reset Data & Settings", icon = icon("sync"),
                                    class = "btn-warning btn-sm", style = "width: 100%; margin-top: 10px; font-weight: bold;"),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       uiOutput("dea_data_layer_ui"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       uiOutput("dea_group_col_ui"),
                       radioButtons("dea_mode", "Comparison Mode:", choices = c("One vs Rest (Find Markers)" = "one_vs_rest", "One vs One (Targeted)" = "one_vs_one")),
                       uiOutput("dea_comparison_ui"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       splitLayout(
                         numericInput("dea_min_pct", "Min Pct:", 0.2, step = 0.05, min = 0, max = 1),
                         numericInput("dea_logfc_thresh", "Log2FC Thresh:", 1, step = 0.05, min = 0)
                       ),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       actionButton("run_dea", " Identify Markers", icon = icon("search"), class = "btn-info btn-lg",
                                    style = "width: 100%; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     ),
                     box(
                       title = span(icon("filter"), " Plot Filters"), status = "primary", solidHeader = TRUE, width = NULL,
                       sliderInput("volcano_fc_cut", "Log2FC Cutoff", 0, 5, 0.5, 0.1),
                       numericInput("volcano_p_cut", "Adj P-value Cutoff", 0.05, 0, 1, 0.001)
                     )
              ),
              column(width = 9,
                     # 1. Top Markers Table 放在上面
                     box(
                       title = span(icon("table"), " Top Markers Table"), status = "success", width = NULL,
                       downloadButton("dea_download_csv", "Export CSV", class="btn-default btn-sm"),
                       br(), br(),
                       shinycssloaders::withSpinner(DT::dataTableOutput("dea_table", width = "100%"), type = 4, color = "#3c8dbc")
                     ),
                     # 2. Volcano Plot 放在下面
                     box(
                       title = span(icon("fire"), " Volcano Plot"), status = "success", width = NULL,
                       # 新增靠右的下载按钮
                       div(style = "text-align: right; margin-bottom: 10px;",
                           downloadButton("dl_volcano_plot_pdf", " Download PDF", class = "btn-default btn-sm")
                       ),
                       shinycssloaders::withSpinner(plotOutput("volcano_plot", height = "550px"), type = 4, color = "#dd4b39")
                     )
              )
            )
          ),
          tabPanel(
            title = "4. Pseudotime Analysis",
            value = "tab_rna_Pseudo",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("route"), " Trajectory Settings"), status = "primary", solidHeader = TRUE, width = NULL,
                       # 1. 数据源状态
                       uiOutput("pseudo_data_status_ui"),
                       actionButton("btn_reset_pseudo", " Reset Data & Settings", icon = icon("sync"),
                                    class = "btn-warning btn-sm", style = "width: 100%; margin-top: 10px; font-weight: bold;"),
                       hr(style = "border-top: 1px solid #d2d6de;"),
                       # 【新增】算法选择
                       radioButtons("pseudo_algorithm", "Select Core Algorithm:",
                                    choices = c("Cluster-based" = "cluster",
                                                "Graph-based" = "graph"),
                                    selected = "cluster"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       # 2. 选择降维坐标 (依赖于上一步的运行结果)
                       uiOutput("pseudo_dr_select_ui"),
                       # 3. 选择细胞分组(Cluster)与起点
                       uiOutput("pseudo_group_col_ui"),
                       uiOutput("pseudo_start_clus_ui"),
                       hr(style = "border-top: 1px dashed #d2d6de;"),
                       actionButton("run_pseudo", " Infer Trajectory", icon = icon("project-diagram"), class = "btn-info btn-lg",
                                    style = "width: 100%; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("chart-area"), " Pseudotime Visualization"), status = "primary", width = NULL,
                       div(style = "text-align: right; margin-bottom: 10px;",
                           downloadButton("dl_pseudo_plot_pdf", " Download PDF", class = "btn-default btn-sm")
                       ),
                       shinycssloaders::withSpinner(plotOutput("pseudo_plot", height = "600px"), type = 4, color = "#8e44ad"),
                       br(),
                       downloadButton("download_pseudo_data", " Download Pseudotime (CSV)", class="btn-default btn-sm")
                     )
              )
            )
          )
        )
      ),
      # Tab 3: Epigenome Analysis ----
      tabItem(
        tabName = "Epigenome_Analysis",
        div(class = "module-header",
            h2(icon("align-left"), " Epigenome Analysis"),
            p("scNOMe-seq, Single-Cell Methylation & Accessibility: High-Performance Matrix Assembly, Epigenetic Landscaping, and Strict DMR Profiling.")
        ),
        box(
          title = "User Guide: Epigenomics Module", width = 12, collapsible = TRUE, collapsed = FALSE, class = "guide-box",
          tags$ul(
            tags$li(strong("Aggregated Data & Quality Control:"),
                    " Seamlessly ingest custom genomic intervals (.bed) alongside raw single-cell coverage profiles (.cov). The computational backend leverages an ultra-fast, memory-optimized non-equi join algorithm to precisely quantify triad epigenetic metrics (methylated, unmethylated, and global levels) at single-cell resolution, followed by stringent, sparsity-aware filtering protocols."),
            tags$li(strong("Epigenetic Landscape & Dimension Reduction:"),
                    " Mitigate inherent single-cell epigenomic sparsity through sophisticated data imputation algorithms (k-NN or Mean-based). Elucidate complex epigenetic heterogeneities via interactive Ridge density plots, and deploy an extensive arsenal of manifold learning techniques (including PCA, UMAP, NMF, MDS, and PLS-DA) to robustly dissect cellular substructures and topological variations."),
            tags$li(strong("Differential Region Analysis (DRA):"),
                    " Execute a highly rigorous, dual-statistical testing framework to accurately identify Differentially Methylated or Accessible Regions (DMRs/DARs). Effectively profile population-specific epigenetic signatures, seamlessly visualized through interactive, publication-ready Volcano plots.")
          )
        ),
        fluidRow(
          valueBoxOutput("sample_count_box", width = 4),
          valueBoxOutput("region_count_box", width = 4),
          valueBoxOutput("qc_status_box", width = 4)
        ),
        tabsetPanel(
          id = "epi_main_tabs",
          type = "tabs",
          tabPanel(
            title = "1. Matrix Assembly & QC",
            value = "tab_epi_assembly",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = "1. Data Aggregation", status = "primary", solidHeader = TRUE, width = NULL,
                       div(id = "epi_upload_ui",
                           fileInput("bismark_files", "Upload .cov files (Multiple):", multiple = TRUE, accept = c(".cov", ".txt", ".gz")),
                           fileInput("bed_file", "Upload BED file (Genomic Regions):", multiple = FALSE, accept = c(".bed", ".csv")),
                       ),
                       sliderInput("num_threads",
                                   span(icon("microchip"), " Parallel Threads (CPU Cores):"),
                                   min = 1,
                                   max = 16, # 自动检测服务器最大核数
                                   # max = min(16, max(1, parallel::detectCores() - 2)), # 自动检测服务器最大核数
                                   value = min(4, max(1, parallel::detectCores() - 2)), # 默认给4核
                                   step = 1),
                       div(style = "display: flex; gap: 10px; width: 100%;",
                           # 原有的 Run 按钮
                           actionButton("btn_aggregate", " Run Aggregation",
                                        icon = icon("layer-group"), class = "btn-info",
                                        style = "flex: 2; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           # 【新增】：Stop 按钮，默认隐藏 (display: none)
                           actionButton("btn_stop_aggregate", " Stop & Reset",
                                        icon = icon("stop-circle"), class = "btn-danger",
                                        style = "display: none; flex: 2; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           # 原有的 Reset 按钮
                           actionButton("btn_reset_epi_assembly", " Reset & Clear",
                                        icon = icon("trash-alt"), class = "btn-warning",
                                        style = "flex: 1; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                       ),
                       div(style = "display: flex; gap: 10px; width: 100%; margin-top: 15px; margin-bottom: 15px;",
                           actionButton("btn_use_example_epi", " Use Example", icon = icon("lightbulb"), class = "btn-success",
                                        style = "flex: 1; font-weight: bold; border-radius: 5px; display: inline-flex; align-items: center; justify-content: center; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           downloadButton("btn_dl_example_epi", " Download Example",
                                          style = "flex: 1; font-weight: bold; border-radius: 5px; display: inline-flex; align-items: center; justify-content: center;")
                           # tags$a(
                           #   href = "Integration_example_data.zip", # 直接指向 www 下的文件名
                           #   "Download Example",
                           #   class = "btn btn-default",
                           #   style = "font-weight: bold;",
                           #   download = "scMATE_MultiOmics_Example.zip" # 提示浏览器下载时的默认文件名
                           # )
                       )
                     ),
                     box(
                       title = "2. Quality Control (QC)", status = "primary", solidHeader = TRUE, width = NULL,
                       helpText("Calculates NA ratios independently based on the RAW matrix."),
                       numericInput("qc_row_top_n", "1. Keep Top N Regions (Least NAs):", value = 2000, min = 500, max = 5000, step = 500),
                       sliderInput("qc_col_na_thresh", "2. Max NA Ratio per Cell:", min = 0, max = 1, value = 0.80, step = 0.05),
                       actionButton("btn_run_qc", "Run QC", icon = icon("filter"), class = "btn-info", width = "100%",
                                    style = "font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("terminal"), " QC Execution & System Log"),
                       status = "info", solidHeader = TRUE, width = NULL, collapsible = TRUE,
                       # 使用 uiOutput 替代原先的 verbatimTextOutput
                       uiOutput("epi_qc_log_html")
                     ),
                     box(
                       title = span(icon("table"), "Data Preview & Export"), status = "success", solidHeader = F, width = NULL,
                       radioButtons("view_data_type", "Select Data to View:",
                                    choices = c("Raw Aggregated Data" = "raw", "QC Filtered Data" = "qc"),
                                    inline = TRUE),
                       hr(),
                       DTOutput("epi_data_table") %>% withSpinner(color="#0dc5c1"),
                       br(),
                       uiOutput("epi_download_ui")
                     )
              )
            )
          ),
          tabPanel(
            title = "2. Dimension Reduction",
            value = "tab_epi_dimred",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = "1. Data & Metadata", status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("dr_matrix_source_ui"),
                       hr(),
                       fileInput("dr_group_file", "Upload Metadata (.xlsx or .csv):", accept = c(".xlsx", ".csv")),
                       uiOutput("dr_sheet_ui"),
                       uiOutput("dr_column_selectors"),
                       hr(),
                       div(style = "display: flex; gap: 10px; width: 100%; margin-bottom: 10px;",
                           # 左侧运行按钮 (flex: 1 保证两者各占 50% 宽度)
                           actionButton("dr_btn_run_ridge", " Generate Landscape", icon = icon("mountain"),
                                        class = "btn-info",
                                        style = "flex: 1; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           # 右侧重置按钮
                           actionButton("dr_btn_reset", " Reset", icon = icon("sync"),
                                        class = "btn-warning",
                                        style = "flex: 1; font-weight:bold; padding: 6px 2px; white-space: normal;")
                       )
                     ),
                     box(
                       title = "2. Reduction Settings", status = "primary", solidHeader = TRUE, width = NULL,
                       selectInput("dr_impute_method", "NA Imputation Method:", choices = c("KNN (Recommended)" = "knn", "Row Mean" = "mean")),
                       conditionalPanel("input.dr_impute_method == 'knn'", numericInput("dr_knn_k", "KNN 'k' neighbors:", value = 10, min = 2, max = 50)),
                       hr(),
                       selectInput("dr_method", "Algorithm:", choices = c("PCA", "UMAP", "MDS", "NMF")),
                       conditionalPanel("input.dr_method == 'UMAP'", splitLayout(numericInput("dr_umap_neighbors", "n_neighbors", 15), numericInput("dr_umap_dist", "min_dist", 0.1))),
                       conditionalPanel("input.dr_method == 'MDS'", selectInput("dr_mds_dist_method", "Distance:", c("Spearman" = "spearman", "Pearson" = "pearson"))),
                       conditionalPanel("input.dr_method == 'NMF'", numericInput("dr_nmf_rank", "Rank (Clusters):", 2, min = 2)),
                       # conditionalPanel("input.dr_method == 'PLS-DA'", numericInput("dr_plsda_ncomp", "Components:", 2, min = 2)),
                       br(),
                       actionButton("dr_btn_run", "Run DimRed", icon = icon("project-diagram"), class = "btn-info btn-lg", width = "100%", style = "font-weight:bold;")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("chart-bar"), " Analysis Results"), status = "success", solidHeader = F, width = NULL,
                       tabsetPanel(
                         id = "epi_result_el_dim",
                         tabPanel("Epigenetic Landscape", value = "tab_el", icon = icon("mountain"),
                                  br(),
                                  shinycssloaders::withSpinner(plotOutput("dr_plot_ridge", height = "600px"), type = 4, color = "#17a2b8"),
                                  hr(),
                                  downloadButton("dr_btn_download_ridge_plot", "Download Plot (PDF)", class="btn-default"),
                                  downloadButton("dr_btn_download_ridge_data", "Download Stats (CSV)", class="btn-default")
                         ),
                         tabPanel("Dimension Reduction", value = "tab_dim", icon = icon("project-diagram"),
                                  br(),
                                  shinycssloaders::withSpinner(plotOutput("dr_plot_output", height = "600px"), type = 4, color = "#0dc5c1"),
                                  hr(),
                                  downloadButton("dr_btn_download_plot", "Download Plot (PDF)", class="btn-default"),
                                  downloadButton("dr_btn_download_data", "Download Coordinates (CSV)", class="btn-default")
                         )
                       )
                     )
              )
            )
          ),
          tabPanel(
            title = "3. Differential Region Analysis",
            value = "tab_epi_diff",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = "1. Data & Metadata", status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("diff_matrix_source_ui"),
                       hr(),
                       uiOutput("diff_metadata_source_ui"),
                       uiOutput("diff_sheet_ui"),
                       br(),
                       actionButton("diff_btn_reset", " Reset Data & Settings", icon = icon("sync"),
                                    class = "btn-warning btn-sm", style = "width: 100%; margin-bottom: 10px; font-weight:bold;"),
                       hr(),
                       h5(icon("cogs"), " Explicit Column Mapping"),
                       helpText("Please specify which columns in your metadata contain the corresponding sample IDs and grouping info:"),
                       uiOutput("diff_mapping_ui")
                     ),
                     box(
                       title = "2. Comparison Settings", status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("diff_target_ui"),
                       radioButtons("diff_compare_mode", "Compare Mode:", choices = c("One vs Rest" = "1vsRest", "One vs One" = "1vs1"), inline = TRUE),
                       uiOutput("diff_control_ui"),
                       hr(),
                       selectInput("diff_effect_metric", "Effect Size Metric (X-axis):",
                                   choices = c("Log2 Odds Ratio" = "Log2_Odds_Ratio",
                                               "Absolute Difference (Diff)" = "Diff",
                                               "Hedges' g" = "Hedges_g"),
                                   selected = "logFC"),
                       numericInput("diff_effect_th", "Effect Size Threshold (+/-):", value = 0.58, min = 0, step = 0.1),
                       numericInput("diff_p_th", "FDR Threshold:", value = 0.05, step = 0.01),
                       actionButton("diff_btn_run", "Run Analysis & Plot", icon = icon("balance-scale"), class = "btn-info btn-lg", width = "100%", style = "font-weight:bold;")
                     )
              ),
              column(width = 9,
                     box(
                       title = span(icon("fire"), " Volcano Plot"), status = "success", solidHeader = F, width = NULL,
                       shinycssloaders::withSpinner(plotOutput("diff_volcano_plot", height = "500px"), type = 4, color = "#3c8dbc"),
                       hr(),
                       downloadButton("diff_btn_dl_plot", "Download Volcano Plot (PDF)", class = "btn-default")
                     ),
                     box(
                       title = span(icon("table"), "Differential Regions (DMRs) Data"), status = "success", solidHeader = F, width = NULL,
                       div(style = "background: #fcf8e3; padding: 10px; border-left: 3px solid #f39c12; margin-bottom: 10px;",
                           "Note: P-values are calculated using Fisher's Exact Test on counts. If counts are missing or invalid, it automatically falls back to a Welch Two-Sample T-Test on .level data."
                       ),
                       shinycssloaders::withSpinner(DT::DTOutput("diff_result_table"), type = 4, color = "#f39c12"),
                       br(),
                       downloadButton("diff_btn_dl_csv", "Download Result Table (CSV)", class = "btn-default")
                     )
              )
            )
          )
          # tabPanel(
          #   title = "4. ATAC Format Converter",
          #   value = "tab_epi_atac_convert",
          #   br(),
          #   fluidRow(
          #     # 左侧控制面板：上传和说明
          #     column(width = 3,
          #            box(
          #              title = tagList(icon("upload"), " scATAC-seq Data Input"),
          #              status = "primary", solidHeader = TRUE, width = NULL,
          #              # 数据格式说明
          #              tags$div(
          #                style = "background-color: #f9f9f9; padding: 15px; border-left: 4px solid #3c8dbc; margin-bottom: 15px;",
          #                tags$h5(tags$b("1. Upload ATAC Matrix (Required):")),
          #                tags$p("Row = Peak ID (chr:start-end), Columns = Cells, Values = Counts"),
          #                tags$h5(tags$b("2. Target Regions BED (Optional):")),
          #                tags$p("First 3 columns must be: ", tags$code("chr"), ", ", tags$code("start"), ", ", tags$code("end"),". Intersects ATAC peaks to your custom regions.")
          #              ),
          #              # 1. 上传 ATAC 矩阵
          #              fileInput("atac_matrix_file", "1. Upload Peak Matrix (.csv)",
          #                        accept = c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
          #              # 2. 上传 目标染色体区域 (BED/CSV)
          #              fileInput("target_region_file", "2. Upload Target Regions (Optional, .bed/.csv)",
          #                        accept = c(".bed", ".csv", ".txt")),
          #              tags$div(style = "display: flex; gap: 10px;",
          #                       actionButton("btn_convert_atac", "Convert to scMATE",
          #                                    icon = icon("play-circle"),
          #                                    class = "btn-info",
          #                                    style = "flex: 2; font-weight: bold; font-size: 15px;"),
          #
          #                       actionButton("btn_reset_atac", "Reset",
          #                                    icon = icon("redo"),
          #                                    class = "btn-warning",
          #                                    style = "flex: 1; font-weight: bold; font-size: 15px;")
          #              ),
          #              br(), hr(),
          #              # 下载按钮 1 (原始 Peaks)
          #              shinyjs::hidden(
          #                downloadButton("download_atac_covs", "Download Original Peaks (.cov ZIP)",
          #                               class = "btn-success btn-block", style = "font-weight: bold; margin-bottom: 10px;")
          #              )
          #            )
          #     ),
          #     # 右侧展示面板：使用 TabsetPanel 区分两个表的预览table
          #     column(width = 9,
          #            box(
          #              title = span(icon("table"), " Converted Data Preview"), status = "success", width = NULL,
          #              # title = tagList(icon("table"), " Converted Data Preview"),
          #              # status = "info", solidHeader = TRUE, width = NULL,
          #              tabsetPanel(
          #                tabPanel("Original ATAC Peaks",
          #                         br(),
          #                         tags$div(
          #                           style = "display: flex; justify-content: flex-end; margin-bottom: 10px;",
          #                           shinyjs::hidden(downloadButton("download_preview_orig", "Download Table (.csv)", class = "btn-default btn-sm"))
          #                         ),
          #                         # helpText("Previewing signals based on the original ATAC Matrix regions:"),
          #                         DTOutput("atac_preview_table")),
          #                tabPanel("Target Mapped Regions",
          #                         br(),
          #                         tags$div(
          #                           style = "display: flex; justify-content: flex-end; margin-bottom: 10px;",
          #                           shinyjs::hidden(downloadButton("download_preview_mapped", "Download Table (.csv)", class = "btn-default btn-sm"))
          #                         ),
          #                         # helpText("Previewing signals intersected and mapped to your uploaded Target Regions. (Shows Max ATAC signal within target):"),
          #                         DTOutput("atac_mapped_preview_table"))
          #              )
          #            )
          #     )
          #   )
          # )
        )
      ),
      # Tab 4: Integration Analysis ----
      tabItem(
        tabName = "Integration_Analysis",
        div(class = "module-header",
            h2(icon("layer-group"), " Multi-Omics Integration Analysis"),
            p("Seamless Multi-omics Integration: High-fidelity coordinate mapping, spatial topological visualization, and joint Z-score driver discovery across Transcriptome, Methylation, and Accessibility layers.")
        ),
        box(
          title = "User Guide: Integration & Systems Biology", width = 12, collapsible = TRUE, class = "guide-box",
          tags$ul(
            tags$li(strong("Spatial-to-Gene Mapping & Integration:"),
                    " Seamlessly execute high-fidelity alignment of disparate epigenomic intervals (CpG methylation and GpC accessibility) to corresponding transcriptional entities (RNA). The engine deploys stringent coordinate-to-symbol mapping algorithms and exact inner-join harmonization to dynamically assemble a cohesive, multi-dimensional omics matrix at single-gene resolution."),
            tags$li(strong("Topological & Regulatory Inference:"),
                    " Reconstruct comprehensive, chromosome-wide multi-omic topologies and interactive cis-regulatory landscapes. Systematically classify gene-centric epigenetic regulatory modalities and synthesize multi-layered omic signatures via Joint Z-score transformations to effectively pinpoint master transcriptional drivers and regulatory hubs."),
            tags$li(strong("Functional Enrichment Profiling:"),
                    " Automate comprehensive Gene Ontology (GO) and KEGG pathway over-representation analyses on cross-modality prioritized marker genes. The downstream pipeline is fortified by adaptive genomic ID conversion, rigorous statistical penalization (e.g., FDR correction), and highly intuitive enrichment visualizations.")
          )
        ),
        fluidRow(
          valueBoxOutput("integ_features_box", width = 4),
          valueBoxOutput("integ_samples_box", width = 4),
          valueBoxOutput("integ_status_box", width = 4)
        ),
        tabsetPanel(
          id = "intergration_main_tabs",
          type = "tabs",
          tabPanel(
            title = "1. Data Integration",
            value = "tab_intergration_matrix",
            br(),
            box(
              title = "Configuration & Data Upload", width = 12, status = "primary", solidHeader = TRUE, collapsible = TRUE,
              # 【新增】：在这里显示“已使用示例数据”的提示框
              uiOutput("integ_example_msg"),
              h4(icon("globe"), "Step 1: Global Settings (Common Files)", style = "border-bottom: 1px solid #eee; padding-bottom: 5px; color: #3C5488; font-weight: bold;"),
              fluidRow(
                column(width = 4, fileInput("integ_region_file", "Region Annotation (CSV):", accept = ".csv", buttonLabel = "Browse...", placeholder = "No file selected")),
                column(width = 4, fileInput("integ_meta_file", "Sample Metadata (Excel):", accept = c(".xlsx"), buttonLabel = "Browse...", placeholder = "No file selected")),
                column(width = 4,
                       textInput("global_target_group", "Target Group Name:", value = "", placeholder = "e.g., E4.5 or Cluster1"),
                       span(style = "font-size: 12px; color: #888; display: block; margin-top: -5px;", icon("keyboard"), " Manually type the exact group name (must match across omics).")
                )
              ),
              fluidRow(
                column(width = 12,
                       div(style = "background-color: #f7f9fb; padding: 12px 15px; border-radius: 5px; border-left: 4px solid #3C5488; margin-top: 10px; margin-bottom: 10px;",
                           tags$style(HTML("
                                           /* 【添加处】：增加标题与下方选项之间的行距 */
                                           #integ_mode .control-label {
                                           margin-bottom: 16px !important;  /* 设置标题下方的间距，可根据需要微调为 10px ~ 16px */
                                           font-weight: bold;
                                           color: #2c3e50;
                                           }
                                           /* 2x2 网格排版 */
                                           #integ_mode .shiny-options-group {
                                           display: grid;
                                           grid-template-columns: 1fr 1fr;  /* 左右等宽 2 列 */
                                           gap: 8px 20px;                  /* 选项之间的上下间距 8px，左右列间距 20px */
                                           }
                                           #integ_mode .radio {
                                           margin-top: 0px;
                                           margin-bottom: 0px;
                                           }
                                           ")),
                           radioButtons("integ_mode",
                                        label = "Integration Mode:",
                                        choices = c("RNA + DNA Methylation (CpG) + Chromatin Accessibility (GpC)" = "tri",
                                                    "RNA + DNA Methylation (CpG)" = "rna_cpg",
                                                    "RNA + Chromatin Accessibility (GpC)" = "rna_gpc",
                                                    "DNA Methylation (CpG) + Chromatin Accessibility (GpC)"  = "cpg_gpc"),
                                        selected = "tri",
                                        inline = FALSE)
                       )
                )
              ),
              br(),
              h4(icon("database"), "Step 2: Omics Data Input", style = "border-bottom: 1px solid #eee; padding-bottom: 5px; color: #3C5488; font-weight: bold;"),
              fluidRow(
                # 1. RNA (Transcriptome) - 在 tri, rna_cpg, rna_gpc 模式下显示
                column(width = 4,
                       conditionalPanel(
                         condition = "input.integ_mode == 'tri' || input.integ_mode == 'rna_cpg' || input.integ_mode == 'rna_gpc'",
                         div(class = "well", style = "background-color: #fff; border-top: 3px solid #E64B35; padding: 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
                             h4(icon("dna"), " RNA (Transcriptome)", style = "color: #E64B35; margin-top: 0; font-weight: bold;"),
                             fileInput("integ_rna_rds", "RNA Object (.rds):", accept = ".rds"),
                             radioButtons(
                               "rna_matrix_source",
                               "RNA Matrix Source:",
                               choices = c(
                                 "Use pre-normalized assays$RNA$data" = "data",
                                 "Use raw/filtered counts and normalize per cell" = "counts"
                               ),
                               selected = "data",
                               inline = FALSE
                             ),
                             uiOutput("ui_rna_rds_group_col"),
                             verbatimTextOutput("txt_rna_avail_groups", placeholder = TRUE),
                             hr(style = "border-top: 1px dashed #ccc; margin-top: 10px; margin-bottom: 10px;"),
                             radioButtons("rna_gene_mode", "Gene Selection:",
                                          choices = c("Use All Genes" = "all", "Use Diff Genes" = "diff"),
                                          selected = "all", inline = TRUE),
                             conditionalPanel(
                               condition = "input.rna_gene_mode == 'diff'",
                               div(style = "background-color: #fcfcfc; padding: 10px; border: 1px solid #eee; border-radius: 4px;",
                                   fileInput("integ_rna_diff", "Upload RNA Diff (.csv):", accept = ".csv"),
                                   p(strong("Filter Thresholds:"), style = "margin-bottom: 5px; font-size: 13px;"),
                                   fluidRow(
                                     column(6, uiOutput("ui_rna_pval_col")),
                                     column(6, numericInput("rna_pval_th", "P-val <", value = 0.05, step = 0.01))
                                   ),
                                   fluidRow(
                                     column(6, uiOutput("ui_rna_logfc_col")),
                                     column(6, numericInput("rna_logfc_th", "|logFC| >", value = 0.5, step = 0.1))
                                   )
                               )
                             )
                         )
                       )
                ),
                # 2. CpG (DNA Methylation) - 在 tri, rna_cpg, cpg_gpc 模式下显示 (隐藏了 rna_gpc)
                column(width = 4,
                       conditionalPanel(
                         condition = "input.integ_mode == 'tri' || input.integ_mode == 'rna_cpg' || input.integ_mode == 'cpg_gpc'",
                         div(class = "well", style = "background-color: #fff; border-top: 3px solid #4DBBD5; padding: 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
                             h4(icon("circle"), " CpG (DNA Methylation)", style = "color: #4DBBD5; margin-top: 0; font-weight: bold;"),
                             splitLayout(
                               fileInput("integ_cpg_mat", "CpG Matrix:", accept = ".csv"),
                               fileInput("integ_cpg_dmr", "DMRs (Optional):", accept = ".csv"),
                               cellWidths = c("50%", "50%")
                             ),
                             uiOutput("ui_cpg_sheet_select"),
                             fluidRow(column(6, uiOutput("ui_cpg_id_col")), column(6, uiOutput("ui_cpg_group_col"))),
                             hr(style = "border-top: 1px dashed #ccc; margin-top: 10px; margin-bottom: 10px;"),
                             radioButtons("cpg_filter_mode", "DMR Filtering:",
                                          choices = c("Use All in File" = "all", "Filter by Thresholds" = "filter"),
                                          selected = "all", inline = TRUE),
                             conditionalPanel(
                               condition = "input.cpg_filter_mode == 'filter'",
                               div(style = "background-color: #fcfcfc; padding: 10px; border: 1px solid #eee; border-radius: 4px;",
                                   p(strong("Filter Thresholds:"), style = "margin-bottom: 5px; font-size: 13px;"),
                                   fluidRow(
                                     column(6, uiOutput("ui_cpg_pval_col")),
                                     column(6, numericInput("cpg_pval_th", "P-val <", value = 0.05, step = 0.01))
                                   ),
                                   fluidRow(
                                     column(6, uiOutput("ui_cpg_diff_col")),
                                     column(6, numericInput("cpg_diff_th", "|Diff| >", value = 20, step = 5))
                                   )
                               )
                             )
                         )
                       )
                ),
                # 3. GpC (Chromatin Accessibility) - 在 tri, cpg_gpc, rna_gpc 模式下显示
                column(width = 4,
                       conditionalPanel(
                         condition = "input.integ_mode == 'tri' || input.integ_mode == 'cpg_gpc' || input.integ_mode == 'rna_gpc'",
                         div(class = "well", style = "background-color: #fff; border-top: 3px solid #00A087; padding: 15px; box-shadow: 0 1px 3px rgba(0,0,0,0.1);",
                             h4(icon("circle-notch"), " GpC (Chromatin Accessibility)", style = "color: #00A087; margin-top: 0; font-weight: bold;"),
                             splitLayout(
                               fileInput("integ_gpc_mat", "GpC Matrix:", accept = ".csv"),
                               fileInput("integ_gpc_dmr", "DARs (Optional):", accept = ".csv"),
                               cellWidths = c("50%", "50%")
                             ),
                             uiOutput("ui_gpc_sheet_select"),
                             fluidRow(column(6, uiOutput("ui_gpc_id_col")), column(6, uiOutput("ui_gpc_group_col"))),
                             hr(style = "border-top: 1px dashed #ccc; margin-top: 10px; margin-bottom: 10px;"),
                             radioButtons("gpc_filter_mode", "DAR Filtering:",
                                          choices = c("Use All in File" = "all", "Filter by Thresholds" = "filter"),
                                          selected = "all", inline = TRUE),
                             conditionalPanel(
                               condition = "input.gpc_filter_mode == 'filter'",
                               div(style = "background-color: #fcfcfc; padding: 10px; border: 1px solid #eee; border-radius: 4px;",
                                   p(strong("Filter Thresholds:"), style = "margin-bottom: 5px; font-size: 13px;"),
                                   fluidRow(
                                     column(6, uiOutput("ui_gpc_pval_col")),
                                     column(6, numericInput("gpc_pval_th", "P-val <", value = 0.05, step = 0.01))
                                   ),
                                   fluidRow(
                                     column(6, uiOutput("ui_gpc_diff_col")),
                                     column(6, numericInput("gpc_diff_th", "|Diff| >", value = 10, step = 5))
                                   )
                               )
                             )
                         )
                       )
                )
              ),
              fluidRow(
                column(width = 12,
                       div(style = "text-align: right; padding-top: 10px; padding-bottom: 10px; padding-right: 15px;",
                           actionButton("integ_btn_run", " Run Integration", icon = icon("rocket"), class = "btn-info",
                                        style = "font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           actionButton("integ_btn_reset", " Reset All", icon = icon("trash-alt"), class = "btn-warning",
                                        style = "font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           actionButton("integ_btn_use_example", " Use Example", icon = icon("lightbulb"), class = "btn-success",
                                        style = "font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);"),
                           downloadButton("integ_btn_dl_example", "Download Example",
                                          class = "btn-default", style = "color: black; font-weight: bold;")
                       )
                )
              )
            ),
            fluidRow(
              box(
                title = "Integration Visualization & Results", width = 12, status = "success", solidHeader = F,
                tabsetPanel(
                  tabPanel("Data Table", icon = icon("table"),
                           br(),
                           div(style = "text-align: right; margin-bottom: 10px;",
                               downloadButton("integ_download_data", "Download Merged Table", class = "btn-default btn-sm")),
                           DT::DTOutput("integ_table")
                  ),
                  tabPanel("Correlations", icon = icon("project-diagram"),
                           br(),
                           div(style = "text-align: right; margin-bottom: 10px;",
                               downloadButton("integ_download_scatter_pdf", " Download PDF", class = "btn-default btn-sm")),
                           shinycssloaders::withSpinner(plotOutput("integ_plot_scatter", height = "500px"))
                  ),
                  tabPanel("Matrix Plot", icon = icon("th"),
                           br(),
                           div(style = "text-align: right; margin-bottom: 10px;",
                               downloadButton("integ_download_matrix_pdf", " Download PDF", class = "btn-default btn-sm")),
                           shinycssloaders::withSpinner(plotOutput("integ_plot_matrix", height = "600px"))
                  )
                )
              )
            )
          ),
          tabPanel(
            title = "2. Multi-omics Data Analysis",
            value = "tab_multi_omics_analysis",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = span(icon("cogs"), " Analysis Settings"), status = "primary", solidHeader = TRUE, width = NULL,
                       uiOutput("ui_multi_data_source"),
                       actionButton("multi_btn_reset", " Reset Data & Settings", icon = icon("sync"),
                                    class = "btn-warning btn-sm", style = "width: 100%; margin-top: 5px; margin-bottom: 10px; font-weight:bold;"),
                       hr(),
                       h4(icon("dna"), " Spatial Topology", style = "color: #3C5488; font-weight: bold;"),
                       # uiOutput("ui_topo_chr_select"),
                       uiOutput("ui_topo_chr_select"),
                       uiOutput("ui_topo_gene_select"), # 【新增】基因选择框
                       actionButton("btn_run_topo", " Map Topology", icon = icon("project-diagram"), class = "btn-info btn-block", style = "font-weight: bold; margin-bottom: 15px;"),
                       hr(),
                       h4(icon("fire"), " States & Drivers", style = "color: #E64B35; font-weight: bold;"),
                       p("Calculate epigenetic states and joint Z-scores.", style = "color: #888; font-size: 12px;"),
                       numericInput("num_top_genes", "Top N Driver Genes:", value = 40, min = 10, max = 200, step = 10),
                       actionButton("btn_run_states_heatmap", " Run States & Heatmap", icon = icon("chart-pie"), class = "btn-info btn-block", style = "font-weight: bold;")
                     )
              ),
              column(width = 9,
                     box(
                       title = "Multi-omics Visualization & Results", status = "success", solidHeader = F, width = NULL,
                       tabsetPanel(
                         id = "multi_result_tabset",
                         tabPanel("Chromosome Topology", value = "tab_topo", icon = icon("stream"),
                                  br(),
                                  div(style = "text-align: right; margin-bottom: 10px;",
                                      downloadButton("dl_topo_data", " Download Data", class = "btn-default btn-sm"),
                                      downloadButton("dl_topo_pdf", " Download PDF", class = "btn-default btn-sm")
                                  ),
                                  shinycssloaders::withSpinner(plotOutput("plot_multi_topo", height = "600px"))
                         ),
                         tabPanel("Driver Genes (Heatmap)", value = "tab_heatmap", icon = icon("th"),
                                  br(),
                                  div(style = "text-align: right; margin-bottom: 10px;",
                                      downloadButton("dl_heatmap_data", " Download Data", class = "btn-default btn-sm"),
                                      downloadButton("dl_heatmap_pdf", " Download PDF", class = "btn-default btn-sm")
                                  ),
                                  shinycssloaders::withSpinner(plotOutput("plot_multi_heatmap", height = "700px"))
                         ),
                         tabPanel("Regulatory States", value = "tab_states", icon = icon("chart-pie"),
                                  br(),
                                  div(style = "text-align: right; margin-bottom: 10px;",
                                      downloadButton("dl_states_data", " Download Data", class = "btn-default btn-sm"),
                                      downloadButton("dl_states_pdf", " Download PDF", class = "btn-default btn-sm")
                                  ),
                                  fluidRow(column(8, offset = 2, shinycssloaders::withSpinner(plotOutput("plot_multi_states", height = "500px"))))
                         )
                       )
                     )
              )
            )
          ),
          # tabPanel(
          #   title = "3. Enhancer-Promoter Interactions",
          #   value = "tab_enhancer_promoter_interact",
          #   br(),
          #   fluidRow(
          #     # 左侧：参数与数据上传面板
          #     column(width = 3,
          #            box(
          #              title = span(icon("sliders-h"), " E-P Configuration"),
          #              status = "primary", solidHeader = TRUE, width = NULL,
          #              h5(icon("upload"), " Upload Matrices (.csv)", style = "color: #3C5488; font-weight: bold;"),
          #              fileInput("ep_enh_cpg", "1. Enhancer CpG Matrix:", accept = ".csv"),
          #              fileInput("ep_enh_gpc", "2. Enhancer GpC Matrix:", accept = ".csv"),
          #              fileInput("ep_pro_cpg", "3. Promoter CpG Matrix:", accept = ".csv"),
          #              fileInput("ep_pro_gpc", "4. Promoter GpC Matrix:", accept = ".csv"),
          #              hr(),
          #              h5(icon("list"), " Annotation & Params", style = "color: #E64B35; font-weight: bold;"),
          #              fileInput("ep_pro_anno", "Promoter Annotation (.csv):", accept = ".csv"),
          #              numericInput("ep_max_dist", "Max Interaction Window (bp):", value = 50000, step = 10000),
          #              actionButton("btn_run_ep", " Run E-P Analysis", icon = icon("project-diagram"),
          #                           class = "btn-info btn-lg", style = "width: 100%; font-weight: bold; margin-top: 10px;")
          #            )
          #     ),
          #     # 右侧：可视化与结果面板
          #     column(width = 9,
          #            box(
          #              title = "Interaction Landscape & Results", status = "success", solidHeader = FALSE, width = NULL,
          #              tabsetPanel(
          #                # 子标签页 3：数据表
          #                tabPanel("Data Table", icon = icon("table"),
          #                         br(),
          #                         div(style = "text-align: right; margin-bottom: 10px;",
          #                             downloadButton("dl_ep_table", "Export Interactions", class = "btn-default btn-sm")),
          #                         DT::DTOutput("table_ep_res")
          #                ),
          #                # # 子标签页 2：全局散点图
          #                # tabPanel("Global Correlation", icon = icon("project-diagram"),
          #                #          br(),
          #                #          div(style = "text-align: right; margin-bottom: 10px;",
          #                #              downloadButton("dl_ep_scatter", "Download PDF", class = "btn-default btn-sm")),
          #                #          fluidRow(column(10, offset = 1, shinycssloaders::withSpinner(plotOutput("plot_ep_scatter", height = "450px"))))
          #                # ),
          #                # 子标签页 1：局部基因拓扑弧线图
          #                tabPanel("Locus Arc Plot", icon = icon("bezier-curve"),
          #                         br(),
          #                         fluidRow(
          #                           column(4, selectizeInput("ep_target_gene", "Select Target Gene:", choices = NULL, width = "100%")),
          #                           column(8, div(style = "text-align: right; margin-top: 25px;",
          #                                         downloadButton("dl_ep_arc", "Download PDF", class = "btn-default btn-sm")))
          #                         ),
          #                         shinycssloaders::withSpinner(plotOutput("plot_ep_arc", height = "650px"))
          #                )
          #              )
          #            )
          #     )
          #   )
          # ),
          tabPanel(
            title = "3. Enrichment Analysis",
            value = "tab_integ_enrich",
            br(),
            fluidRow(
              column(width = 3,
                     box(
                       title = "Enrichment Config", status = "primary", solidHeader = TRUE, width = NULL,
                       fileInput("enrich_file_input", "Gene List (CSV)", accept = c(".csv", ".txt")),
                       uiOutput("ui_enrich_gene_col"),
                       hr(),
                       selectInput("enrich_species", "Species", choices = c("Mouse" = "mouse", "Human" = "human")),
                       selectInput("enrich_db", "Database", choices = c("GO BP" = "BP", "GO MF" = "MF", "GO CC" = "CC", "KEGG" = "KEGG")),
                       splitLayout(numericInput("enrich_pval", "P-val Cut", 0.05), numericInput("enrich_qval", "Q-val Cut", 0.2)),
                       br(),
                       actionButton("run_enrichment", "Run Analysis", icon = icon("flask"), class = "btn-info btn-lg",
                                    style = "width: 100%; font-weight: bold; border-radius: 5px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);")
                     )
              ),
              column(width = 9,
                     box(
                       title = "Enrichment Results", status = "primary", width = NULL,
                       tabsetPanel(
                         tabPanel("Table", br(), downloadButton("download_enrich_res", "Export Results", class="btn-default"), br(), br(), DT::DTOutput("enrich_table")),
                         tabPanel("Dot Plot", br(), shinycssloaders::withSpinner(plotOutput("enrich_dotplot", height = "600px"))),
                         tabPanel("Bar Plot", br(), shinycssloaders::withSpinner(plotOutput("enrich_barplot", height = "600px")))
                       )
                     )
              )
            )
          )
        )
      ),
      # Tab 5: User Guide (Markdown) ----
      tabItem(
        tabName = "User_Guide",
        div(class = "module-header",
            h2(icon("book"), " scMATE User Manual"),
            p("Comprehensive step-by-step instructions and data format guidelines for all modules.")
        ),
        fluidRow(
          column(12,
                 box(
                   title = "Platform Documentation", status = "primary", solidHeader = T, width = 12,
                   # 使用 tabsetPanel 分模块展示 Markdown 说明
                   tabsetPanel(
                     # 1. 概述与数据准备
                     tabPanel(
                       title = "1. Data Preparation", icon = icon("file-alt"),
                       br(),
                       markdown("
                       ### Welcome to scMATE
                       scMATE is designed for seamless, zero-code analysis of single-cell Multi-omics data. Before starting, please ensure your data matches the required formats.
                       #### 📁 Required Data Formats
                       - **Transcriptome Matrix (scRNA-seq):**
                       - Format: `.csv`, `.txt`, or pre-built `.rds` object.
                       - Structure: Rows must be **Gene Symbols/IDs**, Columns must be **Cell Barcodes**.
                       - **Epigenome Data (CpG/GpC):**
                       - Raw Bismark format: `.cov` or `.cov.gz` files containing methylation signals.
                       - Genomic Intervals: A `.bed` or `.csv` file with at least 3 columns (`chr`, `start`, `end`).
                       - **Metadata:**
                       - Format: `.csv` or `.xlsx`.
                       - Must contain a column linking to the Cell IDs in your matrices.
                      > **💡 Pro Tip:** For large datasets (>50k cells), we recommend uploading pre-processed `.rds` files to save browser memory and upload time.
                       ")
                     ),
                     # 2. 转录组模块说明
                     tabPanel(
                       title = "2. Transcriptome Module", icon = icon("microscope"),
                       br(),
                       markdown("
                       ### Transcriptome Analysis Pipeline
                       This module processes scRNA-seq data from raw counts to developmental trajectories.

                       #### Step 1: Create Object & QC
                       1. Upload your Raw Count Matrix and (optional) Metadata.
                       2. Select the correct **Gene ID Column**.
                       3. Use the **Pre-filter** to remove genes/cells with extreme sparsity.
                       4. Click **Build Object**.
                       5. Switch to the *QC & Filter* panel, select the mitochondrial prefix (e.g., `^MT-`), and apply strict thresholds to remove dead cells/doublets.

                       #### Step 2: Dimension Reduction & Clustering
                       1. Choose a Data Layer (Normalized/Scaled).
                       2. Select your algorithm: **PCA**, **t-SNE**, or **UMAP**.
                       3. *Optional:* Check **Perform Auto-Clustering** to run Leiden/Hierarchical clustering.

                       #### Step 3: Differential Gene Analysis (DEA)
                       1. Choose comparison mode: **One vs Rest** (find cluster markers) or **One vs One**.
                       2. Set Log2FC and P-value thresholds.
                       3. The platform will automatically compute the statistics using a highly optimized Wilcoxon rank-sum engine and output an interactive Volcano Plot.

                       #### Step 4: Pseudotime Inference
                       1. Select the dimension reduction embedding (e.g., UMAP).
                       2. Specify the **Starting Cluster (Root)**.
                       3. The module uses `princurve` (Cluster-based) or `Monocle-style K-NN` (Graph-based) to infer developmental trajectories.
                       ")
                     ),

                     # 3. 表观组模块说明
                     tabPanel(
                       title = "3. Epigenome Module", icon = icon("align-left"),
                       br(),
                       markdown("
                       ### Epigenome Analysis Pipeline (scNOMe-seq)
                       This module handles ultra-sparse single-cell methylation and accessibility data.
                       #### Step 1: Matrix Assembly & QC
                       1. Upload multiple `.cov` files and your target `.bed` regions.
                       2. Set the number of **CPU Threads** based on your server capacity.
                       3. Click **Run Aggregation** (scMATE uses non-equi joins to quickly map signals).
                       4. Apply row/column QC to filter out regions with too many NAs.

                       #### Step 2: Dimension Reduction & Landscape
                       1. Upload Metadata and link the sample IDs.
                       2. Choose an Imputation method (KNN is highly recommended for dropouts).
                       3. Generate the **Epigenetic Landscape (Ridge Plot)** to view global methylation density.
                       4. Run manifold learning (PCA/UMAP/NMF) to find epigenetic substructures.

                       #### Step 3: Differential Region Analysis
                       1. Select the Target Group (Case) and Control Group.
                       2. Ensure you correctly map the `.level`, `.meth`, and `.nonmeth` columns from the metadata.
                       3. The module applies a **Dual-test framework** (Fisher's Exact Test + Variance Test) to strictly define Differentially Methylated/Accessible Regions (DMRs/DARs).
                       ")
                     ),

                     # 4. 多组学整合说明
                     tabPanel(
                       title = "4. Integration Module", icon = icon("layer-group"),
                       br(),
                       markdown("
                       ### Multi-Omics Integration & Systems Biology
                       This is the core of scMATE, linking Epigenetics to Transcriptional Output.

                       #### Step 1: Data Integration
                       1. Select your integration mode (e.g., `RNA + CpG + GpC`).
                       2. Type in the **Target Group Name** (Must exactly match the metadata across all omics layers).
                       3. Upload the corresponding matrices and annotation files.
                       4. Click **Run Integration** to map genomic regions to gene promoters/bodies.

                       #### Step 2: Spatial Topology & Joint Analysis
                       - **Chromosome Topology:** Select a chromosome to visualize how RNA expression, CpG methylation, and GpC accessibility co-vary across physical Megabase positions.
                       - **States & Drivers:** Calculates regulatory states (e.g., *Poised*, *Fully Activated*) and a Joint Z-score to rank master transcriptional driver genes.

                       #### Step 3: Enrichment Analysis
                       Input your discovered master driver genes into the GO/KEGG pathway engine to uncover the underlying biological mechanisms.
                       ")
                     )
                   )
                 )
          )
        )
      )
    )
  )
)




# ---- Server Logic ----
options(
  shiny.maxRequestSize = 500 * 1024^2,
  shiny.sanitize.errors = TRUE,
  future.globals.maxSize = 5 * 1024^3
)

server <- function(input, output, session) {
  library(ggplot2)
  library(Matrix)
  library(data.table)
  library(plotly)
  library(patchwork)
  library(writexl)
  library(tidyr)
  library(ggridges)
  library(ggrepel)
  library(ggpubr)
  library(readxl)
  library(stringr)
  library(igraph)
  library(FNN)
  library(tictoc)
  library(rhdf5)


  observeEvent(input$goto_tab, {
    # 这里的 "sidebar_menu_id" 必须是您在 ui.R 中 sidebarMenu 里的 id。
    # 如果您原来没写 id，请去 ui.R 加上： sidebarMenu(id = "sidebar_menu_id", ...)
    updateTabItems(session, inputId = "sidebar_menu_id", selected = input$goto_tab)
  })

  session$onSessionEnded(function() {
    # 1. 将巨大的反应式对象设为 NULL
    RNA_values$sci_object <- NULL
    RNA_values$pseudo_plot_obj <- NULL
    RNA_values$raw_input_df = NULL
    RNA_values$raw_matrix = NULL
    RNA_values$raw_metadata = NULL
    RNA_values$excel_sheets = NULL
    RNA_values$excel_path = NULL
    RNA_values$qc_plot_obj = NULL
    RNA_values$dr_plot_obj = NULL
    RNA_values$volcano_plot_obj = NULL
    DEA_values$markers = NULL

    Epi_values$data_list <- NULL
    Epi_values$last_active_time <- NULL
    DR_values$group_raw = NULL
    DR_values$plot_obj = NULL
    DR_values$coord_df = NULL
    DR_values$ridge_obj = NULL
    DR_values$ridge_df = NULL
    DR_values$unlink_step1 = FALSE
    Diff_values$group_raw = NULL
    Diff_values$result_df = NULL
    Diff_values$plot_obj = NULL
    Diff_values$unlink_step1 = FALSE
    Diff_values$unlink_step2 = FALSE

    Integ_values$meta_file_path = NULL
    Integ_values$sheets = NULL
    Integ_values$rna_obj = NULL
    Integ_values$merged_df = NULL
    Integ_values$plot_scatter_obj = NULL
    Integ_values$plot_matrix_obj = NULL
    Multi_values$raw_data = NULL
    Multi_values$topo_plot = NULL
    Multi_values$states_plot = NULL
    Multi_values$heatmap_plot = NULL
    Multi_values$topo_data = NULL
    Multi_values$states_data = NULL
    Multi_values$heatmap_data = NULL
    Multi_values$unlink_step1 = FALSE
    Enrich_values$res_obj = NULL
    Enrich_values$res_df = NULL

    # 2. 清理临时文件 (如果你在服务器上生成了没用的中间文件)
    # unlink(tempdir(), recursive = TRUE)
    # 3. 强制触发 R 的底层垃圾回收，将 RAM 物理归还给操作系统
    gc()
    message("User session ended. Memory released.")
  })


  # ----Transcriptome Analysis----
  # ---- Transcriptome QC ----
  # 1. 定义响应式变量存储数据
  RNA_values <- reactiveValues(
    is_example = FALSE,
    sci_object = NULL,
    raw_input_df = NULL,
    raw_matrix = NULL,
    raw_metadata = NULL,
    excel_sheets = NULL,
    excel_path = NULL,
    qc_plot_obj = NULL,
    dr_plot_obj = NULL,
    volcano_plot_obj = NULL
  )

  # 核心底层函数 1: 创建轻量级 sciET 对象
  CreateSciETObject <- function(counts, project_name = "sciET_Project") {
    if (!inherits(counts, "dgCMatrix")) {
      counts <- as(as.matrix(counts), "CsparseMatrix")
    }
    cell_names <- colnames(counts)
    # 极速计算基础 QC
    meta_data <- data.frame(
      row.names = cell_names,
      # orig.ident = rep(project_name, length(cell_names)),
      nCount_RNA = as.numeric(Matrix::colSums(counts)),
      nFeature_RNA = as.numeric(Matrix::colSums(counts > 0))
    )
    object <- list(
      project = project_name,
      assays = list(
        RNA = list(
          counts = counts,
          filter_counts = NULL,
          data = NULL,
          scale.data = NULL)
      ),
      meta.data = meta_data,
      filter_meta.data = NULL,
      reductions = list(
        pca = NULL,              # 等待填入 PCA 坐标
        umap = NULL,             # 等待填入 UMAP 坐标
        tsne = NULL
      ),
      var.genes = NULL          # 等待填入高变基因
    )
    class(object) <- "sciET"
    return(object)
  }

  # 核心底层函数 2: 高级 Metadata 添加引擎 (处理数据框与向量)
  AddMetaData_sciET <- function(object, meta_data, id_col = NULL, group_cols = NULL) {
    current_meta <- object$meta.data
    cell_names <- rownames(current_meta)
    # 情况 A: 向量模式 (用户上传了单列数据，或者强制按顺序匹配)
    if (is.null(id_col) || id_col == "MATCH_BY_ORDER") {
      # 提取所有要添加的列
      for (col in group_cols) {
        vec <- meta_data[[col]]
        # 检查长度
        if (length(vec) != length(cell_names)) {
          stop(paste("Vector length (", length(vec), ") does not match cell count (", length(cell_names), ")."))
        }
        # 按顺序硬塞入对象
        current_meta[[col]] <- vec
      }
    }
    # 情况 B: 数据框模式 (精准 ID 匹配)
    else {
      # 去除 metadata 中 ID 列的重复项 (以防万一)
      clean_meta <- meta_data[!duplicated(meta_data[[id_col]]), ]
      rownames(clean_meta) <- as.character(clean_meta[[id_col]])
      common_cells <- intersect(cell_names, rownames(clean_meta))
      if (length(common_cells) == 0) {
        err_msg <- sprintf(
          "ID Mismatch Error! You selected '%s' as Cell ID.\nMatrix IDs start with: %s...\nMetadata IDs start with: %s...",
          id_col,
          paste(head(cell_names, 3), collapse=", "),
          paste(head(rownames(clean_meta), 3), collapse=", ")
        )
        stop(err_msg)
      }
      for (col in group_cols) {
        current_meta[[col]] <- NA # 初始化为 NA
        current_meta[common_cells, col] <- clean_meta[common_cells, col]
      }
    }
    object$meta.data <- current_meta
    return(object)
  }

  # 读取表达矩阵与动态选择行名
  observeEvent(input$RNA_data_input1, {
    req(input$RNA_data_input1)
    progress <- shiny::Progress$new(); on.exit(progress$close())
    progress$set(message = "Reading Matrix...", value = 0.5)
    # 彻底清空旧数据，防止缓存干扰
    RNA_values$is_example <- FALSE
    RNA_values$sci_object <- NULL
    RNA_values$raw_input_df <- NULL
    tryCatch({
      filepath <- input$RNA_data_input1$datapath
      ext <- tolower(tools::file_ext(filepath))
      if(ext %in% c("h5","hdf5")){
        #### 读取10X CellRanger h5
        showNotification("Detected H5 file, parsing 10X Genomics format",type="message")
        h5f <- rhdf5::H5Fopen(filepath)
        # 10X h5标准路径：/matrix/features/name /matrix/barcodes /matrix/data /matrix/indices /matrix/indptr /matrix/shape
        features <- rhdf5::h5read(h5f,"/matrix/features/name")
        barcodes <- rhdf5::h5read(h5f,"/matrix/barcodes")
        data <- rhdf5::h5read(h5f,"/matrix/data")
        indices <- rhdf5::h5read(h5f,"/matrix/indices")
        indptr <- rhdf5::h5read(h5f,"/matrix/indptr")
        shape <- rhdf5::h5read(h5f,"/matrix/shape")
        rhdf5::H5Fclose(h5f)
        nrow <- shape[1]
        ncol <- shape[2]
        # 构建dgCMatrix稀疏矩阵
        mat_sparse <- Matrix::sparseMatrix(
          i = indices +1,
          p = indptr,
          x = data,
          dims = c(nrow,ncol)
        )
        rownames(mat_sparse) <- features
        colnames(mat_sparse) <- barcodes
        # 转化为data.frame，第一列放置gene（完全模仿csv输入格式！！！）
        df <- as.data.frame(as.matrix(mat_sparse))
        df <- cbind(gene_name = rownames(df),df)
        RNA_values$raw_input_df <- df
        showNotification("H5 matrix loaded. Please select the Gene ID column.", type = "warning")
      }else{
        #### 原有csv/txt逻辑保持不变
        df <- data.table::fread(filepath, data.table = FALSE, check.names = FALSE)
        # 忽略大小写查找名为 "length" 或 "Length" 的列
        len_col <- grep("^length$", colnames(df), ignore.case = TRUE, value = TRUE)
        if (length(len_col) > 0) {
          # 1. 提取长度数值
          lengths_vec <- as.numeric(df[[len_col[1]]])
          # 2. 【核心修正】打入基因名标签！
          # 刚读取的数据框 df，真正的基因名通常在第一列（即 df[[1]]）
          # 绝对不能用 rownames(df)，因为此时多半只是 "1", "2", "3" 等行号
          names(lengths_vec) <- as.character(df[[1]])
          # 3. 剥离并存储
          RNA_values$gene_lengths <- lengths_vec
          df[[len_col[1]]] <- NULL
          showNotification("Gene lengths extracted and named successfully.", type = "message")
        } else {
          RNA_values$gene_lengths <- NULL
        }
        RNA_values$raw_input_df <- df
        showNotification("Matrix loaded. Please select the Gene ID column.", type = "warning")
      }
    }, error = function(e) showNotification(paste("Read error:", e$message), type = "error"))
  })

  output$rna_id_selector_ui <- renderUI({
    req(RNA_values$raw_input_df)
    cols <- colnames(RNA_values$raw_input_df)
    default_sel <- cols[1]
    priority_cols <- c("gene_name", "gene_symbol", "Symbol", "gene_id", "GeneID")
    for(p in priority_cols) { if(p %in% cols) { default_sel <- p; break } }
    selectInput("rna_id_col_user", "Select RowName Column:", choices = cols, selected = default_sel)
  })

  # 读取 Metadata 与动态映射配置
  observeEvent(input$RNA_data_input2, {
    req(input$RNA_data_input2)
    file <- input$RNA_data_input2
    # 彻底清空之前的 Metadata 状态
    RNA_values$is_example <- FALSE
    RNA_values$excel_sheets <- NULL
    RNA_values$raw_metadata <- NULL
    RNA_values$excel_path <- file$datapath
    tryCatch({
      # 获取所有 sheet 名称
      sheets <- readxl::excel_sheets(file$datapath)
      RNA_values$excel_sheets <- sheets
    }, error = function(e) showNotification(paste("Excel read error:", e$message), type = "error"))
  })

  # --- 2. 独立渲染：Excel Sheet 选择器 ---
  # 这个 UI 只在上传新文件时刷新一次，选 Sheet 不会触发它重刷
  output$rna_sheet_selector_ui <- renderUI({
    req(RNA_values$excel_sheets)
    # 默认选中 "RNA"（如果存在），否则选第一个
    target_sheet <- if("RNA" %in% RNA_values$excel_sheets) "RNA" else RNA_values$excel_sheets[1]
    tagList(
      hr(),
      h5("1. Select Excel Sheet:", style="color:#d35400; font-weight:bold;"),
      selectInput("selected_sheet", NULL, choices = RNA_values$excel_sheets, selected = target_sheet)
    )
  })

  # --- 3. 监听 Sheet 切换 (仅更新数据，不重刷 Sheet UI) ---
  observeEvent(input$selected_sheet, {
    req(RNA_values$excel_path, input$selected_sheet)
    tryCatch({
      RNA_values$raw_metadata <- readxl::read_excel(RNA_values$excel_path, sheet = input$selected_sheet)
    }, error = function(e) NULL)
  })

  # --- 4. 独立渲染：列名映射选择器 ---
  # 当 RNA_values$raw_metadata 变化时（比如换了 Sheet），只有这个框会重刷
  output$rna_col_mapping_ui <- renderUI({
    req(RNA_values$raw_metadata)
    cols <- colnames(RNA_values$raw_metadata)
    # 创建一个带空值的选项，强迫用户自己选
    id_choices <- c("--- Please Select ---" = "", "MATCH_BY_ORDER (Vector Mode)" = "MATCH_BY_ORDER", cols)
    # --- 新增：处理 Example 的默认选中项 ---
    default_id <- ""
    default_group <- NULL
    if (isTRUE(RNA_values$is_example)) {
      if ("Run" %in% cols) default_id <- "Run"
      if ("Development_Stage" %in% cols) default_group <- "Development_Stage"
    }
    tagList(
      hr(),
      h5("2. Map Metadata Columns:", style="font-weight:bold;"),
      # Cell ID 默认值为空字符串 ("")
      selectInput("meta_id_col", "Cell ID Column (Matches Matrix):",
                  choices = id_choices,
                  selected = ""),
      # Group 默认值为 NULL (什么都不选)
      selectizeInput("meta_group_col", "Select Grouping Info to Add:",
                     choices = cols,
                     multiple = TRUE,
                     selected = NULL)
    )
  })

  # 步骤 5: 核心处理按钮 (生成矩阵、创建对象、融和分组)
  observeEvent(input$runButton2, {
    tic("RNA build rds object total time:")
    req(RNA_values$raw_input_df, input$rna_id_col_user)
    # 【安全拦截】：既然设为空了，必须确保用户选了 Cell ID 才能跑，否则直接中断并提示
    if (!is.null(RNA_values$raw_metadata)) {
      if (is.null(input$meta_id_col) || input$meta_id_col == "") {
        showNotification("Please explicitly select a 'Cell ID Column' before building the object.", type = "error")
        return(NULL)
      }
    }
    progress <- shiny::Progress$new(); on.exit(progress$close())
    tryCatch({
      # --- A. 数据清洗与矩阵生成 (保留您之前优化的 rowsum 逻辑) ---
      df_raw <- RNA_values$raw_input_df
      id_col <- input$rna_id_col_user
      # 1. 直接从原始数据提取分组 ID（完美保证长度等于矩阵行数）
      group_ids <- as.character(df_raw[[id_col]])
      # 2. 移除无用列（动态把用户选的 id_col 也加入黑名单，防止其混入数值矩阵）
      bad_cols <- c("Length", "length", "Geneid", "GeneID", "gene_id", "gene_name", "Chr", "Start", "End", "Strand", id_col)
      df_clean <- df_raw[, !toupper(colnames(df_raw)) %in% toupper(bad_cols), drop = FALSE]
      # 3. 严格提取数值列并转为底层 Matrix
      numeric_cols <- sapply(df_clean, is.numeric)
      mat_numeric <- as.matrix(df_clean[, numeric_cols, drop = FALSE])
      if(ncol(mat_numeric) < 1) stop("No numeric sample columns remaining.")
      # 4. C 语言级 rowsum 合并 (同名基因极速相加，同时将 unique ID 设为行名)
      mat <- base::rowsum(mat_numeric, group = group_ids, reorder = FALSE)
      rm(mat_numeric, df_clean); gc() # 极致内存回收
      # --- B. 新增：底层矩阵级别的 Pre-filter (等效于 Seurat) ---
      progress$set(message = "Pre-filtering Matrix (min.cells/features)...", value = 0.4)
      # 过滤死细胞 (min.features: 细胞中表达量>0的基因数必须大于阈值)
      n_features_per_cell <- Matrix::colSums(mat > 0)
      keep_cells <- n_features_per_cell >= input$min_features_raw
      mat <- mat[, keep_cells, drop = FALSE]
      # 过滤垃圾基因 (min.cells: 基因至少在几个细胞中表达)
      n_cells_per_gene <- Matrix::rowSums(mat > 0)
      keep_genes <- n_cells_per_gene >= input$min_cells_raw
      mat <- mat[keep_genes, , drop = FALSE]
      if(ncol(mat) == 0 || nrow(mat) == 0) {
        stop("Pre-filter is too strict! 0 cells or 0 genes remaining. Please lower min.cells / min.features.")
      }
      # --- C. 创建底层 sciET 对象 ---
      progress$set(message = "Creating Object...", value = 0.6)
      sci_obj <- CreateSciETObject(mat)
      # --- D. 融合 Metadata ---
      if (!is.null(RNA_values$raw_metadata) && length(input$meta_group_col) > 0) {
        progress$set(message = "Mapping Metadata...", value = 0.8)
        id_mapping <- if(input$meta_id_col == "MATCH_BY_ORDER") NULL else input$meta_id_col
        sci_obj <- AddMetaData_sciET(sci_obj, RNA_values$raw_metadata, id_mapping, input$meta_group_col)
      }
      RNA_values$sci_object <- sci_obj
      # 创建完毕后，自动将单选按钮切回 "raw" 视图
      updateRadioButtons(session, "view_data_type", selected = "raw")
      progress$set(message = "Done!", value = 1)
      showNotification(sprintf("Object Built! Kept %d Genes across %d Cells.", nrow(mat), ncol(mat)), type = "message")
    }, error = function(e) showNotification(paste("Error:", e$message), type = "error"))
    toc()
  })

  output$data_table1 <- DT::renderDT({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    view_type <- input$view_data_type
    # 1. 根据当前视图提取对应的数据
    if (view_type == "raw") {
      # Raw 视图：展示 Step 1 矩阵过滤后的基础信息
      if (is.null(obj$assays$RNA$counts)) return(NULL)
      n_genes <- nrow(obj$assays$RNA$counts)
      n_cells <- ncol(obj$assays$RNA$counts)
      meta_df <- obj$meta.data
      cap <- tags$caption(
        style = "caption-side: top; text-align: center; font-weight: bold; color: #2980b9; font-size: 18px; padding-bottom: 10px;",
        icon("info-circle"), " Raw Data Summary Matrix"
      )
    } else {
      # QC 视图：展示 Step 3 严格质控后的信息
      if (is.null(obj$filter_meta.data)) {
        return(DT::datatable(
          data.frame(Status = "Awaiting Step 3...", Message = "Please run 'Step 3: Apply Filter' first."),
          options = list(dom = 't', className = 'dt-center', pageLength = 1), rownames = FALSE
        ))
      }
      n_genes <- nrow(obj$assays$RNA$filter_counts)
      n_cells <- ncol(obj$assays$RNA$filter_counts)
      meta_df <- obj$filter_meta.data
      cap <- tags$caption(
        style = "caption-side: top; text-align: center; font-weight: bold; color: #27ae60; font-size: 18px; padding-bottom: 10px;",
        icon("check-circle"), " Post-QC Data Summary Matrix"
      )
    }
    # 2. 构建优雅的总结数据框 (Summary Dataframe)
    summary_list <- list(
      " Total Genes Analyzed" = format(n_genes, big.mark = ","),
      " Total Cells Recovered" = format(n_cells, big.mark = ",")
    )
    # 3. 动态扫描 Metadata 并统计分组信息
    exclude_cols <- c("nCount_RNA", "nFeature_RNA", "percent_mt")
    group_cols <- setdiff(colnames(meta_df), exclude_cols)
    if (length(group_cols) > 0) {
      for (g_col in group_cols) {
        group_counts <- table(meta_df[[g_col]], useNA = "ifany")
        for (g_name in names(group_counts)) {
          display_name <- ifelse(is.na(g_name), "Unassigned (NA)", g_name)
          # 添加层次感的排版和图标
          row_name <- paste0(" ├─ 🏷️ Group [", g_col, "] : ", display_name)
          summary_list[[row_name]] <- format(group_counts[[g_name]], big.mark = ",")
        }
      }
    } else {
      summary_list[["Metadata Status"]] <- "No grouping metadata appended."
    }
    # 4. 转换为最终数据框
    summary_df <- data.frame(
      "Metrics_and_Grouping" = names(summary_list), # 稍后在列名上隐藏下划线
      "Cell_Count" = unlist(summary_list),
      stringsAsFactors = FALSE,
      check.names = FALSE
    )
    # 美化列名
    colnames(summary_df) <- c("Metrics & Grouping", "Count / Value")
    # 5. 高级 DT 渲染 (打造大厂级撑满 Box 的视觉效果)
    DT::datatable(
      summary_df,
      caption = cap,
      rownames = FALSE,
      # class = 'cell-border stripe hover' : 添加单元格边框、交替条纹和鼠标悬停高亮
      class = 'cell-border stripe hover',
      options = list(
        dom = 't',               # 只显示表格，隐藏搜索和分页
        bSort = FALSE,           # 禁用排序，保持层级结构
        autoWidth = TRUE,
        # 核心改动 1：强制开启垂直滚动，并设定高度（例如 350px），如果数据少，它会撑开结构；数据多则内部滚动
        scrollY = "350px",
        scrollCollapse = TRUE,   # 允许表格在数据较少时稍微收缩，但配合 CSS 会显得很饱满
        paging = FALSE,          # 禁用分页，一拉到底
        columnDefs = list(
          list(width = '65%', targets = 0, className = 'dt-left'),  # 左侧对齐，占主导
          list(width = '35%', targets = 1, className = 'dt-center') # 右侧数字居中对齐
        ),
        # 核心改动 2：通过 JS 注入极具高级感的 CSS 样式 (拉高行距，增大字号)
        initComplete = JS(
          "function(settings, json) {",
          # 美化表头
          "$(this.api().table().header()).css({
              'background-color': '#34495e',
              'color': '#ffffff',
              'font-size': '16px',
              'font-weight': 'bold',
              'text-transform': 'uppercase'
          });",
          # 拉高数据行的行高，使其显得宽敞大气
          "$(this.api().table().body()).find('td').css({
              'padding-top': '15px',
              'padding-bottom': '15px',
              'font-size': '15px'
          });",
          "}"
        )
      )
    ) %>%
      # 使用 formatStyle 进一步强化视觉对比度
      DT::formatStyle(
        'Metrics & Grouping',
        fontWeight = 'bold',
        color = '#2c3e50',
        # 让第一层级（Genes/Cells）背景微灰，子层级（Groups）背景纯白，增强层次感
        backgroundColor = styleEqual(
          c(" Total Genes Analyzed", " Total Cells Recovered", " Metadata Status"),
          c("#ecf0f1", "#ecf0f1", "#fdf2e9")
        )
      ) %>%
      DT::formatStyle(
        'Count / Value',
        color = '#e74c3c',
        fontWeight = 'bold',
        fontSize = '16px'
      )
  })
  # 功能: 动态识别 Metadata 中的分组列 (剔除连续型数值列)
  output$qc_group_selector_ui <- renderUI({
    req(RNA_values$sci_object)
    meta_cols <- colnames(RNA_values$sci_object$meta.data)
    # 排除掉不能作为分组标签的连续型数值列
    exclude_cols <- c("nCount_RNA", "nFeature_RNA", "percent_mt")
    valid_groups <- setdiff(meta_cols, exclude_cols)
    # 默认选中 orig.ident，如果用户上传了其他分组，智能选中最后上传的分组
    default_sel <- if(length(valid_groups) > 1) valid_groups[length(valid_groups)] else "orig.ident"
    selectInput("qc_plot_group", "Group Plot By:",
                choices = valid_groups,
                selected = default_sel)
  })

  # 功能: 计算线粒体比例并按动态分组绘制 QC 图
  observeEvent(input$runQC, {
    tic("RNA qc plot total time:")
    req(RNA_values$sci_object)
    tryCatch({
      obj <- RNA_values$sci_object
      # 1. 动态获取线粒体前缀
      pattern <- if(input$species_mt == "custom") input$custom_mt else input$species_mt
      # 2. 底层矩阵极速计算线粒体比例
      mt_genes <- grep(pattern, rownames(obj$assays$RNA$counts), value = TRUE)
      if(length(mt_genes) > 0) {
        mt_counts <- Matrix::colSums(obj$assays$RNA$counts[mt_genes, , drop = FALSE])
        obj$meta.data$percent_mt <- (mt_counts / obj$meta.data$nCount_RNA) * 100
      } else {
        obj$meta.data$percent_mt <- 0
        showNotification("Warning: No mitochondrial genes found. Check pattern or species.", type = "warning")
      }
      RNA_values$sci_object <- obj
      meta <- obj$meta.data
      # 3. 安全获取绘图分组列名 (防止用户还没选好就点击)
      group_col <- input$qc_plot_group
      if (is.null(group_col) || !(group_col %in% colnames(meta))) {
        group_col <- "orig.ident" # 默认回退到全局标识
      }
      # 4. 数据清洗与因子化：创建专门的绘图列 "Plot_Group"
      # 防止因为 NA 或空字符串导致 ggplot2 崩溃直接吞掉数据
      meta$Plot_Group <- as.character(meta[[group_col]])
      meta$Plot_Group[is.na(meta$Plot_Group) | meta$Plot_Group == ""] <- "Unknown"
      meta$Plot_Group <- as.factor(meta$Plot_Group)
      # 5. 宽表转长表 (专为 ggplot 分面设计)
      qc_long <- meta %>%
        dplyr::select(Plot_Group, nFeature_RNA, nCount_RNA, percent_mt) %>%
        tidyr::pivot_longer(cols = c("nFeature_RNA", "nCount_RNA", "percent_mt"),
                            names_to = "Metric", values_to = "Value")
      # 固定面板顺序
      qc_long$Metric <- factor(qc_long$Metric, levels = c("nFeature_RNA", "nCount_RNA", "percent_mt"))
      # 6. 高级 ggplot2 原生渲染输出
      sci_palette <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF",
                       "#F39B7FFF", "#8491B4FF", "#91D1C2FF", "#DC0000FF",
                       "#7E6148FF", "#B09C85FF", "#FF7F00", "#6A3D9A")
      # [核心逻辑] 动态扩增颜色：如果分组数超过12，自动插值生成足够的颜色；如果不超过，就直接按顺序使用
      num_groups <- length(levels(qc_long$Plot_Group))
      if (num_groups <= length(sci_palette)) {
        # 如果分组数 <= 12，严格依次提取原色（比如选3个，就绝对是红、蓝、绿）
        dynamic_colors <- sci_palette[1:num_groups]
      } else {
        # 如果分组数 > 12，通过插值算法生成平滑过渡的新颜色集，防止报错
        dynamic_colors <- colorRampPalette(sci_palette)(num_groups)
      }
      p_qc <- ggplot(qc_long, aes(x = Plot_Group, y = Value, fill = Plot_Group)) +
        geom_violin(trim = FALSE, color = "black", alpha = 0.9, scale = "width", linewidth = 0.6) +
        geom_jitter(width = 0.2, size = 0.5, alpha = 0.3, color = "grey30") +
        facet_wrap(~ Metric, scales = "free_y", ncol = 3, strip.position = "top") +
        theme_bw(base_size = 14) +
        labs(x = group_col, y = "Metric Value") +
        theme(
          legend.position = "none",
          axis.title.x = element_text(face = "bold", size = 14, margin = margin(t = 10)),
          axis.text.x = element_text(angle = 45, hjust = 1, face = "bold", color = "black"),
          axis.text.y = element_text(color = "black"),
          strip.background = element_rect(fill = "#f8f9fa", color = "black", linewidth = 1),
          strip.text = element_text(face = "bold", size = 14, color = "#2C3E50"),
          panel.grid.major.x = element_blank(),
          panel.grid.minor.x = element_blank(),
          panel.border = element_rect(color = "black", linewidth = 1.2)
        ) +
        # 传入判定好的颜色集
        scale_fill_manual(values = dynamic_colors)
      # 保存为实际的 ggplot 对象，供下载使用
      RNA_values$qc_plot_obj <- p_qc
      # 输出到前端
      output$qc_plot <- renderPlot({
        req(RNA_values$qc_plot_obj)
        RNA_values$qc_plot_obj
      })
      showNotification("Metrics calculated and grouped plot generated!", type = "message")
    }, error = function(e)
      showNotification(paste("QC Error:", e$message), type = "error"))
    toc()
  })

  # 功能: 核心底层过滤引擎 (写入 filter_counts 和 filter_meta.data)
  observeEvent(input$runFilter, {
    tic("RNA filter data total time:")
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    # 安全检查：确保已经计算了线粒体
    if (is.null(obj$meta.data$percent_mt)) {
      showNotification("Please 'Calculate & Plot' metrics first before filtering!", type = "error")
      return(NULL)
    }
    # 获取用户选择的标准化方法 (增加容错保护)
    norm_method <- input$rna_norm_method
    if (is.null(norm_method)) norm_method <- "LogNormalize"
    progress <- shiny::Progress$new(); on.exit(progress$close())
    tryCatch({
      # 阶段 1: 严格质控过滤 (Quality Control Filtering)
      progress$set(message = "Applying Filters...", value = 0.2)
      meta <- obj$meta.data
      # 向量化条件筛选 (绝对高效)
      keep_cells <- rownames(meta)[
        meta$nCount_RNA >= input$min_nCount &
          meta$nCount_RNA <= input$max_nCount &
          meta$nFeature_RNA >= input$min_nFeature &
          meta$nFeature_RNA <= input$max_nFeature &
          meta$percent_mt <= input$max_mt
      ]
      # 安全拦截：防止全部细胞被过滤掉导致下游全盘崩溃
      if (length(keep_cells) == 0) {
        showNotification("Filter too strict! 0 cells remaining. Please adjust thresholds.", type = "error", duration = 8)
        return(NULL) # 提前终止，不污染原始对象
      }
      # 切片操作：强制保留为稀疏矩阵格式 (drop = FALSE)
      obj$filter_meta.data <- meta[keep_cells, , drop = FALSE]
      obj$assays$RNA$filter_counts <- obj$assays$RNA$counts[, keep_cells, drop = FALSE]
      # 阶段 2: 极速稀疏矩阵标准化 (Sparse Matrix Normalization Engine)
      progress$set(message = paste0("Normalizing (", norm_method, ")..."), value = 0.5)
      # 提取刚过滤好的稀疏矩阵作为基底
      counts_sparse <- obj$assays$RNA$filter_counts
      # 计算每个细胞的总 UMI (列和)，这步极快
      col_sums <- Matrix::colSums(counts_sparse)
      norm_mat <- NULL
      if (norm_method == "LogNormalize") {
        # 公式: ln( (count / total_count) * 10000 + 1 )
        # 稀疏矩阵极速运算技巧: 利用 R 的转置和向量回收机制进行除法
        norm_mat <- Matrix::t(Matrix::t(counts_sparse) / col_sums) * 10000
        # 暴力破解 C 语言级插槽: 直接对非零元素 (@x) 求对数，速度提升百倍！
        norm_mat@x <- log1p(norm_mat@x)
      } else if (norm_method == "LogCPM") {
        # 公式: log2( (count / total_count) * 1,000,000 + 1 )
        norm_mat <- Matrix::t(Matrix::t(counts_sparse) / col_sums) * 1e6
        norm_mat@x <- log2(norm_mat@x + 1)
      } else if (norm_method == "TPM") {
        # 1. 安全检查：确保矩阵确实带有长度信息
        req(RNA_values$gene_lengths)
        # 【新增核心逻辑：获取当前矩阵余下的基因，通过基因名匹配提取真实对应的长度】
        current_genes <- rownames(counts_sparse)
        filtered_lengths <- RNA_values$gene_lengths[current_genes]
        # 检查是否因为某种拼写错误导致部分基因没有匹配到长度
        if (any(is.na(filtered_lengths))) {
          stop("Error: Cannot find length information for some genes after filtering. Check gene names matching.")
        }
        # 此处不需要也不能再仅判断 length() != nrow()，因为我们已经精确匹配
        # 2. 获取基因长度（单位转换为 KiloBases, kb)
        gene_lengths_kb <- filtered_lengths / 1000
        # 防止极少数异常情况下基因长度为0或NA，用极其微小的值替代，避免计算崩溃 (除以0得到 Inf)
        gene_lengths_kb[gene_lengths_kb == 0 | is.na(gene_lengths_kb)] <- 1e-6
        # 3. 计算 RPK (Reads Per Kilobase) = Counts / Length(kb)
        # 最佳实践：使用 Matrix::Diagonal 构造对角矩阵进行相乘。
        # 这个方法可以直接维系 `dgCMatrix` 稀疏格式不变，防止爆内存 (OOM Defensive)
        kb_inv <- 1 / gene_lengths_kb
        rpk_mat <- Matrix::Diagonal(x = kb_inv) %*% counts_sparse
        # 4. 获取每个细胞的 RPK 综合 (Sum RPK)
        rpk_col_sums <- Matrix::colSums(rpk_mat)
        # 5. 计算最终 True TPM = RPK / (Sum RPK / 1,000,000)
        norm_mat <- Matrix::t(Matrix::t(rpk_mat) / (rpk_col_sums / 1e6))
        # 如对数处理则取消注释下一行，纯TPM无需log
        norm_mat@x <- log2(norm_mat@x + 1)
      }
      # 将计算好的归一化矩阵存入 data 插槽
      obj$assays$RNA$data <- norm_mat
      # 阶段 3: 数据中心化与缩放 (Scaling Engine) - 具备 OOM 防御机制
      progress$set(message = "Scaling Data (Memory Intensive)...", value = 0.8)
      # 行业潜规则：Scale 必须把稀疏矩阵转为密集矩阵，极耗内存。
      # 我们加入 tryCatch 保护，如果服务器内存爆了，优雅跳过，保证网页不死机。
      tryCatch({
        # 将稀疏矩阵转置后 scale (按列标准化)，再转置回来 (按行/基因)
        scale_mat <- t(scale(t(as.matrix(norm_mat))))
        # 剔除因为整行全是 0 导致算出来的 NaN (除以 0 导致)
        scale_mat[is.na(scale_mat)] <- 0
        obj$assays$RNA$scale.data <- scale_mat
      }, error = function(err) {
        # 防御性编程：记录警告，但程序继续运行
        showNotification("Warning: Data scaling skipped to prevent memory overflow (OOM).", type = "warning", duration = 10)
        obj$assays$RNA$scale.data <- NULL
      })
      # 阶段 4: 封包与清理
      progress$set(message = "Finalizing Object...", value = 0.95)
      # 强制触发 R 垃圾回收，清空刚才计算产生的临时密集矩阵，死守 Web Server 内存生命线
      gc()
      # 更新全局响应式对象
      RNA_values$sci_object <- obj
      # 动态生成成功反馈文案，UI 实时展示
      msg <- sprintf(
        "Success! Kept %d cells. Applied %s normalization.",
        length(keep_cells), norm_method
      )
      updateRadioButtons(session, "view_data_type", selected = "qc")
      showNotification(msg, type = "message", duration = 8)
    }, error = function(e) {
      showNotification(paste("Filtering/Normalization Error:", e$message), type = "error", duration = 10)
    })
    toc()
  })

  # 下载自定义对象
  output$download_ui <- renderUI({
    req(RNA_values$sci_object)
    downloadButton("download_rds", "Download sciET Object (.rds)", class = "btn-success btn-lg", style = "width: 100%;")
  })
  output$download_rds <- downloadHandler(
    filename = function() { paste0("sciET_Object_", Sys.Date(), ".rds") },
    content = function(file) {
      saveRDS(RNA_values$sci_object, file = file)
    }
  )
  output$dl_qc_plot_pdf <- downloadHandler(
    filename = function() {
      paste0("scRNA_QC_ViolinPlot_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      # 假设你在 renderPlot 时把图保存到了 RNA_values$qc_plot_obj
      req(RNA_values$qc_plot_obj)
      ggsave(file, plot = RNA_values$qc_plot_obj, width = 10, height = 6, device = "pdf")
    }
  )

  # 功能: 全局重置与极速内存释放引擎
  observeEvent(input$reset_rna_all, {
    # 1. 弹出防误触确认框 (可选，如果不需要确认可以直接注释掉 showModal 部分)
    showModal(modalDialog(
      title = span(icon("exclamation-triangle"), " Warning: Destructive Action", style = "color: red;"),
      "This will permanently delete all uploaded data, models, and plots from RAM. Are you sure?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_reset_rna", "Yes, Clear Memory", class = "btn-danger")
      )
    ))
  })

  # 只有用户点击了"确认"，才真正执行内存释放
  observeEvent(input$confirm_reset_rna, {
    removeModal()
    progress <- shiny::Progress$new(); on.exit(progress$close())
    progress$set(message = "Flushing RAM & Pointers...", value = 0.3)
    # 1. 彻底清空数据源 (动态 UI 失去数据源会自然死亡)
    RNA_values$is_example <- FALSE
    RNA_values$sci_object <- NULL
    RNA_values$raw_input_df <- NULL
    RNA_values$raw_metadata <- NULL
    RNA_values$excel_sheets <- NULL
    RNA_values$excel_path <- NULL
    RNA_values$qc_plot_obj <- NULL
    RNA_values$dr_plot_obj <- NULL
    RNA_values$volcano_plot_obj <- NULL
    # 2. 物理清空浏览器的文件上传框 (打破 HTML 缓存)
    try({
      shinyjs::reset("RNA_data_input1")
      shinyjs::reset("RNA_data_input2")
      shinyjs::runjs("document.getElementById('RNA_data_input1').value = '';")
      shinyjs::runjs("document.getElementById('RNA_data_input2').value = '';")
      shinyjs::runjs("$('#RNA_data_input1').closest('.input-group').find('input[type=\"text\"]').val('');")
      shinyjs::runjs("$('#RNA_data_input2').closest('.input-group').find('input[type=\"text\"]').val('');")
    }, silent = TRUE)
    # 3. 只恢复静态参数，绝不去 update 任何动态生成的 selectInput！
    updateNumericInput(session, "min_cells_raw", value = 3)
    updateNumericInput(session, "min_features_raw", value = 200)
    updateRadioButtons(session, "view_data_type", selected = "raw")
    progress$set(message = "Reclaiming Physical RAM...", value = 0.8)
    gc(verbose = FALSE, reset = TRUE, full = TRUE)
    showNotification("Complete Reset Successful. System Restored to Initial State.", type = "warning")
  })

  # --- 新增: 监听 Use Example 按钮 ---
  observeEvent(input$use_example_rna, {
    progress <- shiny::Progress$new(); on.exit(progress$close())
    progress$set(message = "Loading Example Data...", value = 0.2)
    # 1. 开启 Example 模式标记
    RNA_values$is_example <- TRUE
    # 2. 定义本地系统目录下的文件路径 (请根据你的实际文件名修改)
    mat_path <- "data/GSE121650_RNA_counts_choose20000.csv"
    meta_path <- "data/GSE121690_sample_final_choose.xlsx"
    # 检查文件是否存在
    if(!file.exists(mat_path) || !file.exists(meta_path)) {
      showNotification("Example files not found in system! Please check 'example_data' folder.", type = "error")
      return(NULL)
    }
    # 3. 极速读取表达矩阵
    progress$set(message = "Reading Matrix CSV...", value = 0.4)
    tryCatch({
      df <- data.table::fread(mat_path, data.table = FALSE, check.names = FALSE)
      RNA_values$raw_input_df <- df
    }, error = function(e) showNotification(paste("Matrix read error:", e$message), type = "error"))
    # 4. 读取 Metadata (锁定 sheet = "RNA")
    progress$set(message = "Reading Metadata XLSX...", value = 0.7)
    tryCatch({
      RNA_values$excel_path <- meta_path
      sheets <- readxl::excel_sheets(meta_path)
      RNA_values$excel_sheets <- sheets
      # 自动识别并读取 "RNA" Sheet
      target_sheet <- if("RNA" %in% sheets) "RNA" else sheets[1]
      RNA_values$raw_metadata <- readxl::read_excel(meta_path, sheet = target_sheet)
    }, error = function(e) showNotification(paste("Metadata read error:", e$message), type = "error"))
    shinyjs::runjs("$('#RNA_data_input1').closest('.input-group').find('input[type=\"text\"]').val('example_matrix.csv');")
    shinyjs::runjs("$('#RNA_data_input2').closest('.input-group').find('input[type=\"text\"]').val('example_metadata.xlsx');")
    progress$set(message = "Done!", value = 1)
    showNotification("Example data loaded successfully! You can now click 'Build Object'.", type = "message")
  })

  output$dl_example_rna <- downloadHandler(
    filename = function() {
      # 用户下载后看到的文件名
      "scMATE_RNA_Example_Data.zip"
    },
    content = function(file) {
      # 替换为你服务器/本地存放该 zip 文件的真实相对路径
      # 例如：存放在 app 根目录的 example_data 文件夹下
      existing_zip_path <- "data/RNA_example_data.zip"
      # 检查文件是否存在，防止报错
      if (file.exists(existing_zip_path)) {
        # 直接将现成的 zip 文件复制到 Shiny 分配的下载路径
        file.copy(from = existing_zip_path, to = file)
      } else {
        # 如果找不到文件，给出一个空的或包含错误提示的文本文件代替
        writeLines("Error: The example zip file was not found on the server.", file)
        showNotification("Example zip file not found on server!", type = "error")
      }
    }
  )

  # 1. 细胞数统计 (淡蓝冰川系)
  output$cell_count_box <- renderValueBox({
    num <- if(is.null(RNA_values$sci_object)) 0 else ncol(RNA_values$sci_object$assays$RNA$counts)
    # 加入了强制高度 115px，确保大小统一
    custom_css <- tags$style(HTML("
      #cell_count_box .small-box { height: 115px !important; background-color: #F0F8FF !important; color: #1E3A8A !important;
                                   border-left: 5px solid #3B82F6 !important; border-radius: 8px !important;
                                   box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #cell_count_box .small-box .icon-large { color: #93C5FD !important; opacity: 0.4; }
    "))
    valueBox(
      value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #1D4ED8;", format(num, big.mark=","))),
      subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #3B82F6;", "Total Cells Recovered"),
      icon = icon("users"), color = "aqua"
    )
  })
  # 2. 基因数统计 (莫兰迪绿/薄荷绿系)
  output$gene_count_box <- renderValueBox({
    num <- if(is.null(RNA_values$sci_object)) 0 else nrow(RNA_values$sci_object$assays$RNA$counts)
    # 加入了强制高度 115px
    custom_css <- tags$style(HTML("
      #gene_count_box .small-box { height: 115px !important; background-color: #F0FDF4 !important; color: #14532D !important;
                                   border-left: 5px solid #22C55E !important; border-radius: 8px !important;
                                   box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #gene_count_box .small-box .icon-large { color: #86EFAC !important; opacity: 0.4; }
    "))
    valueBox(
      value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #15803D;", format(num, big.mark=","))),
      subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #16A34A;", "Genes Detected"),
      icon = icon("dna"), color = "green"
    )
  })
  # 3. 动态分组状态监控 (智能变色+信息反馈)
  output$group_status_box <- renderValueBox({
    obj <- RNA_values$sci_object
    if (is.null(obj)) {
      val_text <- "Awaiting"
      sub_text <- "Metadata Status"
      bg_color <- "#FEFCE8" ; border_color <- "#EAB308" ; text_color <- "#A16207" ; icon_color <- "#FDE047"
      icon_name <- "hourglass-half"
    } else {
      exclude_cols <- c("nCount_RNA", "nFeature_RNA", "percent_mt", "orig.ident")
      custom_groups <- setdiff(colnames(obj$meta.data), exclude_cols)
      n_groups <- length(custom_groups)
      if (n_groups == 0) {
        val_text <- "No Group"
        sub_text <- "Basic QC metrics only"
        bg_color <- "#F8FAFC" ; border_color <- "#94A3B8" ; text_color <- "#475569" ; icon_color <- "#CBD5E1"
        icon_name <- "exclamation-circle"
      } else {
        # 将文字精简，保证在 30px 字体下不换行
        val_text <- sprintf("%d Groups", n_groups)
        show_cols <- paste(head(custom_groups, 2), collapse = ", ")
        sub_text <- paste0("[", show_cols, ifelse(n_groups > 2, ", ...", ""), "]")

        bg_color <- "#FAF5FF" ; border_color <- "#A855F7" ; text_color <- "#6B21A8" ; icon_color <- "#D8B4FE"
        icon_name <- "layer-group"
      }
    }
    # 加入强制高度 115px，并加入防文本换行的 CSS 设定
    custom_css <- tags$style(HTML(sprintf("
      #group_status_box .small-box { height: 115px !important; background-color: %s !important; border-left: 5px solid %s !important;
                                     border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #group_status_box .small-box .icon-large { color: %s !important; opacity: 0.4; }
      /* 核心修复：防止列名太长导致换行把盒子撑大 */
      #group_status_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }
    ", bg_color, border_color, icon_color)))
    valueBox(
      value = tagList(
        custom_css,
        # 字体大小统一恢复为 30px
        tags$span(style = sprintf("font-weight: 800; font-size: 30px; color: %s;", text_color), val_text)
      ),
      # 副标题字体大小统一恢复为 15px
      subtitle = tags$span(style = sprintf("font-weight: 600; font-size: 15px; color: %s;", text_color), sub_text),
      icon = icon(icon_name), color = "yellow"
    )
  })


  # ---- Transcriptome Dim Reduction Clustering Server Logic ----
  # 0. 智能识别数据状态：决定显示 "上传框" 还是 "已连接提示"
  output$dr_data_status_ui <- renderUI({
    if (is.null(RNA_values$sci_object)) {
      # 状态 A: 内存无数据，显示红色警示和上传框
      tagList(
        h5(tags$b("Data Source"), style = "color: #dd4b39;"),
        fileInput("dr_upload_rds", "Upload sciET Object (.rds):",
                  accept = c(".rds", ".RDS"), width = "100%"),
        helpText(icon("info-circle"), " No data detected from Step 1. Please upload a processed object.")
      )
    } else {
      # 状态 B: 内存有数据，显示绿色成功横幅，隐藏上传框
      tagList(
        h5(tags$b("Data Source"), style = "color: #00a65a;"),
        div(class = "alert alert-success", style = "padding: 10px; margin-bottom: 0px;",
            icon("check-circle"), tags$b(" Ready: "), "Using filtered data from Step 1.")
      )
    }
  })

  # 0 监听直接上传 RDS 的情况
  observeEvent(input$dr_upload_rds, {
    req(input$dr_upload_rds)
    progress <- shiny::Progress$new()
    progress$set(message = "Loading RDS File...", value = 0.5)
    on.exit(progress$close())
    tryCatch({
      uploaded_obj <- readRDS(input$dr_upload_rds$datapath)
      # 格式校验：极其重要的防御性编程
      if (!is.list(uploaded_obj) || is.null(uploaded_obj$assays$RNA$counts)) {
        stop("Invalid file structure. Please upload a valid sciET object.")
      }
      RNA_values$sci_object <- uploaded_obj
      showNotification("RDS file successfully loaded into memory!", type = "message", duration = 5)
    }, error = function(e) {
      showNotification(paste("Error reading RDS:", e$message), type = "error", duration = 8)
      shinyjs::reset("dr_upload_rds")
    })
  })

  # 1. 动态渲染分组选择器 (强制读取过滤后的元数据 filter_meta.data)
  output$dr_group_col_ui <- renderUI({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    # 获取元数据
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    meta_cols <- colnames(meta)
    # 排除连续型数值列
    exclude_cols <- c("nCount_RNA", "nFeature_RNA", "percent_mt")
    valid_groups <- setdiff(meta_cols, exclude_cols)
    # 【核心修复：UI 状态保持逻辑】
    # 使用 isolate() 获取用户当前已经选中的值，防止引发反应式死循环
    current_sel <- isolate(input$dr_group_col)
    # 判断：如果用户当前已经选了一个有效的值，就保持这个值；否则使用默认值
    if (!is.null(current_sel) && current_sel %in% valid_groups) {
      final_sel <- current_sel
    } else {
      final_sel <- if("orig.ident" %in% valid_groups) "orig.ident" else valid_groups[1]
    }
    selectInput("dr_group_col", "Color Cells By:",
                choices = valid_groups,
                selected = final_sel) # 使用带有记忆的 final_sel
  })
  # 【新增】：1.5 动态侦测并渲染可用的数据层 (Data Layer)
  output$dr_layer_select_ui <- renderUI({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    # 智能探测当前对象中存在哪些数据矩阵
    available_layers <- c()
    if (!is.null(obj$assays$RNA$filter_counts)) available_layers <- c(available_layers, "Filtered Counts (Raw)" = "filter_counts")
    if (!is.null(obj$assays$RNA$data)) available_layers <- c(available_layers, "Normalized Data" = "data")
    if (!is.null(obj$assays$RNA$scale.data)) available_layers <- c(available_layers, "Scaled Data" = "scale.data")
    if (length(available_layers) == 0) {
      available_layers <- c("Raw Counts" = "counts") # 兜底机制
    }
    # 【核心修复：UI 状态保持逻辑】
    # 使用 isolate() 获取用户当前已经选中的 Layer，防止引发反应式死循环
    current_layer <- isolate(input$dr_data_layer)
    # 判断：如果用户当前已经选了一个值，并且这个值在可用的 layer 中，就保持这个值；否则使用默认值
    if (!is.null(current_layer) && current_layer %in% available_layers) {
      final_layer <- current_layer
    } else {
      # 默认选中处理程度最高的数据（通常是 scale.data 或 data）
      final_layer <- tail(available_layers, 1)
    }
    selectInput("dr_data_layer", "Data Layer to Use:",
                choices = available_layers,
                selected = final_layer) # 使用带有记忆的 final_layer
  })
  # 2. 动态渲染各算法的参数设置
  output$dr_params_ui <- renderUI({
    req(input$dr_method_rna)
    if (input$dr_method_rna == "PCA") {
      tagList(
        h5(tags$b("PCA Parameters"), style = "color: #3c8dbc;"),
        numericInput("pca_rank", "Number of PCs to compute:", value = 30, min = 5, max = 100, step = 5)
        # helpText("Note: Normalization & Top 2000 HVGs selection will be performed on FILTERED data automatically.")
      )
    } else if (input$dr_method_rna == "t-SNE") {
      tagList(
        h5(tags$b("t-SNE Parameters"), style = "color: #3c8dbc;"),
        sliderInput("tsne_pca_dims", "Use PCA Dimensions:", min = 1, max = 50, value = c(1, 20)),
        numericInput("tsne_perp", "Perplexity:", value = 30, min = 5, max = 100),
        numericInput("tsne_iter", "Max Iterations:", value = 1000, min = 500, max = 2000, step = 100)
      )
    } else if (input$dr_method_rna == "UMAP") {
      tagList(
        h5(tags$b("UMAP Parameters"), style = "color: #3c8dbc;"),
        sliderInput("umap_pca_dims", "Use PCA Dimensions:", min = 1, max = 50, value = c(1, 20)),
        numericInput("umap_neighbors", "Number of Neighbors:", value = 30, min = 5, max = 100),
        numericInput("umap_mindist", "Minimum Distance:", value = 0.3, min = 0.01, max = 1.0, step = 0.05)
      )
    }
  })

  # 3. 核心算法执行引擎
  observeEvent(input$run_dr, {
    tic("RNA dim reduction total time:")
    req(RNA_values$sci_object, input$dr_method_rna, input$dr_data_layer)
    method <- input$dr_method_rna
    layer_name <- input$dr_data_layer
    obj <- RNA_values$sci_object
    # 获取用户指定的底层矩阵
    mat <- obj$assays$RNA[[layer_name]]
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    if(is.null(mat)) {
      showNotification(paste("Error: Layer", layer_name, "is missing!"), type = "error")
      return(NULL)
    }
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    tryCatch({
      # 算法 A: PCA (自适应数据层)
      if (method == "PCA") {
        progress$set(message = paste("Calculating HVGs on", layer_name, "..."), value = 0.2)
        # 1. 极速计算高变基因 HVG (兼容稀疏矩阵与密集矩阵)
        rM <- Matrix::rowMeans(mat)
        rVar <- Matrix::rowMeans(mat^2) - rM^2
        hvgs <- names(sort(rVar, decreasing = TRUE))[1:min(2000, length(rVar))]
        obj$var.genes <- hvgs
        # 2. 执行 Truncated SVD (PCA)
        progress$set(message = "Running Truncated SVD (PCA)...", value = 0.6)
        mat_hvg <- mat[hvgs, , drop = FALSE]
        # 无论输入的是 counts 还是 scale.data，prcomp_irlba 的 center/scale. 参数都能保证 PCA 数学安全
        pca_res <- irlba::prcomp_irlba(Matrix::t(mat_hvg), n = input$pca_rank, center = TRUE, scale. = TRUE)
        pca_coords <- pca_res$x
        rownames(pca_coords) <- colnames(mat)
        colnames(pca_coords) <- paste0("PC_", 1:ncol(pca_coords))
        obj$reductions$pca <- pca_coords
        obj$reductions$current_plot <- pca_coords[, 1:2]
        colnames(obj$reductions$current_plot) <- c("Dim1", "Dim2")
        obj$reductions$current_method <- "PCA"
        showNotification(paste("PCA completed using top", length(hvgs), "HVGs from", layer_name, "!"), type = "message")
      }
      # 算法 B: t-SNE
      else if (method == "t-SNE") {
        if(is.null(obj$reductions$pca)) stop("PCA not found! Please run PCA first.")
        progress$set(message = "Calculating t-SNE manifold...", value = 0.5)
        dims_use <- input$tsne_pca_dims[1]:input$tsne_pca_dims[2]
        pca_input <- obj$reductions$pca[, dims_use, drop = FALSE]
        tsne_res <- Rtsne::Rtsne(pca_input, pca = FALSE,
                                 perplexity = input$tsne_perp,
                                 max_iter = input$tsne_iter,
                                 check_duplicates = FALSE)
        tsne_coords <- tsne_res$Y
        rownames(tsne_coords) <- rownames(pca_input)
        colnames(tsne_coords) <- c("tSNE_1", "tSNE_2")
        obj$reductions$tsne <- tsne_coords
        obj$reductions$current_plot <- tsne_coords
        colnames(obj$reductions$current_plot) <- c("Dim1", "Dim2")
        obj$reductions$current_method <- "t-SNE"
        showNotification("t-SNE layout optimized successfully!", type = "message")
      }
      # 算法 C: UMAP
      else if (method == "UMAP") {
        if(is.null(obj$reductions$pca)) stop("PCA not found! Please run PCA first.")
        progress$set(message = "Calculating UMAP embedding...", value = 0.5)
        dims_use <- input$umap_pca_dims[1]:input$umap_pca_dims[2]
        pca_input <- obj$reductions$pca[, dims_use, drop = FALSE]
        umap_res <- uwot::umap(pca_input,
                               n_neighbors = input$umap_neighbors,
                               min_dist = input$umap_mindist,
                               n_components = 2, fast_sgd = TRUE)
        umap_coords <- umap_res
        rownames(umap_coords) <- rownames(pca_input)
        colnames(umap_coords) <- c("UMAP_1", "UMAP_2")
        obj$reductions$umap <- umap_coords
        obj$reductions$current_plot <- umap_coords
        colnames(obj$reductions$current_plot) <- c("Dim1", "Dim2")
        obj$reductions$current_method <- "UMAP"
        showNotification("UMAP coordinates generated successfully!", type = "message")
      }
      # 核心新增：聚类算法模块
      if (input$do_clustering) {
        progress$set(message = "Extracting Principal Components...", value = 0.7)
        # 科学界规范：聚类应该基于 PCA 的高维特征空间，而不是 UMAP/t-SNE 的二维空间
        # 如果没有 PCA，则退化使用当前的 2D 坐标兜底
        cluster_input <- if (!is.null(obj$reductions$pca)) {
          obj$reductions$pca[, 1:min(20, ncol(obj$reductions$pca)), drop = FALSE]
        } else {
          obj$reductions$current_plot
        }
        if (input$cluster_method == "graph") {
          progress$set(message = "Building K-NN Graph (FNN)...", value = 0.8)
          # 使用 C 级别的 FNN 极速构建 K-NN 图
          k_n <- min(20, nrow(cluster_input) - 1)
          knn_res <- FNN::get.knn(cluster_input, k = k_n)
          edges <- do.call(rbind, lapply(1:nrow(cluster_input), function(i) cbind(rep(i, k_n), knn_res$nn.index[i, ])))
          progress$set(message = "Running Leiden Community Detection...", value = 0.9)
          g <- igraph::graph_from_edgelist(edges, directed = FALSE)
          g <- igraph::simplify(g)
          leiden_res <- igraph::cluster_leiden(g, resolution_parameter = input$cluster_res)
          cluster_labels <- paste0("Cluster_", leiden_res$membership)
        } else {
          progress$set(message = "Running Hierarchical Clustering...", value = 0.85)
          d_mat <- dist(cluster_input)
          hc_res <- hclust(d_mat, method = "ward.D2")
          cluster_labels <- paste0("Cluster_", cutree(hc_res, k = input$cluster_k))
        }
        # 因子化：提取数字并自然排序 (让 Cluster_2 排在 Cluster_10 前面)
        cluster_nums <- as.numeric(gsub("Cluster_", "", cluster_labels))
        sorted_levels <- paste0("Cluster_", sort(unique(cluster_nums)))
        cluster_factor <- factor(cluster_labels, levels = sorted_levels)
        # 将聚类标签写回 metadata
        obj$filter_meta.data$Auto_Cluster <- cluster_factor
        if(!is.null(obj$filter_meta.data)) obj$filter_meta.data$Auto_Cluster <- cluster_factor
        showNotification(paste("Clustering complete! Found", length(sorted_levels), "clusters."), type = "message")
      }
      # 保存回全局响应值
      RNA_values$sci_object <- obj
    }, error = function(e) {
      showNotification(paste("Algorithm Error:", e$message), type = "error", duration = 8)
    })
    toc()
  })

  # 4. 稳健的可视化渲染引擎 (与 filter_meta.data 结合)
  output$dr_plot <- renderPlot({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    req(obj$reductions$current_plot)
    # 提取坐标和元数据
    coords <- as.data.frame(obj$reductions$current_plot)
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    plot_df <- cbind(coords, meta)
    method_name <- if(!is.null(obj$reductions$current_method)) obj$reductions$current_method else "DimRed"
    group_col <- input$dr_group_col
    sci_palette <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF",
                     "#F39B7FFF", "#8491B4FF", "#91D1C2FF", "#DC0000FF",
                     "#7E6148FF", "#B09C85FF", "#FF7F00", "#6A3D9A")
    # 【图 1】：左图 - 基于用户指定的列着色 (如疾病分组、批次等)
    p1 <- ggplot(plot_df, aes(x = Dim1, y = Dim2, color = .data[[group_col]])) +
      geom_point(size = 2.5, alpha = 0.8) +
      scale_fill_manual(values = sci_palette) +
      scale_color_manual(values = sci_palette) +
      theme_classic(base_size = 14) +
      labs(title = paste(method_name, "by", group_col), x = paste0(method_name, "_1"), y = paste0(method_name, "_2")) +
      theme(plot.title = element_text(face = "bold", hjust = 0.5),
            legend.position = "right") +
      guides(color = guide_legend(override.aes = list(size = 4)))
    # 【图 2】：右图 - 基于刚算出来的无监督聚类着色 (仅当执行了聚类时才画)
    if (input$do_clustering && "Auto_Cluster" %in% colnames(plot_df)) {
      p2 <- ggplot(plot_df, aes(x = Dim1, y = Dim2, color = Auto_Cluster)) +
        geom_point(size = 2.5, alpha = 0.8) +
        theme_classic(base_size = 14) +
        labs(title = "Unsupervised Clustering", x = paste0(method_name, "_1"), y = paste0(method_name, "_2")) +
        theme(plot.title = element_text(face = "bold", hjust = 0.5),
              legend.position = "right") +
        guides(color = guide_legend(override.aes = list(size = 4)))
      # 使用 patchwork 包进行左右丝滑拼接
      final_plot <- p1 + p2 + patchwork::plot_layout(ncol = 2, guides = "collect")
    } else {
      # 如果没勾选分群，只显示一张图，并且居中
      final_plot <- p1 + theme(legend.position = "right")
    }
    # 保存供 PDF 下载
    RNA_values$dr_plot_obj <- final_plot
    return(final_plot)
  })
  # 5. 下载降维坐标数据
  output$download_dr_data <- downloadHandler(
    filename = function() {
      method <- if(!is.null(RNA_values$sci_object$reductions$current_method)) RNA_values$sci_object$reductions$current_method else "DimRed"
      paste0(method, "_Coordinates_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(RNA_values$sci_object$reductions$current_plot)
      coords <- as.data.frame(RNA_values$sci_object$reductions$current_plot)
      coords$Cell_ID <- rownames(coords)
      # 调整列顺序，将 Cell_ID 放第一列
      coords <- coords[, c("Cell_ID", "Dim1", "Dim2")]
      data.table::fwrite(coords, file, row.names = FALSE)
    }
  )
  output$dl_dr_plot_pdf <- downloadHandler(
    filename = function() { paste0("scRNA_DimensionReduction_", Sys.Date(), ".pdf") },
    content = function(file) {
      req(RNA_values$dr_plot_obj)
      # 因为是左右双图并排，所以宽度设宽一点 (width=12)
      ggsave(file, plot = RNA_values$dr_plot_obj, width = 12, height = 6, device = "pdf")
    }
  )

  observeEvent(input$btn_reset_dr, {
    # 1. 清空底层核心响应式变量 (这会自动触发 UI 的重新渲染，将绿色 Ready 变回上传框)
    RNA_values$sci_object <- NULL
    RNA_values$dr_plot_obj <- NULL
    # 2. 强制重置前端的 input 控件，防止幽灵缓存
    shinyjs::reset("dr_upload_rds")
    shinyjs::reset("dr_method_rna")
    # 3. 弹出友好的系统通知
    showNotification(
      "Memory cleared! You can now upload a new .rds object.",
      type = "warning",
      duration = 5
    )
  })


  # ---- Transcriptome Differential Analysis Server Logic ----
  DEA_values <- reactiveValues(
    markers = NULL    # 存储差异分析结果
  )

  # 0. 智能识别数据状态：无缝继承或提示上传
  output$dea_data_status_ui <- renderUI({
    if (is.null(RNA_values$sci_object)) {
      tagList(
        h5(tags$b("Data Source"), style = "color: #dd4b39;"),
        fileInput("dea_upload_rds", "Upload sciET Object (.rds):", accept = c(".rds", ".RDS"), width = "100%"),
        helpText(icon("info-circle"), " No data from Step 1. Please upload a processed object.")
      )
    } else {
      tagList(
        h5(tags$b("Data Source"), style = "color: #00a65a;"),
        div(class = "alert alert-success", style = "padding: 10px; margin-bottom: 0px;",
            icon("check-circle"), tags$b(" Ready: "), "Using loaded object.")
      )
    }
  })

  # 0.1 监听 RDS 文件上传 (汇聚到同一个全局变量)
  observeEvent(input$dea_upload_rds, {
    req(input$dea_upload_rds)
    progress <- shiny::Progress$new(); on.exit(progress$close())
    progress$set(message = "Loading RDS...", value = 0.5)
    tryCatch({
      uploaded_obj <- readRDS(input$dea_upload_rds$datapath)
      if (!is.list(uploaded_obj) || is.null(uploaded_obj$assays$RNA)) stop("Invalid sciET object.")
      RNA_values$sci_object <- uploaded_obj
      showNotification("Object loaded!", type = "message")
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error"); shinyjs::reset("dea_upload_rds")
    })
  })

  # 1. 动态渲染分组选择器 (自带防重置记忆功能)
  output$dea_group_col_ui <- renderUI({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    valid_groups <- setdiff(colnames(meta), c("nCount_RNA", "nFeature_RNA", "percent_mt"))
    current_sel <- isolate(input$dea_group_col)
    final_sel <- if (!is.null(current_sel) && current_sel %in% valid_groups) current_sel else valid_groups[1]
    selectInput("dea_group_col", "Cluster/Group Column:", choices = valid_groups, selected = final_sel)
  })
  # 2. 动态渲染对比组选择
  output$dea_comparison_ui <- renderUI({
    req(RNA_values$sci_object, input$dea_group_col)
    obj <- RNA_values$sci_object
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    # 获取选中列的所有不同分组，并去除 NA
    groups <- as.character(unique(meta[[input$dea_group_col]]))
    groups <- sort(groups[!is.na(groups) & groups != ""])
    if (input$dea_mode == "one_vs_rest") {
      # 模式 A: 选 1 个对其他所有
      selectInput("dea_ident_1", "Test Group (Ident 1):", choices = groups)
    } else {
      # 模式 B: 选 1 个对另 1 个
      tagList(
        selectInput("dea_ident_1", "Test Group (Ident 1):", choices = groups, selected = groups[1]),
        selectInput("dea_ident_2", "Control Group (Ident 2):", choices = groups, selected = if(length(groups)>1) groups[2] else groups[1])
      )
    }
  })

  # 3. 核心算法：手写稀疏矩阵极速 Wilcoxon DEA (完全取代 Seurat)
  observeEvent(input$run_dea, {
    tic("RNA difference analysis total time:")
    req(RNA_values$sci_object, input$dea_group_col, input$dea_ident_1)
    # 防呆设计
    if (input$dea_mode == "one_vs_one" && input$dea_ident_1 == input$dea_ident_2) {
      showNotification("Ident 1 and Ident 2 cannot be the same group!", type = "error")
      return()
    }
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    tryCatch({
      obj <- RNA_values$sci_object
      meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
      mat <- if(!is.null(obj$assays$RNA$filter_counts)) obj$assays$RNA$filter_counts else obj$assays$RNA$counts
      progress$set(message = "Preparing data matrices...", value = 0.1)
      # 1. 划分细胞组
      group_vec <- as.character(meta[[input$dea_group_col]])
      cells_1 <- rownames(meta)[which(group_vec == input$dea_ident_1)]
      if (input$dea_mode == "one_vs_rest") {
        cells_2 <- rownames(meta)[which(group_vec != input$dea_ident_1 & !is.na(group_vec))]
        ident_2_name <- "Rest"
      } else {
        cells_2 <- rownames(meta)[which(group_vec == input$dea_ident_2)]
        ident_2_name <- input$dea_ident_2
      }
      if (length(cells_1) < 3 || length(cells_2) < 3) {
        stop("Not enough cells in one of the groups to perform statistics (Need at least 3).")
      }
      # 2. 极速 LogNormalize (保证数据处于可比状态)
      # 如果对象中已经保存了 norm_data 可以直接用，这里为了稳健，每次快速计算
      progress$set(message = "Log-Normalizing...", value = 0.3)
      col_sums <- Matrix::colSums(mat)
      mat_norm <- Matrix::t(Matrix::t(mat) / col_sums) * 10000
      mat_norm@x <- log1p(mat_norm@x)
      # 分割稀疏矩阵
      mat_1 <- mat_norm[, cells_1, drop = FALSE]
      mat_2 <- mat_norm[, cells_2, drop = FALSE]
      # 3. 极速计算表达比例 (pct.1, pct.2) - 纯矩阵代数运算
      progress$set(message = "Calculating Percentages & Fold Changes...", value = 0.5)
      pct_1 <- round(Matrix::rowSums(mat_1 > 0) / length(cells_1), 3)
      pct_2 <- round(Matrix::rowSums(mat_2 > 0) / length(cells_2), 3)
      # 4. 计算 Log2FC (由于已经是 log1p，需要先 expm1 还原再求均值，最后转 log2)
      # 为了速度，直接在稀疏矩阵上操作
      mat_1_exp <- mat_1; mat_1_exp@x <- expm1(mat_1_exp@x)
      mat_2_exp <- mat_2; mat_2_exp@x <- expm1(mat_2_exp@x)
      mean_1 <- Matrix::rowMeans(mat_1_exp)
      mean_2 <- Matrix::rowMeans(mat_2_exp)
      # 防止 log2(0) 报错，加个极小数 (伪计数)
      log2fc <- log2(mean_1 + 1e-9) - log2(mean_2 + 1e-9)
      # 5. 基于阈值进行快速预过滤 (极大缩减 p-value 计算时间)
      genes_pass <- names(which(
        (pct_1 >= input$dea_min_pct | pct_2 >= input$dea_min_pct) &
          abs(log2fc) >= input$dea_logfc_thresh
      ))
      if (length(genes_pass) == 0) {
        stop("No genes passed the Min Pct and Log2FC thresholds.")
      }
      # 6. 对保留的基因执行 Wilcoxon Rank Sum Test
      progress$set(message = paste("Running statistical tests on", length(genes_pass), "genes..."), value = 0.7)
      # 提取需要检验的数据，转为普通矩阵加快按行提取速度
      test_mat_1 <- as.matrix(mat_1[genes_pass, , drop = FALSE])
      test_mat_2 <- as.matrix(mat_2[genes_pass, , drop = FALSE])
      p_vals <- sapply(1:length(genes_pass), function(i) {
        x <- test_mat_1[i, ]
        y <- test_mat_2[i, ]
        # exact=FALSE, correct=FALSE 加快计算速度
        res <- wilcox.test(x, y, exact = FALSE, correct = FALSE)
        return(res$p.value)
      })
      # 7. 整理结果与多重假设检验校正 (FDR / BH)
      progress$set(message = "Formatting results...", value = 0.9)
      res_df <- data.frame(
        gene = genes_pass,
        p_val = p_vals,
        avg_log2FC = log2fc[genes_pass],
        pct.1 = pct_1[genes_pass],
        pct.2 = pct_2[genes_pass],
        cluster = input$dea_ident_1,   # 标记是谁的 Marker
        comparison = paste0(input$dea_ident_1, " vs ", ident_2_name),
        stringsAsFactors = FALSE
      )
      # 计算 adjust p-value
      res_df$p_val_adj <- p.adjust(res_df$p_val, method = "BH")
      # 按 p_val 升序排列
      res_df <- res_df[order(res_df$p_val), ]
      DEA_values$markers <- res_df
      showNotification(sprintf("DEA completed! Found %d significant genes.", nrow(res_df)), type = "message", duration = 5)
    }, error = function(e) {
      showNotification(paste("DEA Algorithm Error:", e$message), type = "error", duration = 8)
    })
    toc()
  })

  # 4. 火山图渲染 (完全兼容手写的底层数据结构)
  output$volcano_plot <- renderPlot({
    req(DEA_values$markers)
    df <- DEA_values$markers
    fc_cut <- input$volcano_fc_cut
    p_cut <- input$volcano_p_cut
    # [核心修复] 防止 P-value 为 0 时 log10 溢出导致图表崩溃或点消失
    min_nonzero_p <- min(df$p_val_adj[df$p_val_adj > 0], na.rm = TRUE)
    # 如果极小值仍然太小，可以给一个底线比如 1e-300
    df$p_val_adj[df$p_val_adj == 0] <- min_nonzero_p
    # 1. 定义颜色分组逻辑
    df$Significance <- "NS"
    df$Significance[df$avg_log2FC > fc_cut & df$p_val_adj < p_cut] <- "UP"
    df$Significance[df$avg_log2FC < -fc_cut & df$p_val_adj < p_cut] <- "DOWN"
    df$Significance <- factor(df$Significance, levels = c("UP", "DOWN", "NS"))
    # 2. 智能提取 Top 基因用于打标签 (Top 10 UP & Top 10 DOWN)
    top_up <- df %>%
      filter(Significance == "UP") %>%
      arrange(desc(avg_log2FC)) %>%
      head(10)
    top_down <- df %>%
      filter(Significance == "DOWN") %>%
      arrange(avg_log2FC) %>%
      head(10)
    top_genes <- bind_rows(top_up, top_down)
    # 3. 构建标题
    comparison_name <- unique(df$comparison)[1]
    plot_title <- paste("Volcano Plot:", comparison_name)
    sub_title <- paste("Thresholds: |Log2FC| >", fc_cut, " &  adj.P <", p_cut)
    # 定义顶刊级配色 (类似 NPG - Nature Publishing Group)
    my_colors <- c("UP" = "#E64B35", "DOWN" = "#4DBBD5", "NS" = "#DFE6E9")
    # 4. 绘制顶级学术火山图
    p <- ggplot(df, aes(x = avg_log2FC, y = -log10(p_val_adj))) +
      # [美化] 绘制阈值辅助线置于底层，使用更柔和的颜色，避免喧宾夺主
      geom_vline(xintercept = c(-fc_cut, fc_cut), linetype = "dashed", color = "grey40", linewidth = 0.6, alpha = 0.8) +
      geom_hline(yintercept = -log10(p_cut), linetype = "dashed", color = "grey40", linewidth = 0.6, alpha = 0.8) +
      # [美化] 使用 shape=21 赋予点白色描边，增强立体感。动态大小和透明度突出显著基因
      geom_point(aes(fill = Significance,
                     size = Significance,
                     alpha = Significance),
                 shape = 21, color = "white", stroke = 0.3) +
      # 映射配色、大小和透明度
      scale_fill_manual(values = my_colors) +
      scale_size_manual(values = c("UP" = 2.5, "DOWN" = 2.5, "NS" = 1.2)) +
      scale_alpha_manual(values = c("UP" = 0.9, "DOWN" = 0.9, "NS" = 0.4)) +
      # [美化] 添加无重叠的带光晕的基因名称标签
      geom_text_repel(
        data = top_genes,
        aes(label = gene, color = Significance),
        size = 4.5,
        fontface = "bold.italic",    # 粗斜体，更具视觉冲击力
        bg.color = "white",          # 给文字添加白边光晕，防止与背景散点重叠难以阅读
        bg.r = 0.15,                 # 光晕半径
        box.padding = 0.8,
        point.padding = 0.3,
        segment.color = "grey30",
        segment.size = 0.6,
        arrow = arrow(length = unit(0.015, "npc"), type = "closed"), # [新增] 指引线加上小箭头
        min.segment.length = 0,      # 强制显示引线
        show.legend = FALSE,
        max.overlaps = Inf
      ) +
      scale_color_manual(values = c("UP" = "#C0392B", "DOWN" = "#2980B9")) + # 字体颜色稍微深一点点
      # 学术主题美化
      theme_bw(base_size = 14) +
      labs(title = plot_title,
           subtitle = sub_title,
           x = expression(bold("Log"[2]*" Fold Change")),
           y = expression(bold("-Log"[10]*" (Adjusted P-value)"))) +
      theme(
        # 移除多余的网格线，仅保留面板边框
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, size = 1.5),
        # 标题居中与字体设置
        plot.title = element_text(hjust = 0.5, face = "bold", size = 18, color = "#2C3E50", margin = margin(b = 8)),
        plot.subtitle = element_text(hjust = 0.5, size = 12, color = "#7F8C8D", face = "italic", margin = margin(b = 15)),
        # 轴标签字体
        axis.title = element_text(face = "bold", size = 14),
        axis.text = element_text(size = 12, color = "black"),
        axis.ticks = element_line(size = 0.8, color = "black"),
        # 图例美化
        legend.position = "top",
        legend.title = element_blank(),
        legend.text = element_text(size = 12, face = "bold"),
        legend.key = element_blank(),
        legend.background = element_blank(),
        # 增大图例点的尺寸
        legend.key.size = unit(1.5, "cm")
      ) +
      # 覆盖图例，使其变成统一大小的实心圆
      guides(fill = guide_legend(override.aes = list(size = 4, alpha = 1, shape = 21, color = "white")))
    RNA_values$volcano_plot_obj <- p
    return(p)
  })

  # 5. 展示数据表
  output$dea_table <- DT::renderDT({
    req(DEA_values$markers)
    df <- DEA_values$markers
    # 格式化数值以便展示
    df$p_val <- formatC(df$p_val, format = "e", digits = 2)
    df$p_val_adj <- formatC(df$p_val_adj, format = "e", digits = 2)
    df$avg_log2FC <- round(df$avg_log2FC, 3)
    DT::datatable(df,
                  width = "100%",                           # 【新增】强制表格宽度100%
                  class = 'table table-striped table-hover',# 【新增】使用Bootstrap原生全宽样式
                  options = list(
                    pageLength = 10,
                    scrollX = TRUE,
                    autoWidth = FALSE                       # 【修改】关闭autoWidth，让浏览器自动分配剩余空间
                  ),
                  rownames = FALSE,
                  caption = htmltools::tags$caption(
                    style = "caption-side: top; text-align: left; color: #2c3e50; font-weight: bold;",
                    "Differentially Expressed Genes"
                  ))
  })
  # 6. 下载 Marker 表格
  output$dea_download_csv <- downloadHandler(
    filename = function() {
      req(DEA_values$markers)
      comp <- gsub(" ", "_", unique(DEA_values$markers$comparison)[1])
      paste0("Markers_", comp, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(DEA_values$markers)
      data.table::fwrite(DEA_values$markers, file, row.names = FALSE)
    }
  )
  output$dl_volcano_plot_pdf <- downloadHandler(
    filename = function() {
      paste0("scRNA_VolcanoPlot_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      req(RNA_values$volcano_plot_obj)
      ggsave(file, plot = RNA_values$volcano_plot_obj, width = 7, height = 6, device = "pdf")
    }
  )

  observeEvent(input$btn_reset_dea, {
    # 1. 彻底清空底层响应式变量
    RNA_values$sci_object <- NULL       # 置空单细胞对象 (会触发 dea_data_status_ui 重新渲染为上传框)
    DEA_values$markers <- NULL          # 置空差异基因表格数据
    RNA_values$volcano_plot_obj <- NULL # 置空火山图对象
    # 2. 强制重置前端的静态输入控件 (将其弹回默认值)
    shinyjs::reset("dea_upload_rds")
    shinyjs::reset("dea_mode")
    shinyjs::reset("dea_min_pct")
    shinyjs::reset("dea_logfc_thresh")
    shinyjs::reset("volcano_fc_cut")
    shinyjs::reset("volcano_p_cut")
    # 3. 弹出系统通知
    showNotification(
      "DEA data and settings cleared! Ready for new analysis.",
      type = "warning",
      duration = 5
    )
  })


  # ---- Transcriptome Pseudotime Server Logic ----
  library(princurve)
  # 0. 智能识别数据状态
  output$pseudo_data_status_ui <- renderUI({
    if (is.null(RNA_values$sci_object)) {
      tagList(
        h5(tags$b("Data Source"), style = "color: #dd4b39;"),
        fileInput("pseudo_upload_rds", "Upload sciET Object (.rds):", accept = c(".rds", ".RDS"), width = "100%"),
        helpText(icon("info-circle"), " Please upload a processed object with Reduction (PCA/UMAP/t-SNE).")
      )
    } else {
      tagList(
        h5(tags$b("Data Source"), style = "color: #00a65a;"),
        div(class = "alert alert-success", style = "padding: 10px; margin-bottom: 0px;",
            icon("check-circle"), tags$b(" Ready: "), "Object loaded in memory.")
      )
    }
  })

  observeEvent(input$pseudo_upload_rds, {
    req(input$pseudo_upload_rds)
    tryCatch({
      obj <- readRDS(input$pseudo_upload_rds$datapath)
      if (!is.list(obj) || is.null(obj$assays$RNA$counts)) stop("Invalid sciET object.")
      RNA_values$sci_object <- obj
      showNotification("RDS loaded successfully!", type = "message")
    }, error = function(e) showNotification(paste("Error:", e$message), type = "error"))
  })

  observeEvent(input$btn_reset_pseudo, {
    RNA_values$sci_object <- NULL
    RNA_values$pseudo_plot_obj <- NULL
    shinyjs::reset("pseudo_upload_rds")
  })

  # 1. 动态渲染可用的降维方法
  output$pseudo_dr_select_ui <- renderUI({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    available_dr <- c()
    if (!is.null(obj$reductions$pca)) available_dr <- c(available_dr, "PCA" = "pca")
    if (!is.null(obj$reductions$tsne)) available_dr <- c(available_dr, "t-SNE" = "tsne")
    if (!is.null(obj$reductions$umap)) available_dr <- c(available_dr, "UMAP" = "umap")
    if (length(available_dr) == 0) {
      return(tags$b("Error: No Dimensionality Reduction found. Please run DimRed first.", style="color:red;"))
    }
    current_dr <- isolate(input$pseudo_dr_method)
    final_dr <- if (!is.null(current_dr) && current_dr %in% available_dr) current_dr else tail(available_dr, 1)
    selectInput("pseudo_dr_method", "Select Embedding Space:", choices = available_dr, selected = final_dr)
  })

  # 2. 动态渲染分组信息 (Cluster)
  output$pseudo_group_col_ui <- renderUI({
    req(RNA_values$sci_object)
    meta <- if(!is.null(RNA_values$sci_object$filter_meta.data)) RNA_values$sci_object$filter_meta.data else RNA_values$sci_object$meta.data
    valid_groups <- setdiff(colnames(meta), c("nCount_RNA", "nFeature_RNA", "percent_mt"))
    current_col <- isolate(input$pseudo_group_col)
    final_col <- if (!is.null(current_col) && current_col %in% valid_groups) current_col else valid_groups[1]
    selectInput("pseudo_group_col", "Cluster / Group Column:", choices = valid_groups, selected = final_col)
  })
  # 3. 根据选定的分组，动态提取起点 (Start Cluster)
  output$pseudo_start_clus_ui <- renderUI({
    req(RNA_values$sci_object, input$pseudo_group_col)
    meta <- if(!is.null(RNA_values$sci_object$filter_meta.data)) RNA_values$sci_object$filter_meta.data else RNA_values$sci_object$meta.data
    groups <- unique(as.character(meta[[input$pseudo_group_col]]))
    groups <- groups[!is.na(groups) & groups != ""]
    current_start <- isolate(input$pseudo_start_clus)
    final_start <- if (!is.null(current_start) && current_start %in% groups) current_start else groups[1]
    selectInput("pseudo_start_clus", "Starting Cluster (Root):", choices = groups, selected = final_start)
  })

  # 4. 核心算法：基于 princurve 计算拟时序
  observeEvent(input$run_pseudo, {
    req(RNA_values$sci_object, input$pseudo_dr_method, input$pseudo_group_col, input$pseudo_start_clus, input$pseudo_algorithm)
    obj <- RNA_values$sci_object
    coords <- obj$reductions[[input$pseudo_dr_method]]
    if(is.null(coords)) {
      showNotification("Selected coordinates not found!", type = "error")
      return(NULL)
    }
    coords <- coords[, 1:2] # 取前两维
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    start_cells <- rownames(meta)[meta[[input$pseudo_group_col]] == input$pseudo_start_clus]
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    tryCatch({
      if (input$pseudo_algorithm == "cluster") {
        # 引擎 A: Cluster-based (Slingshot-style)
        progress$set(message = "Fitting Principal Curve (Cluster-based)...", value = 0.4)
        fit <- princurve::principal_curve(coords, smoother = "smooth.spline")
        pt <- fit$lambda
        curve_out <- fit$s # 曲线坐标
        progress$set(message = "Calibrating Biological Direction...", value = 0.7)
        mean_pt_start <- mean(pt[names(pt) %in% start_cells], na.rm = TRUE)
        mean_pt_all <- mean(pt, na.rm = TRUE)
        if (mean_pt_start > mean_pt_all) {
          pt <- max(pt, na.rm = TRUE) - pt
        }
      } else {
        # 引擎 B: Graph-based (Monocle3-style)
        progress$set(message = "Building K-NN Graph (Graph-based)...", value = 0.3)
        # 1. 构建 KNN 图网络
        k_neighbors <- min(15, nrow(coords) - 1)
        knn_res <- FNN::get.knn(coords, k = k_neighbors)
        edges <- do.call(rbind, lapply(1:nrow(coords), function(i) {
          cbind(rep(i, k_neighbors), knn_res$nn.index[i, ])
        }))
        g <- igraph::graph_from_edgelist(edges, directed = FALSE)
        g <- igraph::simplify(g)
        progress$set(message = "Calculating Network Shortest Paths...", value = 0.6)
        # 2. 计算网络距离
        start_indices <- which(rownames(coords) %in% start_cells)
        if(length(start_indices) == 0) stop("No valid root cells found in the coordinate matrix.")
        # 计算所有细胞到起点的最短路径。由于起点是一个Cluster，我们取到任何一个起点细胞的最小距离
        dist_matrix <- igraph::distances(g, v = start_indices, to = igraph::V(g))
        pt <- apply(dist_matrix, 2, min)
        names(pt) <- rownames(coords)
        # 处理断网孤岛细胞 (Inf距离)
        finite_max <- max(pt[is.finite(pt)])
        pt[is.infinite(pt)] <- finite_max * 1.1 # 将孤岛细胞放到时间线最末端
        curve_out <- NULL # 图模型是发散的，我们不画单一主干曲线
      }
      # 统一将拟时序归一化到 0-1 之间 (用户体验更好)
      pt <- (pt - min(pt, na.rm=T)) / (max(pt, na.rm=T) - min(pt, na.rm=T))
      progress$set(message = "Saving Results...", value = 0.9)
      # 将结果存入底层对象
      obj$reductions$pseudotime <- list(
        pseudotime = pt,
        curve_coords = curve_out,  # Graph-based 时为 NULL
        dr_method = input$pseudo_dr_method,
        start_clus = input$pseudo_start_clus,
        group_col = input$pseudo_group_col,
        algorithm = input$pseudo_algorithm # 保存使用的算法
      )
      RNA_values$sci_object <- obj
      showNotification(paste("Trajectory Inference Completed via", toupper(input$pseudo_algorithm), "engine!"), type = "message")
    }, error = function(e) {
      showNotification(paste("Algorithm Error:", e$message), type = "error", duration = 8)
    })
  })

  # 5. 美观的拟时序绘图引擎
  output$pseudo_plot <- renderPlot({
    req(RNA_values$sci_object)
    obj <- RNA_values$sci_object
    if (is.null(obj$reductions$pseudotime)) {
      return(ggplot() + annotate("text", x = 0.5, y = 0.5, label = "No Trajectory Data.\nPlease run Infer Trajectory.", size = 6, color = "grey50") + theme_void())
    }
    pt_res <- obj$reductions$pseudotime
    dr_method <- pt_res$dr_method
    group_col <- pt_res$group_col
    algo <- pt_res$algorithm # 获取当前算法
    coords <- as.data.frame(obj$reductions[[dr_method]][, 1:2])
    colnames(coords) <- c("Dim1", "Dim2")
    coords$Pseudotime <- pt_res$pseudotime
    meta <- if(!is.null(obj$filter_meta.data)) obj$filter_meta.data else obj$meta.data
    if (!is.null(group_col) && group_col %in% colnames(meta)) {
      groups <- as.character(meta[rownames(coords), group_col])
      groups[is.na(groups) | groups == ""] <- "Unknown"
      coords$Cluster <- as.factor(groups)
    } else {
      coords$Cluster <- "All Cells"
    }
    # 通用主题设置
    my_theme <- theme_minimal(base_size = 15) +
      theme(
        plot.title = element_text(face = "bold", hjust = 0.5, size = 16, color = "#2c3e50"),
        axis.title = element_text(face = "bold", size = 13, color = "black"),
        axis.text = element_text(color = "black"),
        panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
        panel.border = element_rect(colour = "black", fill = NA, linewidth = 1.2),
        legend.position = "right"
      )
    sci_palette <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF",
                     "#F39B7FFF", "#8491B4FF", "#91D1C2FF", "#DC0000FF",
                     "#7E6148FF", "#B09C85FF", "#FF7F00", "#6A3D9A")
    # 计算起点聚类的中心点 (用于打上醒目的起始标记)
    root_cells <- coords[coords$Cluster == pt_res$start_clus, ]
    root_centroid <- data.frame(Dim1 = mean(root_cells$Dim1), Dim2 = mean(root_cells$Dim2))
    # 构建基础散点图
    p_left <- ggplot(coords, aes(x = Dim1, y = Dim2)) +
      geom_point(aes(color = Pseudotime), size = 2.5, alpha = 0.8, shape = 16) +
      scale_color_viridis_c(option = "plasma", name = "Pseudotime") +
      labs(title = paste("Pseudotime Gradient (", tools::toTitleCase(algo), ")", sep=""),
           x = paste0(toupper(dr_method), " 1"), y = paste0(toupper(dr_method), " 2")) +
      my_theme
    p_right <- ggplot(coords, aes(x = Dim1, y = Dim2)) +
      geom_point(aes(color = Cluster), size = 2.5, alpha = 0.8, shape = 16) +
      # scale_color_viridis_d(option = "turbo", name = group_col) +
      scale_fill_manual(values = sci_palette) +
      scale_color_manual(values = sci_palette) +
      labs(title = paste("Cluster (", group_col, ")", sep=""),
           x = paste0(toupper(dr_method), " 1"), y = "") +
      guides(color = guide_legend(override.aes = list(size = 4, alpha = 1))) +
      my_theme
    # 如果是 Cluster-based，叠加黑色主干曲线
    if (algo == "cluster" && !is.null(pt_res$curve_coords)) {
      curve_coords <- as.data.frame(pt_res$curve_coords)
      colnames(curve_coords) <- c("Dim1", "Dim2")
      curve_coords$pt <- pt_res$pseudotime
      curve_coords <- curve_coords[order(curve_coords$pt), ]
      p_left <- p_left + geom_path(data = curve_coords, aes(x = Dim1, y = Dim2), color = "black", linewidth = 1.5, arrow = arrow(type = "closed", length = unit(0.18, "inches"), ends = "last"))
      p_right <- p_right + geom_path(data = curve_coords, aes(x = Dim1, y = Dim2), color = "grey20", linewidth = 1, linetype = "dashed", alpha = 0.6)
    }
    # 统一打上起点标记 (黄底黑边大圆点)
    p_left <- p_left + geom_point(data = root_centroid, aes(x = Dim1, y = Dim2), shape = 21, fill = "#f1c40f", color = "black", size = 6, stroke = 1.5)
    p_right <- p_right + geom_point(data = root_centroid, aes(x = Dim1, y = Dim2), shape = 21, fill = "#f1c40f", color = "black", size = 6, stroke = 1.5)
    # 拼接图表
    combined_plot <- patchwork::wrap_plots(p_left, p_right, ncol = 2) +
      patchwork::plot_annotation(
        title = paste("Trajectory Inference via", tools::toTitleCase(algo), "Algorithm"),
        subtitle = paste("Rooted at:", pt_res$start_clus),
        theme = theme(plot.title = element_text(size = 20, face = "bold", hjust = 0.5), plot.subtitle = element_text(size = 15, color = "#7f8c8d", hjust = 0.5))
      )
    RNA_values$pseudo_plot_obj <- combined_plot
    return(combined_plot)
  })
  output$dl_pseudo_plot_pdf <- downloadHandler(
    filename = function() { paste0("Trajectory_Plot_", Sys.Date(), ".pdf") },
    content = function(file) {
      req(RNA_values$pseudo_plot_obj)
      # 将原来的 width = 8, height = 7 改为宽屏比例
      ggsave(file, plot = RNA_values$pseudo_plot_obj, width = 14, height = 6.5, device = "pdf")
    }
  )
  output$download_pseudo_data <- downloadHandler(
    filename = function() { paste0("Pseudotime_Data_", Sys.Date(), ".csv") },
    content = function(file) {
      req(RNA_values$sci_object$reductions$pseudotime)
      pt_res <- RNA_values$sci_object$reductions$pseudotime
      dr_method <- pt_res$dr_method
      coords <- as.data.frame(RNA_values$sci_object$reductions[[dr_method]][, 1:2])
      out_df <- data.frame(
        Cell_ID = rownames(coords),
        Dim_1 = coords[, 1],
        Dim_2 = coords[, 2],
        Pseudotime = pt_res$pseudotime
      )
      # 尝试加入用户的聚类/分组信息
      meta <- if(!is.null(RNA_values$sci_object$filter_meta.data)) RNA_values$sci_object$filter_meta.data else RNA_values$sci_object$meta.data
      group_col <- isolate(input$pseudo_group_col)
      if (!is.null(group_col) && group_col %in% colnames(meta)) {
        out_df$Cluster <- meta[out_df$Cell_ID, group_col]
      }
      data.table::fwrite(out_df, file, row.names = FALSE)
    }
  )



  # ---- Epigenome Analysis ----
  # ---- Epigenome Translation ----
  library(GenomicRanges)
  library(IRanges)
  library(future)
  library(future.apply)
  library(promises)
  library(parallel)
  # 核心数据容器：使用 List 存储两条命脉数据
  Epi_values <- reactiveValues(
    data_list = list(
      raw_matrix = NULL,
      qc_matrix = NULL
    ),
    qc_log_text = "System Initialized.\nWaiting for Data Aggregation and QC...",
    last_active_time = NULL,  # 【新增】：系统活跃时间戳，用于 2 分钟倒计时自毁
    # 【新增】：用于劫持和统一管理文件上传状态
    bismark_info = NULL,
    bed_info = NULL,
    # 【核心新增】：异步循环状态机
    agg_state = list(
      running = FALSE,
      batch_in_progress = FALSE, # 【新增】：防止重复派发任务的锁
      cluster_obj = NULL,  # 【核武器控制台】：保存后台物理进程的句柄
      current_batch = 1,
      total_batches = 0,
      batches = list(),
      results = list(),
      master_bed_gr = NULL,
      n_regions = 0,
      master_region_ids = NULL,
      progress = NULL
    )
  )

  # 【新增】：监听真实上传动作
  observeEvent(input$bismark_files, { Epi_values$bismark_info <- input$bismark_files })
  observeEvent(input$bed_file, { Epi_values$bed_info <- input$bed_file })

  # 步骤 1: 运行聚合 (Run Aggregation)
  observeEvent(input$btn_aggregate, {
    req(Epi_values$bismark_info, Epi_values$bed_info)
    shinyjs::hide("btn_aggregate")
    shinyjs::show("btn_stop_aggregate")
    shinyjs::disable("btn_reset_epi_assembly")
    showNotification("Initializing... Building memory indexes.", type = "warning")
    Epi_values$data_list$raw_matrix <- NULL
    gc(verbose = FALSE, reset = TRUE)
    n_cores <- input$num_threads
    tryCatch({
      # 【核心改变】：手动创建 PSOCK 集群，从而获得生杀大权！
      cl <- parallel::makePSOCKcluster(n_cores)
      Epi_values$agg_state$cluster_obj <- cl
      Epi_values$agg_state$worker_pids <- unlist(parallel::clusterEvalQ(cl, Sys.getpid()))
      plan(cluster, workers = cl) # 将 future 挂载到我们可控的集群上
      # 构建母本 GRanges (全局只做一次)
      bed_df <- fread(Epi_values$bed_info$datapath, select = 1:3, nThread = 1)
      setnames(bed_df, 1:3, c("chr", "start", "end"))
      bed_df[, region_id := paste0(chr, ":", start, "-", end)]
      Epi_values$agg_state$master_bed_gr <- GRanges(
        seqnames = bed_df$chr,
        ranges = IRanges(start = bed_df$start, end = bed_df$end)
      )
      Epi_values$agg_state$master_region_ids <- bed_df$region_id
      Epi_values$agg_state$n_regions <- length(Epi_values$agg_state$master_bed_gr)
      # 将文件切分为按核心数计算的多个批次 (Batches)
      n_files <- nrow(Epi_values$bismark_info)
      idx <- seq_len(n_files)
      batches <- split(idx, ceiling(seq_along(idx) / n_cores))
      Epi_values$agg_state$batches <- batches
      Epi_values$agg_state$total_batches <- length(batches)
      Epi_values$agg_state$current_batch <- 1
      Epi_values$agg_state$results <- list()
      # 启动原生进度条
      Epi_values$agg_state$progress <- shiny::Progress$new()
      Epi_values$agg_state$progress$set(message = paste('Fast Mapping on', n_cores, 'Cores...'), value = 0)
      # 激活后台引擎
      Epi_values$agg_state$running <- TRUE
      tic("Parallel Aggregation Time:")
    }, error = function(e) {
      showNotification(paste("Initialization Error:", e$message), type = "error")
      shinyjs::show("btn_aggregate"); shinyjs::hide("btn_stop_aggregate")
      if (!is.null(Epi_values$agg_state$cluster_obj)) {
        parallel::stopCluster(Epi_values$agg_state$cluster_obj)
      }
    })
  })

  # 3. 【核心技术】：真正的非阻塞异步循环引擎 (future + promises)
  observe({
    req(Epi_values$agg_state$running)
    # 【核心锁】：如果后台正在算当前批次，主线程就原地休息 100 毫秒，不派发新任务
    # 这就是保持主线程不被阻塞，随时能接收 Stop 信号的秘密！
    if (isTRUE(Epi_values$agg_state$batch_in_progress)) {
      invalidateLater(100, session)
      return()
    }
    state <- Epi_values$agg_state
    b_idx <- state$batches[[state$current_batch]]
    file_paths <- Epi_values$bismark_info$datapath[b_idx]
    file_names <- Epi_values$bismark_info$name[b_idx]
    # 提取局部变量传入后台
    local_master_gr <- state$master_bed_gr
    local_n_regions <- state$n_regions
    state$progress$set(
      detail = sprintf("Processing Batch %d / %d (Files %d to %d)...",
                       state$current_batch, state$total_batches, min(b_idx), max(b_idx)),
      value = (state$current_batch - 1) / state$total_batches
    )
    # 【上锁】：标记后台开始干活了
    Epi_values$agg_state$batch_in_progress <- TRUE
    # 将这批文件打包成多个独立的 future 任务
    p_list <- lapply(seq_along(file_paths), function(i) {
      f_path <- file_paths[i]
      f_name <- file_names[i]
      # 真正的异步分发 (主线程执行到这里瞬间完成，不会卡住)
      future({
        raw_name <- f_name
        cell_name <- gsub("\\.cov(\\.gz)?$|\\.bed(\\.gz)?$|\\.txt(\\.gz)?$|\\.csv$", "", raw_name, ignore.case = TRUE)
        cell_name <- gsub("[-_\\. ]+", ".", cell_name)
        cell_name <- gsub("^\\.|\\.$", "", cell_name)
        cov_df <- data.table::fread(f_path, select = c(1, 2, 5, 6), nThread = 1)
        data.table::setnames(cov_df, c("chr", "pos", "meth", "unmeth"))
        cov_gr <- GRanges(seqnames = cov_df$chr, ranges = IRanges(start = cov_df$pos, width = 1))
        hits <- findOverlaps(cov_gr, local_master_gr)
        hit_dt <- data.table::data.table(
          region_idx = subjectHits(hits),
          meth = cov_df$meth[queryHits(hits)],
          unmeth = cov_df$unmeth[queryHits(hits)]
        )
        agg <- hit_dt[, .(meth = sum(meth, na.rm=TRUE), unmeth = sum(unmeth, na.rm=TRUE)), by = region_idx]
        res_meth <- rep(NA_real_, local_n_regions)
        res_unmeth <- rep(NA_real_, local_n_regions)
        res_meth[agg$region_idx] <- agg$meth
        res_unmeth[agg$region_idx] <- agg$unmeth
        res_level <- res_meth / (res_meth + res_unmeth)
        res_level[is.nan(res_level)] <- NA_real_
        cell_vecs <- list(res_meth, res_unmeth, res_level)
        names(cell_vecs) <- c(paste0(cell_name, ".meth"), paste0(cell_name, ".nonmeth"), paste0(cell_name, ".level"))
        return(cell_vecs)
      }, seed = TRUE,
      packages = c("data.table", "GenomicRanges", "IRanges"),
      # 严格环境隔离，只带必要变量进后台
      globals = list(f_path = f_path, f_name = f_name, local_master_gr = local_master_gr, local_n_regions = local_n_regions))
    })
    # 【魔法汇聚】：等待这批任务全算完后，自动触发毁调函数 (主线程在此期间是自由的！)
    promises::promise_all(.list = p_list) %...>% (function(res_list) {
      # 拦截判断：如果在这等待期间，用户按下了 Stop 按钮 (running 变成 FALSE)
      # 就直接把算出来的结果扔进垃圾桶，什么也不做！
      if (!Epi_values$agg_state$running) {
        return()
      }
      # 如果没按 Stop，正常合并结果
      Epi_values$agg_state$results <- c(Epi_values$agg_state$results, res_list)
      # 检查是否全部批次完成
      if (Epi_values$agg_state$current_batch >= Epi_values$agg_state$total_batches) {
        Epi_values$agg_state$progress$set(value = 1, detail = "Finalizing Matrix...")
        flat_list <- unlist(Epi_values$agg_state$results, recursive = FALSE)
        final_list <- c(list(region_id = Epi_values$agg_state$master_region_ids), flat_list)
        final_dt <- setDT(final_list)
        Epi_values$data_list$raw_matrix <- as.data.frame(final_dt)
        updateRadioButtons(session, "view_data_type", selected = "raw")
        # 关停引擎
        Epi_values$agg_state$running <- FALSE
        Epi_values$agg_state$batch_in_progress <- FALSE
        Epi_values$agg_state$progress$close()
        plan(sequential)
        gc(verbose = FALSE, reset = TRUE)
        shinyjs::show("btn_aggregate"); shinyjs::hide("btn_stop_aggregate"); shinyjs::enable("btn_reset_epi_assembly")
        showNotification("Ultra-Fast Parallel Aggregation Complete!", type = "message", duration = 5)
        toc()
        Epi_values$last_active_time <- Sys.time()
      } else {
        # 还没完成，前往下一批次，【解锁引擎】
        Epi_values$agg_state$current_batch <- Epi_values$agg_state$current_batch + 1
        Epi_values$agg_state$batch_in_progress <- FALSE
      }
    }) %...!% (function(e) {
      # 【核心拦截】：如果是因为我们点击了 Stop 导致进程被杀（running == FALSE）
      # 这个错误是预期内的，我们直接默默吞掉它，什么也不干。
      if (!Epi_values$agg_state$running) {
        return()
      }
      # 如果 running 是 TRUE，说明是真的遇到了代码 Bug 导致的奔溃
      Epi_values$agg_state$running <- FALSE
      Epi_values$agg_state$batch_in_progress <- FALSE
      if (!is.null(Epi_values$agg_state$progress)) {
        try(Epi_values$agg_state$progress$close(), silent = TRUE)
        Epi_values$agg_state$progress <- NULL
      }
      if (!is.null(Epi_values$agg_state$cluster_obj)) {
        parallel::stopCluster(Epi_values$agg_state$cluster_obj)
        Epi_values$agg_state$cluster_obj <- NULL
      }
      plan(sequential)
      shinyjs::show("btn_aggregate"); shinyjs::hide("btn_stop_aggregate"); shinyjs::enable("btn_reset_epi_assembly")
      showNotification(paste("Error in background worker:", e$message), type = "error", duration = 10)
    })
  })

  observeEvent(input$btn_stop_aggregate, {
    # 1. 立即切断 UI 引擎状态，防止异步回调继续写入数据
    Epi_values$agg_state$running <- FALSE
    # 2. 【核心优化】：跨平台物理进程抹杀
    if (!is.null(Epi_values$agg_state$worker_pids)) {
      is_windows <- (.Platform$OS.type == "windows")
      for (pid in Epi_values$agg_state$worker_pids) {
        try({
          if (is_windows) {
            # Windows 环境：使用 taskkill /F (强制) /T (树状杀死子进程)
            # /PID 指定进程号，ignore.stdout 隐藏系统弹窗
            system(paste0("taskkill /F /PID ", pid), ignore.stdout = TRUE, ignore.stderr = TRUE)
          } else {
            # Linux/Mac 环境：沿用 SIGKILL
            tools::pskill(pid, tools::SIGTERM) # 尝试优雅结束
            tools::pskill(pid, tools::SIGKILL) # 强制物理抹杀
          }
        }, silent = TRUE)
      }
      Epi_values$agg_state$worker_pids <- NULL
    }
    # 3. 正常关闭 Socket 集群对象 (释放 R 句柄)
    if (!is.null(Epi_values$agg_state$cluster_obj)) {
      # 在 Windows 上，如果进程已经被 taskkill 杀掉，这里可能会报错，所以加 try
      try(parallel::stopCluster(Epi_values$agg_state$cluster_obj), silent = TRUE)
      Epi_values$agg_state$cluster_obj <- NULL
    }
    # 4. 安全关闭进度条
    if (!is.null(Epi_values$agg_state$progress)) {
      try(Epi_values$agg_state$progress$close(), silent = TRUE)
      Epi_values$agg_state$progress <- NULL
    }
    # 5. 清理内存和状态机
    Epi_values$agg_state$results <- list()
    Epi_values$agg_state$batch_in_progress <- FALSE
    # 强制将 plan 切回单线程，彻底销毁后台链路
    future::plan(future::sequential)
    # 连续执行两次 GC 确保内存被操作系统回收
    gc(verbose = FALSE, reset = TRUE)
    gc(verbose = FALSE, reset = TRUE)
    # 6. 恢复 UI 状态
    shinyjs::show("btn_aggregate")
    shinyjs::hide("btn_stop_aggregate")
    shinyjs::enable("btn_reset_epi_assembly")
    showNotification("Process Terminated! All workers killed and memory reclaimed.", type = "error", duration = 5)
  })

  # 步骤 2: 运行质控 (Run QC) - 严格遵循您的逻辑
  observeEvent(input$btn_run_qc, {
    tic("Epi run qc total time:")
    req(Epi_values$data_list$raw_matrix)
    withProgress(message = 'Performing Smart QC...', value = 0.5, {
      df_raw <- Epi_values$data_list$raw_matrix
      # 核心逻辑 1：提取纯粹的 .level 列用于计算 NA 比例
      level_cols <- grep("\\.level$", colnames(df_raw), value = TRUE)
      if(length(level_cols) == 0) {
        showNotification("Format Error: Could not find '.level' columns.", type="error")
        return()
      }
      # 纯粹的甲基化率矩阵 (用于统计计算)
      mat_level <- as.matrix(df_raw[, level_cols, drop = FALSE])
      total_rows <- nrow(mat_level)
      total_cells <- ncol(mat_level)
      # 阶段 1: 行质控 (Row QC) - 选出 Top N 区域
      row_na_counts <- rowSums(is.na(mat_level))
      ordered_row_indices <- order(row_na_counts)
      top_n <- min(input$qc_row_top_n, total_rows)
      keep_row_idx <- ordered_row_indices[1:top_n]
      # 【核心修改点 1】：基于选出的高质量行，构建子矩阵
      mat_level_subset <- mat_level[keep_row_idx, , drop = FALSE]
      # 阶段 2: 列质控 (Cell QC) - 基于子矩阵进行质控
      # 【核心修改点 2】：在子矩阵上计算 NA，分母变为 top_n
      col_na_ratios <- colSums(is.na(mat_level_subset)) / top_n
      keep_cell_level_names <- colnames(mat_level_subset)[col_na_ratios <= input$qc_col_na_thresh]
      if(length(keep_cell_level_names) == 0) {
        showNotification("QC Failed: All cells exceeded the max NA ratio threshold in the target regions!", type = "error")
        Epi_values$data_list$qc_matrix <- NULL
        return()
      }
      # 核心逻辑 2：映射回三列数据并提取
      base_kept_cells <- gsub("\\.level$", "", keep_cell_level_names)
      cols_to_keep <- c("region_id")
      for (cell in base_kept_cells) {
        cols_to_keep <- c(cols_to_keep, paste0(cell, ".meth"), paste0(cell, ".nonmeth"), paste0(cell, ".level"))
      }
      # 同时应用行过滤和列过滤到完整的原始 DataFrame
      df_qc <- df_raw[keep_row_idx, cols_to_keep, drop = FALSE]
      # 存入 List
      Epi_values$data_list$qc_matrix <- df_qc
      # --- 生成极其专业的日志 (微调了日志文案以反映新逻辑) ---
      raw_regions <- total_rows
      raw_cells <- total_cells
      qc_regions <- length(keep_row_idx)
      qc_cells <- length(base_kept_cells)
      # 动态计算过滤比例
      filtered_regions <- raw_regions - qc_regions
      filtered_cells <- raw_cells - qc_cells
      # 使用 HTML 构建高颜值终端显示效果
      log_html <- HTML(paste0(
        "<div style='background-color: #1E1E1E; color: #D4D4D4; padding: 15px; border-radius: 6px; font-family: \"Courier New\", Courier, monospace; font-size: 14px; box-shadow: inset 0 0 10px rgba(0,0,0,0.5); border: 1px solid #333;'>",
        # "<span style='color: #569CD6;'>root@scMATE</span>:<span style='color: #4EC9B0;'>~</span>$ cat /var/log/epigenome_qc.log<br><br>",
        "<span style='color: #CE9178;'>========== Epigenome QC Summary ==========</span><br>",
        # "<span style='color: #9CDCFE;'>Timestamp:</span> ", Sys.time(), "<br><br>",
        "<b style='color: #DCDCAA;'>[1] Architecture:</b><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> Data Structure : 3 metrics/cell (.meth, .nonmeth, .level)<br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> QC Logic       : Sequential (Row filtering -> Cell filtering)<br><br>",
        "<b style='color: #DCDCAA;'>[2] Parameters Applied:</b><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> Target Regions (Least NAs) : Top <span style='color: #B5CEA8; font-weight: bold;'>", input$qc_row_top_n, "</span><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> Max NA Ratio/Cell          : <span style='color: #B5CEA8; font-weight: bold;'>", (input$qc_col_na_thresh * 100), "%</span><br><br>",
        "<b style='color: #DCDCAA;'>[3] Feature Level (Genomic Regions):</b><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> Initial Input    : ", raw_regions, "<br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> <span style='color: #4EC9B0; font-weight: bold;'>Regions Retained : ", qc_regions, "</span><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> <span style='color: #F44336;'>Regions Filtered : ", filtered_regions, "</span><br><br>",
        "<b style='color: #DCDCAA;'>[4] Sample Level (Cells):</b><br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> Initial Input    : ", raw_cells, " (", raw_cells*3, " columns)<br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> <span style='color: #4EC9B0; font-weight: bold;'>Cells Retained   : ", qc_cells, "</span> (", qc_cells*3, " columns)<br>",
        "&nbsp;&nbsp;<span style='color: #569CD6;'>▶</span> <span style='color: #F44336;'>Cells Filtered   : ", filtered_cells, "</span><br><br>",
        "<span style='color: #CE9178;'>==========================================</span><br>",
        "<span style='color: #4EC9B0; font-weight: bold;'>> STATUS: SUCCESS. Matrix is ready for downstream analysis. </span><span class='blink'>_</span>",
        "</div>",
        # 增加光标闪烁的动画效果CSS
        "<style>.blink { animation: blinker 1s linear infinite; } @keyframes blinker { 50% { opacity: 0; } }</style>"
      ))
      Epi_values$qc_log_text <- log_html
      updateRadioButtons(session, "view_data_type", selected = "qc")
      showNotification(paste0("QC Complete! Retained ", qc_regions, " regions and ", qc_cells, " cells."), type = "message")
      Epi_values$last_active_time <- Sys.time()
      showNotification("Timer reset: You have another 30 minutes before auto-cleanup.", type = "message", duration = 5)
    })
    toc()
  })

  # 【大厂级核心防御 5】：后台死神监听器 (Background Grim Reaper Daemon)
  # 功能：监控内存存活时间。如果闲置超过 120 秒 (2分钟)，强制引爆并清理所有资源
  observe({
    # 只有当系统里有数据（时间戳不为空）时，监听器才启动
    req(Epi_values$last_active_time)
    # 每 10 秒唤醒一次这个代码块 (非阻塞主线程)
    invalidateLater(10000, session)
    # 计算距离最后一次操作过去了多少秒
    time_elapsed <- as.numeric(difftime(Sys.time(), Epi_values$last_active_time, units = "secs"))
    # 设定超时时间：1800 秒
    if (time_elapsed >= 1800) {
      # 1. 斩断数据血缘
      Epi_values$data_list$raw_matrix <- NULL
      Epi_values$data_list$qc_matrix <- NULL
      Epi_values$last_active_time <- NULL # 关闭监听器
      # 2. 更改 UI 提示日志
      Epi_values$qc_log_text <- " SESSION TIMEOUT \n\nAll data and memory caches have been forcefully cleared to protect server stability due to 30 minutes of inactivity.\n\nPlease re-upload your files if you wish to continue."
      updateRadioButtons(session, "view_data_type", selected = "raw")
      # 3. 极深层物理内存清理 (和手动 Reset 一样的最强力度)
      future::plan(future::sequential)
      objs_to_rm <- ls(pattern = "^res_|^flat_|^bed_|^final_|^master_")
      if (length(objs_to_rm) > 0) rm(list = objs_to_rm, envir = environment())
      gc(verbose = FALSE, reset = TRUE, full = TRUE)
      gc(verbose = FALSE, reset = TRUE, full = TRUE)
      # 4. 弹出红色警报给用户
      showNotification("Auto-Cleanup Triggered! All memory & threads forcefully released due to inactivity.",
                       type = "error", duration = 15)
    }
  })

  # 动态渲染质控统计信息
  output$epi_qc_log_html <- renderUI({
    # 如果还没有数据，给一个默认的等待提示面板
    if (Epi_values$qc_log_text == "System Initialized.\nWaiting for Data Aggregation and QC...") {
      HTML(paste0(
        "<div style='background-color: #1E1E1E; color: #6A9955; padding: 15px; border-radius: 6px; font-family: monospace; font-size: 14px;'>",
        "> System Initialized.<br>> Waiting for Data Aggregation and QC...<span class='blink'>_</span>",
        "</div>",
        "<style>.blink { animation: blinker 1s linear infinite; } @keyframes blinker { 50% { opacity: 0; } }</style>"
      ))
    } else {
      # 渲染真正的质控日志
      Epi_values$qc_log_text
    }
  })

  # 数据展示 & 下载逻辑
  # 动态获取当前需要展示的数据
  current_display_data <- reactive({
    if (input$view_data_type == "raw") {
      return(Epi_values$data_list$raw_matrix)
    } else {
      return(Epi_values$data_list$qc_matrix)
    }
  })

  # 渲染表格
  output$epi_data_table <- renderDT({
    df <- current_display_data()
    req(df)
    datatable(df, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE)
  })
  # 渲染下载按钮
  output$epi_download_ui <- renderUI({
    df <- current_display_data()
    req(df)
    label <- ifelse(input$view_data_type == "raw", "Download Raw Matrix (.csv)", "Download QC Matrix (.csv)")
    downloadButton("btn_download_epi", label, class = "btn-success")
  })
  # 执行下载
  output$btn_download_epi <- downloadHandler(
    filename = function() {
      paste0("Epigenome_", input$view_data_type, "_matrix_", Sys.Date(), ".csv")
    },
    content = function(file) {
      data.table::fwrite(current_display_data(), file, row.names = FALSE)
    }
  )

  # 【新增】：Use Example 按钮逻辑
  observeEvent(input$btn_use_example_epi, {
    # 启动进度条
    withProgress(message = 'Loading Example Data...', value = 0, {
      incProgress(0.1, detail = "Locating BED file...")
      # 请修改此处路径：指向您服务器上存放样例 BED 的实际路径
      bed_path <- "data/mm10_genetss2k_choose30000.csv"
      incProgress(0.2, detail = "Scanning cov.gz files...")
      # 请修改此处路径：指向您服务器上存放样例 cov.gz 的文件夹路径
      cov_dir <- "data/cov_data"
      cov_files <- list.files(cov_dir, pattern = "\\.cov(\\.gz)?$", full.names = TRUE)
      # 严密的防崩溃检查
      if (!file.exists(bed_path)) {
        showNotification("Error: Example BED file not found on server.", type = "error")
        return()
      }
      if (length(cov_files) == 0) {
        showNotification("Error: No .cov.gz files found in example directory.", type = "error")
        return()
      }
      # 因为 cov 文件过多，生成动态扫描进度条
      n_cov <- length(cov_files)
      for (i in seq_len(n_cov)) {
        incProgress(0.2 + (0.7 * i / n_cov), detail = sprintf("Reading file %d / %d: %s", i, n_cov, basename(cov_files[i])))
        Sys.sleep(0.01) # 微小延迟，防止服务器 SSD 读太快导致进度条一闪而过
      }
      incProgress(0.95, detail = "Mounting data to UI...")
      # 1. 构造伪造的 fileInput 数据框，挂载到全局变量
      Epi_values$bismark_info <- data.frame(
        name = basename(cov_files),
        size = file.info(cov_files)$size,
        type = "application/gzip",
        datapath = cov_files,
        stringsAsFactors = FALSE
      )
      Epi_values$bed_info <- data.frame(
        name = basename(bed_path),
        size = file.info(bed_path)$size,
        type = "text/plain",
        datapath = bed_path,
        stringsAsFactors = FALSE
      )
      # 2. 【核心黑科技】：使用 shinyjs 强行修改前端 input 框的显示文字
      # 完全遵照您的要求：Bismark前端显示 example_region_data，BED前端显示 example_cov
      shinyjs::runjs('
      $("#bismark_files").closest(".input-group").find("input[type=\'text\']").val("example_region_data (Multiple Files Loaded)");
      $("#bed_file").closest(".input-group").find("input[type=\'text\']").val("example_cov.bed");
    ')
      incProgress(1, detail = "Ready!")
      showNotification("Example data loaded! You can now click 'Run Aggregation'.", type = "message", duration = 5)
    })
  })

  # 步骤 0: 一键重置 (Reset Data & Inputs)
  observeEvent(input$btn_reset_epi_assembly, {
    showModal(modalDialog(
      title = span(icon("exclamation-triangle"), " Warning: Destructive Action", style = "color: red;"),
      "This will permanently delete all uploaded Bismark files, BED files, aggregated matrices, and QC results from RAM. Are you sure you want to reset the system?",
      footer = tagList(
        modalButton("Cancel"),
        actionButton("confirm_reset_epi", "Yes, Clear Everything", class = "btn-danger", icon = icon("trash-alt"))
      )
    ))
  })

  # 2. 用户点击确认后，执行真正的核弹级清理逻辑
  observeEvent(input$confirm_reset_epi, {
    removeModal() # 关闭弹窗
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Executing Deep System Purge...", value = 0.3)
    # 【第一层：斩断数据血缘与后台定时器】
    # 将包含几十个 GB 的矩阵彻底置空，切断 R 的底层指针
    Epi_values$data_list$raw_matrix <- NULL
    Epi_values$data_list$qc_matrix <- NULL
    # ★ 极其关键：切断你写的 2 分钟自毁定时器，否则后台会一直报错
    Epi_values$last_active_time <- NULL
    # 【新增】：彻底清空代理的文件状态
    Epi_values$bismark_info <- NULL
    Epi_values$bed_info <- NULL
    # 降维模块重置
    DR_values$group_raw <- NULL
    DR_values$plot_obj <- NULL
    DR_values$coord_df <- NULL
    DR_values$ridge_obj <- NULL
    DR_values$ridge_df <- NULL
    DR_values$unlink_step1 <- NULL
    # DR_values <- reactiveValues(
    #   group_raw = NULL,
    #   plot_obj = NULL,
    #   coord_df = NULL,
    #   ridge_obj = NULL,     # 新增：存储山脊图对象
    #   ridge_df = NULL,      # 新增：存储山脊图后台数据
    #   unlink_step1 = FALSE  # 新增：用于拦截 Step1 数据的软断开标志
    # )
    progress$set(message = "Resetting UI Inputs...", value = 0.5)
    # 【第二层：彻底清空前端所有输入与参数】
    # 1. 重置文件上传组件 (需要 UI 中包含 shinyjs::useShinyjs())
    try({
      shinyjs::reset("epi_upload_ui")
    }, silent = TRUE)
    # 2. 将滑块和数字输入框恢复到默认出厂设置
    updateSliderInput(session, "num_threads", value = min(4, max(1, parallel::detectCores() - 2)))
    updateNumericInput(session, "qc_row_top_n", value = 2000)
    updateSliderInput(session, "qc_col_na_thresh", value = 0.80)
    # 3. 恢复右侧数据表格的日志与单选按钮
    Epi_values$qc_log_text <- "System Initialized.\nWaiting for Data Aggregation and QC..."
    updateRadioButtons(session, "view_data_type", selected = "raw")
    progress$set(message = "Annihilating Ghost Processes...", value = 0.7)
    # 【第三层：绞杀后台并行僵尸进程】
    # 强制关闭并销毁任何还在后台挂起的 future/multisession 进程池，强迫它们把吃掉的 RAM 吐出来
    future::plan(future::sequential)
    progress$set(message = "Reclaiming Physical RAM...", value = 0.9)
    # 【第四层：极深层物理内存清理】
    # 搜索并删除当前 Session 环境下可能残留的临时大变量
    objs_to_rm <- ls(pattern = "^res_|^flat_|^bed_|^final_|^master_")
    if (length(objs_to_rm) > 0) {
      suppressWarnings(rm(list = objs_to_rm, envir = environment()))
    }
    # 连续执行两次强力 GC (Garbage Collection)
    # 第一次标记可达对象，第二次清扫垃圾并重置内存高水位线 (High-water mark)
    gc(verbose = FALSE, reset = TRUE, full = TRUE)
    gc(verbose = FALSE, reset = TRUE, full = TRUE)
    progress$set(message = "System Restored", value = 1)
    # 【第五层：用户反馈】
    showNotification("Complete Reset Successful: All inputs cleared, memory reclaimed, and system restored to default state.",
                     type = "warning", duration = 8)
  })

  # 独立模块：表观组 Download Example 数据流 (Zero-CPU 直传机制)
  output$btn_dl_example_epi <- downloadHandler(
    filename = function() {
      # 用户下载到本地时的专业命名，附带日期戳
      paste0("scMATE_Epi_Example_Data_", Sys.Date(), ".zip")
    },
    content = function(file) {
      # 【需要您配置的唯一参数】：指向您服务器上那个已经打包好的 zip 文件
      # 假设您把它放在了项目根目录下的 example_data 文件夹里
      existing_zip_path <- "data/Epi_example_data.zip"
      # 极客级前置防御：检查文件是否存在，防止应用崩溃
      if (!file.exists(existing_zip_path)) {
        showNotification("Error: The example ZIP file is missing on the server! Please contact administrator.",
                         type = "error", duration = 8)
        stop("Server-side missing file error.")
      }
      # 【核心大厂级操作】：不消耗任何 CPU 算力，直接通过 file.copy 将二进制流推给前端
      file.copy(existing_zip_path, file)
    },
    contentType = "application/zip" # 明确告诉浏览器这是一个 ZIP 文件
  )
  # 结果概览 (自动读取自定义对象)
  # 1. 细胞/样本数统计 (冰川淡蓝系)
  output$sample_count_box <- renderValueBox({
    num <- 0
    box_title <- "Uploaded Files"
    box_icon <- "file-upload"
    if (!is.null(Epi_values$data_list$qc_matrix)) {
      # 质控完成：计算保留的细胞数
      num <- (ncol(Epi_values$data_list$qc_matrix) - 1) / 3
      box_title <- "QC Passed Cells"
      box_icon <- "user-check"
    } else if (!is.null(input$bismark_files)) {
      # 仅上传了文件
      num <- nrow(input$bismark_files)
    }
    # 注入淡蓝色系 CSS 并锁定高度为 115px
    custom_css <- tags$style(HTML("
      #sample_count_box .small-box { height: 115px !important; background-color: #F0F8FF !important; color: #1E3A8A !important;
                                     border-left: 5px solid #3B82F6 !important; border-radius: 8px !important;
                                     box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #sample_count_box .small-box .icon-large { color: #93C5FD !important; opacity: 0.4; }
      #sample_count_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }
    "))
    valueBox(
      value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #1D4ED8;", format(num, big.mark = ","))),
      subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #3B82F6;", box_title),
      icon = icon(box_icon), color = "aqua"
    )
  })
  # 2. 统计输入的区域数 (薄荷淡绿系)
  output$region_count_box <- renderValueBox({
    num <- 0
    box_title <- "Target Regions"
    box_icon <- "dna"
    if (!is.null(Epi_values$data_list$qc_matrix)) {
      # 质控完成
      num <- nrow(Epi_values$data_list$qc_matrix)
      box_title <- "QC Passed Regions"
      box_icon <- "filter"
    } else if (!is.null(Epi_values$data_list$raw_matrix)) {
      # 聚合完成
      num <- nrow(Epi_values$data_list$raw_matrix)
    } else if (!is.null(input$bed_file)) {
      # 仅上传文件，防卡顿
      num <- "Ready"
      box_icon <- "upload"
    }
    # 判断 num 是数字还是 "Ready" 字符，再决定是否加千分位
    val_display <- if(is.numeric(num)) format(num, big.mark = ",") else num
    # 注入淡绿色系 CSS 并锁定高度为 115px
    custom_css <- tags$style(HTML("
      #region_count_box .small-box { height: 115px !important; background-color: #F0FDF4 !important; color: #14532D !important;
                                     border-left: 5px solid #22C55E !important; border-radius: 8px !important;
                                     box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #region_count_box .small-box .icon-large { color: #86EFAC !important; opacity: 0.4; }
      #region_count_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }
    "))
    valueBox(
      value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #15803D;", val_display)),
      subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #16A34A;", box_title),
      icon = icon(box_icon), color = "green"
    )
  })
  # 3. 统计 QC 质控状态 (智能动态变色系)
  output$qc_status_box <- renderValueBox({
    if (!is.null(Epi_values$data_list$qc_matrix)) {
      # 状态 C: 质控已通过 (高级鸢尾紫，代表数据处理成功)
      status_text <- "Passed"
      subtitle_text <- "QC Filter Applied"
      bg_color <- "#FAF5FF" ; border_color <- "#A855F7" ; text_color <- "#6B21A8" ; icon_color <- "#D8B4FE"
      box_icon <- "check-circle"
    } else if (!is.null(Epi_values$data_list$raw_matrix)) {
      # 状态 B: 聚合完毕，准备好质控 (青绿色/Teal，提示用户可以点QC按钮了)
      status_text <- "Ready"
      subtitle_text <- "Awaiting QC Setup"
      bg_color <- "#F0FDFA" ; border_color <- "#14B8A6" ; text_color <- "#0F766E" ; icon_color <- "#99F6E4"
      box_icon <- "play-circle"
    } else {
      # 状态 A: 啥也没有 (警示浅黄色)
      status_text <- "Pending"
      subtitle_text <- "Awaiting Data"
      bg_color <- "#FEFCE8" ; border_color <- "#EAB308" ; text_color <- "#A16207" ; icon_color <- "#FDE047"
      box_icon <- "hourglass-half"
    }
    # 动态注入配色，并锁定高度为 115px 防变形
    custom_css <- tags$style(HTML(sprintf("
      #qc_status_box .small-box { height: 115px !important; background-color: %s !important; border-left: 5px solid %s !important;
                                  border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; }
      #qc_status_box .small-box .icon-large { color: %s !important; opacity: 0.4; }
      #qc_status_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }
    ", bg_color, border_color, icon_color)))
    valueBox(
      value = tagList(
        custom_css,
        tags$span(style = sprintf("font-weight: 800; font-size: 30px; color: %s;", text_color), status_text)
      ),
      subtitle = tags$span(style = sprintf("font-weight: 600; font-size: 15px; color: %s;", text_color), subtitle_text),
      icon = icon(box_icon), color = "yellow"
    )
  })


  # ---- Epigenome Dim Reduction ----
  # Step 2: Epigenome Dimension Reduction Server Logic
  DR_values <- reactiveValues(
    group_raw = NULL,
    plot_obj = NULL,
    coord_df = NULL,
    ridge_obj = NULL,     # 新增：存储山脊图对象
    ridge_df = NULL,      # 新增：存储山脊图后台数据
    unlink_step1 = FALSE  # 新增：用于拦截 Step1 数据的软断开标志
  )

  observeEvent(Epi_values$data_list$qc_matrix, {
    DR_values$unlink_step1 <- FALSE # 一旦 Step 1 有新数据，立刻解除软断开，恢复绿框
  }, ignoreNULL = FALSE)

  # --- 1. 严格的智能数据路由 (Smart Data Routing) ---
  output$dr_matrix_source_ui <- renderUI({
    # 核心修改：增加 isFALSE(DR_values$unlink_step1)
    if (!is.null(Epi_values$data_list$qc_matrix) && isFALSE(DR_values$unlink_step1)) {
      div(
        style = "padding: 10px; background-color: #d4edda; color: #155724; border-radius: 5px; border: 1px solid #c3e6cb;",
        icon("check-circle"), tags$b(" Linked to Step 1 (QC Data)"), br(),
        paste("Ready: ", nrow(Epi_values$data_list$qc_matrix), "Regions")
      )
    } else {
      # 否则（不管是原始数据还是空数据，或者被手动Reset了），强制手动上传
      div(
        style = "padding: 10px; background-color: #fff3cd; color: #856404; border-radius: 5px; border: 1px solid #ffeeba;",
        icon("upload"), tags$b(" Manual Matrix Upload"), br(),
        "QC data from Step 1 not found. Please upload a matrix.",
        fileInput("dr_external_matrix", label = NULL, accept = c(".csv"))
      )
    }
  })

  # 【新增/修改】：手动上传矩阵后，反向同步至 Step 1 (Matrix Assembly & QC)

  observeEvent(input$dr_external_matrix, {
    req(input$dr_external_matrix$datapath)
    withProgress(message = 'Parsing manual matrix and syncing to Step 1...', value = 0.5, {
      file_path <- input$dr_external_matrix$datapath
      # 1. 完整读取上传的数据矩阵 (保留行/列名)
      df_manual <- data.table::fread(file_path, data.table = FALSE)
      # 2. 【核心注入】：赋给 Step 1 的 raw_matrix
      # 这会直接驱动 Step 1 中的 "Raw Aggregated Data" 表格动态显示本数据
      Epi_values$data_list$raw_matrix <- df_manual
      # 3. 同时初始化/同步给 qc_matrix
      # 这样当前页面（降维）可以直接识别并使用，不会报缺失错误
      Epi_values$data_list$qc_matrix <- df_manual
      # 4. 软断开 Step 1 的自动覆盖标记（保持手动上传数据的独立性）
      DR_values$unlink_step1 <- TRUE
      # 5. 更新 Step 1 质控控制台的终端输出日志，给用户明确提示
      Epi_values$qc_log_text <- paste0(
        "--------------------------------------------------\n",
        "[Info] Manual Matrix loaded from Dim Reduction module!\n",
        "--------------------------------------------------\n",
        "Total Target Regions (Rows) : ", nrow(df_manual), "\n",
        "Total Samples / Cells (Cols): ", ncol(df_manual), "\n\n",
        "Status: Data is now available in 'Raw Aggregated Data'.\n",
        "You can configure filtering parameters and click [Run QC],\n",
        "or switch directly to Step 2 for Dimensional Reduction."
      )
      showNotification(
        "Manual Matrix loaded! Synced to Step 1 (Raw Aggregated Data) and ready for QC.",
        type = "message"
      )
    })
  })

  # --- 2. 动态获取活跃矩阵 ---
  get_active_matrix <- reactive({
    # if (!is.null(Epi_values$data_list$qc_matrix) && isFALSE(DR_values$unlink_step1)) {
    #   return(Epi_values$data_list$qc_matrix)
    # } else {
    #   req(input$dr_external_matrix)
    #   return(data.table::fread(input$dr_external_matrix$datapath, data.table = FALSE))
    # }
    # 优先获取 qc_matrix（如果是手动上传，上面的 observeEvent 已经同步注入了）
    if (!is.null(Epi_values$data_list$qc_matrix)) {
      return(Epi_values$data_list$qc_matrix)
    }
    return(NULL)
  })

  # --- 3. 读取 Metadata 与 Sheet 选择逻辑 ---
  output$dr_sheet_ui <- renderUI({
    req(input$dr_group_file)
    ext <- tools::file_ext(input$dr_group_file$name)
    if(ext == "xlsx") {
      sheets <- tryCatch(readxl::excel_sheets(input$dr_group_file$datapath), error = function(e) NULL)
      req(sheets)
      selectInput("dr_sheet_name", "Select Excel Sheet:", choices = sheets, selected = sheets[1])
    }
  })

  observe({
    req(input$dr_group_file)
    ext <- tools::file_ext(input$dr_group_file$name)
    tryCatch({
      if(ext == "xlsx") {
        req(input$dr_sheet_name)
        DR_values$group_raw <- readxl::read_excel(input$dr_group_file$datapath, sheet = input$dr_sheet_name)
      } else {
        DR_values$group_raw <- data.table::fread(input$dr_group_file$datapath, data.table = FALSE)
      }
    }, error = function(e){
      showNotification("Error reading metadata file.", type = "error")
    })
  })

  output$dr_column_selectors <- renderUI({
    req(DR_values$group_raw)
    cols <- colnames(DR_values$group_raw)
    tagList(
      selectInput("dr_col_sample", "Select Sample ID Column:", choices = cols, selected = "level"),
      selectInput("dr_col_group", "Select Group Column:", choices = c("",cols), selected = "")
    )
  })

  # --- 4. 核心计算与绘图逻辑 (含智能模糊匹配) ---
  observeEvent(input$dr_btn_run, {
    tic("Epi dim reduction total time:")
    raw_df <- get_active_matrix()
    req(raw_df, DR_values$group_raw, input$dr_col_sample, input$dr_col_group)
    withProgress(message = 'Running Dimension Reduction...', value = 0.1, {
      tryCatch({
        # 步骤 A: 提取矩阵与列名处理
        incProgress(0.1, detail = "Formatting Matrix...")
        rownames(raw_df) <- raw_df[[1]]
        # 提取 .level 列 (如果存在)
        level_cols <- grep("\\.level$", colnames(raw_df), value = TRUE)
        if (length(level_cols) > 0) {
          meth_mat <- as.matrix(raw_df[, level_cols, drop = FALSE])
        } else {
          meth_mat <- as.matrix(raw_df[, -1, drop = FALSE])
        }
        # 步骤 B: 终极智能样本匹配 (Smart Fuzzy Matching)
        meta_data <- data.frame(
          RawSampleID = as.character(DR_values$group_raw[[input$dr_col_sample]]),
          Group = as.character(DR_values$group_raw[[input$dr_col_group]]),
          stringsAsFactors = FALSE
        )
        # 核心清洗函数：剥离所有可能的后缀和特殊符号
        smart_clean <- function(x) {
          x <- gsub("\\.level$", "", x, ignore.case = TRUE)
          x <- gsub("\\.meth$", "", x, ignore.case = TRUE)
          x <- gsub("\\.nonmeth$", "", x, ignore.case = TRUE)
          x <- gsub("\\.cov$", "", x, ignore.case = TRUE)
          x <- gsub("\\.gz$", "", x, ignore.case = TRUE)
          x <- gsub("[-_ ]", ".", x)
          x <- gsub("\\.+", ".", x)
          x <- gsub("^\\.|\\.$", "", x)
          return(x)
        }
        mat_clean_names <- smart_clean(colnames(meth_mat))
        meta_clean_names <- smart_clean(meta_data$RawSampleID)
        colnames(meth_mat) <- mat_clean_names
        meta_data$CleanID <- meta_clean_names
        common_samples <- intersect(meta_data$CleanID, colnames(meth_mat))
        if(length(common_samples) < 3) {
          stop(paste0("Sample Match Error!\nMatrix: ", paste(head(mat_clean_names, 3), collapse=","),
                      "\nMetadata: ", paste(head(meta_clean_names, 3), collapse=",")))
        }
        # 对齐数据
        meth_mat <- meth_mat[, common_samples, drop = FALSE]
        meta_data <- meta_data[match(common_samples, meta_data$CleanID), ]
        meta_data$SampleID <- meta_data$CleanID
        # 步骤 C: 缺失值填充 (Imputation)
        incProgress(0.3, detail = "Imputing Missing Values...")
        if(any(is.na(meth_mat))) {
          if(input$dr_impute_method == "knn") {
            if(!requireNamespace("impute", quietly = TRUE)) stop("Please install 'impute' R package.")
            meth_mat <- impute::impute.knn(meth_mat, k = input$dr_knn_k)$data
          } else {
            row_means <- rowMeans(meth_mat, na.rm = TRUE)
            idx_na <- which(is.na(meth_mat), arr.ind = TRUE)
            meth_mat[idx_na] <- row_means[idx_na[, 1]]
          }
        }
        # 步骤 D: 降维算法运行
        plot_title <- input$dr_method
        x_lab <- paste0(input$dr_method, " 1")
        y_lab <- paste0(input$dr_method, " 2")
        if(input$dr_method == "PCA") {
          pca_res <- prcomp(t(meth_mat), center = TRUE, scale. = FALSE)
          var_exp <- pca_res$sdev^2 / sum(pca_res$sdev^2)
          coords <- data.frame(SampleID = rownames(pca_res$x), Dim1 = pca_res$x[,1], Dim2 = pca_res$x[,2])
          # 覆盖默认标签
          x_lab <- paste0("PC1 (", round(var_exp[1]*100, 1), "%)")
          y_lab <- paste0("PC2 (", round(var_exp[2]*100, 1), "%)")
          plot_title <- "PCA"
        } else if(input$dr_method == "UMAP") {
          n_samples <- ncol(meth_mat)
          safe_n_neighbors <- min(input$dr_umap_neighbors, n_samples - 1)
          if(safe_n_neighbors < 2) safe_n_neighbors <- 2 # 强制兜底，防止极少样本时 C++ 底层报错
          umap_matrix <- uwot::umap(
            X = t(meth_mat),
            n_neighbors = safe_n_neighbors,
            min_dist = input$dr_umap_dist,
            n_threads = 1, # Web Server 核心原则：限制单任务线程数，防止某用户卡死整个服务器 CPU
            pca = NULL     # 默认不提前做 PCA，直接算距离矩阵
          )
          coords <- data.frame(SampleID = colnames(meth_mat),
                               Dim1 = umap_matrix[,1],
                               Dim2 = umap_matrix[,2])
          # 使用默认的 UMAP 1, UMAP 2 作为标签
        } else if(input$dr_method == "MDS") {
          dist_mat <- as.dist(1 - cor(meth_mat, method = input$dr_mds_dist_method, use = "pairwise.complete.obs"))
          mds_res <- cmdscale(dist_mat, k = 2)
          coords <- data.frame(SampleID = rownames(mds_res), Dim1 = mds_res[,1], Dim2 = mds_res[,2])
          # 使用默认的 MDS 1, MDS 2 作为标签
        } else if (input$dr_method == "NMF") {
          # 检查包
          if(!requireNamespace("NMF", quietly = TRUE)) stop("Package 'NMF' is required. Please install it.")
          # 检查非负性
          if(min(meth_mat, na.rm = TRUE) < 0) stop("NMF requires non-negative data. Your matrix contains negative values.")
          nmf_rank <- input$dr_nmf_rank
          # NMF 计算 (注意：meth_mat 行是 Features，列是 Samples，符合 NMF 输入要求)
          res <- NMF::nmf(meth_mat, rank = nmf_rank, seed = "random")
          # 提取系数矩阵 H (Rank x Samples)，并转置得到 (Samples x Rank)
          h_mat <- t(NMF::coef(res))
          coords <- data.frame(SampleID = rownames(h_mat), Dim1 = h_mat[,1], Dim2 = h_mat[,2])
          x_lab <- "Basis 1"
          y_lab <- "Basis 2"
          plot_title <- paste0("NMF (Rank=", nmf_rank, ")")
        }
        # else if (input$dr_method == "PLS-DA") {
        #   # 检查包
        #   if(!requireNamespace("mixOmics", quietly = TRUE)) stop("Package 'mixOmics' is required. Please install via BiocManager.")
        #   # 准备数据: X 需要转置为 (Samples x Features)
        #   X <- t(meth_mat)
        #   # Y: 响应变量 (基于清洗对齐后的 meta_data$Group)
        #   Y <- as.factor(meta_data$Group)
        #   # 检查 Y 的水平数
        #   if(length(levels(Y)) < 2) stop("PLS-DA requires at least 2 different groups.")
        #   # 运行 PLS-DA
        #   plsda_res <- mixOmics::plsda(X, Y, ncomp = input$dr_plsda_ncomp)
        #   # 提取 variates (坐标)
        #   plsda_coords <- plsda_res$variates$X
        #   coords <- data.frame(SampleID = rownames(plsda_coords), Dim1 = plsda_coords[,1], Dim2 = plsda_coords[,2])
        #   x_lab <- paste0("Component 1 (", round(plsda_res$prop_expl_var$X[1] * 100, 1), "%)")
        #   y_lab <- paste0("Component 2 (", round(plsda_res$prop_expl_var$X[2] * 100, 1), "%)")
        #   plot_title <- "PLS-DA"
        # }
        # 步骤 E: 绘图与数据保存
        incProgress(0.2, detail = "Generating Publication-Quality Plot...")
        plot_df <- merge(coords, meta_data, by = "SampleID")
        DR_values$coord_df <- plot_df
        # 1. 定义经典的科研配色体系 (Nature Publishing Group 风格)
        sci_palette <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF",
                         "#F39B7FFF", "#8491B4FF", "#91D1C2FF", "#DC0000FF",
                         "#7E6148FF", "#B09C85FF", "#FF7F00", "#6A3D9A")
        # 2. 判断是否每个分组都有至少3个样本 (少于3个样本画椭圆会报错)
        group_counts <- table(plot_df$Group)
        can_draw_ellipse <- all(group_counts >= 3) && length(group_counts) > 1
        # 3. 基础图层构建
        p <- ggplot(plot_df, aes(x = Dim1, y = Dim2, fill = Group, color = Group)) +
          # 辅助线：添加 x=0 和 y=0 的原点虚线 (放在最底层)
          geom_hline(yintercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.5) +
          geom_vline(xintercept = 0, linetype = "dashed", color = "gray60", linewidth = 0.5)
        # 4. 智能添加置信椭圆 (仅当样本量足够时)
        if (can_draw_ellipse) {
          p <- p +
            stat_ellipse(level = 0.95, geom = "polygon", alpha = 0.1, show.legend = FALSE, color = NA) + # 带有透明底色的多边形
            stat_ellipse(level = 0.95, geom = "path", linewidth = 0.8, linetype = 2, show.legend = FALSE) # 虚线边界
        }
        # 5. 添加带有白色描边的高级散点图 (放在椭圆之上)
        p <- p +
          geom_point(size = 4.5, alpha = 0.9, shape = 21, stroke = 0.6, color = "white") +
          # 坐标轴与标题
          labs(x = x_lab, y = y_lab, title = plot_title) +
          # 应用科研配色
          scale_fill_manual(values = sci_palette) +
          scale_color_manual(values = sci_palette) +
          # 6. 高级精美主题设置 (类似 theme_classic 但带有全包围边框)
          theme_bw(base_size = 15) +
          theme(
            plot.title = element_text(hjust = 0.5, face = "bold", size = 18, margin = margin(b = 15)),
            axis.title.x = element_text(face = "bold", margin = margin(t = 10)),
            axis.title.y = element_text(face = "bold", margin = margin(r = 10)),
            axis.text = element_text(color = "black", size = 12),
            # 图例美化
            legend.position = "right",
            legend.title = element_text(face = "bold", size = 14),
            legend.text = element_text(size = 13),
            legend.background = element_rect(fill = "transparent", color = NA),
            legend.key = element_blank(),
            # 边框与网格线控制 (去除内部网格，保留外围加粗边框)
            panel.grid.major = element_blank(),
            panel.grid.minor = element_blank(),
            panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
            axis.ticks = element_line(color = "black", linewidth = 0.8),
            axis.ticks.length = unit(0.2, "cm")
          )
        DR_values$plot_obj <- p
        showNotification("Dimension Reduction Successful!", type = "message")
        updateTabsetPanel(session, inputId = "epi_result_el_dim", selected = "tab_dim")
      }, error = function(e){
        showNotification(paste("Error:", e$message), type = "error", duration = 8)
      })
    })
  })

  # --- 新增 5. 核心计算与绘图逻辑：山脊图 (Epigenetic Landscape) ---
  observeEvent(input$dr_btn_run_ridge, {
    tic("Generate Epi landscape total time:")
    raw_df <- get_active_matrix()
    req(raw_df, DR_values$group_raw, input$dr_col_sample, input$dr_col_group)
    withProgress(message = 'Calculating Epigenetic Landscape...', value = 0.3, {
      tryCatch({
        # 依赖检查
        if(!requireNamespace("ggridges", quietly = TRUE)) stop("Please install 'ggridges' package.")
        rownames(raw_df) <- raw_df[[1]]
        # 提取 .level 列 (如果存在)
        level_cols <- grep("\\.level$", colnames(raw_df), value = TRUE)
        if (length(level_cols) > 0) {
          meth_mat <- as.matrix(raw_df[, level_cols, drop = FALSE])
        } else {
          meth_mat <- as.matrix(raw_df[, -1, drop = FALSE])
        }
        # 智能样本匹配 (复用强大的匹配逻辑)
        meta_data <- data.frame(
          RawSampleID = as.character(DR_values$group_raw[[input$dr_col_sample]]),
          Group = as.character(DR_values$group_raw[[input$dr_col_group]]),
          stringsAsFactors = FALSE
        )
        smart_clean <- function(x) {
          x <- gsub("\\.level$", "", x, ignore.case = TRUE)
          x <- gsub("\\.meth$", "", x, ignore.case = TRUE)
          x <- gsub("\\.nonmeth$", "", x, ignore.case = TRUE)
          x <- gsub("\\.cov$", "", x, ignore.case = TRUE)
          x <- gsub("\\.gz$", "", x, ignore.case = TRUE)
          x <- gsub("[-_ ]", ".", x)
          x <- gsub("\\.+", ".", x)
          x <- gsub("^\\.|\\.$", "", x)
          return(x)
        }
        mat_clean_names <- smart_clean(colnames(meth_mat))
        meta_clean_names <- smart_clean(meta_data$RawSampleID)
        colnames(meth_mat) <- mat_clean_names
        meta_data$CleanID <- meta_clean_names
        common_samples <- intersect(meta_data$CleanID, colnames(meth_mat))
        if(length(common_samples) < 3) stop("Match Error! Check your sample ID names.")
        meth_mat <- meth_mat[, common_samples, drop = FALSE]
        meta_data <- meta_data[match(common_samples, meta_data$CleanID), ]
        # 核心计算：计算每个单细胞的全局均值
        incProgress(0.6, detail = "Computing Single-Cell Global Means...")
        cell_means <- colMeans(meth_mat, na.rm = TRUE)
        ridge_df <- data.frame(
          SampleID = common_samples,
          Group = meta_data$Group,
          Global_Mean = cell_means
        )
        # 转换为因子，保持字母排序（或用户可以在未来扩展排序逻辑）
        ridge_df$Group <- as.factor(ridge_df$Group)
        DR_values$ridge_df <- ridge_df
        # 核心绘图：高颜值山脊图
        incProgress(0.8, detail = "Rendering Ridge Plot...")
        sci_palette <- c("#E64B35FF", "#4DBBD5FF", "#00A087FF", "#3C5488FF",
                         "#F39B7FFF", "#8491B4FF", "#91D1C2FF", "#DC0000FF",
                         "#7E6148FF", "#B09C85FF", "#FF7F00", "#6A3D9A")
        p_ridge <- ggplot(ridge_df, aes(x = Global_Mean, y = Group, fill = Group)) +
          ggridges::geom_density_ridges(alpha = 0.8, scale = 1.5, rel_min_height = 0.01,
                                        color = "white", linewidth = 0.5) +
          scale_fill_manual(values = sci_palette) +
          labs(
            title = "Global Epigenetic Landscape",
            subtitle = "Distribution of Mean Epigenetic Levels per Single Cell",
            x = "Global Mean Level",
            y = "Group / Condition"
          ) +
          theme_bw(base_size = 15) +
          theme(
            plot.title = element_text(hjust = 0.5, face = "bold", size = 18, margin = margin(b = 10)),
            plot.subtitle = element_text(hjust = 0.5, size = 13, color = "grey30", margin = margin(b = 15)),
            axis.title.x = element_text(face = "bold", margin = margin(t = 10)),
            axis.title.y = element_text(face = "bold", margin = margin(r = 10)),
            axis.text = element_text(color = "black", size = 13),
            legend.position = "none", # 山脊图不需要图例，Y轴已经说明了
            panel.grid.major.x = element_line(color = "grey80", linetype = "dashed"),
            panel.grid.minor = element_blank(),
            panel.grid.major.y = element_blank(),
            panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
            axis.ticks = element_line(color = "black", linewidth = 0.8)
          )
        DR_values$ridge_obj <- p_ridge
        showNotification("Landscape generated! Check the Epigenetic Landscape tab.", type = "message")
        updateTabsetPanel(session, inputId = "epi_result_el_dim", selected = "tab_el")
      }, error = function(e){
        showNotification(paste("Error:", e$message), type = "error", duration = 8)
      })
    })
    toc()
  })

  # --- 6. 渲染图表与下载 ---
  output$dr_plot_output <- renderPlot({ req(DR_values$plot_obj); DR_values$plot_obj })
  output$dr_btn_download_plot <- downloadHandler(
    filename = function() { paste0("DimRed_", input$dr_method, ".pdf") },
    content = function(file) { ggsave(file, plot = DR_values$plot_obj, width = 8, height = 6) }
  )
  output$dr_btn_download_data <- downloadHandler(
    filename = function() { paste0("DimRed_Coords_", input$dr_method, ".csv") },
    content = function(file) { data.table::fwrite(DR_values$coord_df, file, row.names = FALSE) }
  )
  # 山脊图输出
  output$dr_plot_ridge <- renderPlot({ req(DR_values$ridge_obj); DR_values$ridge_obj })
  output$dr_btn_download_ridge_plot <- downloadHandler(
    filename = function() { paste0("Epigenetic_Landscape_Ridge.pdf") },
    content = function(file) { ggsave(file, plot = DR_values$ridge_obj, width = 8, height = 6) }
  )
  output$dr_btn_download_ridge_data <- downloadHandler(
    filename = function() { paste0("Epigenetic_Landscape_Stats.csv") },
    content = function(file) { data.table::fwrite(DR_values$ridge_df, file, row.names = FALSE) }
  )

  observeEvent(input$dr_btn_reset, {
    # 1. 彻底清空底层数据和绘图对象 (防止“幽灵图”和错位下载)
    DR_values$group_raw <- NULL
    DR_values$plot_obj  <- NULL
    DR_values$coord_df  <- NULL
    DR_values$ridge_obj <- NULL
    DR_values$ridge_df  <- NULL
    DR_values$unlink_step1 <- TRUE
    # 2. 强制清空前端的静态和动态输入框
    shinyjs::reset("dr_external_matrix") # 清空手动上传的矩阵
    shinyjs::reset("dr_group_file")      # 清空 Metadata
    shinyjs::reset("dr_impute_method")   # 恢复插补算法默认值
    shinyjs::reset("dr_method")          # 恢复降维算法默认值 (PCA)
    # 3. 弹出系统反馈
    showNotification("Epigenome DimRed data and settings have been fully cleared!",
                     type = "warning", duration = 5)
  })


  # ---- Epigenome Data DEG ----
  # Step 3: Differential Analysis Server Logic
  Diff_values <- reactiveValues(
    group_raw = NULL,
    result_df = NULL,
    plot_obj = NULL,
    unlink_step1 = FALSE, # 用于断开 Step 1 的矩阵
    unlink_step2 = FALSE  # 用于断开 Step 2 的 Metadata
  )

  # --- 新增：监听前两步的数据变化，一旦前两步重新运行，自动恢复绿框 ---
  observeEvent(Epi_values$data_list$qc_matrix, { Diff_values$unlink_step1 <- FALSE }, ignoreNULL = FALSE)
  observeEvent(DR_values$group_raw, { Diff_values$unlink_step2 <- FALSE }, ignoreNULL = FALSE)

  # --- 1. 智能数据路由 ---
  output$diff_matrix_source_ui <- renderUI({
    # 增加 isFALSE 判断
    if (!is.null(Epi_values$data_list$qc_matrix) && isFALSE(Diff_values$unlink_step1)) {
      div(
        style = "padding: 10px; background-color: #d4edda; color: #155724; border-radius: 5px; border: 1px solid #c3e6cb;",
        icon("check-circle"), tags$b(" Linked to Step 1 (QC Data)"), br(),
        paste("Ready: ", nrow(Epi_values$data_list$qc_matrix), "Regions")
      )
    } else {
      div(
        style = "padding: 10px; background-color: #fff3cd; color: #856404; border-radius: 5px; border: 1px solid #ffeeba;",
        icon("upload"), tags$b(" Manual Matrix Upload"), br(),
        "QC data from Step 1 not found. Please upload a matrix.",
        fileInput("diff_external_matrix", label = NULL, accept = c(".csv"))
      )
    }
  })

  get_diff_matrix <- reactive({
    # 增加 isFALSE 判断
    if (!is.null(Epi_values$data_list$qc_matrix) && isFALSE(Diff_values$unlink_step1)) {
      return(Epi_values$data_list$qc_matrix)
    } else {
      req(input$diff_external_matrix)
      return(data.table::fread(input$diff_external_matrix$datapath, data.table = FALSE))
    }
  })

  # --- 2. 智能数据路由: Metadata ---
  output$diff_metadata_source_ui <- renderUI({
    # 增加 isFALSE 判断
    if (!is.null(DR_values$group_raw) && isFALSE(Diff_values$unlink_step2)) {
      div(
        style = "padding: 10px; background-color: #d4edda; color: #155724; border-radius: 5px; border: 1px solid #c3e6cb;",
        icon("check-circle"), tags$b(" Linked to Step 2 (Metadata)"), br(),
        paste("Ready: ", nrow(DR_values$group_raw), "Samples")
      )
    } else {
      div(
        style = "padding: 10px; background-color: #fff3cd; color: #856404; border-radius: 5px; border: 1px solid #ffeeba;",
        icon("upload"), tags$b(" Manual Metadata Upload"), br(),
        "Metadata from Step 2 not found.",
        fileInput("diff_group_file", label = NULL, accept = c(".xlsx", ".csv"))
      )
    }
  })

  output$diff_sheet_ui <- renderUI({
    req(is.null(DR_values$group_raw), input$diff_group_file)
    if(tools::file_ext(input$diff_group_file$name) == "xlsx") {
      sheets <- tryCatch(readxl::excel_sheets(input$diff_group_file$datapath), error = function(e) NULL)
      req(sheets)
      selectInput("diff_sheet_name", "Select Excel Sheet:", choices = sheets)
    }
  })

  observe({
    # 增加 isFALSE 判断
    if (!is.null(DR_values$group_raw) && isFALSE(Diff_values$unlink_step2)) {
      Diff_values$group_raw <- DR_values$group_raw
    } else {
      req(input$diff_group_file)
      ext <- tools::file_ext(input$diff_group_file$name)
      tryCatch({
        if(ext == "xlsx") {
          req(input$diff_sheet_name)
          Diff_values$group_raw <- readxl::read_excel(input$diff_group_file$datapath, sheet = input$diff_sheet_name)
        } else {
          Diff_values$group_raw <- data.table::fread(input$diff_group_file$datapath, data.table = FALSE)
        }
      }, error = function(e){})
    }
  })

  smart_select <- function(choices, keywords, fallback_idx) {
    for (kw in keywords) {
      match_idx <- grep(kw, choices, ignore.case = TRUE)
      if (length(match_idx) > 0) return(choices[match_idx[1]])
    }
    if (length(choices) >= fallback_idx) return(choices[fallback_idx])
    return(choices[1])
  }

  output$diff_mapping_ui <- renderUI({
    req(Diff_values$group_raw)
    cols <- colnames(Diff_values$group_raw)
    tagList(
      selectInput("diff_col_level", "1. IDs for '.level' (Continuous):", choices = cols, selected = smart_select(cols, c("level", "ratio"), 1)),
      selectInput("diff_col_site", "2. IDs for '.meth' (Meth counts):", choices = cols, selected = smart_select(cols, c("site", "meth", "count"), 2)),
      selectInput("diff_col_nonsite", "3. IDs for '.nonmeth' (Unmeth counts):", choices = cols, selected = smart_select(cols, c("nonsite", "nonmeth", "unmeth"), 3)),
      selectInput("diff_col_group", "4. Group/Condition Column:", choices = c("",cols), selected = "")
    )
  })
  output$diff_target_ui <- renderUI({
    req(Diff_values$group_raw, input$diff_col_group)
    groups <- unique(as.character(Diff_values$group_raw[[input$diff_col_group]]))
    groups <- groups[!is.na(groups) & trimws(groups) != ""]
    selectInput("diff_target_group", "1. Select Target Group (Case):", choices = groups)
  })
  output$diff_control_ui <- renderUI({
    req(Diff_values$group_raw, input$diff_col_group, input$diff_target_group)
    if (input$diff_compare_mode == "1vs1") {
      groups <- unique(as.character(Diff_values$group_raw[[input$diff_col_group]]))
      groups <- groups[!is.na(groups) & trimws(groups) != ""]
      control_choices <- setdiff(groups, input$diff_target_group)
      selectInput("diff_control_group", "2. Select Control Group:", choices = control_choices)
    } else {
      div(
        style = "margin-top: 10px; padding: 12px; background-color: #e8f4f8; border-left: 4px solid #3c8dbc; border-radius: 4px;",
        tags$b(icon("info-circle"), " Control Group Locked:"), br(),
        "All other valid groups except ", tags$b(input$diff_target_group, style="color:#d35400;")
      )
    }
  })

  # --- 3. 核心差异分析算法 (完美匹配用户的数学公式，且高度向量化) ---
  observeEvent(input$diff_btn_run, {
    tic("Epi differential region total time:")
    raw_mat <- get_diff_matrix()
    meta <- Diff_values$group_raw
    req(raw_mat, meta, input$diff_target_group, input$diff_col_level, input$diff_col_site, input$diff_col_nonsite, input$diff_col_group)
    withProgress(message = 'Running Differential Analysis...', value = 0.1, {
      tryCatch({
        # 将第一列设为行名
        if(is.character(raw_mat[[1]])) {
          rownames(raw_mat) <- raw_mat[[1]]
        }
        # --- 步骤 A: 提取分组索引 ---
        group_vec <- as.character(meta[[input$diff_col_group]])
        target_group <- input$diff_target_group
        target_idx <- which(group_vec == target_group)
        if (input$diff_compare_mode == "1vs1") {
          control_group <- input$diff_control_group
          control_idx <- which(group_vec == control_group)
        } else {
          control_group <- "Rest"
          control_idx <- which(group_vec != target_group & !is.na(group_vec) & trimws(group_vec) != "")
        }
        if (length(target_idx) < 2 || length(control_idx) < 2) {
          stop("Need at least 2 samples in both Target and Control groups to calculate variance!")
        }
        # 清洗并匹配列名
        clean_vector <- function(x) { trimws(as.character(x[!is.na(x)])) }
        t_level <- clean_vector(meta[[input$diff_col_level]][target_idx]); t_level <- t_level[t_level %in% colnames(raw_mat)]
        t_site  <- clean_vector(meta[[input$diff_col_site]][target_idx]);  t_site  <- t_site[t_site %in% colnames(raw_mat)]
        t_non   <- clean_vector(meta[[input$diff_col_nonsite]][target_idx]); t_non <- t_non[t_non %in% colnames(raw_mat)]
        c_level <- clean_vector(meta[[input$diff_col_level]][control_idx]); c_level <- c_level[c_level %in% colnames(raw_mat)]
        c_site  <- clean_vector(meta[[input$diff_col_site]][control_idx]);  c_site  <- c_site[c_site %in% colnames(raw_mat)]
        c_non   <- clean_vector(meta[[input$diff_col_nonsite]][control_idx]); c_non <- c_non[c_non %in% colnames(raw_mat)]
        if(length(t_level) < 2 || length(c_level) < 2) {
          stop("Sample names from metadata do not match matrix column names.")
        }
        # --- 步骤 B: Level 数据处理 (完美复现你的函数逻辑，但采用高速向量化) ---
        incProgress(0.2, detail = "Calculating methylation effects...")
        t_mat_level <- as.matrix(raw_mat[, t_level, drop=FALSE])
        c_mat_level <- as.matrix(raw_mat[, c_level, drop=FALSE])
        # 1. 严格过滤：两组中非NA数量都必须 >= 2
        keep_idx <- (rowSums(!is.na(t_mat_level)) >= 2) & (rowSums(!is.na(c_mat_level)) >= 2)
        t_mat_level <- t_mat_level[keep_idx, , drop=FALSE]
        c_mat_level <- c_mat_level[keep_idx, , drop=FALSE]
        valid_regions <- rownames(t_mat_level)
        # 2. 向量化计算 (替代原函数的 for 循环，速度提升百倍)
        t_mean <- rowMeans(t_mat_level, na.rm = TRUE)
        c_mean <- rowMeans(c_mat_level, na.rm = TRUE)
        t_var <- apply(t_mat_level, 1, var, na.rm = TRUE)
        c_var <- apply(c_mat_level, 1, var, na.rm = TRUE)
        # 3. 计算用户定义的公式
        diff_val <- t_mean - c_mean
        # scores <- diff_val / (1 + sqrt(t_var^2 + c_var^2))
        # 每个区域的有效样本数
        n_target <- rowSums(!is.na(t_mat_level))
        n_control <- rowSums(!is.na(c_mat_level))
        # 避免样本量过小导致自由度为 0
        valid_n <- n_target >= 2 & n_control >= 2
        # 计算合并方差
        pooled_var <- rep(NA_real_, length(diff_val))
        pooled_var[valid_n] <- (
          (n_target[valid_n] - 1) * t_var[valid_n] +
            (n_control[valid_n] - 1) * c_var[valid_n]
        ) / (
          n_target[valid_n] + n_control[valid_n] - 2
        )
        # 合并标准差
        pooled_sd <- sqrt(pooled_var)
        # 防止两组方差均为 0 时出现 Inf
        sd_floor <- 1e-8
        pooled_sd_safe <- pmax(pooled_sd, sd_floor)
        # Cohen's d
        cohen_d <- diff_val / pooled_sd_safe
        # Hedges' g 小样本校正系数
        correction_J <- rep(NA_real_, length(diff_val))
        correction_J[valid_n] <- 1 - 3 / (
          4 * (n_target[valid_n] + n_control[valid_n]) - 9
        )
        # Hedges' g
        hedges_g <- correction_J * cohen_d
        # 对无效值进行处理
        hedges_g[!is.finite(hedges_g)] <- NA_real_
        # Log2 Odds Ratio
        eps <- 1e-4
        # 检查数据范围
        if (any(t_mean < 0 | t_mean > 1, na.rm = TRUE) ||
            any(c_mean < 0 | c_mean > 1, na.rm = TRUE)) {
          stop("Methylation .level values must be between 0 and 1.")
        }
        # 防止均值为 0 或 1
        t_mean_clip <- pmin(pmax(t_mean, eps), 1 - eps)
        c_mean_clip <- pmin(pmax(c_mean, eps), 1 - eps)
        # Odds
        t_odds <- t_mean_clip / (1 - t_mean_clip)
        c_odds <- c_mean_clip / (1 - c_mean_clip)
        # Odds Ratio
        odds_ratio <- t_odds / c_odds
        # 新的 logFC：Log2 Odds Ratio
        log2_odds_ratio <- log2(odds_ratio)
        odds_ratio[!is.finite(odds_ratio)] <- NA_real_
        log2_odds_ratio[!is.finite(log2_odds_ratio)] <- NA_real_
        # --- 步骤 C: Count 数据的 Fisher 检验 ---
        incProgress(0.2, detail = "Running Fisher's Exact Test on Sites...")
        # 严格使用上面过滤后的 valid_regions 提取 count 数据
        t_mat_site <- as.matrix(raw_mat[valid_regions, t_site, drop=FALSE])
        t_mat_non  <- as.matrix(raw_mat[valid_regions, t_non, drop=FALSE])
        c_mat_site <- as.matrix(raw_mat[valid_regions, c_site, drop=FALSE])
        c_mat_non  <- as.matrix(raw_mat[valid_regions, c_non, drop=FALSE])
        # 汇总 count 数
        t_site_sum <- rowSums(t_mat_site, na.rm=TRUE)
        t_non_sum  <- rowSums(t_mat_non, na.rm=TRUE)
        c_site_sum <- rowSums(c_mat_site, na.rm=TRUE)
        c_non_sum  <- rowSums(c_mat_non, na.rm=TRUE)
        # 智能检测 count 数据是否有效 (列必须存在，且最大值不能全都是 <= 1 的小数)
        valid_counts <- FALSE
        if (length(t_site) > 0 && length(t_non) > 0 && length(c_site) > 0 && length(c_non) > 0) {
          suppressWarnings({
            max_val <- max(c(t_mat_site, t_mat_non, c_mat_site, c_mat_non), na.rm=TRUE)
          })
          if (is.finite(max_val) && max_val > 1) {
            valid_counts <- TRUE
          }
        }
        # 预分配 P 值向量 (默认为 1)
        p_values <- rep(1, length(valid_regions))
        n_test <- length(valid_regions)
        step <- max(1, floor(n_test / 10))
        for (i in 1:n_test) {
          if(i %% step == 0) incProgress(0.4 / 10)
          # 构建 2x2 列联表：
          # [ Target_Meth, Control_Meth ]
          # [ Target_Unmeth, Control_Unmeth ]
          # mat <- matrix(c(t_site_sum[i], t_non_sum[i],
          #                 c_site_sum[i], c_non_sum[i]), nrow=2)
          # if(sum(mat) > 0) {
          #   try({ p_values[i] <- fisher.test(mat)$p.value }, silent = TRUE)
          # }
          if(i %% step == 0) incProgress(0.4 / 10)
          pval <- 1
          # 1. 优先尝试 Fisher Exact Test (如果有真正的 count 数据)
          if (valid_counts) {
            mat <- matrix(c(t_site_sum[i], t_non_sum[i],
                            c_site_sum[i], c_non_sum[i]), nrow=2)
            if(sum(mat) > 0) {
              try({ pval <- fisher.test(mat)$p.value }, silent = TRUE)
            }
          }
          # 2. 自动降级 (Fallback)：
          # 如果未提供 count 数据、把 Beta 值误当成 count，或 Fisher 算完毫无差异 (P=1)
          # 则自动改用连续变量 (.level) 的 Welch T-Test 计算 P 值
          # if (pval == 1 || is.na(pval)) {
          #   try({
          #     x <- t_mat_level[i, ]
          #     y <- c_mat_level[i, ]
          #     x <- x[!is.na(x)]
          #     y <- y[!is.na(y)]
          #     if (length(x) >= 2 && length(y) >= 2) {
          #       # T 检验要求两组中至少有一组方差大于0
          #       if (var(x) > 0 || var(y) > 0) {
          #         pval <- t.test(x, y)$p.value
          #       } else if (mean(x) != mean(y)) {
          #         # 如果两组内部方差都是 0 但均值不同，说明存在极显著差异
          #         pval <- .Machine$double.eps
          #       }
          #     }
          #   }, silent = TRUE)
          # }
          p_values[i] <- pval
        }
        # --- 步骤 D: 合并计算结果并绘制火山图 ---
        incProgress(0.1, detail = "Generating Plot & Table...")
        final_df <- data.frame(
          chrdata = valid_regions,
          P.Value = p_values,
          FDR = p.adjust(p_values, method = "fdr"),
          var_group = t_var,
          var_nogroup = c_var,
          Diff = diff_val,
          # Scores = scores,
          Hedges_g = hedges_g,
          Odds_Ratio = odds_ratio,
          Log2_Odds_Ratio = log2_odds_ratio,
          stringsAsFactors = FALSE
        )
        # 1. 获取用户选择的指标和阈值
        metric_col <- input$diff_effect_metric
        th_effect <- input$diff_effect_th
        th_fdr <- input$diff_p_th
        effect_vals <- final_df[[metric_col]]
        final_df$Significance <- "Not Sig"
        min_diff <- 0.10 # 最小实际甲基化差异阈值
        # --- 优化点 1：精确分类 ---
        up_idx <- !is.na(effect_vals) & effect_vals >= th_effect & final_df$Diff >= min_diff & !is.na(final_df$FDR) & final_df$FDR < th_fdr
        down_idx <- !is.na(effect_vals) & effect_vals <= -th_effect & final_df$Diff <= -min_diff & !is.na(final_df$FDR) & final_df$FDR < th_fdr
        final_df$Significance[up_idx] <- "Hypermethylated"
        final_df$Significance[down_idx] <- "Hypomethylated"
        # --- 优化点 2：统计各组数量并动态生成高大上的图例标签 ---
        n_up <- sum(final_df$Significance == "Hypermethylated", na.rm = TRUE)
        n_down <- sum(final_df$Significance == "Hypomethylated", na.rm = TRUE)
        n_ns <- sum(final_df$Significance == "Not Sig", na.rm = TRUE)
        label_up <- paste0("Hypermethylated (n=", n_up, ")")
        label_down <- paste0("Hypomethylated (n=", n_down, ")")
        label_ns <- paste0("Not Sig (n=", n_ns, ")")
        # 将 Significance 转换为 Factor，固定图例顺序，并应用新标签
        final_df$Significance <- factor(
          final_df$Significance,
          levels = c("Hypermethylated", "Hypomethylated", "Not Sig"),
          labels = c(label_up, label_down, label_ns)
        )
        # --- 修复核心 1：按 FDR 升序排列数据 ---
        # 这样呈现给用户的表格和下载的 CSV 中，最显著的 DMR 才会排在最前面！
        final_df <- final_df[order(final_df$FDR, -abs(final_df[[metric_col]]), na.last = TRUE), ]
        # --- 修复核心 2：将赋值给 reactiveValues，这一步激活了表格的显示！ ---
        Diff_values$result_df <- final_df
        # 1. 提取高甲基化 (Up) 且按 FDR 升序排列的前 5 个
        df_up <- final_df[final_df$Significance == label_up, ]
        top_up <- head(df_up, 5) # 因为前面已经按 FDR 排好序了，直接 head 即可
        # 2. 提取低甲基化 (Down) 且按 FDR 升序排列的前 5 个
        df_down <- final_df[final_df$Significance == label_down, ]
        top_down <- head(df_down, 5)
        # 3. 合并成最终的标注数据集
        top_genes <- rbind(top_up, top_down)
        x_label <- switch(
          metric_col,
          "Log2_Odds_Ratio" = expression(bold(Log[2]~"Odds Ratio")),
          "Diff" = expression(bold("Methylation Difference (" * Delta * ")")),
          "Hedges_g" = expression(bold("Hedges' g")),
          expression(bold("Effect Size"))
        )
        # 计算对称的 X 轴范围
        max_x <- max(abs(effect_vals), na.rm = TRUE)
        x_limit <- max_x * 1.05 # 增加 5% 的边缘留白
        # --- 修复核心 3：高级 ggplot2 绘制 ---
        p <- ggplot(
          # 注意这里：仅在喂给 ggplot 时，我们在系统内存里把不显著的点排在前面（防止遮挡），不影响原 final_df
          final_df[order(final_df$Significance, decreasing = TRUE), ],
          aes(
            x = .data[[metric_col]],
            y = -log10(pmax(FDR, .Machine$double.xmin)),
            fill = Significance,
            size = Significance,   # 映射大小
            alpha = Significance   # 映射透明度
          )
        ) +
          # 阈值线（改为更柔和的灰色点划线，避免喧宾夺主）
          geom_hline(yintercept = -log10(th_fdr), linetype = "twodash", color = "#404040", linewidth = 0.5, alpha = 0.7) +
          geom_vline(xintercept = c(-th_effect, th_effect), linetype = "twodash", color = "#404040", linewidth = 0.5, alpha = 0.7) +
          # 绘制散点：边框统一使用深灰色（比纯白或纯黑更有高级感）
          geom_point(shape = 21, stroke = 0.3, color = "#4D4D4D") +
          # 强制对称的 X 轴
          scale_x_continuous(limits = c(-x_limit, x_limit)) +
          # 自定义映射：颜色、大小、透明度
          # 采用 Nature 风格配色: 红色 #E64B35FF, 蓝色 #4DBBD5FF, 灰色 #E0E0E0
          scale_fill_manual(values = setNames(c("#E64B35FF", "#4DBBD5FF", "#E0E0E0"), c(label_up, label_down, label_ns))) +
          # 显著点放大(2.5)，不显著点缩小(1.2)
          scale_size_manual(values = setNames(c(2.5, 2.5, 1.2), c(label_up, label_down, label_ns))) +
          # 显著点不透明(0.9)，不显著点半透明(0.4) 降低视觉噪音
          scale_alpha_manual(values = setNames(c(0.9, 0.9, 0.4), c(label_up, label_down, label_ns))) +
          theme_bw(base_size = 15) +
          labs(
            title = paste("DMRs:", target_group, "vs", control_group),
            subtitle = paste("Thresholds: |Effect Size| >", th_effect, "& FDR <", th_fdr), # 添加副标题说明阈值
            x = x_label,
            y = expression(bold(-Log[10]~"FDR"))
          ) +
          theme(
            plot.title = element_text(hjust = 0.5, face = "bold", size = 18, color = "#333333"),
            plot.subtitle = element_text(hjust = 0.5, size = 12, color = "#666666", margin = margin(b = 15)),
            # 优化图例：去掉标题，稍微放大圆点，增加间距
            legend.position = "top",
            legend.title = element_blank(),
            legend.text = element_text(size = 12),
            legend.key.size = unit(1.5, "lines"),
            # 简化网格线，让数据更突出
            panel.grid.major = element_line(color = "#F0F0F0"),
            panel.grid.minor = element_blank(),
            panel.border = element_rect(color = "black", fill = NA, linewidth = 1.2),
            axis.text = element_text(color = "black"),
            axis.title = element_text(face = "bold")
          ) +
          # 优化文字标签 (ggrepel)
          ggrepel::geom_text_repel(
            data = top_genes,
            aes(label = chrdata),
            size = 4,                   # 字体稍微调小一点显精致
            color = "black",
            fontface = "bold.italic",   # 加粗+斜体，适合基因或区域命名
            box.padding = 0.8,
            point.padding = 0.3,
            segment.color = "#666666",  # 引导线改为深灰色
            segment.size = 0.5,         # 引导线粗细
            max.overlaps = 50,          # 允许更多的重叠尝试，确保文字都能画出来
            bg.color = "white",         # 文字轮廓白边，比死板的白色背景框更好看
            bg.r = 0.15,
            show.legend = FALSE         # 防止标签干扰图例
          )
        # 为了覆盖原生的 size/alpha 映射到图例上，我们需要覆盖 guides
        p <- p + guides(
          fill = guide_legend(override.aes = list(size = 4, alpha = 1)),
          size = "none",
          alpha = "none"
        )
        Diff_values$plot_obj <- p
        showNotification("Differential Analysis Complete!", type = "message")
      }, error = function(e){
        showNotification(paste("Analysis Error:", e$message), type = "error", duration = 10)
      })
    })
    toc()
  })

  # --- 4. 渲染输出与下载 ---
  output$diff_result_table <- DT::renderDT({
    req(Diff_values$result_df)
    df <- Diff_values$result_df
    format_cols <- intersect(
      c(
        "Diff",
        "Hedges_g",
        "Odds_Ratio",
        "Log2_Odds_Ratio",
        "P.Value",
        "FDR",
        "var_group",
        "var_nogroup"
      ),
      colnames(df)
    )
    DT::datatable(
      df,
      options = list(
        scrollX = TRUE,
        pageLength = 10
      ),
      rownames = FALSE
    ) %>%
      DT::formatSignif(
        columns = format_cols,
        digits = 4
      )
  })
  output$diff_volcano_plot <- renderPlot({ req(Diff_values$plot_obj); Diff_values$plot_obj })
  output$diff_btn_dl_csv <- downloadHandler(
    filename = function() { paste0("DA_", input$diff_target_group, "_", Sys.Date(), ".csv") },
    content = function(file) { data.table::fwrite(Diff_values$result_df, file, row.names = FALSE) }
  )
  output$diff_btn_dl_plot <- downloadHandler(
    filename = function() { paste0("Volcano_", input$diff_target_group, "_", Sys.Date(), ".pdf") },
    content = function(file) { ggplot2::ggsave(file, plot = Diff_values$plot_obj, width = 8, height = 6) }
  )

  observeEvent(input$diff_btn_reset, {
    # 1. 彻底清空画图对象和结果表，防止“幽灵图”
    Diff_values$group_raw <- NULL
    Diff_values$result_df <- NULL
    Diff_values$plot_obj  <- NULL
    # 2. 激活软断开标志，强制 UI 变回黄色的上传框
    Diff_values$unlink_step1 <- TRUE
    Diff_values$unlink_step2 <- TRUE
    # 3. 使用 shinyjs 清空所有前端输入框（确保页面顶部的 library(shinyjs) 并在 UI 加入 useShinyjs()）
    shinyjs::reset("diff_external_matrix")
    shinyjs::reset("diff_group_file")
    shinyjs::reset("diff_effect_metric")
    shinyjs::reset("diff_effect_th")
    shinyjs::reset("diff_p_th")
    shinyjs::reset("diff_compare_mode")
    # 4. 弹出成功提示
    showNotification("Differential Analysis data and settings have been fully cleared!",
                     type = "warning", duration = 5)
  })


  # ---- ATAC Format Converter ----
  # 初始化 reactiveValues，移除不需要的 out_dir_mapped
  rv_atac <- reactiveValues(
    out_dir = NULL,
    preview_df = NULL,
    preview_df_mapped = NULL
  )

  observeEvent(input$btn_convert_atac, {
    req(input$atac_matrix_file)
    id_reading <- showNotification("Processing Data & Computing... Please wait.",
                                   duration = NULL, type = "message", closeButton = FALSE)
    # 1. 智能容错读取
    raw_data <- tryCatch({
      df <- data.table::fread(input$atac_matrix_file$datapath, data.frame = TRUE, header = "auto", fill = TRUE)
      if(all(is.na(df[[1]])) || df[[1]][1] == "") stop("Header mismatch in fread")
      df
    }, error = function(e1) {
      tryCatch({
        read.csv(input$atac_matrix_file$datapath, check.names = FALSE, stringsAsFactors = FALSE)
      }, error = function(e2) {
        removeNotification(id_reading)
        showNotification(paste("File format error:", e2$message), type = "error", duration = 15)
        return(NULL)
      })
    })
    req(raw_data)
    regions <- raw_data[[1]]
    counts_df <- raw_data[, -1, drop = FALSE]
    cell_names <- colnames(counts_df)
    counts_mat <- as.matrix(counts_df)
    mode(counts_mat) <- "numeric"
    counts_mat[is.na(counts_mat)] <- 0
    # TF-IDF 计算
    col_sums <- colSums(counts_mat, na.rm = TRUE)
    col_sums[col_sums == 0] <- 1
    tf_mat <- sweep(counts_mat, 2, col_sums, FUN = "/")
    num_cells <- ncol(counts_mat)
    row_cells_detected <- rowSums(counts_mat > 0, na.rm = TRUE)
    idf <- rep(0, nrow(counts_mat))
    valid_peaks <- row_cells_detected > 0
    idf[valid_peaks] <- log(1 + num_cells / row_cells_detected[valid_peaks])
    tfidf_mat <- sweep(tf_mat, 1, idf, FUN = "*")
    cell_max_tfidf <- apply(tfidf_mat, 2, max, na.rm = TRUE)
    cell_max_tfidf[cell_max_tfidf == 0 | is.na(cell_max_tfidf)] <- 1
    level_mat <- sweep(tfidf_mat, 2, cell_max_tfidf, FUN = "/")
    # 解析原始 Regions
    regions_clean <- gsub(":", "-", regions)
    peak_parts <- strsplit(regions_clean, "-")
    chr_vec <- sapply(peak_parts, function(x) if(length(x)>=1) x[1] else NA)
    start_vec <- as.numeric(sapply(peak_parts, function(x) if(length(x)>=2) x[2] else NA))
    end_vec <- as.numeric(sapply(peak_parts, function(x) if(length(x)>=3) x[3] else NA))
    atac_gr <- GRanges(seqnames = chr_vec, ranges = IRanges(start = start_vec, end = end_vec))
    # 2. 读取 Target Region
    has_target <- !is.null(input$target_region_file)
    target_gr <- NULL
    target_regions_chr <- NULL
    target_regions_str <- NULL
    hit_dt <- NULL
    if (has_target) {
      target_df <- tryCatch({
        tmp <- data.table::fread(input$target_region_file$datapath, select = 1:3, header = "auto")
        data.table::setnames(tmp, 1:3, c("chr", "start", "end"))
        tmp
      }, error = function(e) {
        showNotification("Target file invalid. Must have at least 3 columns (chr, start, end).", type = "warning")
        return(NULL)
      })
      if (!is.null(target_df)) {
        target_regions_chr <- target_df
        target_regions_str <- paste0(target_df$chr, ":", target_df$start, "-", target_df$end)
        target_gr <- GRanges(seqnames = target_df$chr, ranges = IRanges(start = target_df$start, end = target_df$end))
        hits <- findOverlaps(target_gr, atac_gr)
        hit_dt <- data.table::data.table(target_idx = queryHits(hits), atac_idx = subjectHits(hits))
      } else {
        has_target <- FALSE
      }
    }
    # 3. 构造 Preview 数据 (预览前 5 个细胞)
    preview_cells <- cell_names[1:min(5, length(cell_names))]
    # A. 原始 Preview
    preview_df <- data.frame(regionID = regions, stringsAsFactors = FALSE)
    for (cell in preview_cells) {
      cell_levels <- level_mat[, cell]
      meth_val <- round(cell_levels * 100)
      preview_df[[paste0(cell, ".meth")]] <- meth_val
      preview_df[[paste0(cell, ".nonmeth")]] <- 100 - meth_val
      preview_df[[paste0(cell, ".level")]] <- round(cell_levels, 4)
    }
    rv_atac$preview_df <- preview_df
    # B. Target Mapped Preview
    if (has_target) {
      preview_df_mapped <- data.frame(Target_Region = target_regions_str, stringsAsFactors = FALSE)
      for (cell in preview_cells) {
        cell_levels <- level_mat[, cell]
        hit_dt_cell <- data.table::copy(hit_dt)
        hit_dt_cell$lvl <- cell_levels[hit_dt_cell$atac_idx]
        agg <- hit_dt_cell[, .(mapped_lvl = max(lvl)), by = target_idx]
        target_levels <- rep(0, length(target_gr))
        target_levels[agg$target_idx] <- agg$mapped_lvl
        meth_val_m <- round(target_levels * 100)
        preview_df_mapped[[paste0(cell, ".meth")]] <- meth_val_m
        preview_df_mapped[[paste0(cell, ".nonmeth")]] <- 100 - meth_val_m
        preview_df_mapped[[paste0(cell, ".level")]] <- round(target_levels, 4)
      }
      rv_atac$preview_df_mapped <- preview_df_mapped
    } else {
      rv_atac$preview_df_mapped <- data.frame(Message = "No Target Regions uploaded.")
    }
    # 4. 生成所有细胞的 Original .cov 文件 (后台并行处理)
    # 移除了 mapped cov 文件的生成逻辑，大幅提升速度
    temp_dir_orig <- file.path(tempdir(), paste0("scMATE_orig_", as.integer(Sys.time())))
    dir.create(temp_dir_orig, showWarnings = FALSE)
    removeNotification(id_reading)
    withProgress(message = 'Generating Original .cov files...', value = 0, {
      for (i in seq_along(cell_names)) {
        cell <- cell_names[i]
        levels_out <- level_mat[, i]
        keep_idx <- which(levels_out > 0 & !is.na(chr_vec) & !is.na(start_vec) & !is.na(end_vec))
        if (length(keep_idx) > 0) {
          valid_levels <- levels_out[keep_idx]
          meth_out <- round(valid_levels * 100)
          cov_out <- data.frame(
            chr = chr_vec[keep_idx], start = start_vec[keep_idx], end = end_vec[keep_idx],
            level = valid_levels, meth = meth_out, nonmeth = 100 - meth_out
          )
          write.table(cov_out, file.path(temp_dir_orig, paste0(cell, ".cov")), sep = "\t", quote = FALSE, row.names = FALSE, col.names = TRUE)
        }
        incProgress(1 / length(cell_names), detail = paste("Processed", cell))
      }
    })
    # 5. 更新 UI 状态，显示右上角的按钮
    rv_atac$out_dir <- temp_dir_orig
    shinyjs::show("download_atac_covs")
    shinyjs::show("download_preview_orig")
    if (has_target) {
      shinyjs::show("download_preview_mapped")
      showNotification("Conversion and Mapping complete! Ready for download.", type = "message")
    } else {
      shinyjs::hide("download_preview_mapped")
      showNotification("Original Conversion complete! Ready for download.", type = "message")
    }
  })

  # 【新增】：重置按钮逻辑
  observeEvent(input$btn_reset_atac, {
    # 1. 重置文件上传组件 (需要 shinyjs::useShinyjs() 支持)
    shinyjs::reset("atac_matrix_file")
    shinyjs::reset("target_region_file")
    # 2. 清空内部存储的数据 (这会自动清空右侧的 DT 表格)
    rv_atac$out_dir <- NULL
    rv_atac$preview_df <- NULL
    rv_atac$preview_df_mapped <- NULL
    # 3. 隐藏所有相关的下载按钮
    shinyjs::hide("download_atac_covs")
    shinyjs::hide("download_preview_orig")
    shinyjs::hide("download_preview_mapped")
    # 4. 提示用户重置成功
    showNotification("Data and UI have been successfully reset.", type = "message")
  })

  # --- 独立渲染 DT 表格 ---
  output$atac_preview_table <- renderDT({
    req(rv_atac$preview_df)
    datatable(rv_atac$preview_df, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE, class = "cell-border stripe")
  })

  output$atac_mapped_preview_table <- renderDT({
    req(rv_atac$preview_df_mapped)
    datatable(rv_atac$preview_df_mapped, options = list(pageLength = 10, scrollX = TRUE), rownames = FALSE, class = "cell-border stripe")
  })

  # --- 独立的下载处理器 ---
  # 1. 原始 .cov ZIP 下载
  output$download_atac_covs <- downloadHandler(
    filename = function() { paste0("scATAC_Original_cov_", format(Sys.time(), "%Y%m%d_%H%M"), ".zip") },
    content = function(file) {
      req(rv_atac$out_dir)
      owd <- setwd(rv_atac$out_dir); on.exit(setwd(owd))
      zip::zip(zipfile = file, files = list.files(pattern = "\\.cov$"))
    }
  )

  # 2. 原始表格数据 (CSV) 下载
  output$download_preview_orig <- downloadHandler(
    filename = function() { paste0("scATAC_Original_PreviewData_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv") },
    content = function(file) {
      req(rv_atac$preview_df)
      write.csv(rv_atac$preview_df, file, row.names = FALSE)
    }
  )

  # 3. Mapped 表格数据 (CSV) 下载
  output$download_preview_mapped <- downloadHandler(
    filename = function() { paste0("scATAC_Mapped_PreviewData_", format(Sys.time(), "%Y%m%d_%H%M"), ".csv") },
    content = function(file) {
      req(rv_atac$preview_df_mapped)
      write.csv(rv_atac$preview_df_mapped, file, row.names = FALSE)
    }
  )



  # ----Integration Analysis----
  # ---- Integration Analysis Server Logic (Multi-Sheet Support) ----
  Integ_values <- reactiveValues(
    meta_file_path = NULL,
    sheets = NULL,
    rna_obj = NULL,
    merged_df = NULL,
    plot_scatter_obj = NULL,
    plot_matrix_obj = NULL,
    use_example = FALSE
  )

  output$integ_example_msg <- renderUI({
    if (Integ_values$use_example) {
      div(class = "alert alert-success", style = "margin-bottom: 15px;",
          icon("check-circle"), " Example Data Loaded! You can safely click 'Run Integration' now."
      )
    }
  })

  observeEvent(Integ_values$merged_df, {
    Multi_values$unlink_step1 <- FALSE
  }, ignoreNULL = FALSE)

  observeEvent(c(input$integ_region_file, input$integ_meta_file, input$integ_rna_rds), {
    Integ_values$use_example <- FALSE
  })

  # --- 1. Metadata File Upload ---
  observeEvent(input$integ_meta_file, {
    req(input$integ_meta_file)
    Integ_values$meta_file_path <- input$integ_meta_file$datapath
    tryCatch({
      sheets <- readxl::excel_sheets(Integ_values$meta_file_path)
      Integ_values$sheets <- sheets
      output$ui_cpg_sheet_select <- renderUI({ selectInput("cpg_sheet", "Select CpG Sheet:", choices = sheets, selected = "CpG") })
      output$ui_gpc_sheet_select <- renderUI({ selectInput("gpc_sheet", "Select GpC Sheet:", choices = sheets, selected = "GpC") })
    }, error = function(e) { showNotification("Error reading Excel sheets.", type = "error") })
  })

  # --- 2. RNA RDS Upload & Column Selection ---
  observeEvent(input$integ_rna_rds, {
    req(input$integ_rna_rds)
    progress <- shiny::Progress$new()
    progress$set(message = "Loading Custom RNA Object...", value = 0.3)
    on.exit(progress$close())
    tryCatch({
      custom_obj <- readRDS(input$integ_rna_rds$datapath)
      if(is.null(custom_obj$assays) || is.null(custom_obj$meta.data)) stop("File structure missing assays or meta.data.")
      Integ_values$rna_obj <- custom_obj
      meta_df <- if(!is.null(custom_obj$filter_meta.data)) custom_obj$filter_meta.data else custom_obj$meta.data
      meta_cols <- colnames(meta_df)
      output$ui_rna_rds_group_col <- renderUI({
        default_col <- meta_cols[1]
        if ("Developmental_stage" %in% meta_cols) default_col <- "Developmental_stage"
        else if ("Development_stage" %in% meta_cols) default_col <- "Development_stage"
        selectInput("rna_rds_group_col", "Choose Grouping Column:", choices = meta_cols, selected = default_col)
      })
      showNotification("RNA Object Loaded Successfully.", type = "message")
    }, error = function(e){ showNotification(paste("Error:", e$message), type = "error", duration = 10) })
  })

  output$txt_rna_avail_groups <- renderText({
    req(Integ_values$rna_obj, input$rna_rds_group_col)
    custom_obj <- Integ_values$rna_obj
    meta_df <- if(!is.null(custom_obj$filter_meta.data)) custom_obj$filter_meta.data else custom_obj$meta.data
    groups <- unique(meta_df[[input$rna_rds_group_col]])
    paste("Groups found:", paste(head(groups, 10), collapse=", "), "...")
  })

  create_col_selectors <- function(prefix, sheet_name) {
    req(Integ_values$meta_file_path, sheet_name)
    df <- readxl::read_excel(Integ_values$meta_file_path, sheet = sheet_name)
    cols <- colnames(df)
    list(
      renderUI({ selectInput(paste0(prefix, "_id_col"), "Sample ID Column:", choices = cols, selected = "level") }),
      renderUI({ selectInput(paste0(prefix, "_group_col"), "Group Column:", choices = cols, selected = "Developmental_stage") })
    )
  }

  observeEvent(input$cpg_sheet, { res <- create_col_selectors("cpg", input$cpg_sheet); output$ui_cpg_id_col <- res[[1]]; output$ui_cpg_group_col <- res[[2]] })
  observeEvent(input$gpc_sheet, { res <- create_col_selectors("gpc", input$gpc_sheet); output$ui_gpc_id_col <- res[[1]]; output$ui_gpc_group_col <- res[[2]] })
  observeEvent(input$integ_rna_diff, {
    req(input$integ_rna_diff)
    cols <- colnames(data.table::fread(input$integ_rna_diff$datapath, nrows = 1, data.table = FALSE))
    guess_pval <- grep("p.*val|padj|fdr", cols, ignore.case = TRUE, value = TRUE)[1]
    guess_lfc <- grep("log.*fc|fold.*change", cols, ignore.case = TRUE, value = TRUE)[1]
    output$ui_rna_pval_col <- renderUI({
      selectInput("rna_pval_col", "P-val Col:",choices = cols, selected = ifelse(is.na(guess_pval), cols[1], guess_pval)) })
    output$ui_rna_logfc_col <- renderUI({
      selectInput("rna_logfc_col", "logFC Col:", choices = cols, selected = ifelse(is.na(guess_lfc), cols[2], guess_lfc)) })
  })
  observeEvent(input$integ_cpg_dmr, {
    if (!is.null(input$integ_cpg_dmr)) {
      cols <- colnames(data.table::fread(input$integ_cpg_dmr$datapath, nrows = 1, data.table = FALSE))
      guess_pval <- grep("p.*val|padj|fdr", cols, ignore.case = TRUE, value = TRUE)[1]
      guess_diff <- grep("diff|meth.*diff|delta", cols, ignore.case = TRUE, value = TRUE)[1]
      output$ui_cpg_pval_col <- renderUI({
        selectInput("cpg_pval_col", "P-val Col:", choices = cols, selected = ifelse(is.na(guess_pval), cols[1], guess_pval))
      })
      output$ui_cpg_diff_col <- renderUI({
        selectInput("cpg_diff_col", "Diff Col:", choices = cols, selected = ifelse(is.na(guess_diff), cols[min(2, length(cols))], guess_diff))
      })
    } else {
      # 用户未上传时清空下拉框
      output$ui_cpg_pval_col <- renderUI({ NULL })
      output$ui_cpg_diff_col <- renderUI({ NULL })
    }
  })
  observeEvent(input$integ_gpc_dmr, {
    if (!is.null(input$integ_gpc_dmr)) {
      cols <- colnames(data.table::fread(input$integ_gpc_dmr$datapath, nrows = 1, data.table = FALSE))
      guess_pval <- grep("p.*val|padj|fdr", cols, ignore.case = TRUE, value = TRUE)[1]
      guess_diff <- grep("diff|acc.*diff|delta", cols, ignore.case = TRUE, value = TRUE)[1]

      output$ui_gpc_pval_col <- renderUI({
        selectInput("gpc_pval_col", "P-val Col:", choices = cols, selected = ifelse(is.na(guess_pval), cols[1], guess_pval))
      })
      output$ui_gpc_diff_col <- renderUI({
        selectInput("gpc_diff_col", "Diff Col:", choices = cols, selected = ifelse(is.na(guess_diff), cols[min(2, length(cols))], guess_diff))
      })
    } else {
      output$ui_gpc_pval_col <- renderUI({ NULL })
      output$ui_gpc_diff_col <- renderUI({ NULL })
    }
  })

  prepare_rna_matrix <- function(rna_assay, source = "data", scale_factor = 1e4) {
    if (source == "data") {
      expr_mat <- rna_assay$data
      if (is.null(expr_mat)) {
        stop(
          "RNA normalized data is missing: assays$RNA$data was not found. ",
          "Select the raw/filtered counts option instead."
        )
      }
      if (is.null(rownames(expr_mat)) || is.null(colnames(expr_mat))) {
        stop("RNA data matrix must have gene row names and cell column names.")
      }
      # data slot should be non-negative normalized expression,
      # not assays$RNA$scale.data
      if (any(expr_mat < 0, na.rm = TRUE)) {
        stop(
          "assays$RNA$data contains negative values. ",
          "It may be scale.data rather than normalized expression."
        )
      }
      return(list(
        mat = expr_mat,
        label = "assays$RNA$data (pre-normalized)"
      ))
    }
    counts <- rna_assay$counts
    if (is.null(counts)) {
      counts <- rna_assay$filter_counts
    }
    if (is.null(counts)) {
      stop("Neither assays$RNA$counts nor filter_counts was found.")
    }
    if (is.data.frame(counts)) {
      counts <- as.matrix(counts)
    }
    if (is.null(rownames(counts)) || is.null(colnames(counts))) {
      stop("RNA count matrix must have gene row names and cell column names.")
    }
    if (any(counts < 0, na.rm = TRUE)) {
      stop("RNA count matrix contains negative values.")
    }
    library_size <- Matrix::colSums(counts)
    if (any(!is.finite(library_size) | library_size <= 0)) {
      stop("RNA matrix contains cells with invalid or zero library size.")
    }
    # Normalize each cell to 10,000 counts, then log1p transform
    normalized_mat <- counts %*%
      Matrix::Diagonal(x = scale_factor / library_size)
    normalized_mat <- log1p(normalized_mat)
    list(
      mat = normalized_mat,
      label = "counts -> library-size normalization -> log1p"
    )
  }

  # 核心整合逻辑 (支持4种动态模式)
  observeEvent(input$integ_btn_run, {
    tic("Integration multi-omics total time:")
    req(input$global_target_group)
    target_group <- trimws(as.character(input$global_target_group))
    if(target_group == "") { showNotification("Please enter a valid Target Group Name!", type = "error"); return(NULL) }
    mode <- input$integ_mode # "tri", "rna_cpg", "cpg_gpc"
    if (Integ_values$use_example) {
      path_region   <- "data/mm10_genetss2k_choose30000.csv"
      path_cpg_mat  <- "data/Epigenome_qcCpG_matrix_example_2026-03-30.csv"
      path_cpg_dmr  <- "data/DA_E4.5_CpG_2026-03-30.csv"
      path_gpc_mat  <- "data/Epigenome_qcGpC_matrix_example_2026-03-30.csv"
      path_gpc_dmr  <- "data/DA_E4.5_GpC_2026-03-30.csv"
      path_rna_diff <- "data/Markers_E4.5_vs_Rest_2026-03-30.csv"
    } else {
      req(input$integ_region_file)
      path_region <- input$integ_region_file$datapath
      # 根据模式检查依赖文件
      path_cpg_mat <- NULL
      path_cpg_dmr <- NULL
      if (mode %in% c("tri", "rna_cpg", "cpg_gpc")) {
        req(input$integ_cpg_mat) # 只强制要求 Matrix
        path_cpg_mat  <- input$integ_cpg_mat$datapath
        # 如果上传了 DMR 则获取路径，否则设为 NULL
        path_cpg_dmr  <- if (!is.null(input$integ_cpg_dmr)) input$integ_cpg_dmr$datapath else NULL
      }
      path_gpc_mat <- NULL
      path_gpc_dmr <- NULL
      if (mode %in% c("tri", "cpg_gpc", "rna_gpc")) {
        req(input$integ_gpc_mat) # 只强制要求 Matrix
        path_gpc_mat  <- input$integ_gpc_mat$datapath
        # 如果上传了 DAR 则获取路径，否则设为 NULL
        path_gpc_dmr <- if (!is.null(input$integ_gpc_dmr)) input$integ_gpc_dmr$datapath else NULL
      }
      # 修复1：加上 "rna_gpc"
      if (mode %in% c("tri", "rna_cpg", "rna_gpc") && input$rna_gene_mode == "diff") {
        req(input$integ_rna_diff)
        path_rna_diff <- input$integ_rna_diff$datapath
      }
    }
    # UI 输入检查
    if (mode %in% c("tri", "rna_cpg", "rna_gpc")) {
      req(Integ_values$rna_obj, input$rna_rds_group_col)
      group_col_rna <- input$rna_rds_group_col
    }
    if (mode %in% c("tri", "rna_cpg", "cpg_gpc")) { req(input$cpg_sheet, input$cpg_id_col, input$cpg_group_col) }
    if (mode %in% c("tri", "cpg_gpc", "rna_gpc")) { req(input$gpc_sheet, input$gpc_id_col, input$gpc_group_col) }
    progress <- shiny::Progress$new()
    progress$set(message = "Starting Integration...", value = 0.1)
    on.exit(progress$close())
    tryCatch({
      # === STEP A: Process Region Annotation (双重提取 ID & Name) ===
      progress$set(detail = "Processing Region Annotation...", value = 0.2)
      region_df <- read.csv(path_region, stringsAsFactors = FALSE)
      col_names <- colnames(region_df)
      id_col <- grep("^gene_id$|^ensembl_id$|^id$", col_names, value = TRUE, ignore.case = TRUE)[1]
      if(is.na(id_col)) stop("Region File Error: Could not find 'gene_id' column.")
      name_col <- grep("^gene_name$|^symbol$|^genename$", col_names, value = TRUE, ignore.case = TRUE)[1]
      if(is.na(name_col)) name_col <- id_col
      region_df$final_gene_id <- region_df[[id_col]]
      region_df$final_gene_name <- region_df[[name_col]]
      if(!"chrdata" %in% colnames(region_df)) {
        if(!all(c("chr", "start", "end") %in% colnames(region_df))) stop("Region File Error: Must have 'chr', 'start', 'end' columns.")
        region_df$chrdata <- paste0(trimws(region_df$chr), ":", trimws(region_df$start), "-", trimws(region_df$end))
      }
      region_df$chrdata <- trimws(region_df$chrdata)
      region_df$chrdata_nochr <- gsub("^chr", "", region_df$chrdata, ignore.case = TRUE)
      region_map <- region_df %>%
        dplyr::select(chrdata, chrdata_nochr, GeneID = final_gene_id, GeneName = final_gene_name) %>%
        mutate(GeneID = toupper(gsub("\\..*|_.*", "", trimws(as.character(GeneID)))),
               GeneName = trimws(as.character(GeneName))) %>%
        dplyr::filter(GeneID != "", !is.na(GeneID))
      gene_id_to_name <- region_map %>% dplyr::select(GeneID, GeneName) %>% dplyr::distinct(GeneID, .keep_all = TRUE)
      # === STEP B: Process RNA (仅在涉及 RNA 的模式下执行) ===
      if (mode %in% c("tri", "rna_cpg", "rna_gpc")) {
        progress$set(detail = "Calculating RNA Averages...", value = 0.3)
        custom_obj <- Integ_values$rna_obj
        meta_df <- if(!is.null(custom_obj$filter_meta.data)) custom_obj$filter_meta.data else custom_obj$meta.data
        meta_df[[group_col_rna]] <- trimws(as.character(meta_df[[group_col_rna]]))
        if(!target_group %in% unique(meta_df[[group_col_rna]])) {
          stop(paste0("RNA Error: Target group '", target_group, "' not found in RNA metadata. Available: ", paste(head(unique(meta_df[[group_col_rna]]), 3), collapse=", ")))
        }
        target_cells <- rownames(meta_df)[which(meta_df[[group_col_rna]] == target_group)]
        rna_assay <- custom_obj$assays$RNA
        rna_prepared <- prepare_rna_matrix(
          rna_assay = rna_assay,
          source = if (is.null(input$rna_matrix_source)) {
            "data"
          } else {
            input$rna_matrix_source
          }
        )
        expr_mat <- rna_prepared$mat
        valid_cells <- intersect(target_cells, colnames(expr_mat))
        if(length(valid_cells) == 0) stop("RNA Error: Sample IDs in metadata do not match RNA matrix column names.")
        valid_rna_genes <- rownames(expr_mat)
        if(input$rna_gene_mode == "diff") {
          rna_diff_df <- data.table::fread(path_rna_diff, data.table = FALSE)
          if(!input$rna_pval_col %in% colnames(rna_diff_df)) stop("RNA Diff Error: P-val column not found!")
          if(!input$rna_logfc_col %in% colnames(rna_diff_df)) stop("RNA Diff Error: logFC column not found!")
          rna_diff_df <- rna_diff_df[rna_diff_df[[input$rna_pval_col]] < input$rna_pval_th & abs(rna_diff_df[[input$rna_logfc_col]]) > input$rna_logfc_th, ]
          gene_col <- grep("id|ensembl|gene_id", colnames(rna_diff_df), ignore.case=T, value=T)[1]
          if(is.na(gene_col)) gene_col <- colnames(rna_diff_df)[1]
          diff_genes <- unique(trimws(as.character(rna_diff_df[[gene_col]])))
          valid_rna_genes <- intersect(valid_rna_genes, diff_genes)
          if(length(valid_rna_genes) == 0) stop("No genes passed the RNA differential thresholds or matched the RDS matrix!")
        }
        sub_mat <- expr_mat[valid_rna_genes, valid_cells, drop = FALSE]
        rna_vals <- Matrix::rowMeans(sub_mat, na.rm = TRUE)
        clean_rna_ids <- toupper(gsub("\\..*|_.*", "", trimws(names(rna_vals))))
        rna_res <- data.frame(GeneID = clean_rna_ids, RNA_Exp = as.numeric(rna_vals), stringsAsFactors = FALSE) %>%
          dplyr::filter(RNA_Exp > 0) %>% dplyr::group_by(GeneID) %>% dplyr::summarise(RNA_Exp = sum(RNA_Exp, na.rm = TRUE)) %>% dplyr::ungroup()
      }
      # === STEP C: Helper for Methylation Processing ===
      # 【Bug修复区】：修复了 dplyr::inner_join 时列名被覆盖导致 chrdata 不存在的问题
      process_meth_layer <- function(mat_path, dmr_path, sheet_name, id_col, group_col, type_name, region_map, filter_mode, pval_col, pval_th, diff_col, diff_th) {
        meta_df <- readxl::read_excel(Integ_values$meta_file_path, sheet = sheet_name)
        meta_df[[group_col]] <- trimws(as.character(meta_df[[group_col]]))
        if(!target_group %in% meta_df[[group_col]]) stop(paste(type_name, "Error: Target group '", target_group, "' not found in Excel sheet", sheet_name))
        target_ids <- trimws(as.character(meta_df %>% dplyr::filter(.data[[group_col]] == target_group) %>% pull(.data[[id_col]])))
        mat <- data.table::fread(mat_path, data.table = FALSE, header = TRUE)
        rownames(mat) <- trimws(as.character(mat[,1])); mat <- mat[,-1]
        valid_ids <- intersect(target_ids, colnames(mat))
        if(length(valid_ids) == 0) stop(paste(type_name, "Error: Sample IDs mismatch."))
        mat_feats <- rownames(mat)
        match_std <- sum(mat_feats %in% region_map$chrdata)
        match_nochr <- sum(mat_feats %in% region_map$chrdata_nochr)
        use_col <- if(match_nochr > match_std) "chrdata_nochr" else "chrdata"
        # 【修改的核心逻辑：支持 DMR 为空】
        if (!is.null(dmr_path) && file.exists(dmr_path)) {
          stats <- read.csv(dmr_path, stringsAsFactors = FALSE)
          if(filter_mode == "filter") {
            if(!pval_col %in% colnames(stats)) stop(paste(type_name, "Diff Error: Column", pval_col, "not found!"))
            if(!diff_col %in% colnames(stats)) stop(paste(type_name, "Diff Error: Column", diff_col, "not found!"))
            stats <- stats[stats[[pval_col]] < pval_th & abs(stats[[diff_col]]) > diff_th, ]
          }
          colnames(stats)[1] <- "chrdata"
          valid_regions <- trimws(as.character(stats$chrdata))
        } else {
          # 如果没有上传 DMR 文件，则使用 Matrix 中的所有位点参与后续整合
          valid_regions <- mat_feats
        }
        common_feats <- intersect(valid_regions, rownames(mat))
        if(length(common_feats) == 0) stop(paste(type_name, "Error: Selected regions do not match Matrix row names."))
        sub_mat <- mat[common_feats, valid_ids, drop=FALSE]
        avg_vals <- rowMeans(sub_mat, na.rm = TRUE)
        res_df <- data.frame(RegionID = names(avg_vals), value = as.numeric(avg_vals), stringsAsFactors = FALSE)
        res_df[[paste0(type_name, "_level")]] <- res_df$value; res_df$value <- NULL
        join_vec <- setNames(use_col, "RegionID")
        # 这里处理合并逻辑
        res_df <- res_df %>% dplyr::inner_join(region_map, by = join_vec)
        # 关键修复：如果在合并中 chrdata 作为 key 被 RegionID 替换了，我们把它重新改回 chrdata
        if (use_col == "chrdata") {
          res_df <- res_df %>% dplyr::rename(chrdata = RegionID)
        }
        res_df <- res_df %>%
          dplyr::select(chrdata, GeneID, !!sym(paste0(type_name, "_level")))
        return(res_df)
      }
      # === STEP D: Execute Processing for CpG and GpC ===
      if (mode %in% c("tri", "rna_cpg", "cpg_gpc")) {
        progress$set(detail = "Processing CpG Data...", value = 0.5)
        cpg_res <- process_meth_layer(path_cpg_mat, path_cpg_dmr, input$cpg_sheet, input$cpg_id_col, input$cpg_group_col, "CpG", region_map, input$cpg_filter_mode, input$cpg_pval_col, input$cpg_pval_th, input$cpg_diff_col, input$cpg_diff_th)
        if(is.null(cpg_res) || nrow(cpg_res) == 0) stop("CpG Error: No overlaps found between Region Annotation and CpG data.")
      }
      if (mode %in% c("tri", "cpg_gpc", "rna_gpc")) {
        progress$set(detail = "Processing GpC Data...", value = 0.6)
        gpc_res <- process_meth_layer(path_gpc_mat, path_gpc_dmr, input$gpc_sheet, input$gpc_id_col, input$gpc_group_col, "GpC", region_map, input$gpc_filter_mode, input$gpc_pval_col, input$gpc_pval_th, input$gpc_diff_col, input$gpc_diff_th)
        if(is.null(gpc_res) || nrow(gpc_res) == 0) stop("GpC Error: No overlaps found between Region Annotation and GpC data.")
      }
      # === STEP E: Dynamic Merge Based on Selected Mode ===
      progress$set(detail = "Aggregating Regions & Merging...", value = 0.8)
      final_region_dict <- region_map %>% dplyr::group_by(GeneID) %>% dplyr::summarise(Associated_Regions = paste(unique(chrdata), collapse = ":")) %>% dplyr::ungroup()
      if (mode == "tri") {
        # 模式 1: 三组学 (依赖 Gene ID)
        cpg_agg <- cpg_res %>% dplyr::group_by(GeneID) %>% dplyr::summarise(CpG_level = mean(CpG_level, na.rm=TRUE))
        gpc_agg <- gpc_res %>% dplyr::group_by(GeneID) %>% dplyr::summarise(GpC_level = mean(GpC_level, na.rm=TRUE))
        merged_df <- rna_res %>%
          dplyr::inner_join(cpg_agg, by = "GeneID") %>%
          dplyr::inner_join(gpc_agg, by = "GeneID") %>%
          dplyr::left_join(final_region_dict, by = "GeneID") %>%
          dplyr::left_join(gene_id_to_name, by = "GeneID") %>%
          dplyr::select(Associated_Regions, GeneID, GeneName, RNA_Exp, CpG_level, GpC_level)
      } else if (mode == "rna_cpg") {
        # 模式 2: RNA + DNA甲基化 (依赖 Gene ID)
        cpg_agg <- cpg_res %>% dplyr::group_by(GeneID) %>% dplyr::summarise(CpG_level = mean(CpG_level, na.rm=TRUE))
        merged_df <- rna_res %>%
          dplyr::inner_join(cpg_agg, by = "GeneID") %>%
          dplyr::left_join(final_region_dict, by = "GeneID") %>%
          dplyr::left_join(gene_id_to_name, by = "GeneID") %>%
          dplyr::select(Associated_Regions, GeneID, GeneName, RNA_Exp, CpG_level)
      } else if (mode == "rna_gpc") {
        # 模式 3: RNA + 染色质开放性 (依赖 Gene ID)
        gpc_agg <- gpc_res %>% dplyr::group_by(GeneID) %>% dplyr::summarise(GpC_level = mean(GpC_level, na.rm=TRUE))
        merged_df <- rna_res %>%
          dplyr::inner_join(gpc_agg, by = "GeneID") %>%
          dplyr::left_join(final_region_dict, by = "GeneID") %>%
          dplyr::left_join(gene_id_to_name, by = "GeneID") %>%
          dplyr::select(Associated_Regions, GeneID, GeneName, RNA_Exp, GpC_level)
      } else if (mode == "cpg_gpc") {
        # 模式 4: DNA甲基化 + 染色质开放性 (依赖 Region chrdata)
        # 针对 chrdata 取平均值（如果有重复区域），并提取首个匹配的 GeneID 用于显示
        cpg_reg <- cpg_res %>% dplyr::group_by(chrdata) %>% dplyr::summarise(CpG_level = mean(CpG_level, na.rm=TRUE), GeneID = dplyr::first(GeneID))
        gpc_reg <- gpc_res %>% dplyr::group_by(chrdata) %>% dplyr::summarise(GpC_level = mean(GpC_level, na.rm=TRUE), GeneID = dplyr::first(GeneID))
        merged_df <- dplyr::inner_join(cpg_reg, gpc_reg, by = "chrdata") %>%
          dplyr::rename(Associated_Regions = chrdata, GeneID = GeneID.x) %>%
          dplyr::left_join(gene_id_to_name, by = "GeneID") %>%
          dplyr::select(Associated_Regions, GeneID, GeneName, CpG_level, GpC_level)
      }
      if(nrow(merged_df) == 0) {
        stop("Integration Failed: No overlapping elements found between the chosen Omics layers.")
      }
      Integ_values$merged_df <- merged_df
      progress$set(detail = "Integration Complete!", value = 1)
      showNotification(paste("Success! Fully integrated", nrow(merged_df), "features."), type = "message", duration = 8)
    }, error = function(e){
      print(e)
      showModal(modalDialog(
        title = span(icon("exclamation-triangle"), " Integration Error"),
        p("The system encountered an error during data integration:"),
        tags$div(style="color: red; font-weight: bold; padding: 10px; background-color: #ffe6e6; border-radius: 5px;", e$message),
        easyClose = TRUE, footer = modalButton("Close")
      ))
    })
    toc()
  })

  observeEvent(input$integ_btn_use_example, {
    showNotification("Loading Example Data... Please wait.", type = "message")
    Integ_values$use_example <- TRUE
    updateTextInput(session, "global_target_group", value = "E4.5")
    updateRadioButtons(session, "integ_mode", selected = "tri") # 示例默认三组学
    updateRadioButtons(session, "rna_gene_mode", selected = "diff")
    updateRadioButtons(session, "cpg_filter_mode", selected = "all")
    updateRadioButtons(session, "gpc_filter_mode", selected = "all")
    js_code <- "
    $('#integ_region_file').closest('.input-group').find('input[type=\"text\"]').val('example_region.csv');
    $('#integ_meta_file').closest('.input-group').find('input[type=\"text\"]').val('example_metadata.xlsx');
    $('#integ_rna_rds').closest('.input-group').find('input[type=\"text\"]').val('example_RNA.rds');
    $('#integ_rna_diff').closest('.input-group').find('input[type=\"text\"]').val('example_RNA_Diff.csv');
    $('#integ_cpg_mat').closest('.input-group').find('input[type=\"text\"]').val('example_CpG_Matrix.csv');
    $('#integ_cpg_dmr').closest('.input-group').find('input[type=\"text\"]').val('example_CpG_DMR.csv');
    $('#integ_gpc_mat').closest('.input-group').find('input[type=\"text\"]').val('example_GpC_Matrix.csv');
    $('#integ_gpc_dmr').closest('.input-group').find('input[type=\"text\"]').val('example_GpC_DMR.csv');
  "
    shinyjs::runjs(js_code)
    ex_path_meta   <- "data/GSE121690_sample_final_choose.xlsx"
    ex_path_rna    <- "data/sciET_Object_2026-03-30.rds"
    ex_path_rndiff <- "data/Markers_E4.5_vs_Rest_2026-03-30.csv"
    tryCatch({
      Integ_values$meta_file_path <- ex_path_meta
      sheets <- readxl::excel_sheets(ex_path_meta)
      Integ_values$sheets <- sheets
      output$ui_cpg_sheet_select <- renderUI({ selectInput("cpg_sheet", "Select CpG Sheet:", choices = sheets, selected = "CpG") })
      output$ui_gpc_sheet_select <- renderUI({ selectInput("gpc_sheet", "Select GpC Sheet:", choices = sheets, selected = "GpC") })
      custom_obj <- readRDS(ex_path_rna)
      Integ_values$rna_obj <- custom_obj
      meta_df <- if(!is.null(custom_obj$filter_meta.data)) custom_obj$filter_meta.data else custom_obj$meta.data
      meta_cols <- colnames(meta_df)
      output$ui_rna_rds_group_col <- renderUI({
        default_col <- meta_cols[1]
        if ("Developmental_stage" %in% meta_cols) default_col <- "Developmental_stage"
        else if ("Development_stage" %in% meta_cols) default_col <- "Development_stage"
        selectInput("rna_rds_group_col", "Choose Grouping Column:", choices = meta_cols, selected = default_col)
      })
      rna_diff_cols <- colnames(data.table::fread(ex_path_rndiff, nrows = 1, data.table = FALSE))
      guess_pval <- grep("p.*val|padj|fdr", rna_diff_cols, ignore.case = TRUE, value = TRUE)[1]
      guess_lfc <- grep("log.*fc|fold.*change", rna_diff_cols, ignore.case = TRUE, value = TRUE)[1]
      output$ui_rna_pval_col <- renderUI({ selectInput("rna_pval_col", "P-val Col:", choices = rna_diff_cols, selected = ifelse(is.na(guess_pval), rna_diff_cols[1], guess_pval)) })
      output$ui_rna_logfc_col <- renderUI({ selectInput("rna_logfc_col", "logFC Col:", choices = rna_diff_cols, selected = ifelse(is.na(guess_lfc), rna_diff_cols[2], guess_lfc)) })
    }, error = function(e){ showNotification(paste("Error loading example files:", e$message), type = "error") })
  })

  observeEvent(input$integ_btn_reset, {
    showModal(modalDialog(
      title = span(icon("exclamation-triangle"), " Warning: Destructive Action", style = "color: red;"),
      "This will permanently delete all uploaded Omics files, RNA objects, aggregated matrices, and integration results from RAM. Are you sure you want to reset the system?",
      footer = tagList(modalButton("Cancel"), actionButton("confirm_reset_integ", "Yes, Clear Everything", class = "btn-danger", icon = icon("trash-alt")))
    ))
  })

  observeEvent(input$confirm_reset_integ, {
    removeModal()
    progress <- shiny::Progress$new()
    on.exit(progress$close())
    progress$set(message = "Executing Deep System Purge...", value = 0.3)
    Integ_values$meta_file_path <- NULL; Integ_values$sheets <- NULL; Integ_values$rna_obj <- NULL
    Integ_values$merged_df <- NULL; Integ_values$plot_scatter_obj <- NULL; Integ_values$plot_matrix_obj <- NULL
    Integ_values$use_example <- FALSE
    progress$set(message = "Resetting UI Inputs...", value = 0.5)
    try({
      shinyjs::reset("integ_region_file"); shinyjs::reset("integ_meta_file"); shinyjs::reset("integ_rna_rds"); shinyjs::reset("integ_rna_diff")
      shinyjs::reset("integ_cpg_mat"); shinyjs::reset("integ_cpg_dmr"); shinyjs::reset("integ_gpc_mat"); shinyjs::reset("integ_gpc_dmr")
    }, silent = TRUE)
    updateTextInput(session, "global_target_group", value = "")
    updateRadioButtons(session, "integ_mode", selected = "tri")
    updateRadioButtons(session, "rna_gene_mode", selected = "all"); updateNumericInput(session, "rna_pval_th", value = 0.05); updateNumericInput(session, "rna_logfc_th", value = 0.5)
    updateRadioButtons(session, "cpg_filter_mode", selected = "all"); updateNumericInput(session, "cpg_pval_th", value = 0.05); updateNumericInput(session, "cpg_diff_th", value = 20)
    updateRadioButtons(session, "gpc_filter_mode", selected = "all"); updateNumericInput(session, "gpc_pval_th", value = 0.05); updateNumericInput(session, "gpc_diff_th", value = 10)
    output$ui_rna_rds_group_col <- renderUI(NULL); output$txt_rna_avail_groups <- renderText(NULL); output$ui_rna_pval_col <- renderUI(NULL); output$ui_rna_logfc_col <- renderUI(NULL)
    output$ui_cpg_sheet_select <- renderUI(NULL); output$ui_cpg_id_col <- renderUI(NULL); output$ui_cpg_group_col <- renderUI(NULL); output$ui_cpg_pval_col <- renderUI(NULL); output$ui_cpg_diff_col <- renderUI(NULL)
    output$ui_gpc_sheet_select <- renderUI(NULL); output$ui_gpc_id_col <- renderUI(NULL); output$ui_gpc_group_col <- renderUI(NULL); output$ui_gpc_pval_col <- renderUI(NULL); output$ui_gpc_diff_col <- renderUI(NULL)
    progress$set(message = "Annihilating Ghost Processes...", value = 0.7)
    future::plan(future::sequential)
    progress$set(message = "Reclaiming Physical RAM...", value = 0.9)
    objs_to_rm <- ls(pattern = "^cpg_|^gpc_|^rna_|^merged_|^sub_mat|^custom_obj")
    if (length(objs_to_rm) > 0) suppressWarnings(rm(list = objs_to_rm, envir = environment()))
    gc(verbose = FALSE, reset = TRUE, full = TRUE)
    progress$set(message = "System Restored", value = 1)
    showNotification("Complete Reset Successful.", type = "warning", duration = 8)
  })

  # 4.2 Scatter Plot: Dynamically adapt to selected columns
  output$integ_plot_scatter <- renderPlot({
    req(Integ_values$merged_df)
    df <- Integ_values$merged_df
    my_theme <- theme_bw(base_size = 14) + theme(panel.grid.minor = element_blank())
    plot_list <- list()
    if("CpG_level" %in% names(df) && "RNA_Exp" %in% names(df)) {
      p1 <- ggplot(df, aes(x=CpG_level, y=RNA_Exp)) + geom_point(alpha=0.6, size=1.5, color="#4DBBD5") + geom_smooth(method="lm", color="black", linetype="dashed", se=TRUE) + stat_cor(method = "spearman", label.x.npc = "left", label.y.npc = "top", size = 5) + labs(x = "CpG Methylation", y = "RNA Expression") + my_theme
      plot_list <- append(plot_list, list(p1))
    }
    if("GpC_level" %in% names(df) && "RNA_Exp" %in% names(df)) {
      p2 <- ggplot(df, aes(x=GpC_level, y=RNA_Exp)) + geom_point(alpha=0.6, size=1.5, color="#00A087") + geom_smooth(method="lm", color="black", linetype="dashed", se=TRUE) + stat_cor(method = "spearman", label.x.npc = "left", label.y.npc = "top", size = 5) + labs(x = "GpC Accessibility", y = "RNA Expression") + my_theme
      plot_list <- append(plot_list, list(p2))
    }
    if("CpG_level" %in% names(df) && "GpC_level" %in% names(df)) {
      p3 <- ggplot(df, aes(x=CpG_level, y=GpC_level)) + geom_point(alpha=0.6, size=1.5, color="#E64B35") + geom_smooth(method="lm", color="black", linetype="dashed", se=TRUE) + stat_cor(method = "spearman", label.x.npc = "left", label.y.npc = "top", size = 5) + labs(x = "CpG Methylation", y = "GpC Accessibility") + my_theme
      plot_list <- append(plot_list, list(p3))
    }
    final_p <- patchwork::wrap_plots(plot_list, ncol = length(plot_list))
    Integ_values$plot_scatter_obj <- final_p
    return(final_p)
  })

  # 4.3 Matrix Plot: Dynamic adaptation
  output$integ_plot_matrix <- renderPlot({
    req(Integ_values$merged_df)
    df <- Integ_values$merged_df
    cols_sel <- c()
    if("RNA_Exp" %in% names(df)) cols_sel <- c(cols_sel, "RNA" = "RNA_Exp")
    if("CpG_level" %in% names(df)) cols_sel <- c(cols_sel, "CpG" = "CpG_level")
    if("GpC_level" %in% names(df)) cols_sel <- c(cols_sel, "GpC" = "GpC_level")
    plot_df <- df %>% dplyr::select(dplyr::all_of(cols_sel))
    plot_density <- function(data, var, title_text) {
      ggplot(data, aes_string(x = var)) + geom_density(fill = "#B09C85", alpha = 0.5, color = "black") + theme_bw(base_size = 12) + theme(panel.grid.minor = element_blank(), axis.title = element_blank(), axis.text.y = element_blank(), axis.ticks.y = element_blank()) + annotate("text", x = Inf, y = Inf, label = title_text, hjust = 1.2, vjust = 1.5, size = 5, fontface = "bold")
    }
    plot_scatter_matrix <- function(data, x_var, y_var) {
      ggplot(data, aes_string(x = x_var, y = y_var)) + geom_point(alpha = 0.5, size = 1, color = "#3C5488") + theme_bw(base_size = 12) + theme(panel.grid.minor = element_blank())
    }
    plot_cor_text <- function(data, x_var, y_var) {
      r_val <- cor(data[[x_var]], data[[y_var]], method = "spearman", use = "complete.obs")
      lbl <- sprintf("R = %.2f", r_val)
      ggplot() + annotate("text", x = 0.5, y = 0.5, label = lbl, size = 6, fontface = "bold", color = "black") + theme_void() + theme(panel.border = element_rect(color = "grey80", fill = NA, size = 1))
    }
    if (ncol(plot_df) == 3) {
      p11 <- plot_density(plot_df, "RNA", "RNA Exp"); p12 <- plot_cor_text(plot_df, "RNA", "CpG"); p13 <- plot_cor_text(plot_df, "RNA", "GpC")
      p21 <- plot_scatter_matrix(plot_df, "RNA", "CpG") + labs(x = "", y = "CpG"); p22 <- plot_density(plot_df, "CpG", "CpG Level"); p23 <- plot_cor_text(plot_df, "CpG", "GpC")
      p31 <- plot_scatter_matrix(plot_df, "RNA", "GpC") + labs(x = "RNA", y = "GpC"); p32 <- plot_scatter_matrix(plot_df, "CpG", "GpC") + labs(x = "CpG", y = ""); p33 <- plot_density(plot_df, "GpC", "GpC Level")
      p_mat <- (p11 | p12 | p13) / (p21 | p22 | p23) / (p31 | p32 | p33)
    } else if (ncol(plot_df) == 2) {
      v1 <- names(plot_df)[1]; v2 <- names(plot_df)[2]
      p11 <- plot_density(plot_df, v1, paste(v1, "Level")); p12 <- plot_cor_text(plot_df, v1, v2)
      p21 <- plot_scatter_matrix(plot_df, v1, v2) + labs(x = v1, y = v2); p22 <- plot_density(plot_df, v2, paste(v2, "Level"))
      p_mat <- (p11 | p12) / (p21 | p22)
    }
    p_mat <- p_mat + patchwork::plot_annotation(title = "Omics Correlation Matrix", theme = theme(plot.title = element_text(size = 18, face = "bold", hjust = 0.5)))
    Integ_values$plot_matrix_obj <- p_mat
    return(p_mat)
  })

  output$integ_table <- DT::renderDT({
    req(Integ_values$merged_df)
    cols_to_round <- intersect(c("RNA_Exp", "CpG_level", "GpC_level"), colnames(Integ_values$merged_df))
    DT::datatable(Integ_values$merged_df, options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE) %>%
      DT::formatRound(columns = cols_to_round, digits = 3)
  })
  output$integ_download_data <- downloadHandler(filename = function() { paste0("Integrated_Data_", input$global_target_group, ".csv") }, content = function(file) { data.table::fwrite(Integ_values$merged_df, file, row.names = FALSE) })
  output$integ_download_scatter_pdf <- downloadHandler(filename = function() { paste0("MultiOmics_Correlations_", input$global_target_group, ".pdf") }, content = function(file) { req(Integ_values$plot_scatter_obj); width_val <- ifelse(ncol(Integ_values$merged_df) > 5, 15, 6); ggsave(file, plot = Integ_values$plot_scatter_obj, width = width_val, height = 5, device = "pdf") })
  output$integ_download_matrix_pdf <- downloadHandler(filename = function() { paste0("MultiOmics_MatrixPlot_", input$global_target_group, ".pdf") }, content = function(file) { req(Integ_values$plot_matrix_obj); ggsave(file, plot = Integ_values$plot_matrix_obj, width = 8, height = 8, device = "pdf") })
  output$integ_btn_dl_example <- downloadHandler(filename = function() { paste0("scMATE_MultiOmics_Example_", Sys.Date(), ".zip") }, content = function(file) { existing_zip <- "data/Integration_example_data.zip"; if (file.exists(existing_zip)) { file.copy(existing_zip, file) } else { stop("Example ZIP file is missing!") } }, contentType = "application/zip")
  # Data Integration 模块 - 顶部数据概览 Boxes
  output$integ_features_box <- renderValueBox({
    num <- 0; box_title <- "Awaiting Integration"
    if (!is.null(Integ_values$merged_df)) { num <- nrow(Integ_values$merged_df); box_title <- "Overlapped Features" }
    custom_css <- tags$style(HTML("#integ_features_box .small-box { height: 115px !important; background-color: #FAF5FF !important; color: #6B21A8 !important; border-left: 5px solid #A855F7 !important; border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; } #integ_features_box .small-box .icon-large { color: #D8B4FE !important; opacity: 0.4; } #integ_features_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }"))
    val_display <- if(num > 0) format(num, big.mark = ",") else "0"
    valueBox(value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #7E22CE;", val_display)), subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #9333EA;", box_title), icon = icon("project-diagram"), color = "purple")
  })

  output$integ_samples_box <- renderValueBox({
    box_title <- "Target Group"; display_val <- "None"
    if (!is.null(input$global_target_group) && trimws(input$global_target_group) != "") {
      display_val <- trimws(input$global_target_group)
      box_title <- if (!is.null(Integ_values$merged_df)) "Harmonized Group" else "Target Group Staged"
    }
    custom_css <- tags$style(HTML("#integ_samples_box .small-box { height: 115px !important; background-color: #F0F8FF !important; color: #1E3A8A !important; border-left: 5px solid #3B82F6 !important; border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; } #integ_samples_box .small-box .icon-large { color: #93C5FD !important; opacity: 0.4; } #integ_samples_box .small-box h3, #integ_samples_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }"))
    valueBox(value = tagList(custom_css, tags$span(style = "font-weight: 800; font-size: 30px; color: #1D4ED8;", display_val)), subtitle = tags$span(style = "font-weight: 600; font-size: 15px; color: #3B82F6;", box_title), icon = icon("vials"), color = "light-blue")
  })

  output$integ_status_box <- renderValueBox({
    is_merged <- !is.null(Integ_values$merged_df)
    mode <- input$integ_mode
    # 基础共同条件：需要有区域文件和输入正确的 Target Group
    is_ready <- !is.null(input$integ_region_file) && !is.null(input$global_target_group) && trimws(input$global_target_group) != ""
    # 动态适配各类模式的必需文件检查
    if (!is.null(mode)) {
      if(mode == "tri") {
        is_ready <- is_ready && !is.null(Integ_values$rna_obj) && !is.null(input$integ_cpg_mat) && !is.null(input$integ_gpc_mat)
      } else if(mode == "rna_cpg") {
        is_ready <- is_ready && !is.null(Integ_values$rna_obj) && !is.null(input$integ_cpg_mat)
      } else if(mode == "rna_gpc") {
        is_ready <- is_ready && !is.null(Integ_values$rna_obj) && !is.null(input$integ_gpc_mat)
      } else if(mode == "cpg_gpc") {
        is_ready <- is_ready && !is.null(input$integ_cpg_mat) && !is.null(input$integ_gpc_mat)
      }
    } else {
      is_ready <- FALSE
    }
    if (is_merged) {
      status_text <- "Success"; subtitle_text <- "Matrices Harmonized"; bg_color <- "#F0FDFA" ; border_color <- "#14B8A6" ; text_color <- "#0F766E" ; icon_color <- "#5EEAD4"; box_icon <- "check-circle"
    } else if (is_ready) {
      status_text <- "Ready to Run"; subtitle_text <- "Click Rocket Icon"; bg_color <- "#EEF2FF" ; border_color <- "#6366F1" ; text_color <- "#4338CA" ; icon_color <- "#A5B4FC"; box_icon <- "play-circle"
    } else {
      status_text <- "Pending"; subtitle_text <- "Upload Required Data"; bg_color <- "#FFFBEB" ; border_color <- "#F59E0B" ; text_color <- "#B45309" ; icon_color <- "#FDE68A"; box_icon <- "exclamation-circle"
    }
    custom_css <- tags$style(HTML(sprintf("#integ_status_box .small-box { height: 115px !important; background-color: %s !important; border-left: 5px solid %s !important; border-radius: 8px !important; box-shadow: 0 4px 6px rgba(0,0,0,0.05) !important; } #integ_status_box .small-box .icon-large { color: %s !important; opacity: 0.4; } #integ_status_box .small-box p { white-space: nowrap; overflow: hidden; text-overflow: ellipsis; padding-right: 15px; }", bg_color, border_color, icon_color)))
    valueBox(value = tagList(custom_css, tags$span(style = sprintf("font-weight: 800; font-size: 30px; color: %s;", text_color), status_text)), subtitle = tags$span(style = sprintf("font-weight: 600; font-size: 15px; color: %s;", text_color), subtitle_text), icon = icon(box_icon), color = "yellow")
  })


  # ---- Multi-omics Data Analysis (Fixed & Enhanced) ----
  Multi_values <- reactiveValues(
    raw_data = NULL,
    topo_plot = NULL,
    states_plot = NULL,
    heatmap_plot = NULL,
    topo_data = NULL,      # 新增：拓扑图数据
    states_data = NULL,    # 新增：状态统计数据
    heatmap_data = NULL,   # 新增：热图打分数据
    unlink_step1 = FALSE   # 新增：用于拦截 Step1 数据的软断开标志
  )

  # --- 1. 智能数据路由 (UI 渲染) ---
  output$ui_multi_data_source <- renderUI({
    # 核心修改：增加 isFALSE(Multi_values$unlink_step1) 判断
    if (!is.null(Integ_values$merged_df) && nrow(Integ_values$merged_df) > 0 && isFALSE(Multi_values$unlink_step1)) {
      div(
        style = "padding: 10px; background-color: #d4edda; border-left: 5px solid #28a745; border-radius: 4px;",
        h5(icon("check-circle"), " Data Linked Successfully", style = "color: #155724; font-weight: bold; margin-top: 0;"),
        p(paste("Using integrated data from Step 1 (", nrow(Integ_values$merged_df), " genes)."), style = "color: #155724; margin-bottom: 0;")
      )
    } else {
      # 否则，显示黄框，要求用户上传 CSV
      div(
        style = "padding: 10px; background-color: #fff3cd; border-left: 5px solid #ffc107; border-radius: 4px;",
        h5(icon("exclamation-triangle"), " Manual Upload Mode", style = "color: #856404; font-weight: bold; margin-top: 0;"),
        fileInput("multi_upload_file", "Upload Integrated Data (CSV)", accept = ".csv", width = "100%")
      )
    }
  })

  # --- 2. 核心数据获取与染色体扫描 ---
  observe({
    # 获取数据逻辑
    if (!is.null(Integ_values$merged_df) && nrow(Integ_values$merged_df) > 0 && isFALSE(Multi_values$unlink_step1)) {
      Multi_values$raw_data <- Integ_values$merged_df
    } else if (!is.null(input$multi_upload_file)) {
      Multi_values$raw_data <- read.csv(input$multi_upload_file$datapath, stringsAsFactors = FALSE)
    } else {
      Multi_values$raw_data <- NULL
    }
    # 一旦有了数据，立刻解析染色体并更新下拉框
    if (!is.null(Multi_values$raw_data) && "Associated_Regions" %in% colnames(Multi_values$raw_data)) {
      df <- Multi_values$raw_data
      # 极速提取 chr 名称
      chrs <- stringr::str_extract(df$Associated_Regions[!is.na(df$Associated_Regions)], "^[^:]+")
      chrs <- unique(chrs)
      chrs <- chrs[!is.na(chrs) & chrs != ""]
      # 为了美观，尝试对染色体进行自然排序 (chr1, chr2 ... chrX)
      chrs <- str_sort(chrs, numeric = TRUE)
      output$ui_topo_chr_select <- renderUI({
        selectInput("topo_chr", "Select Chromosome:", choices = chrs, selected = chrs[1])
      })
    }
  })

  output$ui_topo_gene_select <- renderUI({
    req(Multi_values$raw_data, input$topo_chr)
    df <- Multi_values$raw_data
    # 动态解析所在染色体，获取该染色体的所有基因
    if (all(c("chr", "GeneName") %in% colnames(df))) {
      chr_df <- df %>% dplyr::filter(chr == input$topo_chr)
    } else if (all(c("Associated_Regions", "GeneName") %in% colnames(df))) {
      chr_df <- df %>%
        dplyr::filter(!is.na(Associated_Regions) & Associated_Regions != "") %>%
        dplyr::filter(stringr::str_extract(Associated_Regions, "^[^:]+") == input$topo_chr)
    } else {
      return(NULL)
    }
    # 提取基因并排序
    genes <- unique(chr_df$GeneName)
    genes <- sort(genes[!is.na(genes) & genes != ""])
    # 使用 selectizeInput 支持搜索，加入 "None" 选项表示不进行高亮
    selectizeInput("topo_gene", "Highlight Gene (Optional):",
                   choices = c("None", genes),
                   selected = "None",
                   multiple = FALSE)
  })

  # --- 3. 功能一：染色体级别的空间拓扑映射 ---
  observeEvent(input$btn_run_topo, {
    req(Multi_values$raw_data, input$topo_chr)
    df <- Multi_values$raw_data
    target_chr <- input$topo_chr
    # 动态检测存在哪些组学列
    has_rna <- "RNA_Exp" %in% colnames(df)
    has_cpg <- "CpG_level" %in% colnames(df)
    has_gpc <- "GpC_level" %in% colnames(df)
    avail_omics <- c()
    if(has_rna) avail_omics <- c(avail_omics, "RNA_Exp")
    if(has_cpg) avail_omics <- c(avail_omics, "CpG_level")
    if(has_gpc) avail_omics <- c(avail_omics, "GpC_level")
    progress <- shiny::Progress$new()
    progress$set(message = paste("Mapping Topology on", target_chr), value = 0.5)
    on.exit(progress$close())
    tryCatch({
      # 1. 坐标解析 (动态兼容独立列与字符串格式)
      if (all(c("chr", "start", "end") %in% colnames(df))) {
        topo_df <- df %>%
          dplyr::mutate(
            start = as.numeric(start),
            end = as.numeric(end),
            midpoint_MB = (start + end) / 2 / 1e6
          ) %>%
          dplyr::filter(chr == target_chr & !is.na(start) & !is.na(end))
      } else if ("Associated_Regions" %in% colnames(df)) {
        topo_df <- df %>%
          dplyr::filter(!is.na(Associated_Regions) & Associated_Regions != "") %>%
          dplyr::mutate(
            chr = stringr::str_extract(Associated_Regions, "^[^:]+"),
            start = as.numeric(stringr::str_extract(Associated_Regions, "(?<=:)\\d+")),
            end = as.numeric(stringr::str_extract(Associated_Regions, "(?<=-)\\d+")),
            midpoint_MB = (start + end) / 2 / 1e6
          ) %>%
          dplyr::filter(chr == target_chr & !is.na(start) & !is.na(end))
      } else {
        stop("Genomic coordinates not found! Need either 'chr/start/end' or 'Associated_Regions' columns.")
      }
      if(nrow(topo_df) < 5) stop("Not enough regions on this chromosome to plot topology.")
      # 2. 数据长格式转换 (动态列)
      plot_data <- topo_df %>%
        tidyr::pivot_longer(
          cols = dplyr::all_of(avail_omics),
          names_to = "Omics",
          values_to = "Value"
        ) %>%
        dplyr::mutate(Omics = factor(Omics, levels = c("RNA_Exp", "CpG_level", "GpC_level")))
      Multi_values$topo_data <- plot_data
      # 3. 绘图美化 (Publication Ready)
      my_colors <- c("RNA_Exp" = "#E64B35", "CpG_level" = "#4DBBD5", "GpC_level" = "#00A087")
      p <- ggplot(plot_data, aes(x = midpoint_MB, y = Value, color = Omics, fill = Omics)) +
        geom_point(alpha = 0.6, size = 2) +
        geom_smooth(method = "loess", span = 0.4, alpha = 0.2, se = FALSE, linewidth = 1.2) +
        facet_grid(Omics ~ ., scales = "free_y", switch = "y") +
        scale_color_manual(values = my_colors) +
        scale_fill_manual(values = my_colors) +
        theme_minimal(base_size = 14) +
        theme(
          strip.placement = "outside",
          strip.background = element_rect(fill = "grey95", color = NA),
          strip.text = element_text(face = "bold", size = 15),
          panel.grid.major.x = element_line(color = "grey80", linetype = "dashed"),
          panel.grid.minor = element_blank(),
          panel.border = element_rect(color = "grey80", fill = NA),
          legend.position = "none"
        ) +
        labs(
          title = paste("Spatial Multi-omics Topology along", target_chr),
          subtitle = paste("Mapped", length(avail_omics), "Omics layers dynamically"),
          x = paste(target_chr, "Physical Genomic Position (Megabases)"),
          y = NULL
        )
      if (!is.null(input$topo_gene) && input$topo_gene != "None" && "GeneName" %in% colnames(topo_df)) {
        # 寻找选中基因在当前坐标系中的物理位置
        gene_info <- topo_df %>% dplyr::filter(GeneName == input$topo_gene)
        if (nrow(gene_info) > 0) {
          hl_pos <- mean(gene_info$midpoint_MB, na.rm = TRUE) # 取平均值防止重复匹配
          p <- p +
            # 添加一条贯穿所有组学面板的垂直虚线
            geom_vline(xintercept = hl_pos, color = "#9C27B0", linetype = "dashed", linewidth = 1) +
            # 在顶部标注基因名称（y = Inf 配合 vjust 会自适应每个分面的最高处）
            annotate("label", x = hl_pos, y = Inf, label = input$topo_gene,
                     vjust = 1.2, color = "white", fill = "#9C27B0", fontface = "bold", alpha = 0.8)
          # 更改一下副标题提示
          p <- p + labs(subtitle = paste("Highlighted Gene:", input$topo_gene, "at ~", round(hl_pos, 2), "MB"))
        }
      }
      # 将最终绘制好的图保存进 reactiveValues
      Multi_values$topo_plot <- p
      showNotification("Topology map generated successfully!", type = "message")
      updateTabsetPanel(session, inputId = "multi_result_tabset", selected = "tab_topo")
    }, error = function(e){ showNotification(paste("Topology Error:", e$message), type = "error") })
  })

  output$plot_multi_topo <- renderPlot({ req(Multi_values$topo_plot); Multi_values$topo_plot })

  # --- 4. 功能二 & 三：状态分类与 Z-score 驱动基因打分 ---
  observeEvent(input$btn_run_states_heatmap, {
    req(Multi_values$raw_data)
    df <- Multi_values$raw_data
    top_n <- input$num_top_genes
    # 动态检测存在哪些列
    has_rna <- "RNA_Exp" %in% colnames(df)
    has_cpg <- "CpG_level" %in% colnames(df)
    has_gpc <- "GpC_level" %in% colnames(df)
    req_cols <- c("GeneName")
    if(has_rna) req_cols <- c(req_cols, "RNA_Exp")
    if(has_cpg) req_cols <- c(req_cols, "CpG_level")
    if(has_gpc) req_cols <- c(req_cols, "GpC_level")
    if(length(req_cols) < 3) {
      showNotification("Error: Need at least 2 Omics layers for joint analysis.", type = "error")
      return(NULL)
    }
    progress <- shiny::Progress$new()
    progress$set(message = "Calculating Epigenetic States...", value = 0.3)
    on.exit(progress$close())
    tryCatch({
      # 1. 动态状态分类逻辑 (根据不同整合模式赋不同生物学意义)
      if (has_rna && has_cpg && has_gpc) {
        # 模式1: 3 组学经典 5 状态
        med_rna <- median(df$RNA_Exp, na.rm = TRUE)
        med_cpg <- median(df$CpG_level, na.rm = TRUE)
        med_gpc <- median(df$GpC_level, na.rm = TRUE)
        df_state <- df %>%
          dplyr::mutate(Reg_State = dplyr::case_when(
            RNA_Exp >= med_rna & CpG_level < med_cpg & GpC_level >= med_gpc ~ "1_Fully_Activated",
            RNA_Exp < med_rna & CpG_level > med_cpg & GpC_level < med_gpc ~ "2_Fully_Silenced",
            RNA_Exp > med_rna & CpG_level > med_cpg ~ "3_Paradox_Active",
            RNA_Exp <= med_rna & CpG_level < med_cpg ~ "4_Poised_State",
            TRUE ~ "5_Intermediate"
          ))
        pal <- c("1_Fully_Activated"="#DC0000", "2_Fully_Silenced"="#4DBBD5", "3_Paradox_Active"="#F39B7F", "4_Poised_State"="#3C5488", "5_Intermediate"="#B09C85")
        state_labels <- c("1_Fully_Activated"="1. Fully Activated", "2_Fully_Silenced"="2. Fully Silenced", "3_Paradox_Active"="3. Paradox Active", "4_Poised_State"="4. Poised State", "5_Intermediate"="5. Intermediate")
      } else if (has_rna && has_cpg) {
        # 模式2: RNA + CpG (4 状态)
        med_rna <- median(df$RNA_Exp, na.rm = TRUE)
        med_cpg <- median(df$CpG_level, na.rm = TRUE)
        df_state <- df %>%
          dplyr::mutate(Reg_State = dplyr::case_when(
            RNA_Exp >= med_rna & CpG_level < med_cpg ~ "1_Active_Unmethylated",
            RNA_Exp < med_rna & CpG_level >= med_cpg ~ "2_Silenced_Methylated",
            RNA_Exp >= med_rna & CpG_level >= med_cpg ~ "3_Paradox_Active",
            RNA_Exp < med_rna & CpG_level < med_cpg ~ "4_Poised_Silenced"
          ))
        pal <- c("1_Active_Unmethylated"="#DC0000", "2_Silenced_Methylated"="#4DBBD5", "3_Paradox_Active"="#F39B7F", "4_Poised_Silenced"="#3C5488")
        state_labels <- c("1_Active_Unmethylated"="1. Active & UnMeth", "2_Silenced_Methylated"="2. Silenced & Meth", "3_Paradox_Active"="3. Paradox Active", "4_Poised_Silenced"="4. Poised / Silenced")
      } else if (has_cpg && has_gpc) {
        # 模式3: CpG + GpC (4 状态)
        med_cpg <- median(df$CpG_level, na.rm = TRUE)
        med_gpc <- median(df$GpC_level, na.rm = TRUE)
        df_state <- df %>%
          dplyr::mutate(Reg_State = dplyr::case_when(
            GpC_level >= med_gpc & CpG_level < med_cpg ~ "1_Accessible_Active",
            GpC_level < med_gpc & CpG_level >= med_cpg ~ "2_Closed_Silenced",
            GpC_level >= med_gpc & CpG_level >= med_cpg ~ "3_Accessible_Meth",
            GpC_level < med_gpc & CpG_level < med_cpg ~ "4_Closed_Unmeth"
          ))
        pal <- c("1_Accessible_Active"="#DC0000", "2_Closed_Silenced"="#4DBBD5", "3_Accessible_Meth"="#F39B7F", "4_Closed_Unmeth"="#3C5488")
        state_labels <- c("1_Accessible_Active"="1. Accessible & UnMeth", "2_Closed_Silenced"="2. Closed & Meth", "3_Accessible_Meth"="3. Accessible & Meth", "4_Closed_Unmeth"="4. Closed & UnMeth")
      } else if (has_rna && has_gpc) {
        # 【新增】模式4: RNA + GpC (4 状态)
        med_rna <- median(df$RNA_Exp, na.rm = TRUE)
        med_gpc <- median(df$GpC_level, na.rm = TRUE)
        df_state <- df %>%
          dplyr::mutate(Reg_State = dplyr::case_when(
            RNA_Exp >= med_rna & GpC_level >= med_gpc ~ "1_Active_Accessible",
            RNA_Exp < med_rna & GpC_level < med_gpc ~ "2_Silenced_Closed",
            RNA_Exp >= med_rna & GpC_level < med_gpc ~ "3_Paradox_Active",
            RNA_Exp < med_rna & GpC_level >= med_gpc ~ "4_Poised_Accessible"
          ))
        pal <- c("1_Active_Accessible"="#DC0000", "2_Silenced_Closed"="#4DBBD5", "3_Paradox_Active"="#F39B7F", "4_Poised_Accessible"="#3C5488")
        state_labels <- c("1_Active_Accessible"="1. Active & Accessible", "2_Silenced_Closed"="2. Silenced & Closed", "3_Paradox_Active"="3. Paradox Active", "4_Poised_Accessible"="4. Poised & Accessible")
      }
      state_summary <- df_state %>% dplyr::count(Reg_State) %>% dplyr::mutate(Fraction = n / sum(n))
      Multi_values$states_data <- state_summary
      # 绘制状态饼图
      Multi_values$states_plot <- ggplot(state_summary, aes(x = 2, y = Fraction, fill = Reg_State)) +
        geom_bar(stat = "identity", color = "white", linewidth = 1) +
        coord_polar(theta = "y", start = 0) +
        xlim(0.5, 2.5) +
        scale_fill_manual(values = pal, labels = state_labels) +
        theme_void(base_size = 15) +
        theme(
          legend.position = "right",
          legend.title = element_text(face = "bold"),
          plot.title = element_text(face = "bold", hjust = 0.5, size = 18)
        ) +
        labs(title = "Epigenetic Regulatory States", fill = "States") +
        geom_text(aes(label = ifelse(Fraction > 0.05, scales::percent(Fraction, accuracy = 0.1), "")),
                  position = position_stack(vjust = 0.5), color = "white", fontface = "bold", size = 5)
      # 2. 动态 Z-score 热图美化
      progress$set(message = "Scoring Driver Genes...", value = 0.7)
      df_clean <- na.omit(df[, req_cols])
      # 定义稳健 Z-score 函数 (Robust Z-score based on Median and MAD)
      # 并在最后限制在 [-3, 3] 以内，保证热图颜色映射不被异常值破坏
      calc_robust_z <- function(x) {
        med_val <- median(x, na.rm = TRUE)
        mad_val <- mad(x, na.rm = TRUE)
        if (!is.finite(mad_val) || mad_val < 1e-8) {
          sd_val <- sd(x, na.rm = TRUE)
          if (!is.finite(sd_val) || sd_val < 1e-8) {
            return(rep(0, length(x)))
          }
          mad_val <- sd_val
        }
        z <- (x - med_val) / mad_val
        # 极值截断处理 (Clipping)
        z <- pmax(pmin(z, 3), -3)
        return(z)
      }
      # 计算 Z-score
      if(has_rna) {
        # RNA 必须先做 log2(x+1) 转换来消除长尾效应，再求稳健 Z-score
        # df_clean$Z_RNA <- calc_robust_z(log2(df_clean$RNA_Exp + 1))
        rna_values <- suppressWarnings(as.numeric(df_clean$RNA_Exp))
        if (any(!is.finite(rna_values))) {
          stop("RNA_Exp contains non-numeric or infinite values.")
        }
        if (any(rna_values < 0)) {
          stop(
            "RNA_Exp contains negative values. ",
            "Please use normalized expression, not scale.data."
          )
        }
        # RNA_Exp has already been normalized/log-transformed in Step 1.
        # Do not apply log2() again here.
        df_clean$Z_RNA <- calc_robust_z(rna_values)
      }
      if(has_cpg) {
        # Level 数据 (0-1) 直接求稳健 Z-score
        df_clean$Z_CpG <- calc_robust_z(df_clean$CpG_level)
      }
      if(has_gpc) {
        df_clean$Z_GpC <- calc_robust_z(df_clean$GpC_level)
      }
      # 动态计算综合打分 (MultiOmic_Score)
      if (has_rna && has_cpg && has_gpc) {
        # 经过同尺度 Robust 标准化后，可以直接加减
        df_clean$MultiOmic_Score <- df_clean$Z_RNA + df_clean$Z_GpC - df_clean$Z_CpG
        heat_cols <- c("Z_RNA", "Z_GpC", "Z_CpG")
        heat_names <- c("RNA (Normalized)", "GpC (Acc)", "CpG (Meth)")
      } else if (has_rna && has_cpg) {
        df_clean$MultiOmic_Score <- df_clean$Z_RNA - df_clean$Z_CpG
        heat_cols <- c("Z_RNA", "Z_CpG")
        heat_names <- c("RNA (Normalized)", "CpG (Meth)")
      } else if (has_cpg && has_gpc) {
        df_clean$MultiOmic_Score <- df_clean$Z_GpC - df_clean$Z_CpG
        heat_cols <- c("Z_GpC", "Z_CpG")
        heat_names <- c("GpC (Acc)", "CpG (Meth)")
      } else if (has_rna && has_gpc) {
        df_clean$MultiOmic_Score <- df_clean$Z_RNA + df_clean$Z_GpC
        heat_cols <- c("Z_RNA", "Z_GpC")
        heat_names <- c("RNA (Normalized)", "GpC (Acc)")
      }
      # 筛选 Top N Driver Genes
      top_genes <- df_clean %>%
        dplyr::arrange(desc(MultiOmic_Score)) %>%
        utils::head(top_n)
      heat_mat <- as.matrix(top_genes[, heat_cols])
      rownames(heat_mat) <- top_genes$GeneName
      colnames(heat_mat) <- heat_names
      my_breaks <- seq(-3, 3, length.out = 101)
      my_colors <- colorRampPalette(c("#3C5488", "white", "#E64B35"))(100)
      dynamic_fontsize <- ifelse(top_n <= 50, 10, ifelse(top_n <= 100, 8, 5))
      Multi_values$heatmap_data <- top_genes
      Multi_values$heatmap_plot <- pheatmap::pheatmap(
        heat_mat,
        cluster_cols = FALSE,
        cluster_rows = TRUE,
        scale = "none",
        color = my_colors,
        breaks = my_breaks,
        main = paste("Top", top_n, "Driver Genes by Joint Score"),
        fontsize_row = dynamic_fontsize,
        fontsize_col = 12,
        border_color = ifelse(top_n <= 80, "grey90", NA),
        angle_col = 45,
        treeheight_row = 30,
        silent = TRUE
      )
      showNotification("States & Heatmap calculated successfully!", type = "message")
      updateTabsetPanel(session, inputId = "multi_result_tabset", selected = "tab_heatmap")
    }, error = function(e){ showNotification(paste("Error:", e$message), type = "error") })
  })

  output$plot_multi_states <- renderPlot({ req(Multi_values$states_plot); Multi_values$states_plot })
  output$plot_multi_heatmap <- renderPlot({ req(Multi_values$heatmap_plot); grid::grid.draw(Multi_values$heatmap_plot$gtable) })
  # --- 5. 新增：全局下载功能 (Export-ready) ---
  output$dl_topo_pdf <- downloadHandler(
    filename = function() { paste0("Topology_Map_", input$topo_chr, "_", Sys.Date(), ".pdf") },
    content = function(file) {
      req(Multi_values$topo_plot)
      ggsave(file, plot = Multi_values$topo_plot, width = 10, height = 7, device = "pdf")
    }
  )
  output$dl_states_pdf <- downloadHandler(
    filename = function() { paste0("Regulatory_States_", Sys.Date(), ".pdf") },
    content = function(file) {
      req(Multi_values$states_plot)
      ggsave(file, plot = Multi_values$states_plot, width = 8, height = 6, device = "pdf")
    }
  )
  output$dl_heatmap_pdf <- downloadHandler(
    filename = function() { paste0("Driver_Genes_Heatmap_Top", input$num_top_genes, "_", Sys.Date(), ".pdf") },
    content = function(file) {
      req(Multi_values$heatmap_plot)
      # 对于 pheatmap，使用 pdf() 设备包裹输出 gtable
      pdf(file, width = 6, height = ifelse(input$num_top_genes > 80, 10, 8))
      grid::grid.draw(Multi_values$heatmap_plot$gtable)
      dev.off()
    }
  )
  output$dl_topo_data <- downloadHandler(
    filename = function() { paste0("Topology_Data_", input$topo_chr, "_", Sys.Date(), ".csv") },
    content = function(file) {
      req(Multi_values$topo_data)
      data.table::fwrite(Multi_values$topo_data, file, row.names = FALSE)
    }
  )
  output$dl_states_data <- downloadHandler(
    filename = function() { paste0("Regulatory_States_Summary_", Sys.Date(), ".csv") },
    content = function(file) {
      req(Multi_values$states_data)
      data.table::fwrite(Multi_values$states_data, file, row.names = FALSE)
    }
  )
  output$dl_heatmap_data <- downloadHandler(
    filename = function() { paste0("Top_Driver_Genes_ZScores_", Sys.Date(), ".csv") },
    content = function(file) {
      req(Multi_values$heatmap_data)
      data.table::fwrite(Multi_values$heatmap_data, file, row.names = FALSE)
    }
  )

  observeEvent(input$multi_btn_reset, {
    # 1. 彻底清空后端的绘图对象和数据缓存（防止幽灵下载和残留显示）
    Multi_values$topo_plot <- NULL
    Multi_values$states_plot <- NULL
    Multi_values$heatmap_plot <- NULL
    Multi_values$topo_data <- NULL
    Multi_values$states_data <- NULL
    Multi_values$heatmap_data <- NULL
    Multi_values$unlink_step1 <- TRUE
    Multi_values$raw_data <- NULL
    # 2. 强制清空前端的输入控件 (需要库 shinyjs)
    shinyjs::reset("multi_upload_file")  # 清空手动上传的 CSV 文件
    shinyjs::reset("num_top_genes")      # 恢复 Top N 驱动基因的默认值 (40)
    shinyjs::reset("topo_chr")           # 恢复染色体选择器的默认状态
    shinyjs::reset("topo_gene")
    # 3. 弹出系统级反馈
    showNotification("Multi-omics analysis data and plots have been fully cleared!",
                     type = "warning", duration = 5)
  })


  # ---- Enhancer-Promoter Interactions ----
  EP_values <- reactiveValues(
    final_table = NULL,
    arc_plot_obj = NULL,
    scatter_plot_obj = NULL
  )

  # 工具函数：极速读取矩阵，计算均值，拆分坐标并强力过滤 NA
  process_ep_matrix <- function(file_path, val_name) {
    # 1. 读入数据，防止列名错位
    df <- as.data.frame(data.table::fread(file_path))
    # 假设第一列是 region (例如 chr1:1000-2000)
    regions <- as.character(df[, 1])
    # 提取数值矩阵并强制转为数值型（消除字符污染）
    val_mat <- df[, -1, drop = FALSE]
    val_mat[] <- lapply(val_mat, function(x) as.numeric(as.character(x)))
    # 计算均值
    mean_level <- rowMeans(val_mat, na.rm = TRUE)
    # 构建数据框并拆分坐标
    res <- data.frame(region = regions, level = mean_level) %>%
      # 使用更包容的正则分隔符：冒号、短横线、下划线、点
      tidyr::separate(region, into = c("chr", "start", "end"),
                      sep = "[:\\-_\\.]", remove = FALSE, extra = "drop", fill = "right") %>%
      dplyr::mutate(
        start = as.numeric(start),
        end = as.numeric(end)
      ) %>%
      # 【核心修复】：强力剔除任何产生 NA 的无效行，防止 GRanges 崩溃
      dplyr::filter(!is.na(start) & !is.na(end) & !is.na(chr))
    colnames(res)[colnames(res) == "level"] <- val_name
    return(res)
  }

  # 核心分析逻辑
  observeEvent(input$btn_run_ep, {
    req(input$ep_enh_cpg, input$ep_enh_gpc, input$ep_pro_cpg, input$ep_pro_gpc, input$ep_pro_anno)
    progress <- shiny::Progress$new()
    progress$set(message = "Processing E-P Interactions...", value = 0.1)
    on.exit(progress$close())
    tryCatch({
      # 1. 读取并处理 4 个组学矩阵
      progress$set(detail = "Parsing matrices...", value = 0.2)
      enh_cpg <- process_ep_matrix(input$ep_enh_cpg$datapath, "enh_CpG_level")
      enh_gpc <- process_ep_matrix(input$ep_enh_gpc$datapath, "enh_GpC_level")
      pro_cpg <- process_ep_matrix(input$ep_pro_cpg$datapath, "pro_CpG_level")
      pro_gpc <- process_ep_matrix(input$ep_pro_gpc$datapath, "pro_GpC_level")
      # 2. 读取注释文件并合并
      progress$set(detail = "Merging annotations...", value = 0.4)
      # 读取 Promoter 注释，并加入 NA 过滤
      pro_anno <- read.csv(input$ep_pro_anno$datapath) %>%
        dplyr::mutate(start = as.numeric(start), end = as.numeric(end)) %>%
        dplyr::filter(!is.na(start) & !is.na(end) & !is.na(chr)) # 防护：剔除缺失坐标的基因
      # Enhancer 合并
      enhancer_df <- enh_cpg %>% dplyr::inner_join(enh_gpc %>% dplyr::select(region, enh_GpC_level), by = "region")
      # Promoter 合并 (假设注释文件有 chr, start, end, gene_id, gene_name)
      promoter_df <- pro_anno %>%
        dplyr::mutate(region = paste0(chr, ":", start, "-", end)) %>%
        dplyr::inner_join(pro_cpg %>% dplyr::select(region, pro_CpG_level), by = "region") %>%
        dplyr::inner_join(pro_gpc %>% dplyr::select(region, pro_GpC_level), by = "region")
      # 3. 构建 GRanges 并寻找重叠
      progress$set(detail = "Calculating spatial overlaps (GRanges)...", value = 0.6)
      max_dist <- input$ep_max_dist
      pro_gr <- GenomicRanges::GRanges(seqnames = promoter_df$chr, ranges = IRanges::IRanges(start = promoter_df$start, end = promoter_df$end))
      enh_gr <- GenomicRanges::GRanges(seqnames = enhancer_df$chr, ranges = IRanges::IRanges(start = enhancer_df$start, end = enhancer_df$end))
      hits <- GenomicRanges::findOverlaps(enh_gr, pro_gr, maxgap = max_dist, ignore.strand = TRUE)
      # 4. 基于索引极速提取拼接
      progress$set(detail = "Assembling interaction table...", value = 0.8)
      idx_enh <- S4Vectors::queryHits(hits)
      idx_pro <- S4Vectors::subjectHits(hits)
      # 智能适配可能的列名 (gene_id vs ensembleID)
      id_col <- if("ensembleID" %in% colnames(promoter_df)) promoter_df$ensembleID else promoter_df$gene_id
      ep_interactions <- data.frame(
        gene_name       = promoter_df$gene_name[idx_pro],
        ensembleID      = id_col[idx_pro],
        Promoter_Region = promoter_df$region[idx_pro],
        Enhancer_Region = enhancer_df$region[idx_enh],
        enh_center      = (enhancer_df$start[idx_enh] + enhancer_df$end[idx_enh]) / 2,
        pro_center      = (promoter_df$start[idx_pro] + promoter_df$end[idx_pro]) / 2,
        enh_CpG_level   = enhancer_df$enh_CpG_level[idx_enh],
        enh_GpC_level   = enhancer_df$enh_GpC_level[idx_enh],
        pro_CpG_level   = promoter_df$pro_CpG_level[idx_pro],
        pro_GpC_level   = promoter_df$pro_GpC_level[idx_pro]
      )
      final_ep_table <- ep_interactions %>%
        dplyr::mutate(Distance_bp = abs(enh_center - pro_center)) %>%
        dplyr::select(gene_name, ensembleID, Promoter_Region, Enhancer_Region, Distance_bp,
                      enh_CpG_level, enh_GpC_level, pro_CpG_level, pro_GpC_level) %>%
        dplyr::arrange(gene_name, Distance_bp)
      EP_values$final_table <- final_ep_table
      # 更新 UI 下拉框
      # updateSelectizeInput(session, "ep_target_gene", choices = unique(final_ep_table$gene_name), server = TRUE)
      updateSelectizeInput(session, "ep_target_gene",
                           choices = unique(final_ep_table$gene_name),
                           server = TRUE,
                           options = list(
                             placeholder = 'Type to search a gene (e.g. SOX2)...',
                             onInitialize = I('function() { this.setValue(""); }') # 初始化为空，强制用户搜索或选择
                           ))
      progress$set(value = 1)
      showNotification(paste("Successfully mapped", nrow(final_ep_table), "E-P interactions!"), type = "message")
    }, error = function(e){
      showNotification(paste("Error in E-P logic:", e$message), type = "error", duration = 10)
    })
  })

  # 输出 1：局部 Arc Plot 弧线图
  output$plot_ep_arc <- renderPlot({
    req(EP_values$final_table, input$ep_target_gene)
    plot_arc_data <- EP_values$final_table %>%
      dplyr::filter(gene_name == input$ep_target_gene) %>%
      dplyr::mutate(
        pro_x = 0,
        # 让增强子交替分布在左右两侧，避免拥挤
        enh_x = ifelse(dplyr::row_number() %% 2 == 1, -Distance_bp, Distance_bp),
        State = dplyr::case_when(
          enh_GpC_level >= 0.35 & pro_CpG_level <= 0.65 ~ "Active",       # 双向奔赴：放宽到 0.35 和 0.65
          enh_GpC_level < 0.35 & pro_CpG_level > 0.65 ~ "Repressed",      # 双向锁死
          TRUE ~ "Primed"                                                 # 预激态：只有一方满足条件
        )
      )
    plot_arc_data$State <- factor(plot_arc_data$State, levels = c("Active", "Primed", "Repressed"))
    if(nrow(plot_arc_data) == 0) return(NULL)
    p1 <- ggplot(plot_arc_data) +
      # 1. 主轴线美化：变细且颜色更柔和
      geom_hline(yintercept = 0, color = "#D3D3D3", linewidth = 1.5, lineend = "round") +
      # 2. 弧线美化：调整曲率，增加透明度，呈现丝滑感
      geom_curve(aes(x = enh_x, y = 0, xend = pro_x, yend = 0, color = State),
                 curvature = -0.35, linewidth = 0.9, alpha = 0.7, lineend = "round") +
      # 3. 增强子点美化（GpC）：加上白色描边 (stroke)，使用 shape=21
      geom_point(aes(x = enh_x, y = 0, size = enh_GpC_level),
                 shape = 21, fill = "#F39B7F", color = "#FFFFFF", stroke = 1, alpha = 0.9) +
      # 4. 启动子点美化（CpG）：加上深色描边，使其像一个锚点
      geom_point(aes(x = pro_x, y = 0, fill = pro_CpG_level),
                 shape = 22, size = 6, color = "#222222", stroke = 1) +
      # 5. 基因名标签：使用加粗斜体，并且带有指示线段
      geom_text_repel(aes(x = pro_x, y = 0, label = gene_name),
                      nudge_y = -0.15, direction = "x", box.padding = 0.5,
                      fontface = "bold.italic", size = 5.5, color = "#333333",
                      segment.color = "#999999", segment.size = 0.5, na.rm = TRUE) +
      # 6. 距离标签：字体变小巧，颜色变浅，贴近基准线
      geom_text(aes(x = enh_x, y = 0.05, label = paste0(round(Distance_bp/1000, 1), " kb")),
                size = 3.5, color = "#888888", vjust = 0, fontface = "italic", na.rm = TRUE) +
      # 7. 颜色与比例尺
      scale_color_manual(values = c(
        "Active" = "#00A087",      # 翠绿：已激活
        "Primed" = "#F39B7F",      # 珊瑚橙：预激/准备中
        "Repressed" = "#B09C85"    # 灰棕：抑制态
      )) +
      scale_fill_gradientn(colors = c("#E8F0F9", "#89A7C2", "#3C5488"), name = "Promoter CpG\n(Methylation)") +
      scale_size_continuous(range = c(2.5, 7.5), name = "Enhancer GpC\n(Accessibility)") +
      # 关键修复 2：动态 Y 轴缩放，替代写死的 coord_cartesian
      # 上方扩展 40% 的空间留给弧线，下方扩展 20% 留给基因名，完美自适应任何距离！
      scale_y_continuous(expand = expansion(mult = c(0.2, 0.4))) +
      theme_void() +
      theme(
        legend.position = "bottom",
        legend.box = "horizontal",
        legend.title = element_text(size = 10, face = "bold", color = "#444444"),
        legend.text = element_text(size = 9, color = "#555555"),
        plot.title = element_text(face = "bold", size = 16, hjust = 0.5, color = "#2C3E50", margin = margin(b = 15)),
        plot.margin = margin(15, 20, 10, 20) # 优化四周留白
      ) +
      ggtitle(paste(input$ep_target_gene, "Regulatory Landscape"))
    EP_values$arc_plot_obj <- p1
    return(p1)
  }, res = 100) # <-- 这里的 res = 120 是让图片彻底变清晰的核心！

  # 输出 2：全局散点图 Correlation
  output$plot_ep_scatter <- renderPlot({
    req(EP_values$final_table)
    p2 <- ggplot(EP_values$final_table, aes(x = enh_GpC_level, y = pro_CpG_level)) +
      geom_hline(yintercept = 0.5, linetype = "dashed", color = "#CCCCCC") +
      geom_vline(xintercept = 0.5, linetype = "dashed", color = "#CCCCCC") +
      geom_point(color = "#4DBBD5", alpha = 0.5, size = 2, shape = 16) +
      geom_smooth(method = "lm", color = "#E64B35", fill = "#E64B35", alpha = 0.2, linewidth = 1.2) +
      annotate("text", x = 0.8, y = 0.1, label = "Active State", color = "#00A087", fontface = "bold", size = 4) +
      annotate("text", x = 0.2, y = 0.9, label = "Repressed State", color = "#3C5488", fontface = "bold", size = 4) +
      labs(
        x = "Enhancer Accessibility (GpC level)", y = "Promoter Methylation (CpG level)",
        title = "Global Epigenetic E-P Correlation",
        subtitle = paste("n =", nrow(EP_values$final_table), "Interaction Pairs")
      ) +
      theme_classic() +
      theme(
        plot.title = element_text(face = "bold", size = 16, color = "#222222"),
        plot.subtitle = element_text(size = 12, color = "#777777", margin = margin(b = 10)),
        axis.title = element_text(face = "bold", size = 13, color = "#333333"),
        axis.text = element_text(size = 11, color = "#555555"),
        axis.line = element_line(color = "#333333", linewidth = 0.8),
        axis.ticks = element_line(color = "#333333", linewidth = 0.8)
      )
    EP_values$scatter_plot_obj <- p2
    return(p2)
  })

  # 输出 3：DT 数据表与下载逻辑
  output$table_ep_res <- DT::renderDT({
    req(EP_values$final_table)
    DT::datatable(EP_values$final_table, options = list(scrollX = TRUE, pageLength = 10), rownames = FALSE) %>%
      DT::formatRound(columns = c("enh_CpG_level", "enh_GpC_level", "pro_CpG_level", "pro_GpC_level"), digits = 3)
  })
  output$dl_ep_arc <- downloadHandler(
    filename = function() { paste0("ArcPlot_", input$ep_target_gene, ".pdf") },
    content = function(file) { ggsave(file, plot = EP_values$arc_plot_obj, width = 8, height = 5) }
  )
  # output$dl_ep_scatter <- downloadHandler(
  #   filename = function() { "Global_EP_Correlation.pdf" },
  #   content = function(file) { ggsave(file, plot = EP_values$scatter_plot_obj, width = 7, height = 6) }
  # )
  output$dl_ep_table <- downloadHandler(
    filename = function() { "EP_Interactions_Result.csv" },
    content = function(file) { data.table::fwrite(EP_values$final_table, file, row.names = FALSE) }
  )


  # ---- Enrichment Analysis Logic (Fixed & Enhanced) ----
  library(clusterProfiler)
  library(org.Mm.eg.db)
  library(org.Hs.eg.db)
  Enrich_values <- reactiveValues(
    res_obj = NULL,  # Store the full enrichResult object
    res_df = NULL    # Store the readable data frame
  )

  # --- 1. Dynamic Column Selector (当文件上传后触发) ---
  output$ui_enrich_gene_col <- renderUI({
    req(input$enrich_file_input)
    # Read only the first row to get column names efficiently
    df_head <- read.csv(input$enrich_file_input$datapath, nrows = 1, header = TRUE)
    cols <- colnames(df_head)
    # 智能猜测列名：优先寻找 GeneID 或 ensembl
    default_col <- cols[1]
    if("GeneID" %in% cols) default_col <- "GeneID"
    else if("ensembl_id" %in% cols) default_col <- "ensembl_id"
    else if(any(grepl("ensembl", cols, ignore.case = TRUE))) default_col <- grep("ensembl", cols, ignore.case = TRUE, value = TRUE)[1]
    selectInput("enrich_gene_col", "Select Gene Column (Ensembl ID):",
                choices = cols,
                selected = default_col)
  })

  # --- 2. Run Enrichment Analysis ---
  observeEvent(input$run_enrichment, {
    req(input$enrich_file_input, input$enrich_gene_col)
    # --- Check Required Packages ---
    if (!requireNamespace("clusterProfiler", quietly = TRUE)) {
      showNotification("Error: Package 'clusterProfiler' is not installed!", type = "error")
      return(NULL)
    }
    progress <- shiny::Progress$new()
    progress$set(message = "Initializing...", value = 0.1)
    on.exit(progress$close())
    tryCatch({
      # Load necessary libraries inside the function
      library(clusterProfiler)
      library(ggplot2)
      # 1. Read File
      progress$set(detail = "Reading data...", value = 0.2)
      df <- read.csv(input$enrich_file_input$datapath, stringsAsFactors = FALSE)
      selected_col <- input$enrich_gene_col
      if(!selected_col %in% colnames(df)){
        stop("Selected column not found in the file.")
      }
      raw_gene_list <- unique(trimws(df[[selected_col]]))
      # 【核心防呆设计】：去除 Ensembl ID 后面的版本号
      # (e.g., ENSMUSG00000025902.13 自动变为 ENSMUSG00000025902)
      clean_gene_list <- gsub("\\..*$", "", raw_gene_list)
      # 2. Setup Species Database
      progress$set(detail = "Loading Database...", value = 0.3)
      org_db <- NULL
      kegg_code <- ""
      if(input$enrich_species == "mouse") {
        if (!require("org.Mm.eg.db", quietly = TRUE)) stop("Package 'org.Mm.eg.db' missing.")
        library(org.Mm.eg.db)
        org_db <- org.Mm.eg.db
        kegg_code <- "mmu"
      } else {
        if (!require("org.Hs.eg.db", quietly = TRUE)) stop("Package 'org.Hs.eg.db' missing.")
        library(org.Hs.eg.db)
        org_db <- org.Hs.eg.db
        kegg_code <- "hsa"
      }
      # 3. ID Conversion (ENSEMBL -> ENTREZID) using bitr
      progress$set(detail = "Converting Ensembl IDs...", value = 0.4)
      gene_map <- bitr(clean_gene_list,
                       fromType = "ENSEMBL",   # 明确指定输入的是 Ensembl ID
                       toType = "ENTREZID",    # 转为 Entrez 供算法底层进行严谨统计计算
                       OrgDb = org_db)
      if(nrow(gene_map) == 0) {
        stop("No valid Ensembl IDs matched the database. Please check your species or column selection.")
      }
      valid_ids <- gene_map$ENTREZID
      # 4. Run Enrichment
      progress$set(detail = "Performing Enrichment...", value = 0.6)
      res <- NULL
      if(input$enrich_db == "KEGG") {
        # KEGG Analysis
        res <- enrichKEGG(
          gene         = valid_ids,
          organism     = kegg_code,
          pvalueCutoff = input$enrich_pval,
          qvalueCutoff = input$enrich_qval
        )
      } else {
        # GO Analysis (BP, MF, CC)
        res <- enrichGO(
          gene          = valid_ids,
          OrgDb         = org_db,
          keyType       = "ENTREZID",  # 显式声明送入的是 Entrez ID
          ont           = input$enrich_db,
          pAdjustMethod = "BH",
          pvalueCutoff  = input$enrich_pval,
          qvalueCutoff  = input$enrich_qval,
          readable      = TRUE         # 【神仙参数】：计算完后，自动把 Entrez 翻译回 Symbol (GeneName) 供图表展示
        )
      }
      # 5. Process Results
      if(is.null(res) || nrow(res@result) == 0) {
        showNotification("No significant enrichment found based on current thresholds.", type = "warning")
        Enrich_values$res_obj <- NULL
        Enrich_values$res_df <- NULL
      } else {
        # 如果是 KEGG，也手动把 Entrez 转回 Symbol 供人类阅读
        if(input$enrich_db == "KEGG") {
          res <- setReadable(res, OrgDb = org_db, keyType = "ENTREZID")
        }
        Enrich_values$res_obj <- res
        Enrich_values$res_df <- as.data.frame(res)
        showNotification(paste("Success! Found", nrow(res), "pathways/terms."), type = "message")
      }
    }, error = function(e) {
      showNotification(paste("Error:", e$message), type = "error", duration = 10)
    })
  })

  # 1. Dot Plot (气泡图)
  output$enrich_dotplot <- renderPlot({
    req(Enrich_values$res_obj)
    dotplot(Enrich_values$res_obj, showCategory = 20, font.size = 12, title = "") +
      scale_color_gradient(low = "#E64B35", high = "#4DBBD5") +
      ggtitle(paste0("Enrichment Dotplot (", input$enrich_db, ")")) +
      theme_bw(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        axis.text.y = element_text(color = "black", face = "plain"),
        axis.text.x = element_text(color = "black", face = "bold"),
        legend.title = element_text(face = "bold"),
        panel.grid.major = element_line(linetype = "dashed", color = "grey90")
      )
  })
  # 2. Bar Plot (柱状图)
  output$enrich_barplot <- renderPlot({
    req(Enrich_values$res_obj)
    barplot(Enrich_values$res_obj, showCategory = 20, font.size = 12, title = "") +
      scale_fill_gradient(low = "#E64B35", high = "#4DBBD5") +
      ggtitle(paste0("Enrichment Barplot (", input$enrich_db, ")")) +
      theme_bw(base_size = 14) +
      theme(
        plot.title = element_text(hjust = 0.5, size = 18, face = "bold"),
        axis.text.y = element_text(color = "black", face = "plain"),
        axis.text.x = element_text(color = "black", face = "bold"),
        legend.title = element_text(face = "bold"),
        panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(linetype = "dashed", color = "grey90")
      )
  })

  # 3. Data Table
  output$enrich_table <- DT::renderDT({
    req(Enrich_values$res_df)
    # Select columns to display
    df_show <- Enrich_values$res_df %>%
      dplyr::select(ID, Description, GeneRatio, p.adjust, geneID)
    DT::datatable(df_show,
                  options = list(scrollX = TRUE, pageLength = 10),
                  rownames = FALSE) %>%
      DT::formatSignif(columns = c("p.adjust"), digits = 3)
  })

  # 4. Download Handler
  output$download_enrich_res <- downloadHandler(
    filename = function() {
      paste0("Enrichment_Results_", input$enrich_db, "_", Sys.Date(), ".csv")
    },
    content = function(file) {
      req(Enrich_values$res_df)
      data.table::fwrite(Enrich_values$res_df, file, row.names = FALSE)
    }
  )


}

shinyApp(ui, server)
