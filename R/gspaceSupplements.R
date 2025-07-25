
################################################################################
### Main constructor of GraphSpace-class objects
################################################################################
.buildGraphSpace <- function(g, mar = 0.1, image = NULL, layout = NULL,
    verbose = TRUE) {
    
    gg <- .validate.igraph(g, layout, verbose)
    
    if(verbose) message("Extracting vertices...")
    nodes <- .get.nodes(gg)
    temp <- .center.nodes(nodes, image, mar)
    nodes <- temp$nodes
    image.mar <- temp$image
    image.layer <- temp$image.layer
    
    if(verbose) message("Extracting edges...")
    edges <- .get.edges(gg)
    
    if(verbose) message("Creating a 'GraphSpace' object...")
    pars <- list(is.directed = is_directed(gg), mar = mar, 
        image.layer = image.layer)
    gs <- new(Class = "GraphSpace", nodes = nodes, edges = edges, 
        graph=gg, image = image.mar, pars = pars, 
        misc = list(g = g, image=image))
    return(gs)
}

################################################################################
### Functions for image adjusts
################################################################################

#-------------------------------------------------------------------------------
.frame.nodes <- function(nodes, image, mar){
    d <- dim(image)
    xr <- range(nodes$x)
    yr <- range(nodes$y)
    if( (xr[1] < 1) || (xr[2] > d[2]) ){
        stop("Graph coordinates outside image dimensions.", call. = FALSE)
    }
    if( (yr[1] < 1) || (yr[2] > d[1]) ){
        stop("Graph coordinates outside image dimensions.", call. = FALSE)
    }
    # adjust image and node coordinates
    res <- list(nodes=nodes, image=image)
    res <- .crop_image(res$nodes, res$image, mar)
    res <- .square_image(res$nodes, res$image)
    # normalize node coordinates
    d <- dim(res$image)
    res$nodes$x <- scales::rescale(res$nodes$x, 
        from = c(1, d[2]), to = c(0, 1))
    res$nodes$y <- scales::rescale(res$nodes$y, 
        from = c(1, d[1]), to = c(0, 1))
    return(res)
}

#-------------------------------------------------------------------------------
.crop_image <- function(nodes, image, mar){
    
    d <- dim(image)
    
    # set node limits to integer
    xl <- range(nodes$x)
    yl <- range(nodes$y)
    xl <- c(ceiling(xl[1]), floor(xl[2]))
    yl <- c(ceiling(yl[1]), floor(yl[2]))
    nodes$x <- scales::rescale(nodes$x, to=xl)
    nodes$y <- scales::rescale(nodes$y, to=yl)
    
    # adjust limits to a square window
    lim <- .adjust.lim(xl, yl, d)
    xl <- lim$xl
    yl <- lim$yl
    mlen <- lim$mlen
    
    # set margins as a fraction of the image border 
    # xm <- min(xl[1]-1, d[2] - xl[2]) * mar
    # ym <- min(yl[1]-1, d[1] - yl[2]) * mar
    # dm <- floor(min(xm,ym))
    
    # set margins as a fraction of the graph size 
    dm <- ceiling(mlen * (1 + mar) * mar)
    
    # check margins
    if((xl[1] - dm) < 1) dm <- floor(xl[1])
    if((yl[1] - dm) < 1) dm <- floor(yl[1])
    if((xl[2] + dm) > d[2]) dm <- floor(d[2] - xl[2])
    if((yl[2] + dm) > d[1]) dm <- floor(d[1] - yl[2])
    
    # set image frame
    xl <- c(xl[1] - dm, xl[2] + dm )
    yl <- c(yl[1] - dm, yl[2] + dm )
    xl <- c(floor(xl[1]), ceiling(xl[2]))
    yl <- c(floor(yl[1]), ceiling(yl[2]))
    
    # check limits
    lim <- .adjust.lim(xl, yl, d)
    xl <- lim$xl
    yl <- lim$yl
    
    # crop on flipped rows to match node y-coordinates
    image <- image[seq.int(nrow(image), 1), ]
    image <- image[seq.int(yl[1], yl[2]), seq.int(xl[1], xl[2])]
    image <- image[seq.int(nrow(image), 1), ]
    
    # set new node coordinates
    nodes$x <- nodes$x - xl[1] + 1
    nodes$y <- nodes$y - yl[1] + 1
    
    res <- list(nodes=nodes, image=image)
    return(res)
} 
# adjust limits to a square window
.adjust.lim <- function(xl, yl, d){
    dx <- xl[2] - xl[1] + 1
    dy <- yl[2] - yl[1] + 1
    if(dx > dy){
        dm <- (dx - dy)/2
        yl <- c(yl[1] - ceiling(dm), yl[2] + floor(dm))
        if(yl[1] < 1) yl[1] <- 1
        if(yl[2] > d[2]) yl[2] <- d[2]
    } else if(dx < dy){
        dm <- (dy - dx)/2
        xl <- c(xl[1] - ceiling(dm), xl[2] + floor(dm))
        if(xl[1] < 1) xl[1] <- 1
        if(xl[2] > d[2]) xl[2] <- d[2]
    }
    dx <- xl[2] - xl[1] + 1
    dy <- yl[2] - yl[1] + 1
    res <- list(xl = xl, yl = yl, mlen = max(dx,dy))
    return(res)
}

#-------------------------------------------------------------------------------
.square_image <- function(nodes, image ){
    d <- dim(image )
    if(d[1] > d[2]){
        n <- ceiling( (d[1] - d[2]) )/2
        img_d <- matrix(NA, nrow = d[1], ncol = d[1])
        img_d[ , seq(n + 1, n + d[2])] <- as.matrix(image )
        nodes$x <- nodes$x + n
        image  <- as.raster(img_d)
    } else if(d[1] < d[2]){
        n <- ceiling( (d[2] - d[1])/2 )
        img_d <- matrix(NA, nrow = d[2], ncol = d[2])
        img_d[seq(n + 1, n + d[1]), ] <- as.matrix(image )
        nodes$y <- nodes$y + n
        image  <- as.raster(img_d)
    }
    res <- list(nodes=nodes, image=image)
    return(res)
}

#-------------------------------------------------------------------------------
.center.nodes <- function(nodes, image, mar, verbose = FALSE){
    if(is.null(image)){
        if(nrow(nodes)>0){
            nodes$x <- nodes$x - mean(range(nodes$x))
            nodes$y <- nodes$y - mean(range(nodes$y))
            from <- range(c(nodes$x, nodes$y))
            to <- c(mar, 1-mar)
            nodes$x <- scales::rescale(nodes$x, from = from, to=to)
            nodes$y <- scales::rescale(nodes$y, from = from, to=to)
        }
        temp <- list(nodes=nodes, image=as.raster(matrix()),
            image.layer = FALSE)
    } else {
        if(verbose) message("Setting graph coordinates to image space...")
        if(!is.raster(image)) image <- as.raster(image)
        if(nrow(nodes) > 0){
            temp <- .frame.nodes(nodes, image, mar)
            temp$image.layer <- TRUE
        } else {
            temp <- list(nodes=nodes, image=image, image.layer=TRUE)
        }
    }
    return(temp)
}

################################################################################
### Get nodes and edges in a df object
################################################################################

#-------------------------------------------------------------------------------
.get.nodes <- function(g){
    lt <- vertex_attr(g)
    nodes <- data.frame(row.names = seq_along(lt[[1]]))
    for(nm in names(lt)){
        nodes[[nm]] <- lt[[nm]]
    }
    vertex <- seq_len(igraph::vcount(g))
    nodes <- cbind(vertex = vertex, nodes)
    rownames(nodes) <- nodes$name
    return(nodes)
}
.get.edges <- function(g){
    if (igraph::is_directed(g)) {
        edges <- .get.directed.edges(g)
    } else {
        edges <- .get.undirected.edges(g)
    }
    return(edges)
}

################################################################################
### Get edges in a df object
################################################################################
.get.undirected.edges <- function(g){
    if(ecount(g)>0){
        vertex <- igraph::V(g)$name
        edges <- igraph::as_edgelist(g, names = FALSE)
        rownames(edges) <- colnames(edges) <- NULL
        edges <- as.data.frame(edges)
        colnames(edges) <- c("vertex1", "vertex2")
        edges$emode <- 0
        edges$name1 <- vertex[edges$vertex1]
        edges$name2 <- vertex[edges$vertex2]
        atts <- .get.eatt(g)
        if(!all(atts[,c(1,2)]==edges[,c(1,2)])){
            stop("unexpected indexing during edge attribute combination.", 
                call. = FALSE)
        }
        edges <- cbind(edges, atts[,-c(1,2)])
        edges <- edges[order(edges$vertex1,edges$vertex2), ]
        edges <- .set.arrowangle(edges)
        edges <- .set.emode(edges)
        edges <- .adjust.arrow.length(edges)
        idx <- colnames(edges) %in% names(.get.empty.edgedf())
        edges <- edges[, c(which(idx), which(!idx))]
    } else {
        edges <- .get.empty.edgedf()
    }
    return(edges)
}
.get.eatt <- function(g){
    lt <- igraph::edge_attr(g)
    atts <- data.frame(row.names = seq_along(lt[[1]]))
    for(nm in names(lt)){
        atts[[nm]] <- lt[[nm]]
    }
    e <- igraph::as_edgelist(g, names = FALSE)
    colnames(e) <- c("vertex1", "vertex2")
    atts <- cbind(e, atts)
    return(atts)
}
.set.arrowangle <- function(edges){
    arrowAngle_1 <- .set.arrowangle1(edges$arrowType)
    arrowAngle_2 <- .set.arrowangle2(edges$arrowType)
    edges <- cbind(edges, arrowAngle_1 = arrowAngle_1,
        arrowAngle_2 = arrowAngle_2)
    return(edges)
}
.set.arrowangle1 <- function(etype){
    arrowAngle <- rep(NA, length(etype))
    arrowAngle[etype %in% c(0, 1, -1)] <- 0
    arrowAngle[etype %in% c(2, 3, -4)] <- 30
    arrowAngle[etype %in% c(-2, -3, 4)] <- 90
    return(arrowAngle)
}
.set.arrowangle2 <- function(etype){
    arrowAngle <- rep(NA, length(etype))
    arrowAngle[etype %in% c(0, 2, -2)] <- 0
    arrowAngle[etype %in% c(1, 3, 4)] <- 30
    arrowAngle[etype %in% c(-1, -3, -4)] <- 90
    return(arrowAngle)
}
.set.emode <- function(edges){
    emode <- abs(edges$arrowType)
    emode[emode>3] <- 3
    edges$emode <- emode
    return(edges)
}

################################################################################
### Get undirected edges in a df object
################################################################################
.get.directed.edges <- function(g) {
    if (ecount(g) > 0) {
        vertex <- igraph::V(g)$name
        E(g)$emode <- 1
        E(g)$emode[igraph::which_mutual(g)] <- 3
        e <- emode <- .adjacency(g, attr = "emode")
        bl <- lower.tri(emode) & emode == 3
        emode[bl] <- 0
        edges <- arrayInd(seq_len(prod(dim(emode))), dim(emode), 
            useNames = TRUE)
        edges <- as.data.frame(edges)
        colnames(edges) <- c("vertex1", "vertex2")
        edges$emode <- as.numeric(emode)
        edges$name1 <- vertex[edges$vertex1]
        edges$name2 <- vertex[edges$vertex2]
        edges$e <- as.numeric(e > 0)
        eid <- e; eid[,] <- 0
        ut <- upper.tri(eid)
        eid[ut] <- seq_len(sum(ut))
        eid <- t(eid)
        eid[ut] <- seq_len(sum(ut))
        edges$eid <- as.numeric(eid)
        edges$ut <- as.numeric(upper.tri(e))
        edges$lt <- as.numeric(lower.tri(e))
        g <- .remove.hidden.eatt(g)
        atts <- .extract.directed.att(g)
        if (!all(atts[, c(1, 2)] == edges[, c(1, 2)])) {
            stop("unexpected indexing during edge attribute combination.", 
                call. = FALSE)
        }
        edges <- cbind(edges, atts[, -c(1, 2)])
        eid <- unique(edges$eid[edges$e > 0])
        edges <- edges[edges$eid %in% eid, ]
        edges <- edges[order(edges$eid), ]
        rownames(edges) <- NULL
        edges <- .set.arrowtype.dir(edges)
        edges <- .set.arrowangle(edges)
        edges <- .set.emode(edges)
        edges <- .adjust.arrow.length(edges)
        idx <- colnames(edges) %in% names(.get.empty.edgedf())
        edges <- edges[, c(which(idx), which(!idx))]
    } else {
        edges <- .get.empty.edgedf()
    }
    return(edges)
}
.set.arrowtype.dir <- function(edges, a_name = "arrowType") {
    # Flip ut/lt from single-edge arrows; this
    # for collecting arrows from the same mtx side
    idx <- which(edges$emode == 1 & edges$lt == 1)
    if (length(idx) > 0) {
        for (i in idx) {
            ii <- which(edges$eid == edges$eid[i])
            edges[ii, c("ut", "lt")] <- edges[ii, c("lt", "ut")]
        }
    }
    # collect left-side arrows
    arrow1 <- edges[edges$lt == 1, a_name]
    arrow1[is.na(arrow1)] <- 0
    # collect right-side arrows
    arrow2 <- edges[edges$ut == 1, a_name]
    arrow2[is.na(arrow2)] <- 0
    # get single-edge assigments
    edges <- edges[, -which(colnames(edges) %in% a_name)]
    edges <- edges[edges$e == 1, ]
    eid <- sort(unique(edges$eid))
    edges <- edges[order(-edges$ut, edges$eid), ]
    edges <- edges[match(eid, edges$eid), ]
    # add arrows and remove intermediate columns
    edges <- .merge.arrowtypes.dir(edges, arrow1, arrow2)
    edges <- edges[, -which(colnames(edges) %in%
            c("e", "eid", "ut", "lt"))]
    return(edges)
}
.merge.arrowtypes.dir <- function(edges, arrow1, arrow2) {
    ##  0 = "---", 1 = "-->",  2 = "<--",  3 = "<->",  4 = "|->",
    ## -1 = "--|", -2 = "|--", -3 = "|-|", -4 = "<-|",
    atypes <- c(0, 1, 2, 3, 4, -1, -2, -3, -4)
    names(atypes) <- c("00","01","10","11","-11","0-1","-10","-1-1","1-1")
    arrowType <- paste0(format(arrow1, digits = 1, trim = TRUE),
        format(arrow2, digits = 1, trim = TRUE))
    edges$arrowType <- as.numeric(atypes[arrowType])
    return(edges)
}
.extract.directed.att <- function(g) {
    # e <- igraph::as_adjacency_matrix(g, sparse = FALSE)
    e <- .adjacency(g)
    atts <- arrayInd(seq_len(prod(dim(e))), dim(e), useNames = TRUE)
    atts <- as.data.frame(atts)
    colnames(atts) <- c("vertex1", "vertex2")
    atts$e <- as.numeric(e)
    # a_names <- names(.get.default.eatt())
    a_names <- igraph::edge_attr_names(g)
    ne <- e == 0
    for (at in a_names) {
        x <- .adjacency(g, attr = at)
        x[ne] <- NA
        if (is.data.frame(x)){
            atts[[at]] <- I(unlist(x, recursive=FALSE))
        } else {
            if (is.numeric(x)) {
                atts[[at]] <- as.numeric(x)
            } else if (is.character(x)) {
                atts[[at]] <- as.character(x)
            }
        }
    }
    rownames(atts) <- NULL
    atts <- atts[, c("vertex1", "vertex2", a_names)]
    return(atts)
}
# ..this is a fix for 'as_adjacency_matrix', when 'attr' is character
.adjacency <- function(g, attr = NULL) {
    if(is.null(attr)){
        exattr <- rep(1, ecount(g))
        x <- matrix(0, nrow = vcount(g), ncol = vcount(g))
    } else {
        exattr <- edge_attr(g, as.character(attr))
        x <- matrix(NA, nrow = vcount(g), ncol = vcount(g))
        if(is.list(exattr)) x <- as.data.frame(x)
    }
    e <- igraph::ends(g, seq_len(ecount(g)), names = FALSE)
    x[e] <- exattr
    if (!is_directed(g)) x[e[,c(2,1)]] <- exattr
    colnames(x) <- rownames(x) <- V(g)$name
    return(x)
}

################################################################################
### Other functions
################################################################################

#-------------------------------------------------------------------------------
.get.empty.edgedf <- function(){
    n <- numeric(); c <- character()
    edges <- data.frame(n, n, n, c, c, n, c, c, n, n, n, n, n, n)
    colnames(edges) <- c("vertex1","vertex2","emode", "name1", "name2", 
        "weight", "edgeLineWidth","edgeLineColor","edgeLineType",
        "arrowType", "arrowAngle_1", "arrowAngle_2", 
        "arrowLength_1", "arrowLength_2")
    return(edges)
}

#-------------------------------------------------------------------------------
.adjust.arrow.length <- function(edges){
    edges$arrowLength_1 <- edges$arrowLength
    edges$arrowLength_2 <- edges$arrowLength
    a_theta <- 60 #default arrow angle * 2 (not implemented)
    a_theta <- a_theta / 180 * pi
    idx <- edges$arrowAngle_1==90
    if(any(idx, na.rm = TRUE)){
        l <- edges$arrowLength_1[idx]/2
        b <- sqrt( (l^2 + l^2) - (2 * l^2) * cos(a_theta))
        edges$arrowLength_1[idx] <- b + edges$edgeLineWidth[idx]/4
    }
    idx <- edges$arrowAngle_2==90
    if(any(idx, na.rm = TRUE)){
        l <- edges$arrowLength_2[idx]/2
        b <- sqrt( (l^2 + l^2) - (2 * l^2) * cos(a_theta))
        edges$arrowLength_2[idx] <- b + edges$edgeLineWidth[idx]/4
    }
    edges <- edges[ , -which(colnames(edges)=="arrowLength")]
    return(edges)
}

#-------------------------------------------------------------------------------
.get.exy <- function(gxy, edges){
    exy <- data.frame(
        x1 = gxy[edges$vertex1,"x"], 
        x2 = gxy[edges$vertex2,"x"], 
        y1 = gxy[edges$vertex1,"y"], 
        y2 = gxy[edges$vertex2,"y"])
    edges <- cbind(edges, exy)
    return(edges)
}
