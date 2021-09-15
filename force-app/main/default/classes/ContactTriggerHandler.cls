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
 * September 13, 2021   Efe Kaan Karakaya        After insert and update were merged. Entire single process logic was changed to bulk operation.
 */
public with sharing class ContactTriggerHandler { 
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onBeforeInsert
     * @description method to determine if the contacts will be inserted contain primary or not.
     * @param insterted contacts
     */
    public void onBeforeInsert(List<Contact> newContacts) {
        Contact primaryContact = getPrimaryContact(newContacts[0].AccountId);
        
        for(Contact c : newContacts) {
            if(c.Is_Primary_Contact__c == true && primaryContact != null) {
                c.Is_Primary_Contact__c.addError('Error! You can only have one primary contact at the moment.');
            }
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onBeforeUpdate
     * @description method to determine if the contacts will be updated contain primary or not.
     * @param contact
     */
    public void onBeforeUpdate(List<Contact> contacts, Map<Id, Contact> contactsMap) {
        Contact primaryContact = getPrimaryContact(contacts[0].AccountId);
        Contact prevPrimaryContact = contactsMap.get(primaryContact.Id);
        Boolean primaryChange = false;
        
        if(prevPrimaryContact != null && prevPrimaryContact.Is_Primary_Contact__c == false) {
            primaryChange = true;
        } 

        Boolean hasNewPrimary = false;

        for(Contact c : contacts) {
            if(c.Is_Primary_Contact__c == true) {
                // If there is no primary contact, one reserved slot is available.
                if(primaryContact == null ) {
                    // User try to update more than one contact as primary.
                    if(hasNewPrimary) {
                		c.Is_Primary_Contact__c.addError('Error! You can only have one primary contact at the moment.');
            		}	
                	hasNewPrimary = true;
                } else {
                    // Current contact is marked as primary, and it's not current primary contact, and there will be no primary change operation.
                    // This situation will cause error.
                    if(c.Id != primaryContact.Id && !primaryChange) {
                        c.Is_Primary_Contact__c.addError('Error! You can only have one primary contact at the moment.');
                    }
                }
            }
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 7, 2021
     * @name onAfterInsertOrUpdate
     * @description method to determine if any of the inserted or updated contact is primary contact.
     * @param inserted or updated contacts
     */
    public void onAfterInsertOrUpdate(List<Contact> contacts, Map<Id, Contact> contactsMap) {
        Contact primaryContact = getPrimaryContact(contacts[0].AccountId);
        
        if(contactsMap.get(primaryContact.Id) != null && !System.isFuture()) {
            System.debug('WORKED');
            updateRecordsAsync(primaryContact.AccountId, primaryContact.Id);
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
		
        try {
            // Update them one by one.
        	for(Contact c : [SELECT Name, MobilePhone, Primary_Contact_Phone__c FROM Contact WHERE AccountId = :accountId]){
            	c.Primary_Contact_Phone__c = pContact.Primary_Contact_Phone__c;
            	contactsToUpdate.add(c);
        	}
            
            // What about failed processes?
            // Perform bulk update operation.
        	Database.update(contactsToUpdate, false); // No rollback
        } catch (DmlException d) {
            System.debug('Error! Database update operation was failed.');
        } catch (QueryException q) {
            System.debug('Error! Contact retrieve query was failed.');
        }
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
        try {
            List<Contact> contacts = [SELECT AccountId, Name, Is_Primary_Contact__c, Phone, MobilePhone, Primary_Contact_Phone__c FROM Contact
                    WHERE AccountId = :acctId AND Is_Primary_Contact__c = true LIMIT 1];
            
            if(contacts.size() == 0) {
            	return null;
        	} else {
            	return contacts[0];
        	}
        } catch (QueryException q) {
            System.debug('Error! getPrimaryContact query was failed.');
            return null;
        }  
    }
}