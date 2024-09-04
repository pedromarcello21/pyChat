from selenium import webdriver
from selenium.webdriver.common.by import By 
import random
from datetime import datetime

# Create Chromeoptions instance 
options = webdriver.ChromeOptions() 
import time

#Keep website persisting
options.add_experimental_option("detach", True)
#Avoid bot detection
options.add_argument('--disable-blink-features=AutomationControlled')

def find_flight(destination):
    # Setting the driver path and requesting a page 
    driver = webdriver.Chrome(options=options) 
    link = "https://www.google.com/travel/flights?gl=US&hl=en-US"

    # Go to streeteasy.com
    driver.get(link)

    driver.maximize_window()

    # Define a function to click on xp path
    def xpath_click(xp):
        time.sleep(random.uniform(1,4))
        driver.find_element(By.XPATH,xp).click()

    search_bar = "//input[@aria-label='Where to? ']"

    xpath_click(search_bar)

    # destination = "MIA"

    inputDestination = driver.find_element(By.XPATH, search_bar)
    inputDestination.send_keys(destination)

    time.sleep(2)


    try:
        destination_first_dropdown = "//li[@class='n4HaVc sMVRZe pIWVuc']"
        xpath_click(destination_first_dropdown)
    except:
        print("can't find path")

    drop_down = "//div[@class='VfPpkd-aPP78e']"
    xpath_click(drop_down)


    click_one_way = "//li[@data-value='2']"
    xpath_click(click_one_way)


    click_calendar = "//div[@class='icWGef A84apb P0ukfb bgJkKe BtDLie']"
    xpath_click(click_calendar)

    todays_date = datetime.today().strftime('%Y-%m-%d')
    click_date = f"//div[@data-iso='{todays_date}']"
    xpath_click(click_date)

    click_done = "//button[@class='VfPpkd-LgbsSe VfPpkd-LgbsSe-OWXEXe-k8QpJ VfPpkd-LgbsSe-OWXEXe-dgl2Hf nCP5yc AjY5Oe DuMIQc LQeN7 z18xM rtW97 Q74FEc dAwNDc']"
    xpath_click(click_done)

    click_search = "//button[@class='VfPpkd-LgbsSe VfPpkd-LgbsSe-OWXEXe-k8QpJ VfPpkd-LgbsSe-OWXEXe-Bz112c-M1Soyc nCP5yc AjY5Oe LQeN7 TUT4y zlyfOd']"
    xpath_click(click_search)
    return f"Searching flights to {destination}..."


