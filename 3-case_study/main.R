source("./functii/librarii.R")
source("./functii/citire_fisiere.R")
date <- citire_fisiere("./date")



AN_SELECTAT <- 2020
df_lung <- bind_rows(date)

df_an <- df_lung |> filter(an == AN_SELECTAT)

X <- df_an |>
  pivot_wider(names_from = indicator, values_from = valoare) |>
  column_to_rownames("cod_tara") |>
  select(-an) |>
  drop_na()

cat("Dimensiune matrice:", dim(X), "\n")   
cat("Tari:", rownames(X), "\n")
cat("Indicatori:", colnames(X), "\n")


# ACP
acp <- princomp(X, cor = TRUE, scores = TRUE)
summary(acp)           
acp$loadings
scoruri <- data.frame(acp$scores[, 1:4])
names(scoruri) <- c("Z1", "Z2", "Z3", "Z4")
scoruri
#cat("\nScoruri ACP (primele 3 componente):\n")
#print(round(scoruri, 3))
var_exp <- round(acp$sdev^2 / sum(acp$sdev^2) * 100, 1)

scoruri$tara <- rownames(acp$scores)

nume_tari <- c(
  AT = "Austria",   BE = "Belgia",    BG = "Bulgaria",
  CZ = "Cehia",     DE = "Germania",  DK = "Danemarca",
  EE = "Estonia",   EL = "Grecia",    ES = "Spania",
  FI = "Finlanda",  FR = "Franța",    HR = "Croația",
  HU = "Ungaria",   IT = "Italia",    LT = "Lituania",
  LU = "Luxemburg", LV = "Letonia",   NL = "Olanda",
  NO = "Norvegia",  PL = "Polonia",   PT = "Portugalia",
  RO = "România",   SE = "Suedia",    SI = "Slovenia",
  SK = "Slovacia"
)
scoruri$tara <- nume_tari[rownames(acp$scores)]


ggplot(scoruri, aes(x = Z1, y = Z2, label = tara)) +
  geom_point(color = "steelblue", size = 4) +
  geom_text_repel(size = 6, max.overlaps = 30, fontface = "bold") +
  geom_hline(yintercept = 0, linetype = "dashed", color = "gray40") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "gray40") +
  labs(
    x = paste0("Z1 – Dezvoltarea economică (",var_exp[1], "%)"),
    y = paste0("Z2 – Stabilitatea pieței muncii (",var_exp[2], "%)")
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(size = 16, face = "bold", margin = margin(b = 15)),
    axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 16, face = "bold", margin = margin(r = 15)),
    axis.text = element_text(size = 13, face = "bold"),
    panel.grid.major = element_line(color = "gray85"),
    panel.grid.minor = element_blank()
  ) + ggtitle(paste0("Reprezentarea grafică a țărilor în spațiul Z1 și Z2 (",AN_SELECTAT , ")"))


# NUMARUL OPTIM DE CLUSTERE (NbClust)
# Rulam pe scoruri_2d — acelasi spatiu folosit la clusterizare
scoruri_2d <- scoruri[, c("Z1", "Z2")]
set.seed(42)
nc <- suppressWarnings(NbClust(scoruri_2d,
                               distance = "euclidean",
                               min.nc   = 2,
                               max.nc   = 12,
                               method   = "ward.D2",
                               index    = "all"))


K <- 3


# K-MEANS 
set.seed(42)
km <- kmeans(scale(scoruri_2d), centers = K, nstart = 25)
rownames(scoruri_2d) <- nume_tari[rownames(scoruri_2d)]

p <- fviz_cluster(km, data = scale(scoruri_2d), choose.vars = c(1, 2),
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
  xlab(paste0("Dezvoltarea economică (",var_exp[1] ,"%)")) +
  ylab(paste0("Stabilitatea pieței muncii (", var_exp[2],"%)"))+
  theme_gray(base_size = 16) +
  theme(
    plot.title   = element_text(size = 16, face = "bold"),
    axis.title.x = element_text(size = 16, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 16, face = "bold", margin = margin(r = 15)),
    axis.text    = element_text(size = 11, face = "bold"),
    legend.text  = element_text(size = 11, face = "bold")
  ) + ggtitle(paste0("Gruparea țărilor prin algoritmul K-means (", AN_SELECTAT, ")"))

scale(scoruri_2d)

clase <- km$cluster
cat("\n--- K-means (k =", K, ") ---\n")
cat("Distributia tarilor in clustere:\n")
print(table(clase))
cat("Centroizi:\n")
print(round(km$centers, 3))


d <- dist(scale(scoruri_2d), method = "euclidean")


# CLUSTERING IERARHIC WARD.D2
hc <- hclust(d, method = "ward.D2")

# Comparatie K-means vs Ward — confirma stabilitatea clusterelor
clase_hc <- cutree(hc, k = K)
cat("\nConcordanta K-means vs Ward:\n")
print(table(Kmeans = clase, Ward = clase_hc))

fviz_dend(hc,
          k = K,
          cex = 1.,
          k_colors = c("#4DAF4A", "#E41A1C", "#377EB8"),
          color_labels_by_k = TRUE,
          rect = TRUE,
          rect_border = c("#4DAF4A", "#E41A1C", "#377EB8"),
          rect_fill = TRUE,
          main = paste0("Dendrograma - Gruparea țărilor prin metoda Ward.D2 (", AN_SELECTAT, ")"),
          xlab = "Țări",
          ylab = "Distanță",
          ggtheme = theme_gray(base_size = 16)) +
  theme(
    plot.title   = element_text(size = 16, face = "bold"),
    axis.title.x = element_text(size = 14, face = "bold", margin = margin(t = 15)),
    axis.title.y = element_text(size = 14, face = "bold", margin = margin(r = 15)),
    axis.text    = element_text(size = 11, face = "bold")  
)


cat("Variabilitatea totală (Total SS):", km$totss, "\n")

cat("Variabilitatea internă pe fiecare cluster:", km$withinss, "\n")
cat("Variabilitatea internă TOTALĂ (Total Within SS):", km$tot.withinss, "\n")
cat("Variabilitatea dintre clustere (Between SS):", km$betweenss, "\n")
proportie_explicata <- km$betweenss / km$totss
cat("Proporția de variabilitate explicată:", proportie_explicata * 100, "%\n")
