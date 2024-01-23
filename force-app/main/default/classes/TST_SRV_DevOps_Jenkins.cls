@isTest
public class TST_SRV_DevOps_Jenkins {

    public class JenkinsMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
            res.setStatusCode(200);            
            return res;            
        }
    }
    private static DevOps_Request_Settings__c createTestSettings(String organization) {
        DevOps_Request_Settings__c settings = new DevOps_Request_Settings__c();
        settings.Name = organization;
        settings.Jenkins_Username__c = 'testUsername';
        settings.Jenkins_API_Key__c = 'testApiKey';
        settings.Jenkins_Endpoint__c = 'https://jenkins.example.com';
        settings.Jenkins_BuildName__c = 'testBuild';
        insert settings;
        return settings;
    }

    @isTest
    static void testAuthenticateJenkins() {
        Test.startTest();
        SRV_DevOps_Jenkins instance1 = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        SRV_DevOps_Jenkins instance2 = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        Test.stopTest();
        System.assertEquals(instance1, instance2);
    }

    @isTest
    static void testCreateJenkinsUser() {
        DevOps_Request_Settings__c testSettings = createTestSettings('TestOrg');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Jenkins.JenkinsMockResponse()); 
        SRV_DevOps_Jenkins jenkins = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        HttpResponse response = jenkins.createJenkinsUser('testUser', 'testPassword', 'test@example.com', 'Test User', 'ProjectRole', 'GlobalRole');
        Test.stopTest();
        System.assertNotEquals(null, response);
        System.assertEquals(200, response.getStatusCode());
    }

    @isTest
    static void testGetQueueProgress() {
        DevOps_Request_Settings__c testSettings = createTestSettings('TestOrg');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Jenkins.JenkinsMockResponse()); 
        SRV_DevOps_Jenkins jenkins = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        HttpResponse response = jenkins.getQueueProgress('queueName');
        Test.stopTest();
        System.assertNotEquals(null, response);
        System.assertEquals(200, response.getStatusCode());
    }
    @isTest
    static void testGetBuildProgress() {
        DevOps_Request_Settings__c testSettings = createTestSettings('TestOrg');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Jenkins.JenkinsMockResponse()); 
        SRV_DevOps_Jenkins jenkins = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        HttpResponse response = jenkins.getBuildProgress('https://jenkins.exmample.com');
        Test.stopTest();
        System.assertNotEquals(null, response);
        System.assertEquals(200, response.getStatusCode());
    }    
    @isTest
    static void testGetBuildRecords() {
        DevOps_Request_Settings__c testSettings = createTestSettings('TestOrg');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Jenkins.JenkinsMockResponse()); 
        SRV_DevOps_Jenkins jenkins = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        HttpResponse response = jenkins.getBuildRecords();
        Test.stopTest();
        System.assertNotEquals(null, response);
        System.assertEquals(200, response.getStatusCode());
    }
    @isTest
    static void testRemoveUser() {
        DevOps_Request_Settings__c testSettings = createTestSettings('TestOrg');
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Jenkins.JenkinsMockResponse()); 
        SRV_DevOps_Jenkins jenkins = SRV_DevOps_Jenkins.authenticateJenkins('TestOrg');
        HttpResponse response = jenkins.removeUser('testUser');
        Test.stopTest();
        System.assertNotEquals(null, response);
        System.assertEquals(200, response.getStatusCode());
    }
    
}