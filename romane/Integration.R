
# scaling: scale gene expression level across cells
# mean = 0 and variance = 1, remove average and divide by sd
# Seurat provides vars.to.regress -> removes effect of unwanted technical or bio variables
# linear regression for each gene  separately and considering the residuaés as corrected scale values
# estimates residals (noise, variability)


#################### Data loading ####################

merged_seurat <- readRDS("./romane/merged_covid_obj.rds")



#################### Data Scaling ####################

# Data scaling in Seurat means standardizing the expression values of each gene
# across all cells to have mean 0 and variance 1

# for each gene:
# substract the mean
# divide by the standard deviation

merged_seurat <- ScaleData(merged_seurat)

# We can regress out unwanted sources of variation while scaling, for example:
merged_seurat <- ScaleData(merged_seurat, vars.to.regress = c("nCount_RNA", "percent.mito"))


# alternative approach to scale the data (normalized, scale, identify variable genes)
# SCTransform 
# does not rely on sequencing depth


# create new assay (SCT not more RNA - 3 layers)
# this has not worked ???
SCT_merged_seurat <- SCTransform(merged_seurat, verbose = FALSE)
SCT_merged_seurat <- SCTransform(merged_seurat, vars.to.regress = "percent.mito", verbose = FALSE)

DefaultAssay(SCT_merged_seurat) <- "RNA" # switch back to RNA 




#################### PCA ####################

# useful when dataset is very big
# dim reduction to represent cells in a low dimensional space 
# 50 components 
# first PC is the one that captures the most variability

# important for clustering, check if variability depends on unwanted external reasons


merged_seurat <- RunPCA(merged_seurat, verbose = FALSE)

# We can plot cells in a low 2D space and color them using the metadata information

DimPlot(merged_seurat, reduction = "pca", group.by = "sample") +
  theme_minimal() + 
  labs(title = "PCA colored by Sample")
# results: each dot is a cell, color based on sample of origin
# cells distributed along the components
# when close together are similar 
# separated -> huge variance



DimPlot(merged_seurat, reduction = "pca", group.by = "condition") +
  theme_minimal() + 
  labs(title = "PCA colored by Condition")
# results - can see some variability bw healthy and covid samples

## ???

# plot mitochondrial percentage in our cells
FeaturePlot(merged_seurat, features = "percent.mito", reduction = "pca") +
  theme_minimal() +
  labs(title = "PCA colored by percent mito")
# if we see along component huge variablility along percent mito -> noise or bath effect due to mito % 
# darker - higher mito percentage



# plot ribo 
FeaturePlot(merged_seurat, features = "percent.ribo", reduction = "pca") +
  theme_minimal() +
  labs(title = "PCA colored by percent ribo")



# Plot PC3 and PC4 
DimPlot(merged_seurat, reduction = "pca", dims = c(3,4), group.by = "condition") +
  theme_minimal()+
  labs(title = "PC3 and PC4 by condition")


# Explores genes that characterize specific components
# how much a gene contrbute to a PC
VizDimLoadings(merged_seurat, dims= 1:2)


# Visualize the variance that each component represent
# SD X PCA -> variability for each PCA
# this variability declines
ElbowPlot(merged_seurat)

# can only select the top 15 PCA (since represents the majority of the variance)





# Integration and Batch effect correction
#  -> Removes unwanted variation by regressing out technical covariates (seq depth, mito content,..)
# when diff patients, diff conditions (control vs treated), multiple seq runs, diff technologies,..
# preserve biological samples

# diff preprocessing steps across samples
# remove external noise
# identify interested genes (biomarkers for example)


# batch corrections algo: harmony, CCA, RPCA,..


integrated_seurat <- IntegrateLayers(
  object = merged_seurat, method = CCAIntegration,
  orig.reduction = "pca", new.reduction = "integrated.cca",
  verbose = FALSE
)

saveRDS(integrated_seurat, "./romane/seurat_merged_cca.RDS")


# integration with SCT
integrated_seurat <- IntegrateLayers(
  object = merged_seurat, method = CCAIntegration, assay = "SCT",
  new.reduction = "integrated.cca", normalization.method = "SCT",
  verbose = FALSE
)

integrated_seurat <- IntegrateLayers(
  object = merged_seurat, method = RPCAIntegration,
  orig.reduction = "pca", new.reduction = "integrated.rpca",
  verbose = FALSE
)

saveRDS(integrated_seurat, "./romane/seurat_merged_rpca.RDS")



