import gspread
import json
import yaml
import requests
from bs4 import BeautifulSoup
from datetime import datetime, timezone

with open('config.yml', "r") as file:
    fund_config = yaml.safe_load(file)

fund_url = fund_config['link']

gc = gspread.oauth(
    credentials_filename="./auth/credentials.json",
    authorized_user_filename="./auth/authorized_user.json",
)

# test
sh = gc.open(fund_config['sheet'])
worksheet = sh.sheet1 # current sheet

# get next row
def next_available_row(worksheet):
    str_list = list(filter(None, worksheet.col_values(1)))
    return str(len(str_list)+1)

def scrape():
    try: 
        page = requests.get(fund_url, timeout=(5, 15))
        soup = BeautifulSoup(page.content, "html.parser")
        fund = soup.find_all("div", class_="number")
        fund_text = fund[0].text
    except:
        nextrow = next_available_row(worksheet)
        fund_text = worksheet.acell(f"B{str(int(nextrow) - 1)}").value
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M"), int(fund_text.replace(",", ""))

def update_sheet():
    nextrow = next_available_row(worksheet)
    time, fund = scrape()
    worksheet.update(f'A{nextrow}', time, value_input_option='USER_ENTERED')
    worksheet.update(f'B{nextrow}', fund)

def lambda_handler(event, context):
    update_sheet()
    return {
        'statusCode': 200,
        'body': json.dumps('fund updated')
    }
