@isTest
public with sharing class TST_SRV_DevOps_Bitbucket {
    
    public class BitbucketMockResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"access_token":"accesstoken","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
            res.setStatusCode(200);            
            return res;            
        }
    }
    @TestSetup
    static void setup(){
        DevOps_Request_Settings__c customSettingObj= new DevOps_Request_Settings__c();
        customSettingObj.Name = 'TestOrg';
        customSettingObj.Bitbucket_Client_ID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9Js';
        customSettingObj.Bitbucket_Client_Secret__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9Jslkwjashgdxjwiqo7yu';
        customSettingObj.BitBucket_Endpoint__c ='https://login1.salesforce.com';
        customSettingObj.Bitbucket_TokenEndpoint__c = 'https://bitbucket.org/sit111e/oauth2/token';
        insert customSettingObj;
    }
    @isTest
    static void testSendEmailInviteToNewUser(){
        //String groupName = devOpsRequestMap.get('bitbucketGroup');
        //String email = devOpsRequestMap.get('email');
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
            HTTPResponse resp = bitbucketAuth.sendEmailInviteToNewUser('testGrp','test@test.com');
            System.assertEquals(200, resp.getStatusCode());
        Test.stopTest();
    }
    @isTest
    static void testAddExistingUserToAGroup(){
        //String groupName = devOpsRequestMap.get('bitbucketGroup');
        //String email = devOpsRequestMap.get('email');
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
            String userAdded = bitbucketAuth.addExistingUserToAGroup('testGrp','test@test.com');
            System.assertNotEquals(null, userAdded);
        Test.stopTest();
    }   

    @isTest
    static void testGetAllUsers(){
        //String groupName = devOpsRequestMap.get('bitbucketGroup');
        //String email = devOpsRequestMap.get('email');
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
            HttpResponse allUsers = bitbucketAuth.getAllUsers();
            System.assertNotEquals(null, allUsers);
        Test.stopTest();
    } 
    @isTest
    static void testRemoveUser(){
        //String groupName = devOpsRequestMap.get('bitbucketGroup');
        //String email = devOpsRequestMap.get('email');
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest('TestOrg');
        Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
            HttpResponse userRemoved = bitbucketAuth.removeUser('testGrp','test@test.com');
            System.assertNotEquals(null, userRemoved);
        Test.stopTest();
    }   
    @isTest
    static void testGetAllUsersOfGroup(){
        //String groupName = devOpsRequestMap.get('bitbucketGroup');
        //String email = devOpsRequestMap.get('email');
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest('TestOrg');
        Test.startTest();
            //Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_Bitbucket.BitbucketMockResponse()); 
            HttpResponse userRemoved = bitbucketAuth.getAllUsersOfGroup('testGrp');
            System.assertNotEquals(null, userRemoved);
        Test.stopTest();
    }   
}