import time

def check_source(driver):
    while True:
        prev_source = driver.page_source
        time.sleep(1)
        print("Loading...")
        if prev_source == driver.page_source:
            break
        else:
            prev_source = driver.page_source
