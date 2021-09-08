/**
 * File:        OppsWithAcctBatch.apcx
 * Project:     Exercise 3
 * Date:        September 8, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  This class is used to do a job by using batch approach. 
 *     The class has an inner-class to hold information about process.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
global class OppsWithAcctBatch implements Database.Batchable<sObject>, Database.Stateful {
 	
    private Map<Id, Record> records; // Map of records, Id represents account id
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name start
     * @description required method to prepare scope of the batch.
     * @params BatchableContext which is retrieved from database
     * @return Scope of the batch
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {
        records = new Map<Id, Record>();
        // Get all primary contacts.
        List<Contact> primaryContacts = [SELECT AccountId, Email FROM Contact WHERE Is_Primary_Contact__c = true];
        
        // Use only accounts which have primary contact.
        for(Contact c : primaryContacts) {
            records.put(c.AccountId, new Record(c.Email));
        }
        
		Set<Id> accountIds = records.keySet();        
        Database.QueryLocator query = Database.getQueryLocator(
            'SELECT Name FROM Account WHERE Id IN :records.accountIds');
     
        return query; // Opportunities are not queried in here because of AggregateResult.
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name execute
     * @description required method to process scope by batch size.
     * @params BatchableContext which is retrieved from database, Scope which is retrieved from start
     */
    global void execute(Database.BatchableContext bc, List<Account> scope) {
        for(Account account : scope) {
            records.get(account.Id).accountName = account.Name;
            List<AggregateResult> resList = [SELECT StageName, SUM(Amount) Total 
                                           FROM Opportunity WHERE AccountId = :account.Id GROUP BY StageName];
            // By using AggreageteResult, get values from grouped stage names.
            for(AggregateResult res : resList) {
                String stage = (String)res.get('StageName');
                Double total = (Double)res.get('Total');
                
                if(stage == 'Closed Won') {
                    records.get(account.Id).closedWonTotal = total;
                } else if(stage == 'Closed Lost') {
                    records.get(account.Id).closedLostTotal = total;
                } else {
                    records.get(account.Id).openTotal += total;
                }
            }
        }
    }

    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name finish
     * @description required method to send email to primary contacts about process.
     * @params BatchableContext which is retrieved from database
     */
    global void finish(Database.BatchableContext bc) {
        for(Id acctId : records.keySet()) {
            Record r = records.get(acctId);
            String acctName = r.accountName;
            String email = r.primaryContactEmail;
            String closedWon = '€' + r.closedWonTotal;
            String closedLost = '€' + r.closedLostTotal;
            String open = '€' + r.openTotal;
            
            String emailSubject = 'Periodical Opportunities Notification About ' + acctName;
            String emailSendTo = records.get(acctId).primaryContactEmail;
            String emailContext = 
                '<h3>Below is a table of opportunities related to the account: ' + acctName + '.<h3><br><table>' +
                '<tr><th>Account</th><th>Stage</th><th>Amount</th></tr>' +
                '<tr><td>' + acctName + '</td><td>Open</td><td>' + open + '</td></tr>' +
                '<tr><td>' + acctName + '</td><td>Closed Won</td><td>' + closedWon + '</td></tr>' +
                '<tr><td>' + acctName + '</td><td>Closed Lost</td><td>' + closedLost + '</td></tr></table>';
            
            EmailUtils.sendingEmailToPrimaryContact(emailSendTo, emailSubject, emailContext);
        }
        
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name Record - Class
     * @description auxiliary class to hold process detail like a record to use them later.
     */
    class Record {
        String accountName {get; set;}
        String primaryContactEmail {get; set;}
        Double closedWonTotal {get; set;}
        Double closedLostTotal {get; set;}
        Double openTotal {get; set;}
        
    	public Record(String email) {
        	primaryContactEmail = email;
            closedWonTotal = 0;
            closedLostTotal = 0;
            openTotal = 0;
    	}
	}
}