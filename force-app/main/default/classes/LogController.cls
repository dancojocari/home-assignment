public with sharing class LogController {

    public static void log(String source, Exception e) {
        insert new Debug_Log__c(
            Source__c = source,
            Line_Number__c = e.getLineNumber(),
            Stack_Trace__c = e.getStackTraceString(),
            Message__c = e.getMessage()
        );
    }

    public static void log(String source, String message) {
        insert new Debug_Log__c(
            Source__c = source,
            Message__c = message
        );
    }
}