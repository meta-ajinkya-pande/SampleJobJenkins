@isTest
public class TST_CNT_DevOps_DevOpsRequest{
  
    public class AllSandboxResponse implements HttpCalloutMock {
      public HTTPResponse respond(HTTPRequest request) {
          HttpResponse response = new HttpResponse();
          response.setHeader('Content-Type', 'application/json');
          response.setBody('{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEo9WAG"},"Id":"0GQ2K000000PEo9WAG","SandboxName":"APIUSAGE","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"to verify API Security and control . Requested from Arun James.","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzNWAW"},"Id":"0GQ2K000000PEzNWAW","SandboxName":"CBEXxST","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"Developer sandbox for Saivamshi Takkadpelly (saivamshi.takkadapelly@iqvia.com)","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEw9WAG"},"Id":"0GQ2K000000PEw9WAG","SandboxName":"CBEXxSVT1","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"New Sandbox for CBEx team for SVT1 env setup","SourceId":null}]}');
          response.setStatusCode(200);
          return response; 
      }
    }
    public class GetClassIdResponse implements HttpCalloutMock {
      public HTTPResponse respond(HTTPRequest request) {
          HttpResponse response = new HttpResponse();
          response.setHeader('Content-Type', 'application/json');
          response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ApexClass","url":"/services/data/v57.0/sobjects/ApexClass/01p2K000003yzvaQAA"},"Id":"01p2K000003yzvaQAA","Name":"CallSampleDataLoader","Body":"global class CallSampleDataLoader implements SandboxPostCopy "}]}');
          response.setStatusCode(200);
          return response; 
      }
    }

    @testSetup 
    static void setup() {       
        DevOps_Request_Settings__c customSettingObj= new DevOps_Request_Settings__c();
        customSettingObj.Name = 'IQVIA';
        customSettingObj.Salesforce_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.Salesforce_CertificateName__c ='devopsrequestservercertificatetoupload1';
        customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
        customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
        customSettingObj.Salesforce_EndPointName__c ='https://TestOrg.my.salesforce.com/services/data/v57.0/';
        customSettingObj.Salesforce_TokenEndPoint__c = 'https://login1.salesforce.com/services/oauth2/token';
        customSettingObj.Sandbox_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.Sandbox_Client_Secrate__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzkwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.PasswordWithToken__c = 'MVG9CEn_O3jvv0zYtGcw';
        customSettingObj.Username__c = 'testuser@test.com';
        insert customSettingObj;
    }

    @isTest
    static void testFetchMetadataDetailLeadResource() {
        CNT_DevOps_DevOpsRequest.DevOpsResourceMetadata devopsResourceMdt;
        Module__mdt module = [select Id, Lead_User_ID__c, Lead_Name__c from Module__mdt where DeveloperName ='DevOps' limit 1];
        User leadUser = [SELECT Id,Email FROM User WHERE Id = :module.Lead_User_ID__c];
        Devops_Resource__mdt devopsResource = [select Id,Email_Id__c  from Devops_Resource__mdt  where Module__c = :module.Id and Email_Id__c != :leadUser.Email limit 1];
        User developerUser = [SELECT Id FROM User WHERE Email = :devopsResource.Email_Id__c limit 1];
        Test.startTest();
        System.runas(leadUser){
          devopsResourceMdt = CNT_DevOps_DevOpsRequest.fetchMetadataDetail();
          System.assertNotEquals(null, devopsResourceMdt,'metadata should be present');
        }       
        Test.stopTest();
    }
    @isTest
    static void testFetchMetadataDetailDeveloperResource() {
        CNT_DevOps_DevOpsRequest.DevOpsResourceMetadata devopsResourceMdt;
        Module__mdt module = [select Id, Lead_User_ID__c, Lead_Name__c from Module__mdt where DeveloperName ='DevOps' limit 1];
        User leadUser = [SELECT Id,Email FROM User WHERE Id = :module.Lead_User_ID__c];
        Devops_Resource__mdt devopsResource = [select Id,Email_Id__c  from Devops_Resource__mdt  where Module__c = :module.Id and Email_Id__c != :leadUser.Email limit 1];
        User developerUser = [SELECT Id FROM User WHERE Email = :devopsResource.Email_Id__c limit 1];
        Test.startTest();
         System.runas(developerUser){
          devopsResourceMdt = CNT_DevOps_DevOpsRequest.fetchMetadataDetail();        
          System.assertNotEquals(null, devopsResourceMdt,'metadata should be present');
        }     
        Test.stopTest();
    }
    @isTest
    static void testGetUserAllocatedSandboxName(){
      Sandbox_Allocation__mdt sandboxAllocation= [select Id, Devops_Resource__r.DeveloperName,Organization__c from Sandbox_Allocation__mdt where Devops_Resource__c != null limit 1];
      CNT_DevOps_DevOpsRequest.UserAllocatedSandboxName allocatedSandbox;
      Test.startTest();
      allocatedSandbox = CNT_DevOps_DevOpsRequest.getUserAllocatedSandboxName(sandboxAllocation.Devops_Resource__r.DeveloperName, sandboxAllocation.Organization__c);
      System.assertNotEquals(null, allocatedSandbox,'Allocated sandbox data should be present');
      Test.stopTest();      
    }
    @isTest
    static void testGetAllSanboxes(){
      CNT_DevOps_DevOpsRequest.SandboxListWithTypeLimit allSandboxList;
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new TST_CNT_DevOps_DevOpsRequest.AllSandboxResponse()); 
      allSandboxList = CNT_DevOps_DevOpsRequest.getAllSanboxes('IQVIA');
      System.assertNotEquals(null, allSandboxList,'Sandboxx should be present');
      Test.stopTest();   
    }

    @isTest
    static void testGetAllSanboxesErrorCondition(){
      CNT_DevOps_DevOpsRequest.SandboxListWithTypeLimit allSandboxList;
      Test.startTest();
      try{
        allSandboxList = CNT_DevOps_DevOpsRequest.getAllSanboxes('TestOrg');
      } catch (Exception  ex) {
        System.assertEquals('Script-thrown exception', ex.getMessage());
      }  
      Test.stopTest();      

    }
    @isTest
    static void testGetAllModule(){
      List<Module__mdt> allModules = new List<Module__mdt>();
      Test.startTest();
      allModules = CNT_DevOps_DevOpsRequest.getAllModule();
      System.assertNotEquals(null, allModules,'At least one module should be present in metadata');
      Test.stopTest();      
    }
    @isTest
    static void TestGetAllDevopsResource(){
      List<DevOps_Resource__mdt> allDevOpsResource;
      Test.startTest();
      allDevOpsResource = CNT_DevOps_DevOpsRequest.getAllDevopsResource();
      System.assertNotEquals(null, allDevOpsResource,'Resource should be present');
      Test.stopTest();
    }
    @isTest
    static void testGetClassId(){
      Sandbox_Allocation__mdt sandboxDataObject = [select Id, DeveloperName,Organization__c from Sandbox_Allocation__mdt where Devops_Resource__c != null limit 1];

      String classId;
      Test.startTest();
      Test.setMock(HttpCalloutMock.class, new TST_CNT_DevOps_DevOpsRequest.GetClassIdResponse()); 
      classId = CNT_DevOps_DevOpsRequest.getClassId('CallSampleDataLoader',sandboxDataObject.DeveloperName,sandboxDataObject.Organization__c);
      System.assertNotEquals(null, classId,'Class Id should not be null');
      System.debug('sandboxList ->' + classId);           
      Test.stopTest();   
    }

    @isTest
    static void testGetClassIdErrorCondition(){
      String classId;
      Test.startTest();
      try{
        classId = CNT_DevOps_DevOpsRequest.getClassId('CallSampleDataLoader','TestSand','TestOrg');
      } catch (Exception  ex) {
        System.assertEquals('Script-thrown exception', ex.getMessage());
      }  
      Test.stopTest();      
    }
    @isTest
    static void testSandboxNameWrapperConstructor(){
      Test.startTest();
      CNT_DevOps_DevOpsRequest.SandboxName sandboxWrapperObj =new CNT_DevOps_DevOpsRequest.SandboxName('Devopsx','Devopsx');
      System.assertNotEquals(null, sandboxWrapperObj,'sandboxWrapperObj should not be null');
      Test.stopTest();      
    }
}