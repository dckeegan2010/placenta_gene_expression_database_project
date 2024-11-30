#David Keegan
#11/15/2024

### This script imports a csv file of our research project spreadsheet, cleans it 
# and creates a pie chart. It iterates through a vector called "fields" so that 
# the user can add more fields later if needed. The user could even read in the
# entire header as the "fields" vector and generate ALL THE PIE at once with a 
# small modification.
#
# The script also saves the plots as png files to the working directory.
#
# Finally, it cleans up the memory. I kept crashing trying to rerun the code and 
# I would have to restart Rstudio, but that went away after I started purging 
# everything
#
# Of note, I chose to combine one-off or verbose fields fields into "Other" 
# rather than delete them. Without going at looking at each study, I didn't want
# to get rid of them.

#import ggplot
library(ggplot2)

# Load the data
data <- read.csv("C:/Users/Davy/Documents/ASU/BIO498/Placenta_Study_Information - Studies.csv", header = TRUE)

# Fields for pie charts, add more as needed
fields <- c("Library.strategy",
            "Sex.of.Offspring.Provided..yes.no.",
            "Samples.from.pregnancy.complications.collected..yes.no.")

# Manually setting threshold of unique values to be combined into "Other"
threshold <- 3



#### Begin Looping through fields ####
for (field in fields) {
  
  # Convert column to table, then to a df
  field_table <- table(data[[field]])
  field_df <- data.frame(Category = names(field_table), Count = as.numeric(field_table))
  
  #### Data cleanup ####
  
  # Remove empty rows
  field_df <- field_df[field_df$Category != "", ]
  
  # Strip leading and trailing whitespace
  field_df$Category <- trimws(field_df$Category)
  
  # Combine "Yes/No" categories 
  field_df$Category <- gsub("(?i)yes", "Yes", field_df$Category, perl = TRUE)
  field_df$Category <- gsub("(?i)no", "No", field_df$Category, perl = TRUE)
  
  # Collapse "RNA"-starting entries into "RNA-seq"
  field_df$Category <- ifelse(grepl("^RNA", field_df$Category, ignore.case = TRUE), "RNA-seq", field_df$Category)
  
  # Combine "N/A" categories 
  field_df$Category <- gsub("(?i)na", "N/A", field_df$Category, perl = TRUE)
  field_df$Category <- gsub("(?i)n/a", "N/A", field_df$Category, perl = TRUE)
  # Fixes the na in RNA from getting turned into N/A
  field_df$Category <- ifelse(grepl("^RN/A", field_df$Category, ignore.case = TRUE), "RNA-seq", field_df$Category)
  
  # Re-aggregate after collapsing categories
  field_df <- aggregate(Count ~ Category, data = field_df, sum)
  
  # Collapse small categories into "Other" 
  field_df$Category <- gsub("(?i)OTHER", "Other", field_df$Category, perl = TRUE)
  field_df$Category <- ifelse(field_df$Count < threshold, "Other", field_df$Category)
  field_df <- aggregate(Count ~ Category, data = field_df, sum)
  field_df$Category <- gsub("(?i)OTHER", "Other", field_df$Category, perl = TRUE)

  
  #### Plot pie chart ####
  
  # Calculate percentages for the legend
  total_count <- sum(field_df$Count)
  field_df$Percentage <- (field_df$Count / total_count) * 100
  field_df$Label <- paste0(field_df$Category, " (", round(field_df$Percentage, 1), "%)")
  
  #print the df after cleanup
  print(field_df)
  
  piechart <- ggplot(field_df, aes(x = "", y = Count, fill = Label)) +
    geom_bar(stat = "identity", width = 1) +
    coord_polar(theta = "y") +
    labs(title = field, x = NULL, y = NULL) +
    theme_void() +
    theme(legend.title = element_blank())
  
  # Print the pie chart
  print(piechart)
  
  # Save the plots, but make it readable and name it after the field
  ggsave(paste0(gsub("[^a-zA-Z0-9]", "_", field), "_piechart.png"), plot = piechart, width = 8, height = 6)
  
  # Clear variables and perform garbage collection because i was having memory issues
  rm(field_table, field_df, piechart)
  gc()
}

