
#load ggplot
library(ggplot2)

df <- as.data.frame(table(mpg$class)) #creates a dataframe structure with preloaded data
colnames(df) <- c("class", "freq") #labels the columns


pie <- ggplot(df, aes(x = "", y=freq, fill = factor(class))) + #dont need an x axis in a pie 
  geom_bar(width = 1, stat = "identity") + #a pie chart is jsut a bar chart wrapped around itself
  theme(axis.line = element_blank(), #i got a blank space baby
    plot.title = element_text(hjust=0.5)) +
    labs(fill="class",
      x=NULL, #dont label axes in polar coordinates
      y=NULL, 
      title="Pie Chart of class",
      caption="Source: mpg")

pie #prints a not pie chart

pie + coord_polar(theta = "y", start=0) #makes it pie-like