@isTest
public class TST_SCH_DevOps_SandboxProgressUpdate {

    @isTest
    static void testSchedulable() {
        String jobId;
        Test.startTest();
        String cron = '0 5 * * * ? '+ (Date.Today().year() + 1);
        SCH_DevOps_SandboxProgressUpdate schedulable = new SCH_DevOps_SandboxProgressUpdate();
        jobId = System.schedule('Test_SCH_DevOps_SandboxProgressUpdate', cron, schedulable);
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}