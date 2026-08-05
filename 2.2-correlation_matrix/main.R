source("./modules/libraries.R")
source("./modules/import_data.R")
dfs  <- import_data("./data/csv/", "./../1-preprocessing/data/output/")

selected_year <- "2024"
for(i in 1:length(date)){
  dfs[[i]] <- dfs[[i]] %>% filter(year == selected_year)
}

df_all <- bind_rows(dfs)
df_wide <- df_all %>%
  pivot_wider(names_from = indicator, values_from = value) %>%
  select(-country_code, -year)

cor_matrix <- cor(df_wide, use = "pairwise.complete.obs", method = "pearson")


short_names <- c(
  "Early Sch. Leaving",
  "Rate Tech Empl.",
  "R&D Expens. Rel. GDP",
  "Tertiary Educ.",
  "Cont. Develop. Of Empl.",
  "Net Migration",
  "Empl. Sup. Ed.",
  "Labour Produc.",
  "Rate Temp. Contract",
  "Rate Of Empl.",
  "Rate Of Unempl.",
  "Annual Revenue"
)

rownames(cor_matrix) <- short_names
colnames(cor_matrix) <- short_names

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
           title = str_glue("Correlation matrix (", selected_year, ")"),
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




