/**
 * File:        OppsWithAcctScheduleTest.apcx
 * Project:     Exercise 3
 * Date:        September 8, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  Test class to test effectiveness of the schedule-batch classes.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 9, 2021    Efe Kaan Karakaya        Schedule 100%, Batch 100% 
 */
@isTest
public class OppsWithAcctScheduleTest {

    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name setup
     * @description method to setup initial objects, and also see if there would be any error in batch class while indexing.
     */
    @testSetup
    public static void setup() {
        // setup
        List<sObject> insertList = new List<sObject>();
        
        // Account 1 has primary contact, so only this account will get notification email.
        Account account1 = new Account(Name='TestAccount1');
        Account account2 = new Account(Name='TestAccount2');
        List<Account> accounts = new List<Account>{account1, account2};
        insert accounts;
        
        
        Contact contact1 = new Contact(AccountId = account1.Id, LastName = 'TestContact1', 
                                       Is_Primary_Contact__c = true, Email = 'efe.karakaya@osf.digital', MobilePhone = '111222333');
        Contact contact2 = new Contact(AccountId = account2.Id, LastName = 'TestContact2', 
                                       Email = 'test2@mail.com', MobilePhone = '111222333');
        List<Contact> contacts = new List<Contact>{contact1, contact2};
        insert contacts;
        
        List<Opportunity> opps = new List<Opportunity>();   
        Date closeDate = Date.today().addDays(3);
        opps.add(new Opportunity(AccountId = account1.Id, Name = 'Opportunity1', 
                                 StageName = 'Closed Won', Amount = 5000, CloseDate = closeDate));
        opps.add(new Opportunity(AccountId = account1.Id, Name = 'Opportunity2', 
                                 StageName = 'Closed Won', Amount = 10000, CloseDate = closeDate));
        opps.add(new Opportunity(AccountId = account1.Id, Name = 'Opportunity3', 
                                 StageName = 'Open', Amount = 12345, CloseDate = closeDate));
        opps.add(new Opportunity(AccountId = account1.Id, Name = 'Opportunity4', 
                                 StageName = 'Closed Lost', Amount = 54321, CloseDate = closeDate));        
        opps.add(new Opportunity(AccountId = account2.Id, Name = 'Opportunity5', 
                                 StageName = 'Closed Won', Amount = 123123, CloseDate = closeDate));  
        insert opps;
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name testSchedule
     * @description method to test schedule functionality. Test if schedule is created or not.
     * @reference https://salesforce.stackexchange.com/a/149718
     */
    @isTest
    public static void testSchedule() {
        List<AsyncApexJob> jobsBefore = [select Id, ApexClassID, ApexClass.Name, Status, JobType from AsyncApexJob];
    	System.assertEquals(0, jobsBefore.size(), 'not expecting any asyncjobs');
        
        Test.startTest();   
        // Schedule test job
        String jobId = System.schedule('OppsWithAcct Schedule Test', '0 0 0 15 3 ? 2072', new OppsWithAcctSchedule());
        Test.stopTest();
        
       	// Check schedulable is in the job list
    	List<AsyncApexJob> jobsScheduled = [select Id, ApexClass.Name from AsyncApexJob where JobType = 'ScheduledApex'];
    	System.assertEquals(1, jobsScheduled.size(), 'expecting one scheduled job');
    	System.assertEquals('OppsWithAcctSchedule', jobsScheduled[0].ApexClass.Name, 'expecting specific scheduled job');

    	// check apex batch is in the job list
    	List<AsyncApexJob> jobsApexBatch = [select Id, ApexClass.Name from AsyncApexJob where JobType = 'BatchApex'];
    	System.assertEquals(1, jobsApexBatch.size(), 'expecting one apex batch job');
    	System.assertEquals('OppsWithAcctBatch', jobsApexBatch[0].ApexClass.Name, 'expecting specific batch job');
    }
}