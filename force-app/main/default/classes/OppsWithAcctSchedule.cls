/**
 * File:        OppsWithAcctSchedule.apcx
 * Project:     Exercise 3
 * Date:        September 8, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  Schedule class, to describe schedule and call batch class.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
global class OppsWithAcctSchedule implements Schedulable{
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name execute
     * @description required method to call and execute batch apex class.
     */
    global void execute(SchedulableContext sc) {
        // OppsWithAcctBatch b = new OppsWithAcctBatch();
        
		Database.executeBatch(new OppsWithAcctBatch() , 100);
    }
}