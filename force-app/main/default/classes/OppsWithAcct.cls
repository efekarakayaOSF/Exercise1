/**
 * File:        OppsWithAcct.apcx
 * Project:     Exercise 3
 * Date:        September 8, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  This class is used to create pre-defined daily, weekly, monthly schedules.
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 */
public class OppsWithAcct {
 	
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name setReminder
     * @description method to create custom schedule.
     * @params schedule name to prevent duplicate, cron expression to set time.
     */
    public static void setReminder(String scheduleName, String cronExp) {
        OppsWithAcctSchedule sc = new OppsWithAcctSchedule();
        System.schedule(scheduleName, cronExp, sc);
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name setReminders
     * @description method to create pre-defined 3 schedule.
     */
    public static void setReminders() {
        OppsWithAcctSchedule sc = new OppsWithAcctSchedule();

        String dailyExp = '0 0 10 ? * * *';
        String weeklyExp = '0 0 13 ? * FRI *';
        String monthlyExp = '0 0 18 ? * 6L *';
        
        System.schedule('Daily reminder primary contacts', dailyExp, sc);
        System.schedule('Weekly reminder primary contacts', weeklyExp, sc);
        System.schedule('Monthly reminder primary contacts', monthlyExp, sc);	
    }
    
    
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name setReminders
     * @description method to create a schedule which will executed immediately(5 secs later).
     */
    public static void setReminderNow() {
        OppsWithAcctSchedule sc = new OppsWithAcctSchedule();
        String hour = String.valueOf(Datetime.now().hour());
		String min = String.valueOf(Datetime.now().minute()); 
		String ss = String.valueOf(Datetime.now().second() + 5);
        
		String cronExp = ss + ' ' + min + ' ' + hour + ' * * ?';
        System.schedule('Job Started At ' + String.valueOf(Datetime.now()), cronExp, sc);
    }
}