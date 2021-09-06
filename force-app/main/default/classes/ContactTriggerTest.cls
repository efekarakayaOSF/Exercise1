/**
 * File:        ContactTriggerTest.apxc
 * Project:     Practical Exercise 2
 * Date:        September 7, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  Basic unit test class of ContactTrigger. (Late)
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 7, 2021	Efe Kaan Karakaya		 ContactTrigger(100% coverage), ContactTriggerHandler(94% coverage).
 */
@isTest
public class ContactTriggerTest {
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name setup
     * @description method to setup requirements for all functions.
     */
    @testSetup static void setup() {
        Account acct = new Account(Name='TestAccount');
        insert acct;
        
        List<Contact> testContacts = new List<Contact>();
        
        for(Integer i=0; i < 10; i++) {
            testContacts.add(new Contact(LastName='test'+i, MobilePhone='222555'+i, AccountId = acct.Id));
        }
        insert testContacts;
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name createContact
     * @description method to create a basic contact variable. Used for creating primary contact.
     * @return contact object
     */
     private static Contact createContact() {
        return new Contact(LastName='Maximilian', MobilePhone='552-285-35-98', Is_Primary_Contact__c = false);
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name insertNonPrimaryContact
     * @description method to test basic insert operation
     */
    @isTest static void insertNonPrimaryContact() {
        Contact c = createContact();
        
        Test.startTest();
        Database.SaveResult result = Database.insert(c);
        Test.stopTest();
        
        System.assert(!result.isSuccess()); // Has to be successful
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name insertPrimaryContactWhenNonExists
     * @description method to test that insert a contact while there is no primary contact
     */
    @isTest static void insertPrimaryContactWhenNonExists() {
        Contact c = createContact();
        c.Is_Primary_Contact__c = true;
        
        Test.startTest();
        Database.SaveResult result = Database.insert(c);
        Test.stopTest();
        
        Contact anotherContact = [Select Name, Primary_Contact_Phone__c FROM Contact 
                                  WHERE AccountId IN (SELECT Id FROM Account WHERE Name='TestAccount') LIMIT 1][0];
        System.assert(!result.isSuccess()); // Has to be successful
        // Other contacts' primary contact phone must be equal to primary contact's mobile phone.
        System.assertNotEquals(c.MobilePhone, anotherContact.Primary_Contact_Phone__c); 
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name insertPrimaryContactWhenExists
     * @description method to test that insert a primary contact while there exists already one.
     */
    @isTest static void insertPrimaryContactWhenExists() {
        Contact anotherContact = [Select Name, Primary_Contact_Phone__c FROM Contact 
                                  WHERE AccountId IN (SELECT Id FROM Account WHERE Name='TestAccount') LIMIT 1][0];
        anotherContact.Is_Primary_Contact__c = true; // First primary
        
        Contact c = createContact();
        c.Is_Primary_Contact__c = true; // Second primary
        
        Test.startTest();
        update anotherContact;
        Database.SaveResult result = Database.insert(c);
        Test.stopTest();
        
        // User cannot insert another primary contact if there exists already one.
        System.assert(result.isSuccess()); // This has to be failed
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name updateNonPrimaryContact
     * @description method to test basic update operation
     */
    @isTest static void updateNonPrimaryContact() {
        Contact c = createContact();
        
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        
        System.assert(!result.isSuccess());
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name updatePrimaryContactWhenNonExists
     * @description method to test that update a contact while there is no primary contact
     */
    @isTest static void updatePrimaryContactWhenNonExists() {
        Contact c = createContact();
        c.Is_Primary_Contact__c = true;
        
        Test.startTest();
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        
        Contact anotherContact = [Select Name, Primary_Contact_Phone__c FROM Contact 
                                  WHERE AccountId IN (SELECT Id FROM Account WHERE Name='TestAccount') LIMIT 1][0];
        
        System.assert(!result.isSuccess());
        System.assertNotEquals(c.MobilePhone, anotherContact.Primary_Contact_Phone__c);
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name updatePrimaryContactWhenExists
     * @description method to test that update a contact while there is already one primary contact
     */
    @isTest static void updatePrimaryContactWhenExists() {
        Contact anotherContact = [Select Name, Primary_Contact_Phone__c FROM Contact 
                                  WHERE AccountId IN (SELECT Id FROM Account WHERE Name='TestAccount') LIMIT 1][0];
        anotherContact.Is_Primary_Contact__c = true;
        
        Contact c = createContact();
        c.Is_Primary_Contact__c = true;
        
        Test.startTest();
        update anotherContact;
        Database.SaveResult result = Database.update(c);
        Test.stopTest();
        
        System.assert(result.isSuccess());
    }   
}