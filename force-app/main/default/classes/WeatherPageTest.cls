/**
 * File:        WeatherPageTest.apxc
 * Project:     Practical Exercise 4
 * Date:        September 10, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  A class to test WeatherPage page and its extension class functionalities.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 10, 2021   Efe Kaan Karakaya        Test result -> 74%
 */
@isTest
public class WeatherPageTest {
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 10, 2021
     * @name testGetCallout
     * @description method to test api with using mock, and check if it is works.
     */
    @isTest
    public static void testGetCallout() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('LondonWeatherData');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json');
        
        Test.setMock(HttpCalloutMock.class, mock);
		
        // Page link 
        PageReference pageRef = Page.WeatherPage;
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(new Account(Name = 'Test1234', BillingCity  = 'London'));
        WeatherPageExtension extension = new WeatherPageExtension(sc);
        HttpResponse result = extension.callApi();
        
        System.assertNotEquals(null,result, 'The callout returned a null response.');
        System.assertEquals(200,result.getStatusCode(), 'The status code is not 200.');
        System.assertEquals('application/json', result.getHeader('Content-Type'), 'The content type value is not expected.');  
        System.assertEquals('London', extension.cityName, 'Inserted and updated accounts are not same.');
        System.assertEquals('overcast clouds', extension.description, 'Retrieved description is wrong.');
        System.assertEquals(292.34, extension.temperature, 'Retrieved temperature is wrong.');
    }
}