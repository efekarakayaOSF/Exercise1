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
 * September 10, 2021   Efe Kaan Karakaya        Queries surrounded by try-catch blocks. Currency is retrieved from user currency.
 */
global class OppsWithAcctBatch implements Database.Batchable<sObject>, Database.Stateful {
 	
    private List<Record> records; // List of records, record contains output values.
    
    public OppsWithAcctBatch() {
        records = new List<Record>();
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name start
     * @description required method to prepare scope of the batch.
     * @params BatchableContext which is retrieved from database
     * @return Scope of the batch
     */
    global Database.QueryLocator start(Database.BatchableContext bc) {   
        Database.QueryLocator query = Database.getQueryLocator(
            'SELECT AccountId, Email, Account.Name FROM Contact WHERE Is_Primary_Contact__c = true');
     
        return query; 
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name execute
     * @description required method to process scope by batch size.
     * @params BatchableContext which is retrieved from database, Scope which is retrieved from start
     */
    global void execute(Database.BatchableContext bc, List<Contact> scope) {
        for(Contact cont : scope) {
            Record rec = new Record(cont.Account.Name, cont.Email); // A record object is initialized.
            try {
            	// By using AggreageteResult, get values from grouped stage names.
            	for(AggregateResult res : [SELECT StageName, SUM(Amount) Total FROM Opportunity 
                                            WHERE AccountId = :cont.AccountId GROUP BY StageName]) {

                	String stage = (String)res.get('StageName');
                	Double total = (Double)res.get('Total');
                
                	if(stage == 'Closed Won') {
                    	rec.closedWonTotal = total;
                	} else if(stage == 'Closed Lost') {
                    	rec.closedLostTotal = total;
                	} else {
                    	rec.openTotal += total;
                	}
            	}
            	records.add(rec); // Record object is added to records list.
            } catch (QueryException q) {
                
                System.debug('::: Error! Query is failed.');
                /*
                 * Notify sysadmin about the problem with contains related information, maybe?
                	User u = [SELECT Email FROM User WHERE Profile.Name = 'System Administrator'];    
                	EmailUtils.sendingEmailToPrimaryContact(u.Email, 'Error:OppsWithAcctBatch', 'resList query is failed.');
				*/
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
        
        String c = UserInfo.getDefaultCurrency();
        // Send email for each record.
        for(Record r : records) {
            String acctName = r.accountName;
            // Just using currency shortening(eg. EUR), but no conversion is made. 
            String closedWon = r.closedWonTotal + ' ' + c;
            String closedLost = r.closedLostTotal + ' ' + c;
            String open = r.openTotal + ' ' + c;
            
            String emailSubject = 'Periodical Opportunities Notification About ' + acctName;
            String emailSendTo = r.primaryContactEmail;
            String emailContext = 
                '<h3>Below is a table of opportunities related to the account: ' +  + '.<h3><br><table>' +
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
        
    	public Record(String acctName, String email) {
        	primaryContactEmail = email;
            accountName = acctName;
            closedWonTotal = 0;
            closedLostTotal = 0;
            openTotal = 0;         
    	}
	}
}