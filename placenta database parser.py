import requests
from bs4 import BeautifulSoup

#function to fetch GEO information
def fetch_geo_data(accession):
    url = f"https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc={accession}"
    response = requests.get(url)
    
    if response.status_code != 200:
        print(f"Error fetching data for {accession}")
        return None
    
    soup = BeautifulSoup(response.text, 'html.parser')
    
    #parse the easy to get info
    geo_info = {
        'GEO ID': accession,
        'Title': soup.find(text="Title").find_next('td').text.strip(),
        'Organism': soup.find(text="Organism").find_next('td').text.strip(),
        'Experiment type': soup.find(text="Experiment type").find_next('td').text.strip(),
        'Platform ID': soup.find(text="Platform ID").find_next('td').text.strip(),
        'BioProject ID': soup.find(text="BioProject").find_next('td').text.strip(),
        'SRA ID': soup.find(text="SRA").find_next('td').text.strip(),
        'Contact name': soup.find(text="Contact name").find_next('td').text.strip(),
        'Submission date': soup.find(text="Submission date").find_next('td').text.strip(),
        'Last update date': soup.find(text="Last update date").find_next('td').text.strip(),
        'Organization name': soup.find(text="Organization name").find_next('td').text.strip(),
    }
    
    #try to find the sample size
    sample_size_element = soup.find(text="Samples")
    if sample_size_element:
        geo_info['Sample size'] = len(sample_size_element.find_all_next('td'))
    else:
        geo_info['Sample size'] = 'Not provided'
    
    return geo_info

#function to display filled out fields
def display_geo_info(geo_info):
    if geo_info:
        print("\n--- GEO Data ---")
        for key, value in geo_info.items():
            print(f"{key}: {value}")
    else:
        print("No data found.")

#main execution
if __name__ == "__main__":
    accession = input("Enter GEO Accession Number (e.g., GSE163286): ")
    geo_info = fetch_geo_data(accession)
    display_geo_info(geo_info)
