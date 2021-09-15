/**
 * File:        ContactTrigger.apxt
 * Project:     Practical Exercise 2
 * Date:        September 6, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  Default trigger to check primary contact collision and 
 *     change primary contact phone field of the contacts.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 13, 2021   Efe Kaan Karakaya        After Insert and After Update operations were merged. newMap added into onBeforeUpdate and AfterInsertOrUpdate.
 */
trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
	ContactTriggerHandler handler = new ContactTriggerHandler();

    // When Trigger.isBefore, checks if there any primary contact collision.
    // When Trigger.isAfter, update Primary Contact Phone field of the contacts.
    if(Trigger.isBefore) {
        if(Trigger.isInsert) {
            handler.onBeforeInsert(Trigger.New);
        } else {
            handler.onBeforeUpdate(Trigger.New, Trigger.newMap);
        }
    } else {
        handler.onAfterInsertOrUpdate(Trigger.New, Trigger.newMap);
    }
}