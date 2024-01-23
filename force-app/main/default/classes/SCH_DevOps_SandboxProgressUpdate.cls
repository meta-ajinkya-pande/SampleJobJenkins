global with sharing class SCH_DevOps_SandboxProgressUpdate implements Schedulable {
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new BCH_DevOps_RequestProgress(), 15);
    }
}