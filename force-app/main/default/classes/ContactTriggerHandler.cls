/**
 * File:        ContactTriggerHandler.apxc
 * Project:     Practical Exercise 2
 * Date:        September 7, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  A handler class to operate trigger functions, check primary
 *     contact collision and update primary contact phone field of the contacts.
 * 
 * Note: Instead of Phone field, each contact has MobilePhone field. (Unfortunately, I've uploaded them like that :/)
 *     In this case, MobilePhone field is used to update Primary_Contact_Phone__c.
 * 	   I set a rule which won't allow user to create a contact without MobilePhone field.
 *     This field is not required but I have to use this restriction in order to use it. 
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
public with sharing class ContactTriggerHandler { 
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onBeforeInsert
     * @description method to determine if the contact will be inserted is primary or not.
     * @param contact
     */
    public void onBeforeInsert(List<Contact> newContact) {
        Contact c = newContact[0];
        Contact primaryContact = getPrimaryContact(c.AccountId);
        
        // Additional control statement.
        if(c.MobilePhone == null) {
            c.MobilePhone.addError('You have to specify a mobile phone value to create the contact.');
        }
        
        if(c.Is_Primary_Contact__c == true && primaryContact != null) {
            c.Is_Primary_Contact__c.addError('You cannot set this contact as primary. There is already one primary contact.');
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onAfterInsert
     * @description method to determine if inserted contact is primary or not.
     * @param inserted contact
     */
    public void onAfterInsert(List<Contact> newContact) {
        Contact c = newContact[0];
        
        if(c.Is_Primary_Contact__c == true) {
            updateRecordsAsync(c.AccountId, c.Id);
        } 
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onBeforeUpdate
     * @description method to determine if the contact will be updated is primary or not.
     * @param contact
     */
    public void onBeforeUpdate(List<Contact> newContact) {
        Contact c = newContact[0];
        Contact primaryContact = getPrimaryContact(c.AccountId);
        
        if(c.Is_Primary_Contact__c == true && primaryContact != null && c.Id != primaryContact.Id) {
            c.Is_Primary_Contact__c.addError('You cannot set this contact as primary. There is already one primary contact.');
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onAfterUpdate
     * @description method to determine if updated contact is primary or not.
     * @param updated contact
     */
    public void onAfterUpdate(List<Contact> newContact) {
        Contact c = newContact[0];
        
        if(c.Is_Primary_Contact__c == true && !System.isFuture()) {
            updateRecordsAsync(c.AccountId, c.Id);
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name updateRecordsAsync
     * @description async method to update primary contact phone field of the contacts
     * @param AccountId, ContactId
     */
    @future(callout=true)
    private static void updateRecordsAsync(Id accountId, Id contactId) {
        // pContact = primary contact
        Contact pContact = getPrimaryContact(accountId);
        
        // As mentioned in header, Primary_Contact_Phone__c is set by MobilePhone.
        pContact.Primary_Contact_Phone__c = pContact.MobilePhone;
        
        List<Contact> contactsToUpdate = new List<Contact>();
        
        // Update them one by one.
        for(Contact c : [SELECT Name, MobilePhone, Primary_Contact_Phone__c FROM Contact WHERE AccountId = :accountId]){
            c.Primary_Contact_Phone__c = pContact.Primary_Contact_Phone__c;
            contactsToUpdate.add(c);
        }

        // Perform bulk update operation.
        Database.update(contactsToUpdate, false);
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name getPrimaryContact
     * @description method to get primary contact
     * @param AccountId
     * @return Primary Contact
     */
    private static Contact getPrimaryContact(Id acctId) {
        List<Contact> contacts = [SELECT Name, Is_Primary_Contact__c, Phone, MobilePhone, Primary_Contact_Phone__c FROM Contact
                    WHERE AccountId = :acctId AND Is_Primary_Contact__c = true LIMIT 1];
        
        if(contacts.size() == 0) {
            return null;
        } else {
            return contacts[0];
        }
    }
}