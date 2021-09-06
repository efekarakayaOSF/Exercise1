/*
 * This class is used as extension of AccountRelatedContacts because of additional functionality.
 * This class can do;
 * + Hold variables in order to needs.
 * + Use that variables to query.
 * + Prepare query result to display in a proper way.
 */

public class AccountRelatedContactsExtension {
    private final Account acct;
    private Map<Integer, Contact> contactsMap;
    private List<List<Contact>> displayPages;
    public Boolean hasResult {get; private set;}
    public String searchTerm{
        get{
            if(searchTerm == null){
                searchTerm = 'contact1';
            }
            return searchTerm;
        }
        set;
    }  
    public String tempPrimaryContactName {get; set;}
    public Integer offset {get; private set;}
    public Integer currentPage {
        get {
            if(currentPage == null) {
                currentPage = 1;
            }
            return currentPage;
        }
        private set;}
    public Integer totalPageSize {get; private set;}
    public Boolean hasPrevious {
        get {
            return (currentPage > 1);
        }
        private set;
    }
    public Boolean hasNext {
        get {
            return (currentPage < totalPageSize);
        }
        private set;
    }
 
    public AccountRelatedContactsExtension(ApexPages.StandardController controller){
        this.acct = (Account)controller.getRecord();
        this.offset = 25;
        receiveNewSearchTerm();
    }
    
    public List<Contact> getContacts() {
        return displayPages.get(currentPage-1);
    }
    
    // Whenever user enter a new search term and hit the search button, this function will be called.
    // This function gets contacts according to search term and fill them into contactsMap.
    public void receiveNewSearchTerm() {
        contactsMap = new Map<Integer, Contact>();
        String newSearchTerm = '%'+ this.searchTerm + '%';
        
        Integer i = 0;
        for(Contact c : [SELECT Name, Title, MobilePhone, Is_Primary_Contact__c FROM Contact WHERE AccountId = :this.acct.Id
            AND Name LIKE :newSearchTerm ORDER BY NAME ASC]) {
                this.contactsMap.put(i, c);
                i++;
            } 
        
        if(contactsMap.size() > 0) {
            hasResult = true;
        } else {
            hasResult = false;
        }
        
        configurePages();
    }
    
    public void configurePages() {
        /* This function organizes result, split it into proper pieces.
         * Offset is defined as 25 by default
         * contactsMap must be filled before this function
         * determine how many pages will be displayed according to contactsMap size depends on offset.
         * displayPages = A list to hold all pages
         * page = single page contains contacts amount of offset (may not be equal to offset, ex. having only 1 record to display)
         */ 
        displayPages = new List<List<Contact>>();
        this.currentPage = 1; // This variable is set to 1 but we have to decrease it by one in order to use it. (zero base index, displayPages[0]..)
        
        /* This section goes 0 to contactsMap size. It takes contacts one by one and add them into a page list.
         * To do that, It goes 25 records(offset) per time which means a page.
         */ 
        Integer i = 0;
        while(i < contactsMap.size()) {
            List<Contact> page = new List<Contact>();
            for(Integer j = 0; j < offset; j++) {
                // If there are less than offset amount of contacts.
                if(i == contactsMap.size()) {
                    break;
                }
                page.add(contactsMap.get(i)); // Get one by one from map.
                i++;
            }
            displayPages.add(page);
        }
        totalPageSize = displayPages.size();
    }
    
    public void next() {
        this.currentPage += 1;
    }
    
    public void previous() {
        this.currentPage -= 1;
    }  
 
    public void changePrimary() {
        /* Change Primary function trigger when commandLink of a contant ('set as primary) from visualforce page.
         * This function takes previous primary contact and next primary contact objects from database.
         * Edit and update them.
    	*/
        
        Contact previousPrimaryContact = [SELECT Name, Is_Primary_Contact__C FROM Contact 
                                            WHERE AccountId = :this.acct.Id AND Is_Primary_Contact__c = true LIMIT 1][0];
        previousPrimaryContact.Is_Primary_Contact__c = false; // Set Is_Primary_Contact__c field as false
        Contact nextPrimaryContact = [SELECT Name, Is_Primary_Contact__c FROM Contact 
                                     WHERE AccountId = :this.acct.Id AND Name = :tempPrimaryContactName LIMIT 1][0];
        
        if(nextPrimaryContact == null) {
            ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.WARNING, 'Unexpected error! Selected contact cannot be found in records.'));
        } else {
            nextPrimaryContact.Is_Primary_Contact__c = true; // Set it as primary contact
            List<Contact> contactsToUpdate = new List<Contact>(); // There are only 2 record to handle, but anyways.. Forza bulk
            contactsToUpdate.add(previousPrimaryContact);
            contactsToUpdate.add(nextPrimaryContact);
            
            try {
                update contactsToUpdate;
            } catch(DmlException e) {
                ApexPages.addMessage(
                new ApexPages.message(
                    ApexPages.severity.WARNING, 'Unexpected error! The contacts cannot be updated for some reason X_X'));
            }
        }
    }
}