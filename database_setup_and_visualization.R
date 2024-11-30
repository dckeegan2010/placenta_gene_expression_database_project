# Libraries
library(RSQLite)
library(DBI)
library(DiagrammeR)

# Load the CSV file
file_name <- "C:/Users/Davy/Documents/ASU/BIO498/Placenta_Study_Information - Studies.csv"
placenta_data <- read.csv(file_name, check.names = FALSE)  # Preserve original names

# Clean column names
names(placenta_data) <- make.names(names(placenta_data), unique = TRUE)
names(placenta_data) <- trimws(names(placenta_data)) # trims leading and trailing white space
names(placenta_data) <- gsub("[^a-zA-Z0-9]", "_", names(placenta_data)) # Turns non alphanumeric into underscore
names(placenta_data) <- sub("_$", "", names(placenta_data)) # Drops trailing underscores
print(names(placenta_data))

# Create SQLite database
db_name <- "PlacentaStudies.db"
con <- dbConnect(SQLite(), dbname = db_name)

# Create the tables
# Create Studies table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Studies (
    StudyID INTEGER PRIMARY KEY AUTOINCREMENT,
    GEO_Series_ID TEXT,
    Title TEXT,
    Organism TEXT,
    Experiment_type TEXT,
    Data_type_from_CURE_list TEXT,
    Additional_data_types_included_in_the_entry_if_any TEXT,
    SuperSeries_check_if_yes TEXT,
    If_SuperSeries_list_GEO_Series_that_are_part_of_the_SuperSeries TEXT,
    Total_GEO_sample_size INTEGER,
    Collection_Site TEXT,
    Country_where_samples_were_collected TEXT,
    Hospital_Center_where_samples_were_collected TEXT,
    Submission_date DATE,
    Last_update_date DATE
)")

# Create Subjects table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Subjects (
    SubjectID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Birthweight_of_offspring_provided_yes_no TEXT,
    Gestational_Age_at_delivery_provided_yes_no TEXT,
    Gestational_Age_at_sample_collection_provided_yes_no TEXT,
    Sex_of_Offspring_Provided_yes_no TEXT,
    Parity_provided_yes_no TEXT,
    Gravidity_provided_yes_no TEXT,
    Number_of_offspring_per_pregnancy_provided_yes_no TEXT,
    Self_reported_race_ethnicity_of_mother_provided_yes_no TEXT,
    Genetic_ancestry_or_genetic_strain_provided_yes_no TEXT,
    Maternal_Height_provided_yes_no TEXT,
    Maternal_Pre_pregnancy_Weight_provided_yes_no TEXT,
    Paternal_Height_provided_yes_no TEXT,
    Paternal_Weight_provided_yes_no TEXT,
    Maternal_age_at_sample_collection_provided_yes_no TEXT,
    Paternal_age_at_sample_collection_provided_yes_no TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Create Phenotypes table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Phenotypes (
    PhenotypeID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Phenotype TEXT,
    Pregnancy_complications_in_data_set_list TEXT,
    Fetal_complications_listed_yes_no TEXT,
    Fetal_complications_in_data_set_list TEXT,
    Other_Phenotypes_Provided_list TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Create Samples table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Samples (
    SampleID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Placental_sampling TEXT,
    Sample_size_placenta INTEGER,
    Sample_size_decidua INTEGER,
    Other_tissue_types_in_data_set_list TEXT,
    Samples_from_pregnancy_complications_collected TEXT,
    Mode_of_delivery_provided_yes_no TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Create Authors table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Authors (
    AuthorID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Supervisor_Contact_Corresponding_author_name TEXT,
    Supervisor_Contact_Corresponding_author_email TEXT,
    Contact_name TEXT,
    E_mail_s TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Create Publications table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS Publications (
    PublicationID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Citation TEXT,
    PMID TEXT,
    PMCID TEXT,
    doi_link TEXT,
    Citation_of_paper_to_discuss TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Create OtherInformation table
dbExecute(con, "
CREATE TABLE IF NOT EXISTS OtherInformation (
    InfoID INTEGER PRIMARY KEY AUTOINCREMENT,
    StudyID INTEGER,
    Additional_Notes_Points_of_Interest_for_Dataset TEXT,
    Additional_Notes_Points_of_interest_for_Study TEXT,
    Recommend_for_future_Journal_Club TEXT,
    Interesting_aspect_of_this_study TEXT,
    FOREIGN KEY (StudyID) REFERENCES Studies(StudyID)
)")

# Insert data into the database

### NOT WORKING ###
#dbWriteTable(con, "Studies", placenta_data, append = TRUE, row.names = FALSE)


# Visualize the database schema 
diagram <- "
digraph ERD { # This "ERD" value can be change to Network for a simplified version
  node [shape=record, style=filled, fillcolor=gold, fontcolor=maroon]; # Fork 'Em!
  
  Studies [label = '{StudyID | GEO_Series_ID | Title | Organism | Experiment_type | Data_type_from_CURE_list | Additional_data_types_included_in_the_entry_if_any | SuperSeries_check_if_yes | If_SuperSeries_list_GEO_Series_that_are_part_of_the_SuperSeries | Total_GEO_sample_size | Collection_Site | Country_where_samples_were_collected | Hospital_Center_where_samples_were_collected | Submission_date | Last_update_date}'];
  Subjects [label = '{SubjectID | StudyID | Birthweight_of_offspring_provided_yes_no | Gestational_Age_at_delivery_provided_yes_no | Sex_of_Offspring_Provided_yes_no | Parity_provided_yes_no | Gravidity_provided_yes_no | Maternal_Height_provided_yes_no | Paternal_Height_provided_yes_no}'];
  Phenotypes [label = '{PhenotypeID | StudyID | Phenotype | Pregnancy_complications_in_data_set_list | Fetal_complications_listed_yes_no | Fetal_complications_in_data_set_list}'];
  Samples [label = '{SampleID | StudyID | Placental_sampling | Sample_size_placenta | Sample_size_decidua | Other_tissue_types_in_data_set_list | Samples_from_pregnancy_complications_collected | Mode_of_delivery_provided_yes_no}'];
  Authors [label = '{AuthorID | StudyID | Supervisor_Contact_Corresponding_author_name | Supervisor_Contact_Corresponding_author_email | Contact_name | E_mail_s}'];
  Publications [label = '{PublicationID | StudyID | Citation | PMID | PMCID | doi_link | Citation_of_paper_to_discuss}'];
  OtherInformation [label = '{InfoID | StudyID | Additional_Notes_Points_of_Interest_for_Dataset | Recommend_for_future_Journal_Club | Interesting_aspect_of_this_study}'];
  
  # Create the arrows
  Studies -> Subjects [label='has'];
  Studies -> Phenotypes [label='has'];
  Studies -> Samples [label='has'];
  Studies -> Authors [label='has'];
  Studies -> Publications [label='has'];
  Studies -> OtherInformation [label='has'];
  Subjects -> Phenotypes [label='associated with'];
  Samples -> Phenotypes [label='associated with'];
}
"

# Display the diagram 
grViz(diagram)



# Commit the transaction and close the connection
dbCommit(con)
dbDisconnect(con)


