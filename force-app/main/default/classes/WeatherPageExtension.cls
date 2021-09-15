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
 * 10 September, 2021   Efe Kaan Karakaya		 A return value was added to callApi function. Test controls were added.
 * 15 September, 2021   Efe Kaan Karakaya        API credentials were moved to the API_Credential__mdt custom metadata. Added try-catch block in constructor.
 */
public class WeatherPageExtension {
	private final Account account;
    private API_Credential__mdt OWM; // OWM -> Open Weather Map
    public boolean hasData {
        get { 
            if(hasData == null) {
                return false;
            }
            return hasData;
        }
        set;}
    public String cityName {get; set;}
    public Double temperature {get; private set;}
    public String description {get; private set;}
    public String icon {
        get {
            return OWM.BASE_URL__c + '/img/wn/' + icon + '@2x.png';
        } 
        private set;}
    
    public WeatherPageExtension(ApexPages.StandardController controller) {
        
        try { 
            OWM = [SELECT ACCESS_TOKEN__c, BASE_URL__c, ENDPOINT__c FROM API_Credential__mdt WHERE Label = 'OWM Credentials'];
        } catch(QueryException q) {
            hasData = false;
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Retrieving metadata was failed.'));
            return;
        }
        
        account = (Account) controller.getRecord();
        if(Test.isRunningTest()) {
            cityName = 'London';
        } else {
            cityName = account.BillingCity;
            callApi();
        }      
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 9, 2021
     * @name callApi
     * @description method to make an api call according to the city name.
     * @returns response of the request
     */
    public HttpResponse callApi() {
        Http http = new Http();
		HttpRequest request = new HttpRequest();
        String endpoint = OWM.ENDPOINT__c + 'q=' + cityName + '&appid=' + OWM.ACCESS_TOKEN__c;
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        
        if(response.getStatusCode() == 200) {
            hasData = true;
            deserializeResponse(response.getBody());
            return response;
        } else {
            hasData = false;
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'No data.'));
            return null;
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