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
 */
trigger ContactTrigger on Contact (before insert, after insert, before update, after update) {
	ContactTriggerHandler handler = new ContactTriggerHandler();

    // When Trigger.isBefore, checks if there any primary contact collision.
    // When Trigger.isAfter, update Primary Contact Phone field of the contacts.
    if(Trigger.isInsert) {
        if(Trigger.isBefore) {
            handler.onBeforeInsert(trigger.New);
        } else {
            handler.onAfterInsert(trigger.New);
        }
    } else if(Trigger.isUpdate) {
        if(Trigger.isBefore) {
            handler.onBeforeUpdate(trigger.New);
        } else {
            handler.onAfterUpdate(trigger.New);
        }
    }
   
}