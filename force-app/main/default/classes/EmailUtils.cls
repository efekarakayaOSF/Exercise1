/**
 * File:        EmailUtils.apcx
 * Project:     Exercise 3
 * Date:        September 8, 2021
 * Created By:  Efe Kaan Karakaya
 * *************************************************************************
 * Description:  Auxiliary class to send email
 * *************************************************************************
 * History:
 * Date:                Modified By:             Description:
 * September 10, 2021   Efe Kaan Karakaya        sendEmail method is added.
 */
public class EmailUtils {
    /**
     * @author Efe Kaan Karakaya
     * @date  September 8, 2021
     * @name sendingEmailToPrimaryContact
     * @description method to send email by using SingleEmailMessage.
     * @params primary contact email, subject of the email, context of the email (In this exercise, html table)
     */
	public static void sendingEmailToPrimaryContact(String sendTo, String subject, String context) {
		Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setToAddresses(new String[]{sendTo});
		semail.setSubject(subject);
        semail.setHtmlBody(context);
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
	}
    

    /**
     * @author Efe Kaan Karakaya
     * @date  September 10, 2021
     * @name sendEmail
     * @description method to send email by using SingleEmailMessage.
     * @params contact email, subject of the email, context of the email
     */
    public static void sendEmail(String sendTo, String subject, String context) {
        Messaging.SingleEmailMessage semail = new Messaging.SingleEmailMessage();
        semail.setToAddresses(new String[]{sendTo});
		semail.setSubject(subject);
        semail.plainTextBody = context;
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {semail});
    }
}