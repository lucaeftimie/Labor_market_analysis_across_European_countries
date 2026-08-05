source("./modules/libraries.R")
source("./modules/import_data.R")

# Import data

dfs <- import_data("./data/csv/", "./../1-preprocessing/data/output/")

selected_year <- 2020
long_df <- bind_rows(dfs)

year_df <- long_df |> filter(year == selected_year)

X <- year_df |>
  pivot_wider(names_from = indicator, values_from = value) |>
  column_to_rownames("country_code") |>
  select(-year) |>
  drop_na()

# Principal component analysis

acp <- princomp(X, cor = TRUE, scores = TRUE)
scores <- data.frame(acp$scores[, 1:4])
names(scores) <- c("Z1", "Z2", "Z3", "Z4")
var_exp <- round(acp$sdev^2 / sum(acp$sdev^2) * 100, 1)

country_names <- c(
	AT = "Austria",     BE = "Belgium",    BG = "Bulgaria",
	CZ = "Czechia",     DE = "Germany",    DK = "Denmark",
	EE = "Estonia",     EL = "Greece",     ES = "Spain",
	FI = "Finland",     FR = "France",     HR = "Croatia",
	HU = "Hungary",     IT = "Italy",      LT = "Lithuania",
	LU = "Luxembourg",  LV = "Latvia",     NL = "Netherlands",
	NO = "Norway",      PL = "Poland",     PT = "Portugal",
	RO = "Romania",     SE = "Sweden",     SI = "Slovenia",
	SK = "Slovakia"
)
scores$Country <- country_names[rownames(scores)]
scores

# Graphical representation of the countries in the Z1–Z2 space

ggplot(scores, aes(x = Z1, y = Z2, label = Country)) +
  geom_point(color = "steelblue", size = 4) +
  geom_text_repel(size = 6, max.overlaps = 30, fontface = "bold") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    x = paste0("Z1 – Economic Growth (",var_exp[1], "%)"),
    y = paste0("Z2 – Labour force stability (",var_exp[2], "%)")
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold", margin = margin(b = 15)),
    axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 16, face = "bold", margin = margin(r = 15)),
    axis.text = element_text(size = 13, face = "bold"),
    panel.grid.major = element_line(color = "gray85"),
    panel.grid.minor = element_blank()
  ) + ggtitle(paste0("Graphical representation of the countries in the Z1–Z2 space (",selected_year , ")"))


# Optimal number of clusters

scores_2d <- scores[, c("Z1", "Z2")]
set.seed(42)
nc <- suppressWarnings(NbClust(scores_2d,
                               distance = "euclidean",
                               min.nc   = 2,
                               max.nc   = 12,
                               method   = "ward.D2",
                               index    = "all"))


K <- 3


# K-MEANS clustering method
set.seed(42)
km <- kmeans(scale(scores_2d), centers = K, nstart = 25)
rownames(scores_2d) <- country_names[rownames(scores)]

p <- fviz_cluster(km, data = scale(scores_2d), choose.vars = c(1, 2),
                  repel = FALSE,
                  labelsize = 0,
                  pointsize = 2.5,
                  palette = c( "#E41A1C", "#4DAF4A", "#377EB8"))

coord <- p$data

p +
  geom_text_repel(
    data = coord,
    aes(x = x, y = y, label = name),
    size = 6,
    max.overlaps = 30,
    fontface = "bold",
    show.legend = FALSE
  ) +
  xlab(paste0("Economic Growth (",var_exp[1] ,"%)")) +
  ylab(paste0("Labour force stability (", var_exp[2],"%)"))+
  theme_gray(base_size = 16) +
  theme(
    plot.title   = element_text(size = 16, face = "bold"),
    axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 16, face = "bold", margin = margin(r = 15)),
    axis.text    = element_text(size = 11, face = "bold"),
    legend.text  = element_text(size = 11, face = "bold")
  ) + ggtitle(paste0("Country Clustering Using the K-Means Algorithm (", selected_year, ")"))


# Ward.D2 clustering method

d <- dist(scale(scores_2d), method = "euclidean")
hc <- hclust(d, method = "ward.D2")

clase_hc <- cutree(hc, k = K)

fviz_dend(hc,
          k = K,
          cex = 1.,
          k_colors = c("#4DAF4A", "#E41A1C", "#377EB8"),
          color_labels_by_k = TRUE,
          rect = TRUE,
          rect_border = c("#4DAF4A", "#E41A1C", "#377EB8"),
          rect_fill = TRUE,
          main = paste0("Dendrogram - Country Clustering Using the Ward.D2 Algorithm (", selected_year, ")"),
          xlab = "Country",
          ylab = "Distance",
          ggtheme = theme_gray(base_size = 16)) +
  theme(
    plot.title   = element_text(size = 16, face = "bold"),
    axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 14, face = "bold", margin = margin(r = 15)),
    axis.text    = element_text(size = 11, face = "bold")  
)


cat("Total sum of squares (Total SS):", km$totss, "\n")

cat("Within-cluster sum of squares for each cluster:", km$withinss, "\n")
cat("Total within-cluster sum of squares (Total Within SS):", km$tot.withinss, "\n")
cat("Between-cluster sum of squares (Between SS):", km$betweenss, "\n")

explained_proportion <- km$betweenss / km$totss
cat("Percentage of variance explained:", explained_proportion * 100, "%\n")

