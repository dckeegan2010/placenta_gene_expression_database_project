#David Keegan
#11/22/2024



#import ggplot
library(ggplot2)

# Load the data
data <- read.csv("C:/Users/Davy/Documents/ASU/BIO498/Placenta_Study_Information - Studies.csv", header = TRUE)

print(names(data))
# Fields for pie charts, add more as needed
fields <- c("Library.strategy",
            "Sex.of.Offspring.Provided..yes.no.",
            "Organism",
            "Pregnancy.trimester..1st..2nd..3rd..term..for.full.term.delivery...premature..for.early.delivery.due.to.complications.")
second_fields <- c("Organization.name",
            "")

# Manually setting threshold of unique values to be combined into "Other"
threshold <- 3

#### Begin Looping through fields ####
for (field in fields) {
  
  # Convert column to table, then to a df
  field_table <- table(data[[field]])
  print(names(field_table))
  field_df <- data.frame(Category = names(field_table), Count = as.numeric(field_table))

  #### Data cleanup ####
  
  # Remove empty rows
  field_df <- field_df[field_df$Category != "", ]
  print(names(field_df))
  # Strip leading and trailing whitespace
  field_df$Category <- trimws(field_df$Category)
  
  # Combine "Yes/No" categories 
  field_df$Category <- gsub("(?i)yes", "Yes", field_df$Category, perl = TRUE)
  field_df$Category <- gsub("(?i)no", "No", field_df$Category, perl = TRUE)
  
  # Collapse "RNA"-starting entries into "RNA-seq"
  field_df$Category <- ifelse(grepl("^RNA", field_df$Category, ignore.case = TRUE), "RNA-seq", field_df$Category)
  
  # Combine "N/A" categories 
  field_df$Category <- gsub("(?i)na", "NA", field_df$Category, perl = TRUE)
  field_df$Category <- gsub("(?i)n/a", "NA", field_df$Category, perl = TRUE)

  # Gestational age field collapse
  field_df$Category <- ifelse(grepl("^1st", field_df$Category, ignore.case = TRUE), "1st", field_df$Category)
  field_df$Category <- ifelse(grepl("^first", field_df$Category, ignore.case = TRUE), "1st", field_df$Category)
  
  field_df$Category <- ifelse(grepl("^pre", field_df$Category, ignore.case = TRUE), "Preterm", field_df$Category)
  field_df$Category <- ifelse(grepl("^No", field_df$Category, ignore.case = TRUE), "NA", field_df$Category)
  field_df$Category <- ifelse(grepl("^-", field_df$Category, ignore.case = TRUE), "NA", field_df$Category)
  field_df$Category <- ifelse(grepl("^term", field_df$Category, ignore.case = TRUE), "Term", field_df$Category)
  field_df$Category <- ifelse(grepl("^full", field_df$Category, ignore.case = TRUE), "Term", field_df$Category)
  field_df$Category <- ifelse(grepl("^NA samples", field_df$Category, ignore.case = TRUE), "NA", field_df$Category)
  field_df$Category <- ifelse(grepl("^NA; cell", field_df$Category, ignore.case = TRUE), "NA", field_df$Category)
  field_df$Category <- ifelse(grepl("^implantation", field_df$Category, ignore.case = TRUE), "NA", field_df$Category)
  field_df$Category <- ifelse(grepl("^embryo", field_df$Category, ignore.case = TRUE), "Other", field_df$Category)
  field_df$Category <- ifelse(grepl("^Embryo", field_df$Category, ignore.case = TRUE), "Other", field_df$Category)
  field_df$Category <- ifelse(grepl("^E18", field_df$Category, ignore.case = TRUE), "Other", field_df$Category)
  field_df$Category <- ifelse(grepl("^6 - 9", field_df$Category, ignore.case = TRUE), "Other", field_df$Category)
  
  
  
  # Homo sapiens
  field_df$Category <- gsub("(?i)Homo Sapiens", "Homo Sapiens", field_df$Category, perl = TRUE)
  field_df$Category <- gsub("(?i)homo sapiens", "Homo Sapiens", field_df$Category, perl = TRUE)
  
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

