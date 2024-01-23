@isTest
public with sharing class TST_UTL_DevOps_BitbucketAuthentication {
    public class AuthenticationRespomse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"access_token":"authenticate succeeded","size":0}');
            res.setStatusCode(200);
            return res;
          }
}

@testSetup 
static void setup() {
    DevOps_Request_Settings__c customSettingObj= new DevOps_Request_Settings__c();
    customSettingObj.Name = 'IQVIA';
    customSettingObj.Salesforce_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
    customSettingObj.Salesforce_CertificateName__c ='devopsrequestservercertificatetoupload1';
    customSettingObj.Bitbucket_Client_ID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
    customSettingObj.Bitbucket_Client_Secret__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzkwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
    customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
    customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
    customSettingObj.Salesforce_HostName__c ='https://TestOrg.my.salesforce.com/services/data/v57.0/';
    customSettingObj.Bitbucket_TokenEndpoint__c = 'https://login1.salesforce.com/services/oauth2/token';
    customSettingObj.Username__c  = 'testuser@test.com';
    customSettingObj.PasswordWithToken__c = 'MVG9CEn_O3jvv0zYtGcw';
    insert customSettingObj;             
   
}
  
@isTest
static void testUTLDevOpsBitbucketAuthentication(){
    Test.startTest();
    UTL_DevOps_BitbucketAuthentication bitbucketAuth = new UTL_DevOps_BitbucketAuthentication('IQVIA');

    //sandboxAuth = new UTL_DevOps_JWTAuthentication('TestOrg');
    Test.setMock(HttpCalloutMock.class, new TST_UTL_DevOps_SandboxAuthentication.AuthenticationRespomse());
    String token = bitbucketAuth.getAccessToken();
    //String  = accessToken.get('accessToken');
    System.assertEquals('authenticate succeeded', token);  
    Test.stopTest();
}
}