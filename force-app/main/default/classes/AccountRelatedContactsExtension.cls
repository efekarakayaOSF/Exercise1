/**
 * File:        AccountRelatedContactsExtension.cls
 * Project:     Practical Exercise 1
 * Date:        September 6, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  An extension class to support functionality of AccountRelatedContacts page.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 6, 2021	Efe Kaan Karakaya		 Mistakes were fixed. Some functional improvements were done.
 * September 10, 2021   Efe Kaan Karakaya        Change temp primary name to temp primary id, queries surrounded by try-catch
 */

public class AccountRelatedContactsExtension {
    private final Account acct;
    public String searchTerm{
        get{
            if(searchTerm == null){
                searchTerm = '';
            }
            return searchTerm;
        }
        set;
    }   // Pre-defined but also can change dynamically in visualforce page.
    public Id tempPrimaryContactId {get; set;} // The value which is taken from visualforce page, indicate next primary contact.
    public Integer offset {get; private set;}
    public Integer maxLimit {get; private set;} // Max display records in a page.
    public Integer recordCount {get; private set;}
    public Boolean hasResult {get; private set;} // Determine that table has records to display or not.
    public Boolean hasPrevious {
        get {
            return (offset > 0);
        }
        private set;
    }
    public Boolean hasNext {
        get {
            Integer expr = recordCount - (maxLimit + offset);
            return (expr > 0);
        }
        private set;
    }
    public Integer pageNumber {
        get {
            return ((offset + 1) / maxLimit) + 1;
        }
    }
    public Integer totalPageNumber {
        get {
            return (recordCount / maxLimit) + 1;
        }
    }
 
    
    public AccountRelatedContactsExtension(ApexPages.StandardController controller){
        this.acct = (Account)controller.getRecord();
        this.maxLimit = 25;
        calculateTotalRecordCount(); // Perform initial page reload.
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name receiveNewSearchTerm
     * @description method to call calculateTotalRecordCount, actually there was no need to create this function.
     *     It will be called from search button in visualforce page. In this case, this function name makes more sense and seems more logical.
     */
    public void receiveNewSearchTerm() {
        calculateTotalRecordCount();
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name calculateTotalRecordCount
     * @description method to calculate total record size of a query, set offset to 0 for new display
     *     results, determine if there exists any result to display.
     */
    private void calculateTotalRecordCount() {
        String tmpSearchTerm = '%' + searchTerm + '%';
        try {
            this.recordCount = [SELECT Count() FROM Contact WHERE AccountId = :acct.Id AND Name LIKE :tmpSearchTerm];
            if(recordCount > 0) {
        	    hasResult = true;
                this.offset = 0;
            } else {
                hasResult = false;
            }   
        } catch(QueryException q) {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Error! Count query is failed.'));
        }  
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name getDisplayResult
     * @description method to get list of corresponding display list. Each page can have maximum 25 records(maxLimit). By using
     *     offset, list is divided into sub-lists depends on next/previous button actions.
     * @return A list of records to display in table (max. 25 records)
     */
    public List<Contact> getDisplayResult() {
        String tmpSearchTerm = '%' + searchTerm + '%';

        try {
            List<Contact> result = [SELECT Name, Title, MobilePhone, Is_Primary_Contact__c FROM Contact WHERE AccountId = :acct.Id
            AND Name LIKE :tmpSearchTerm LIMIT :maxLimit OFFSET :offset];

            return result;
        } catch(QueryException q) {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Error! Result query is failed.'));
            return new List<Contact>();
        }
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name next
     * @description method to increase offset by maxLimit(25) to show new results.
     */
    public void next() {
        offset += maxLimit;
    }
   
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name previous
     * @description method to decrease offset by maxLimit(25) to show previous results.
     */
    public void previous() {
        offset -= maxLimit;
    }  
 
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 6, 2021
     * @name changePrimary
     * @description method to set or change a primary contact. Each account can have only one primary contact at the same time.
     */
    public void changePrimary() {
        try {
            // This list contains previous primary (if exists) and next(not yet) contacts.
		    List<Contact> tempContacts = [SELECT Is_Primary_Contact__c FROM Contact Where AccountId = :acct.Id
                                        AND (Is_Primary_Contact__c = true OR Id = :tempPrimaryContactId)];
            if(tempContacts.size() < 1 || tempContacts.size() > 2) {
                throw new QueryException();
            }
			
            // Assign previous primary to normal contact, temp primary to new primary contact.
            for(Contact c : tempContacts) {
                c.Is_Primary_Contact__c = c.Is_Primary_Contact__c == true ? false : true;
            }
            
			update tempContacts;
        } catch (QueryException q) {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Error! Query is failed.'));
        } catch(DmlException d) {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Error! Contacts cannot be updated.'));
        }      	
    }
}