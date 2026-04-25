## ----Load packages for quick start, eval=TRUE, message=FALSE------------------
#--- Load required packages
library("igraph")
library("ggplot2")
library("RGraphSpace")

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
# Node size (numeric in [0, 100], as '%' of the plot space)
V(gtoy1)$nodeSize <- c(8, 5, 5, 10, 5)

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

# Node transparency (in [0,1])
V(gtoy1)$nodeAlpha <- 1

## ----Edge attributes - 1, eval=TRUE, message=FALSE----------------------------
# Edge width (as in 'lwd' standard graphics; see 'help(gpar)')
E(gtoy1)$edgeLineWidth <- 0.8

# Edge color (Hexadecimal or color name)
E(gtoy1)$edgeLineColor <- c("red","green","blue","black")

# Edge type (as in 'lty' standard graphics; see 'help(gpar)')
E(gtoy1)$edgeLineType <- c("solid", "11", "dashed", "2124")

# Edge transparency (in [0,1])
E(gtoy1)$edgeAlpha <- 1

## ----Edge attributes - 2, eval=TRUE, message=FALSE----------------------------
# Arrowhead types in directed graphs (integer code or character)
## 0 = "---", 1 = "-->", -1 = "--|"
E(gtoy1)$arrowType <- 1

## ----Edge attributes - 3, eval=TRUE, message=FALSE----------------------------
# Arrowhead types in undirected graphs (integer or character code)
##  0 = "---"
##  1 = "-->",  2 = "<--",  3 = "<->",  4 = "|->",
## -1 = "--|", -2 = "|--", -3 = "|-|", -4 = "<-|", 
E(gtoy1)$arrowType <- 1
# Note: in undirected graphs, this attribute overrides the 
# edge's orientation in the edge list

## ----A shortcut for RGraphSpace, eval=TRUE, message=FALSE, out.width="80%"----
# Plot the updated 'gtoy1' using RGraphSpace
plotGraphSpace(gtoy1, add.labels = TRUE)

## ----Load a toy graph, eval=TRUE, message=FALSE, out.width="80%"--------------
# Make a toy modular graph
library("igraph")
gtoy3 <- sample_islands(
  islands.n = 3,       # number of modules
  islands.size = 30,   # nodes per module
  islands.pin = 0.25,  # probability of edges within modules
  n.inter = 2)         # edges between modules

# Assign module membership to nodes
V(gtoy3)$module <- rep(1:3, each = 30)

# Assign colors to nodes
V(gtoy3)$nodeColor <- rainbow(3)[V(gtoy3)$module]

# Assign a categorical variable to nodes
V(gtoy3)$node_group <- c("A", "B", "C")[V(gtoy3)$module]

# Assign numeric variables to nodes and edges
V(gtoy3)$node_var <- runif(vcount(gtoy3))
E(gtoy3)$edge_var <- runif(ecount(gtoy3))

# Create a GraphSpace from the toy igraph
gs <- GraphSpace(gtoy3)

## ----eval=TRUE, message=FALSE, include = FALSE--------------------------------
edge_var <- node_var <- nodeColor <- node_group <- NULL

## ----Plot identity values, eval=TRUE, message=FALSE, out.width="70%"----------
ggplot() + 
  geom_graphspace(colour = "grey", data = gs) +
  theme(aspect.ratio = 1)

## ----Map aesthetics to categorical variables, eval=TRUE, message=FALSE, out.width="70%"----
ggplot() + 
  geom_graphspace(aes(fill = node_group), 
    colour = "grey", data = gs) +
  scale_fill_viridis_d(option = "viridis") +
  theme_gspace_coords()

## ----Map aesthetics to numeric variables, eval=TRUE, message=FALSE, out.width="70%"----
# Map aesthetics to numeric variables
ggplot() + 
  geom_edgespace(aes(colour = edge_var), data = gs) +
  geom_nodespace(aes(fill = node_var), 
    colour = "grey", data = gs) +
  scale_colour_continuous(palette = c("cyan","blue")) +
  scale_fill_continuous(palette = c("white","purple")) +
  theme_gspace_coords()

## ----Map aesthetics to separate colour scales, eval=FALSE, message=FALSE, out.width="70%"----
# if (!require("ggnewscale", quietly = TRUE)) {
#   install.packages("ggnewscale")
# }
# library("ggnewscale")
# ggplot() +
#   geom_edgespace(aes(colour = edge_var), data = gs) +
#   scale_colour_continuous(palette = c("cyan","blue")) +
#   ggnewscale::new_scale_colour() +
#   geom_nodespace(aes(colour = node_var),
#     data = gs, stroke = 2, fill = NA) +
#   scale_colour_continuous(palette = c("white","purple")) +
#   theme_gspace_coords()

## ----Mapping images to graph space, eval=TRUE, message=FALSE, out.width="80%"----
# Extract pixel coordinates for a specific intensity quantile.
coords <- which(volcano == quantile(volcano, 0.85), arr.ind = TRUE)

# Mark target pixels with '0'; it will appear as black in the background. 
# This creates a visual anchor to verify the alignment precision.
volcano2 <- volcano
volcano2[coords] <- 0

# Create an igraph object from the pixel coordinates; 
# note that at this stage, 'y' represents matrix row indices.
gtoy2 <- igraph::make_empty_graph(n = nrow(coords))
igraph::V(gtoy2)$y <- coords[,1]
igraph::V(gtoy2)$x <- coords[,2]

# Highlight the bottom-row vertex (max 'y' index) to demonstrate alignment; 
# since matrix indexing is top-down, this accounts for the default flip 
# between matrix and plot coordinate systems.
igraph::V(gtoy2)$nodeColor <- NA
bottom_row <- which.max(igraph::V(gtoy2)$y)
igraph::V(gtoy2)$nodeColor[bottom_row] <- adjustcolor("red", 0.4)

# Initialize a GraphSpace object
gs <- GraphSpace(gtoy2)

# Map graph coordinates to the image space; by default,
# 'y' row indices will be flipped (see comments below).
gs <- normalizeGraphSpace(gs, image = as_colorraster(volcano2) )

# Render the graph with the raster as background
plotGraphSpace(gs, add.image = TRUE)

## ----Maps with sf, eval=FALSE, message=FALSE, out.width="80%"-----------------
# if(!require("sf", quietly = TRUE)){
#   install.packages("sf")
# }
# if(!require("rnaturalearth", quietly = TRUE)){
#   install.packages("rnaturalearth")
# }
# if(!require("maps", quietly = TRUE)){
#   install.packages("maps")
# }
# if(!require("geometry", quietly = TRUE)){
#   install.packages("geometry")
# }
# library("RGraphSpace")
# library("igraph")
# library("sf")
# library("maps")
# library("geometry")
# library("rnaturalearth")
# 
# # Load and project map
# map_sf <- ne_countries(country = "Brazil", returnclass = "sf")
# map_proj <- st_transform(map_sf)
# 
# # Filter major cities by regional capitals
# data(world.cities, package = "maps")
# r_capitals <- c(
#   "Aracaju", "Belem", "Belo Horizonte", "Boa Vista", "Brasilia",
#   "Campo Grande", "Cuiaba", "Curitiba", "Florianopolis", "Fortaleza",
#   "Goiania", "Joao Pessoa", "Macapa", "Maceio", "Manaus", "Natal",
#   "Palmas", "Porto Alegre", "Porto Velho", "Recife", "Rio Branco",
#   "Rio de Janeiro", "Salvador", "Sao Luis", "Sao Paulo", "Teresina",
#   "Vitoria"
# )
# cities <- subset(world.cities, country.etc == "Brazil" &
#     name %in% r_capitals & pop > 1000000)
# 
# # Create Delaunay triangulation edges
# # Note: the edges hold no particular meaning beyond
# # demonstrating integration between coordinate systems
# tri <- delaunayn(cities[,c("lat","long")])
# edges <- unique(rbind(tri[,c(1,2)], tri[,c(2,3)], tri[,c(1,3)] ))
# 
# # Build igraph with coordinates
# gtoy1 <- igraph::graph_from_edgelist(edges, directed = FALSE)
# igraph::V(gtoy1)$x <- cities$long
# igraph::V(gtoy1)$y <- cities$lat
# igraph::V(gtoy1)$Cities <- cities$name
# igraph::V(gtoy1)$`Population (M)` <- cities$pop/1000000
# igraph::E(gtoy1)$arrowType <- 3
# 
# # Make a GraphSpace
# gs1 <- GraphSpace(gtoy1)
# 
# # Plot
# ggplot() +
#   geom_sf(data = map_proj, fill = "grey95", color = "grey60") +
#   geom_edgespace(color = "grey40", arrow_size = 0.5,
#     arrow_offset = 0.01, data = gs1) +
#   geom_nodespace(aes(fill = Cities, size = `Population (M)`),
#     data = gs1) +
#   scale_size(range = c(3,9)) +
#   scale_fill_discrete() +
#   inject_nodespace() +
#   theme_gspace_legend(key_fill = TRUE)

## ----A shortcut for RedeR, eval=FALSE, message=FALSE--------------------------
# # Load RedeR, a graph package for interactive visualization
# ## Note: this example requires Bioc >= 3.19
# if(!require("BiocManager", quietly = TRUE)){
#   install.packages("BiocManager")
#   #BiocManager::install(version = "3.19")
# }
# if(!require("RedeR", quietly = TRUE)){
#   BiocManager::install("RedeR")
# }
# 
# # Launch the RedeR application
# library("RedeR")
# startRedeR()
# resetRedeR()
# data(gtoy1, package = "RGraphSpace")
# 
# # Send 'gtoy1' to the RedeR interface
# addGraphToRedeR(gtoy1, unit="npc")
# relaxRedeR()
# 
# # Fetch 'gtoy1' with a fresh layout
# gtoy2 <- getGraphFromRedeR(unit="npc")
# 
# # Check the round trip...
# plotGraphSpace(gtoy2, add.labels = TRUE)
# 
# ## Note that for the round trip, shapes and line types are
# ## partially compatible between ggplot2 and RedeR.
# 
# # ...alternatively, just update the graph layout
# gtoy2 <- updateLayoutFromRedeR(g=gtoy1)
# 
# # ...check the updated layout
# plotGraphSpace(gtoy2, add.labels = TRUE)

## ----label='Session information', eval=TRUE, echo=FALSE-----------------------
sessionInfo()

