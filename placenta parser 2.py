import requests
from bs4 import BeautifulSoup
import pandas as pd

#function to fetch GEO metadata
def fetch_geo_data(accession):
    url = f"https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc={accession}"
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Error fetching data for {accession}")
        return None
    
    soup = BeautifulSoup(response.text, 'html.parser')
    
    #parse the fields
    geo_data = {
        'GEO ID': accession,
        'GEO Series ID': accession,  # Same as GEO ID
        'GEO ID Assignment Number': '',  # Leave empty
        'Date of first data annotation': '',  # Leave empty
        'Data type from CURE list': '',  # Manually filled later based on study type
        'Additional data types': '',  # Leave empty if no additional data types
        'SuperSeries': 'Yes' if 'SuperSeries' in response.text else 'No',
        'Sample size (placenta)': '',  # Manual processing required
        'Placental sampling': '',  # Manual processing required
        'Sample size (decidua)': '',  # Manual processing required
        'Other tissue types': '',  # Manual processing required
        'Suspect study is not relevant': '',  # Leave empty
        'Title': soup.find(text="Title").find_next('td').text.strip() if soup.find(text="Title") else 'Not provided',
        'Organism': soup.find(text="Organism").find_next('td').text.strip() if soup.find(text="Organism") else 'Not provided',
        'Characteristics': '',  # Manual processing required
        'Experiment type': soup.find(text="Experiment type").find_next('td').text.strip() if soup.find(text="Experiment type") else 'Not provided',
        'Extracted molecule': '',  # Leave empty unless found
        'Extraction protocol': '',  # Leave empty unless found
        'Library strategy': '',  # Leave empty unless found
        'Library source': '',  # Leave empty unless found
        'Library selection': '',  # Leave empty unless found
        'Instrument model': '',  # Leave empty unless found
        'Assay description': '',  # Leave empty unless found
        'Data processing': '',  # Leave empty unless found
        'Platform ID': soup.find(text="Platform").find_next('td').text.strip() if soup.find(text="Platform") else 'Not provided',
        'SRA ID': soup.find(text="SRA").find_next('td').text.strip() if soup.find(text="SRA") else 'Not provided',
        'BioSample/BioProject ID': soup.find(text="BioProject").find_next('td').text.strip() if soup.find(text="BioProject") else 'Not provided',
        'File types/resources provided': '',  # Leave empty unless found
        'Submission date': soup.find(text="Submission date").find_next('td').text.strip() if soup.find(text="Submission date") else 'Not provided',
        'Last update date': soup.find(text="Last update date").find_next('td').text.strip() if soup.find(text="Last update date") else 'Not provided',
        'Organization name': soup.find(text="Organization name").find_next('td').text.strip() if soup.find(text="Organization name") else 'Not provided',
        'Contact name': soup.find(text="Contact name").find_next('td').text.strip() if soup.find(text="Contact name") else 'Not provided',
        'Country': '',  # Manually input if found
        'Citation': '',  # Leave empty unless found
        'PMID': '',  # Leave empty unless found
        'PMCID': '',  # Leave empty unless found
        'doi': '',  # Leave empty unless found
        'Supervisor/Contact/Corresponding author name': '',  # Further input needed
        'Supervisor/Contact/Corresponding author email': '',  # Further input needed
        'Main topic of the publication': '',  # Manually input based on paper
        'Pregnancy trimester': '',  # Leave empty unless found
        'Birthweight of offspring provided': '',  # Leave empty unless found
        'Gestational Age at delivery provided': '',  # Leave empty unless found
        'Gestational Age at sample collection provided': '',  # Leave empty unless found
        'Sex of Offspring Provided': '',  # Leave empty unless found
        'Parity provided': '',  # Leave empty unless found
        'Gravidity provided': '',  # Leave empty unless found
        'Number of offspring per pregnancy provided': '',  # Leave empty unless found
        'Self-reported race/ethnicity of mother provided': '',  # Leave empty unless found
        'Genetic ancestry or genetic strain provided': '',  # Leave empty unless found
        'Maternal Height provided': '',  # Leave empty unless found
        'Maternal Pre-pregnancy Weight provided': '',  # Leave empty unless found
        'Paternal Height provided': '',  # Leave empty unless found
        'Paternal Weight provided': '',  # Leave empty unless found
        'Maternal age at sample collection provided': '',  # Leave empty unless found
        'Paternal age at sample collection provided': '',  # Leave empty unless found
        'Samples from pregnancy complications collected': '',  # Leave empty unless found
        'Mode of delivery provided': '',  # Leave empty unless found
        'Pregnancy complications in data set': '',  # Leave empty unless found
        'Fetal complications listed': '',  # Leave empty unless found
        'Fetal complications in data set': '',  # Leave empty unless found
        'Other Phenotypes Provided': '',  # Leave empty unless found
        'Hospital/Center where samples were collected': '',  # Leave empty unless found
        'Country where samples were collected': ''  # Leave empty unless found
    }

    return geo_data

#function to fetch SRA Run Selector metadata based on BioSample/BioProject ID
def fetch_sra_data(biosample_id):
    url = f"https://www.ncbi.nlm.nih.gov/Traces/study/?acc={biosample_id}"
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Error fetching SRA data for {biosample_id}")
        return None
    
    soup = BeautifulSoup(response.text, 'html.parser')

    #parse SRA fields
    sra_data = {
        'Instrument model': soup.find(text="Instrument model").find_next('td').text.strip() if soup.find(text="Instrument model") else 'Not provided',
        'Library strategy': soup.find(text="Library strategy").find_next('td').text.strip() if soup.find(text="Library strategy") else 'Not provided',
        'Library source': soup.find(text="Library source").find_next('td').text.strip() if soup.find(text="Library source") else 'Not provided',
        'Library selection': soup.find(text="Library selection").find_next('td').text.strip() if soup.find(text="Library selection") else 'Not provided',
    }
    
    return sra_data

#function to process multiple GEO IDs
def process_geo_table(geo_ids):
    geo_records = []

    for geo_id in geo_ids:
        geo_data = fetch_geo_data(geo_id)
        if geo_data:
            #check if BioSample/BioProject ID is available
            biosample_id = geo_data['BioSample/BioProject ID']
            if biosample_id != 'Not provided':
                sra_data = fetch_sra_data(biosample_id)
                #uipdate GEO data with SRA data if available
                if sra_data:
                    geo_data.update(sra_data)
            geo_records.append(geo_data)
    
    return pd.DataFrame(geo_records)

#main
if __name__ == "__main__":
    geo_ids = ['GSE163286', 'GSE56524']  #ENTER YOUR GEO SERIES ID's HERE
    geo_table = process_geo_table(geo_ids)
    
    #export to csv
    geo_table.to_csv('geo_data_table.csv', index=False)
    print("Data processing complete. Output saved to 'geo_data_table.csv'.")
