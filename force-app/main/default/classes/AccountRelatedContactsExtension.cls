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
    public String tempPrimaryContactName {get; set;} // The value which is taken from visualforce page, indicate next primary contact.
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
        this.recordCount = [SELECT Count() FROM Contact WHERE AccountId = :acct.Id AND Name LIKE :tmpSearchTerm];
        
        if(recordCount > 0) {
        	hasResult = true;
        } else {
            hasResult = false;
        }
        this.offset = 0;
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
		List<Contact> result = [SELECT Name, Title, MobilePhone, Is_Primary_Contact__c FROM Contact WHERE AccountId = :acct.Id
            AND Name LIKE :tmpSearchTerm LIMIT :maxLimit OFFSET :offset];
        
        return result;
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
        // This list contains previous and next(not yet) primary contacts if they exist, ofc.
		List<Contact> tempContacts = [SELECT Name, Is_Primary_Contact__c FROM Contact
                                     	Where AccountId = :acct.Id AND (Is_Primary_Contact__c = true OR Name = :tempPrimaryContactName)];
		
        // That is unexpectable result. List can have maximum 2 records (previous and next).
        if(tempContacts.size() > 2) {
            ApexPages.addMessage(
            	new ApexPages.message(
                	ApexPages.severity.ERROR, 'Unexpected error! More than one primary contact or multi-records with same name'));
        } else {
            List<Contact> contactsToUpdate = new List<Contact>();
            // If there is no primary contact, previousPrimaryContact may be null.
            Contact previousPrimaryContact, nextPrimaryContact; 
            
            // Determine which one is previous and which one is next.
            for(Contact c : tempContacts) {
                if(c.Is_Primary_Contact__c) {
                    previousPrimaryContact = c;
                } else {
                    nextPrimaryContact = c;
                }
            }
            
            // There might be no primary contact yet, it's okay. If exists, set it as false.
            if(previousPrimaryContact != null) {
                previousPrimaryContact.Is_Primary_Contact__c = false;
                update previousPrimaryContact;
            }
            
            nextPrimaryContact.Is_Primary_Contact__c = true; // Set it as primary contact
            update nextPrimaryContact;
        }
    }
}