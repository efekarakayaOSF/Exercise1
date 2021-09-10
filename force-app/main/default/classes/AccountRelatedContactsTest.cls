/**
 * File:        AccountRelatedContactsTest.apxc
 * Project:     Practical Exercise 1
 * Date:        September 10, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  A class to test AccountRelatedContact page and its extension class functionalities.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 10, 2021   Efe Kaan Karakaya        Test result -> 74%
 */
@isTest
public class AccountRelatedContactsTest {
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 10, 2021
     * @name setup
     * @description method to create some dummy objects.
     */
    @testSetup
    public static void setup() {
        Account a = new Account(Name = 'Test1234');
        insert a;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = a.Id, LastName = 'TestContact0', MobilePhone = '123123', Is_Primary_Contact__c = true));
        for(Integer i = 1; i < 48; i++) {
            contacts.add(new Contact(AccountId = a.Id, LastName = 'TestContact'+i, MobilePhone = '123123'));
        }
        insert contacts;
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 10, 2021
     * @name displayTest
     * @description method to test display functionalities of extension.
     */
    @isTest
    public static void displayTest() {    
        // Page link and extension initialize
        Account a = [SELECT Id FROM Account WHERE Name = 'Test1234'];
        PageReference pageRef = Page.AccountRelatedContacts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        AccountRelatedContactsExtension extension = new AccountRelatedContactsExtension(sc);
        
        extension.searchTerm = 'TestContact';
        QueryException unexpectedQueryException;
        
        // This try catch block is used to catch QueryException in calculateTotalRecordCount.
        try {
            extension.receiveNewSearchTerm();
        } catch (QueryException q) {
            unexpectedQueryException = q;
        }
        System.assertEquals(null, unexpectedQueryException, 'Query is failed.');
        System.assertEquals(48, extension.recordCount, 'Missing contacts.');
        
        
        Integer displaySize = -1;
        // This try catch block is used to catch QueryException in getDisplayResult.
        try {
            displaySize = extension.getDisplayResult().size();
        } catch (QueryException q) {
            unexpectedQueryException = q;
        }
        System.assertEquals(null, unexpectedQueryException, 'Display result query is failed.');   
        System.assertEquals(25, displaySize, 'First page must have 25 contacts.');
        
        // Some other test conditions.
        System.assertEquals(true, extension.hasNext, 'Next page has to be exits.');
        System.assertEquals(false, extension.hasPrevious, 'There is no previous page at the first.');
       	System.assertEquals(true, extension.hasResult, 'There must be records to display.');
        System.assertEquals(2, extension.totalPageNumber, 'Total page number must be equals to 2.');
        System.assertEquals(1, extension.pageNumber, 'Current page number must be equals to 1.');
        
        extension.next();
        System.assertEquals(2, extension.pagenumber, 'Page number must be 2 after next() method.');
        
        extension.previous();
        System.assertEquals(1, extension.pageNumber, 'Page number must be 1 after previous() method.');
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 10, 2021
     * @name primaryChangeTest
     * @description method to test primary change operation of extension.
     */
    @isTest
    public static void primaryChangeTest() {
        // Page link and extension initialize
        Account a = [SELECT Id FROM Account WHERE Name = 'Test1234'];
        PageReference pageRef = Page.AccountRelatedContacts;
        Test.setCurrentPage(pageRef);
        ApexPages.StandardController sc = new ApexPages.StandardController(a);
        AccountRelatedContactsExtension extension = new AccountRelatedContactsExtension(sc);
        
        Contact next = new Contact(AccountId = a.Id, LastName = 'primContact' , MobilePhone = '123123');
        insert next;
        
        // This try catch block is used to catch DmlException(update) and QueryException(get contacts).
        DmlException unexpectedDmlException;
        QueryException unexpectedQueryException;
        try {
            extension.tempPrimaryContactId = next.Id;
        	extension.changePrimary();
        } catch (DmlException d) {
            unexpectedDmlException = d;
        } catch (QueryException q) {
            unexpectedQueryException = q;
        }
        System.assertEquals(null, unexpectedDmlException, 'DML is failed.');
        System.assertEquals(null, unexpectedQueryException, 'Query is failed.');
        
        Contact primary = [SELECT Is_Primary_Contact__c FROM Contact WHERE AccountId = :a.Id AND Is_Primary_Contact__c = true][0];

        System.assertEquals(next.Id, primary.Id, 'Primary change is failed.');
    }
    
}