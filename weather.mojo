from python import Python

def get_api_key[key: String]()-> String: #Gets the local api key
    let cp = Python.import_module("configparser") 
    let config = cp.ConfigParser()
    config.read("config.ini")
    return config["api_keys"][key].__str__()

def get_user_response() -> String: #
    let py = Python.import_module("builtins")
    let user_inp = py.input("You: ")
    return user_inp.__str__().replace(" ", "+") #replaces spaces with + instead of space for multi word cities

def get_weather_url(city_input: String, imperial=False) -> String: #Builds the URL for the API call 
    let BASE_WEATHER_API_URL: String = "http://api.openweathermap.org/data/2.5/weather"
    let api_key = get_api_key["openweather"]()
    let units = "imperial" if imperial else "metric"
    let url: String = BASE_WEATHER_API_URL + "?q=" + city_input + "&units=" + units + "&appid=" + api_key

    return url


def get_weather_data(query_url: String, bools: PythonObject) -> PythonObject: #Performs API call with given url and returns a dictionary
    let json = Python.import_module("json")
    let sys = Python.import_module("sys")
    let Urllib = Python.import_module("urllib.request")
    let Errorlib = Python.import_module("urllib.error")
    
    try: #IF the API call errors
        let response = Urllib.urlopen(query_url)
        var data = response.read()
        data = json.loads(data)

        try:   
            let weather_temp_dict = Python.dict()
            let keys: PythonObject = ['conditions', 'temperature', 'humidity', 'wind_speed', 'temp_min', 'temp_max', 'pressure', 'clouds', 'sunrise', 'sunset', 'fahrenheit']
            

            weather_temp_dict['city'] = data['name']

            weather_temp_dict['conditions'] = data['weather'][0]['description']
            weather_temp_dict['temperature'] = data['main']['temp']
            weather_temp_dict['humidity'] = data['main']['humidity']
            weather_temp_dict['wind_speed'] = data['wind']['speed']
            weather_temp_dict['temp_min'] = data['main']['temp_min']
            weather_temp_dict['temp_max'] = data['main']['temp_max']
            weather_temp_dict['pressure'] = data['main']['pressure']
            weather_temp_dict['clouds'] = data['clouds']['all']
            weather_temp_dict['sunrise'] = data['sys']['sunrise']
            weather_temp_dict['sunset'] = data['sys']['sunset']
            weather_temp_dict['fahrenheit'] = True

            for i in range(keys.__len__().__index__()): #Removes any False's in the data_bools
                if(bools[keys[i]] == False):
                    weather_temp_dict.pop(keys[i])
                    
            return (weather_temp_dict.__str__()) #converts python dict to python string to mojo string
        except:
            sys.exit("Bot: Bad json file")
            return "0"
    except error:
        print("Bot: No weather data found for that city.")
        return "0"

def start_weather_chat():
    Python.add_to_path(".")
    let python_functs = Python.import_module("bot") #import local bot file
    let py = Python.import_module("builtins")


    let OPENAI_API_KEY: String = get_api_key['openai']() #openai apikey
    let system_content: String = "You are a poetic assistant, skilled in explaining complex programming concepts with creative flair."
    let user_content: String = "Compose a poem that explains the concept of recursion in programming."

    print("Weather Chatbot")
    while True:
        let user_input: String =  get_user_response()
        if user_input == "exit":
            print("Goodbye!")
            break
        let sys_info1 = 'Generate a dictionary of weather information for a given city. The dictionary should be in the format: {"city": "[City Name]", "country": "[Country Name]", "conditions": [Boolean], "temperature": [Boolean], "humidity": [Boolean], "wind_speed": [Boolean], "temp_min": [Boolean], "temp_max": [Boolean], "pressure": [Boolean], "clouds": [Boolean], "sunrise": [Boolean], "sunset": [Boolean], "fahrenheit": [Boolean]}. For boolean values, use True if that specific piece of information is asked for, or set them all to True if the user asks for general weather information. Use False if the information is not asked for. For the fahrenheit boolean, default it to True, but if the user asks for celsius then set it to False. Ensure that the dictionary is formatted as a string so that it can be converted to a Python dictionary using eval().' 
        let usr_info1 = "User: " + user_input + "\nBot:"
        let bot_response1: String= python_functs.run_bot(sys_info1, usr_info1, OPENAI_API_KEY).__str__() #first bot response

        if bot_response1.find('{', 0)!=-1:  #Checks if was given a valid weather related question
            let weather_dict_bools= python_functs.make_dict(bot_response1) #Converts string dict to real dict

            let weather_url: String = get_weather_url(weather_dict_bools.get("city").__str__(), weather_dict_bools['fahrenheit'].__bool__())  
            let weather_dict_data = python_functs.make_dict(get_weather_data(weather_url, weather_dict_bools))
            if(weather_dict_data.__str__() == "0"): #If weather data is not found for the specific city given
                continue
            
            let keys = weather_dict_bools.keys()

            let string_response_dict = weather_dict_data.__str__()
            let sys_info3 = "You are a helpful weather bot take the given Json dictionary and convert it to a string. The string should convey the provided information about the weather"
            let usr_info3 = "User: " + string_response_dict + "\nBot:"
            let bot_response3 = python_functs.run_bot(sys_info3, usr_info3, OPENAI_API_KEY).__str__()
            print("Bot: "+ bot_response3) 
        else:
            let gpt_prompt = "User: " + user_input + "\nBot:"
            #gpt_response = chat_with_gpt(gpt_prompt)
            let sys_info2 = "you are a helpful weather bot that can answer questions about the weather in any city. You will respond to non weather related questions with 'I am sorry my focus in on weather'"
            let gpt_response = python_functs.run_bot(sys_info2, gpt_prompt, OPENAI_API_KEY).__str__()
            print("Bot: " + gpt_response)


def main():
    start_weather_chat()
