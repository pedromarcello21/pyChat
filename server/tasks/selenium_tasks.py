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

today = datetime.today().strftime('%Y-%m-%d')

def find_flight(destination, date=today):
    print(date)

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


    inputDestination = driver.find_element(By.XPATH, search_bar)
    if inputDestination:
        print("found input path")
        inputDestination.send_keys(destination)

    else:
        return "Try asking again..."

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

    #Tried to implement dynamic date but randomness issue with openai
    # travel_date = datetime.strptime(date, '%Y-%m-%d')
    # def is_date_present():
    #     try:
    #         driver.find_element(By.XPATH, f"//div[@data-iso='{date}']")
    #         return True
    #     except:
    #         return False
        
    
    # timeout = 15
    # end_time = time.time() + timeout
    # while time.time() < end_time:
    #     if is_date_present():
    #         click_date = f"//div[@data-iso='{travel_date}']"
    #         xpath_click(click_date)
    #         return
    #     else:
    #         print("attempting to click next")
    #         click_next = "//div[@class='d53ede rQItBb FfP4Bc Gm3csc']"
    #         xpath_click(click_next)
    #         time.sleep(4)
    #end of randomness issue




    # time.sleep(1)
    # try:
    # driver.find_element(By.XPATH, f"//div[@data-iso='{travel_date}']")

    # except:
    #     while not driver.find_element(By.XPATH, f"//div[@data-iso='{travel_date}']"):
    #         click_next = "//button[@class='VfPpkd-LgbsSe VfPpkd-LgbsSe-OWXEXe-MV7yeb VfPpkd-LgbsSe-OWXEXe-Bz112c-M1Soyc VfPpkd-LgbsSe-OWXEXe-dgl2Hf b9hyVd MQas1c LQeN7 qhgRYc CoZ57 CtwNgb HhfOU a2rVxf']"
    #         xpath_click(click_next)

    click_date = f"//div[@data-iso='{date}']"
    xpath_click(click_date)

    click_done = "//button[@class='VfPpkd-LgbsSe VfPpkd-LgbsSe-OWXEXe-k8QpJ VfPpkd-LgbsSe-OWXEXe-dgl2Hf nCP5yc AjY5Oe DuMIQc LQeN7 z18xM rtW97 Q74FEc dAwNDc']"
    xpath_click(click_done)

    click_search = "//button[@class='VfPpkd-LgbsSe VfPpkd-LgbsSe-OWXEXe-k8QpJ VfPpkd-LgbsSe-OWXEXe-Bz112c-M1Soyc nCP5yc AjY5Oe LQeN7 TUT4y zlyfOd']"
    xpath_click(click_search)
    return f"Here are flights to {destination}!"


