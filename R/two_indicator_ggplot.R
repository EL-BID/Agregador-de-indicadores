two_indicator_plotly<-function()
{
  ay <- list(
    tickfont = list(color = "red"),
    overlaying = "y",
    side = "right",
    title = "% of GDP"
  )
  p <- plot_ly() %>%
    add_lines(x = df[df$src_id_ind=="LMW_403",]$year, y = df[df$src_id_ind=="LMW_403",]$value, name = "GDP: (US$ mill.) - Numbers for Development") %>%
    add_lines(x = df[df$src_id_ind=="NV.AGR.TOTL.ZS",]$year, y = df[df$src_id_ind=="NV.AGR.TOTL.ZS",]$value, name = "Agriculture, value added (% of GDP) -  World Bank", yaxis = "y2") %>%
    layout(
      title = "Comparación de dos indicadores", yaxis2 = ay,
      xaxis = list(title="Year")
    )

}

two_indicator_ggplot<-function()
{
  p <- ggplot(df[df$src_id_ind=="NV.AGR.TOTL.ZS",], aes(x = year)) 
  
  p <- p + geom_line(aes(y = df[df$src_id_ind=="LMW_403",]$value, colour = "GDP: (US$ mill.)"))
  
  p<- p +  geom_line(aes(y = df[df$src_id_ind=="NV.AGR.TOTL.ZS",]$value*20000, colour = "Agriculture, value added (% of GDP)"))
  
  
  # now adding the secondary axis, following the example in the help file ?scale_y_continuous
  # and, very important, reverting the above transformation
  p <- p + scale_y_continuous(expand = c(0, 1), limits = c(0,240000),name = "US$ mill",sec.axis = sec_axis(~./20000,name = "% of GDP"))
  
  
  # modifying colours and theme options
  p <- p + scale_colour_manual(values = c("blue", "red"))
  p <- p + labs(y = "US$ mill",
                x = "Year",
                colour = "Indicator")
  p <- p + theme(legend.position = c(0.9, 1.5))

  p  
}
