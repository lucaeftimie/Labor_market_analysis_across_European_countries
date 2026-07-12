plot_tara <- function(df, cod, nume_tara, nota) {
  df %>%
    filter(cod_tara == cod) %>%
    ggplot(aes(x = an)) +
    geom_line(aes(y = venit_anual, linetype = "Observat"), color = "#888780", linewidth = 1.2) +
    geom_line(aes(y = fitted,      linetype = "Estimat"),  color = "#534AB7", linewidth = 1.2) +
    scale_linetype_manual(
      name   = NULL,
      values = c("Observat" = "solid", "Estimat" = "dashed")
    ) +
    scale_x_continuous(breaks = 2010:2024) +   # ← corectat de la 2009
    scale_y_continuous(labels = scales::label_number(big.mark = ".")) +
    labs(
      title   = paste0("Valori observate vs. estimate — ", nume_tara),
      caption = nota,
      x = "An", y = "Venit anual (EUR)"
    ) +
    theme_minimal(base_size = 13) +
    theme(
      plot.title       = element_text(size = 14, face = "bold",    margin = margin(b = 8)),
      plot.caption     = element_text(size = 10, color = "gray50", face = "italic"),
      axis.title.x     = element_text(size = 12, margin = margin(t = 8)),
      axis.title.y     = element_text(size = 12, margin = margin(r = 8)),
      axis.text.x      = element_text(angle = 45, hjust = 1, size = 10),
      axis.text.y      = element_text(size = 11),
      legend.position  = "top",
      legend.text      = element_text(size = 11),
      panel.grid.minor = element_blank(),
      panel.grid.major = element_line(color = "gray90")
    )
}