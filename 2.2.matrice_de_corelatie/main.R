source("./functii/librarii.R")
source("./functii/citire_fisiere.R")
date  <- citire_fisiere("./date")
an_analiza <- "2024"
for(i in 1:length(date)){
  date[[i]] <- date[[i]] %>% filter(an == an_analiza)
}
df_all <- bind_rows(date)
df_wide <- df_all %>%
  pivot_wider(names_from = indicator, values_from = valoare) %>%
  select(-cod_tara, -an)
cor_matrix <- cor(df_wide, use = "pairwise.complete.obs", method = "pearson")


short_names <- c(
  "Abandon Scolar",
  "Angajati Tech",
  "Chelt. C&D / PIB",
  "Edu. Tertiara",
  "Formare Continua",
  "Migratie Neta",
  "Ocp. Edu. Sup.",
  "Prod. Muncii",
  "Contracte Temp.",
  "Rata Ocupare",
  "Rata Somaj",
  "Venit Anual"
)

colnames(cor_matrix) <- rownames(cor_matrix) <- short_names


ggcorrplot(cor_matrix,
           method = "square",
           type = "lower",
           hc.order = FALSE,
           lab = TRUE,
           lab_size = 5,
           tl.cex = 12,
           tl.col = "grey20",
           colors = c("#C1392B", "#FFFFFF", "#2471A3"),
           outline.color = "grey70",
           title = str_glue("Corelații între indicatori (", an_analiza, ")"),
           ggtheme = theme_minimal(base_size = 12)
) +
  theme(
    plot.title = element_text(hjust = 0.5, size = 14, face = "bold", margin = margin(b = 15)),
    axis.text.x = element_text(angle = 30, hjust = 1, vjust = 1, face = "bold", size = 15),
    axis.text.y = element_text(hjust = 1, face = "bold", size = 15),
    legend.title = element_text(size = 10),
    legend.key.height = unit(1.5, "cm"),
    panel.grid.major = element_line(color = "grey80", linewidth = 0.5),
    panel.grid.minor = element_line(color = "grey90", linewidth = 0.3),
    plot.background = element_rect(fill = "white", color = NA),
    panel.background = element_rect(fill = "white", color = NA),
    plot.margin = margin(15, 15, 15, 15)
  )




