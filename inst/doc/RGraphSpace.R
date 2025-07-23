## ----Load packages for quick start, eval=TRUE, message=FALSE------------------
#--- Load required packages
library(igraph)
library(ggplot2)
library(RGraphSpace)

## ----Toy igraph - 1, eval=TRUE, message=FALSE, results=FALSE------------------
# Make a 'toy' igraph with 5 nodes and 4 edges;
# ..either a directed or undirected graph
gtoy1 <- make_star(5, mode="out")

# Check whether the graph is directed or not
is_directed(gtoy1)
## [1] TRUE

# Check graph size
vcount(gtoy1)
## [1] 5
ecount(gtoy1)
## [1] 4

# Assign 'x' and 'y' coordinates to each vertex;
# ..this can be an arbitrary unit in (-Inf, +Inf)
V(gtoy1)$x <- c(0, 2, -2, -4, -8)
V(gtoy1)$y <- c(0, 0,  2, -4,  0)

# Assign a name to each vertex
V(gtoy1)$name <- paste0("n", 1:5)

## ----Toy igraph - 2, eval=TRUE, message=FALSE, out.width="100%"---------------
# Plot the 'gtoy1' using standard R graphics
plot(gtoy1)

## ----Toy igraph - 3, eval=TRUE, message=FALSE, out.width="80%"----------------
# Plot the 'gtoy1' using RGraphSpace
plotGraphSpace(gtoy1, add.labels = TRUE)

## ----Node attributes, eval=TRUE, message=FALSE--------------------------------
# Node size (numeric in (0, 100), as '%' of the plot space)
V(gtoy1)$nodeSize <- c(8, 5, 5, 5, 5)

# Node shape (integer code between 0 and 25; see 'help(points)')
V(gtoy1)$nodeShape <- c(21, 22, 23, 24, 25)

# Node color (Hexadecimal or color name)
V(gtoy1)$nodeColor <- c("red", "#00ad39", "grey80", "lightblue", "cyan")

# Node line width (as in 'lwd' standard graphics; see 'help(gpar)')
V(gtoy1)$nodeLineWidth <- 1

# Node line color (Hexadecimal or color name)
V(gtoy1)$nodeLineColor <- "grey20"

# Node labels ('NA' will omit labels)
V(gtoy1)$nodeLabel <- c("V1", "V2", "V3", "V4", NA)

# Node label size (in pts)
V(gtoy1)$nodeLabelSize <- 8

# Node label color (Hexadecimal or color name)
V(gtoy1)$nodeLabelColor <- "black"

## ----Edge attributes - 1, eval=TRUE, message=FALSE----------------------------
# Edge width (as in 'lwd' standard graphics; see 'help(gpar)')
E(gtoy1)$edgeLineWidth <- 0.8

# Edge color (Hexadecimal or color name)
E(gtoy1)$edgeLineColor <- c("red","green","blue","black")

# Edge type (as in 'lty' standard graphics; see 'help(gpar)')
E(gtoy1)$edgeLineType <- c("solid", "11", "dashed", "2124")

# Edge weight (numeric >=0; not passed to ggplot)
E(gtoy1)$weight <- 1

## ----Edge attributes - 2, eval=TRUE, message=FALSE----------------------------
# Arrowhead types in directed graphs (integer code or character)
## 0 = "---", 1 = "-->", -1 = "--|"
E(gtoy1)$arrowType <- 1

# Arrowhead length (as in 'lwd' standard graphics; see 'help(gpar)')
E(gtoy1)$arrowLength <- 1

## ----Edge attributes - 3, eval=TRUE, message=FALSE----------------------------
# Arrowhead types in undirected graphs (integer or character code)
##  0 = "---"
##  1 = "-->",  2 = "<--",  3 = "<->",  4 = "|->",
## -1 = "--|", -2 = "|--", -3 = "|-|", -4 = "<-|", 
E(gtoy1)$arrowType <- 1
# Note: in undirected graphs, this attribute overrides the 
# edge's orientation in the edge list

# Arrowhead length (as in 'lwd' standard graphics; see 'help(gpar)')
E(gtoy1)$arrowLength <- 1

## ----A shortcut for RGraphSpace, eval=TRUE, message=FALSE, out.width="80%"----
# Plot the updated 'gtoy1' using RGraphSpace
plotGraphSpace(gtoy1, add.labels = TRUE)

## ----A shortcut for RedeR, eval=FALSE, message=FALSE--------------------------
# # Load RedeR, a graph package for interactive visualization
# ## Note: for this example, please use Bioc >= 3.19
# if(!require("BiocManager", quietly = TRUE)){
#   install.packages("BiocManager")
#   #BiocManager::install(version = "3.19")
# }
# if(!require("RedeR", quietly = TRUE)){
#   BiocManager::install("RedeR")
# }
# 
# # Launch the RedeR application
# library(RedeR)
# startRedeR()
# resetRedeR()
# 
# # Send 'gtoy1' to the RedeR interface
# addGraphToRedeR(gtoy1, unit="npc")
# relaxRedeR()
# 
# # Fetch the graph with a fresh layout
# gtoy2 <- getGraphFromRedeR(unit="npc")
# 
# # Check the round trip...
# plotGraphSpace(gtoy2, add.labels = TRUE)
# 
# ## Note that for the round trip, shapes and line types are
# ## only partially compatible between ggplot2 and RedeR.
# 
# # ...alternatively, just update the graph layout
# gtoy2 <- updateLayoutFromRedeR(g=gtoy1)
# 
# # ...check the updated layout
# plotGraphSpace(gtoy2, add.labels = TRUE)

## ----label='Session information', eval=TRUE, echo=FALSE-----------------------
sessionInfo()

