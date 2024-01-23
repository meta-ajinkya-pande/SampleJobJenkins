@isTest
public with sharing class TST_UTL_DevOps_JWTAuthentication {
        public class Test_JWTHTTPMock implements HttpCalloutMock {
            public HTTPResponse respond(HTTPRequest req) {
                HttpResponse res = new HttpResponse();
                res.setHeader('Content-Type', 'application/json');
                res.setBody('{"access_token":"authent succeeded"}');
                res.setStatusCode(200);
                return res;
              }
      }
      @testSetup 
      static void setup() {            
        DevOps_Request_Settings__c customSettingObj= new DevOps_Request_Settings__c();
        customSettingObj.Name = 'TestOrg';
        customSettingObj.Salesforce_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.Salesforce_CertificateName__c ='devopsrequestservercertificatetoupload1';
        customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
        customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
        customSettingObj.Salesforce_EndPointName__c ='https://TestOrg.my.salesforce.com/services/data/v57.0/';
        customSettingObj.Salesforce_TokenEndPoint__c = 'https://login1.salesforce.com/services/oauth2/token';
        insert customSettingObj;
      }
      @isTest
      static void testUTL_DevOps_JWTAuthentication(){
        Test.startTest();
        UTL_DevOps_JWTAuthentication jwtDevOps ;
        jwtDevOps = new UTL_DevOps_JWTAuthentication('TestOrg');
        Test.setMock(HttpCalloutMock.class, new TST_UTL_DevOps_JWTAuthentication.Test_JWTHTTPMock());
        String accessToken = jwtDevOps.getAccessToken();
        System.assertEquals('', accessToken);  
        Test.stopTest();      
  
      }
}