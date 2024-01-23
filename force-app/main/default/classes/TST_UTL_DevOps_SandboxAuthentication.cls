@isTest
public with sharing class TST_UTL_DevOps_SandboxAuthentication {
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
    customSettingObj.Sandbox_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
    customSettingObj.Sandbox_Client_Secrate__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzkwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
    customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
    customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
    customSettingObj.Salesforce_HostName__c ='https://TestOrg.my.salesforce.com/services/data/v57.0/';
    customSettingObj.Salesforce_TokenEndPoint__c = 'https://login1.salesforce.com/services/oauth2/token';
    customSettingObj.Username__c  = 'testuser@test.com';
    customSettingObj.PasswordWithToken__c = 'MVG9CEn_O3jvv0zYtGcw';
    insert customSettingObj;
  }
  @isTest
  static void testUTL_DevOps_SandboxAuthentication(){
    Test.startTest();
    Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c  from Sandbox_Allocation__mdt limit 1 ];
    System.debug('Sandbox_Allocation__mdt -> '+sandboxDataObject);
    UTL_DevOps_SandboxAuthentication sandboxAuth = UTL_DevOps_SandboxAuthentication.getInstance(sandboxDataObject.Organization__c,sandboxDataObject.DeveloperName);
    //sandboxAuth = new UTL_DevOps_JWTAuthentication('TestOrg');
    Test.setMock(HttpCalloutMock.class, new TST_UTL_DevOps_SandboxAuthentication.AuthenticationRespomse());
    Map<String,String> accessToken = sandboxAuth.authenticSandbox();
    String token = accessToken.get('accessToken');
    System.assertEquals('authenticate succeeded', token);  
    Test.stopTest();
  }
}