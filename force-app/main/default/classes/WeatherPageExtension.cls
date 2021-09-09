/**
 * File:        WeatherPageExtension.apxc
 * Project:     Practical Exercise 4
 * Date:        September 9, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  An extension class to support functionality of Weather page.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
public class WeatherPageExtension {
    private final String API_KEY = 'c10d998217c5e97244af9ef94bd1bb6c';
	private final Account account;
    public String cityName {get; set;}
    public Double temperature {get; private set;}
    public String description {get; private set;}
    public String icon {
        get {
            return 'http://openweathermap.org/img/wn/' + icon + '@2x.png';
        } 
        private set;}
    
    public WeatherPageExtension(ApexPages.StandardController controller) {
        account = (Account) controller.getRecord();
        cityName = account.BillingCity;
        callApi();
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 9, 2021
     * @name callApi
     * @description method to make an api call according to the city name.
     */
    public void callApi() {
        Http http = new Http();
		HttpRequest request = new HttpRequest();
        String endpoint = 'https://api.openweathermap.org/data/2.5/weather?q=' + cityName + '&appid=' + API_KEY;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            deserializeResponse(response.getBody());
        } else {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'No data.'));
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 9, 2021
     * @name deserializeResponse
     * @description method to deserialize the response and gather desired fields.
     * @params JSON Response
     */
    private void deserializeResponse(String response) {
        // Only description and icon of the weather field, temperature of the main field were asked.
        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response); // Response -> Map
        List<Object> weatherField = (List<Object>) results.get('weather'); // Weather field returns as a list.
        Object mainField = results.get('main'); // Main field returns single object.
        
        // Object(fields) -> Map
        Map<String, Object> main = (Map<String, Object>) mainField;
		Map<String, Object> currentWeather = (Map<String, Object>) weatherField[0];

        temperature = (Double) main.get('temp');
        description = (String) currentWeather.get('description');
        icon = (String) currentWeather.get('icon');
    }
     
}