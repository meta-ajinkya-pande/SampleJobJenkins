@isTest
public class TST_SRV_DevOps_SalesforceRequest {
    private static SRV_DevOps_SalesforceRequest devOpsReqInstance;
    
    public class AllSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEo9WAG"},"Id":"0GQ2K000000PEo9WAG","SandboxName":"APIUSAGE","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"to verify API Security and control . Requested from Arun James.","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzNWAW"},"Id":"0GQ2K000000PEzNWAW","SandboxName":"CBEXxST","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"Developer sandbox for Saivamshi Takkadpelly (saivamshi.takkadapelly@iqvia.com)","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEw9WAG"},"Id":"0GQ2K000000PEw9WAG","SandboxName":"CBEXxSVT1","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"New Sandbox for CBEx team for SVT1 env setup","SourceId":null}]}');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class RefreshSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            response.setStatusCode(204);
            return response; 
        }
    }
    public class CreateSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            response.setStatusCode(201);
            return response; 
        }
    }    
    public class GetSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"TestSand","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            
            response.setStatusCode(200);
            return response; 
        }
    }
    public class GetClassIDBySandboxNameResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"ApexClass","url":"/services/data/v57.0/sobjects/ApexClass/01p2K000003yzvaQAA"},"Id":"01p2K000003yzvaQAA","Name":"CallSampleDataLoader","Body":"This Class is Run when Sandox is refreshed or created. nglobal class CallSampleDataLoader implements SandboxPostCopy {   global void runApexClass(SandboxContext context) {      LoadCRMSampleData.createSampleData(20);}"}]}');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class GetProfileIdResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
            response.setStatusCode(200);
            return response; 
        }
    }
    public class CreateSandboxUserResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            if (request.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token'){
                HttpResponse res = new HttpResponse();            
                res.setHeader('Content-Type', 'application/json');            
                res.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
                res.setStatusCode(200);            
                return res;  
            }
            else {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
                response.setStatusCode(201);
                return response; 
            }
            
        }
    }    
    public class DeleteSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            response.setStatusCode(204);
            return response; 
        }
    }
    public class JWTHTTPMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
            res.setStatusCode(200);            
            return res;            
        }
    }
    public class SandboxInfoResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxProcess","records":[{"attributes":{"type":"SandboxProcess","url":"/services/data/v57.0/tooling/sobjects/SandboxProcess/0GR2K000000bmNkWAI"},"Id":"0GR2K000000bmNkWAI","SandboxInfoId":null,"SandboxName":"DevOpsXAK","LicenseType":"DEVELOPER","AutoActivate":false,"StartDate":"2023-05-23T07:20:26.000+0000","EndDate":"2023-05-23T10:15:46.000+0000","Description":"Dev org for Akash Khichi","CopyProgress":100,"Status":"Deleting","SourceId":"0GQ2K000000PEzcWAG"}]}');            
            res.setStatusCode(200);            
            return res;            
        }
    }

    public class reportIdResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Report","url":"/services/data/v57.0/sobjects/Report/00Of2000006wF7yEAE"},"Id":"00Of2000006wF7yEAE"}]}');            
            res.setStatusCode(200);            
            return res;            
        }
    }

    public class objectAPINameResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();            
            res.setHeader('Content-Type', 'application/json');            
            res.setBody('{"done":true, "records":[{"QualifiedApiName":"Account", "attributes":{"type":"EntityDefinition", "url":"/services/data/v57.0/sobjects/EntityDefinition/Account"}}], "totalSize":1}');            
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
        customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
        customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
        customSettingObj.Username__c = 'testuser@test.com';
        customSettingObj.Salesforce_EndPointName__c ='https://TestOrg.my.salesforce.com/services/data/v57.0/';
        customSettingObj.Salesforce_TokenEndPoint__c = 'https://login1.salesforce.com/services/oauth2/token';
        customSettingObj.Sandbox_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.Sandbox_Client_Secrate__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzkwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.PasswordWithToken__c = 'MVG9CEn_O3jvv0zYtGcw';
        insert customSettingObj;
    }

    @isTest
    static void testGetSandboxByName(){
        
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.GetSandboxResponse()); 
            String sandboxName=devOpsReqInstance.getSandboxByName('TestSand');
            System.assertNotEquals(null, sandboxName,'Sandbox data should be present');
            Test.stopTest();
    }
    @isTest
    static void testGetAllSanboxes(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.AllSandboxResponse()); 
            String allSandboxList = devOpsReqInstance.getAllSandboxes();
            System.assertNotEquals(null, allSandboxList,'Sadnbox should be present');
        Test.stopTest();   
    }

    @isTest
    static void testRefreshSandbox(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        String sandboxName ='DevOpsXAKZ';
        String sandboxId ='0GQ2K000030TCUrWAO';
        String sandboxType ='DEVELOPER';
        Boolean autoActivate = true;
        String sourceId = '0GQ2K000030PXzcWAG';
        String classId ='01p2K000003yzvaQAA';
        String description ='Refreshing for testing purpose (test@test.com)';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.RefreshSandboxResponse()); 
            HTTPResponse allSandboxList = devOpsReqInstance.refreshSandbox(sandboxName,sandboxId,sandboxType,autoActivate,sourceId,classId,description);
            System.assertEquals(204, allSandboxList.getStatusCode(), 'when sandbox refresh the status code will be 204');
        Test.stopTest();   
    }

    @isTest
    static void testCreateSandboxClassIdSourceIdNull(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        String sandboxName ='DevOpsXAKQ';
        String sandboxType ='DEVELOPER';
        Boolean autoActivate = true;
        String sourceId = null;
        String classId =null;
        String description ='Refreshing for testing purpose (test@test.com)';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.CreateSandboxResponse()); 
            HTTPResponse createSandboxResponse = devOpsReqInstance.createSandbox(sandboxName,sandboxType,autoActivate,sourceId,classId,description);
            System.assertEquals(201, createSandboxResponse.getStatusCode(), 'when sandbox created the status code will be 201');
        Test.stopTest();   
    }

    @isTest
    static void testCreateSandboxWithClassIdAndSourceId(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        String sandboxName ='DevOpsXAKR';
        String sandboxType ='DEVELOPER';
        Boolean autoActivate = true;
        String sourceId = '0GQ2K000030PXzcWAG';
        String classId ='01p2K000003yzvaQAA';
        String description ='Refreshing for testing purpose (test@test.com)';
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.CreateSandboxResponse()); 
            HTTPResponse createSandboxResponse = devOpsReqInstance.createSandbox(sandboxName,sandboxType,autoActivate,sourceId,classId,description);
            System.assertEquals(201, createSandboxResponse.getStatusCode(), 'when sandbox created the status code will be 201');
        Test.stopTest();   
    }

    @isTest
    static void testDeleteSandbox(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.DeleteSandboxResponse()); 
            HTTPResponse deleteSandboxResponse = devOpsReqInstance.deleteSandbox('DevOpsXAKZ');
            System.assertEquals(204, deleteSandboxResponse.getStatusCode(), 'when sandbox deleted the status code will be 204');
        Test.stopTest();   
    }

    @isTest
    static void testGetSandboxProgess(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.SandboxInfoResponse()); 
            HTTPResponse sandboxInfoProgressResponse = devOpsReqInstance.getSandboxProgess('DevOpsXAKZ');
            System.assertEquals(200, sandboxInfoProgressResponse.getStatusCode());
        Test.stopTest();   
    }
    @isTest
    static void testGetClassIdByClassNameAndOrg(){
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock());
        Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c  from Sandbox_Allocation__mdt limit 1 ];
 
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.GetClassIDBySandboxNameResponse()); 
            String classId = SRV_DevOps_SalesforceRequest.getClassIdByClassNameAndOrg('CallSampleDataLoader',sandboxDataObject.Organization__c,sandboxDataObject.DeveloperName);
            System.assertNotEquals(null, classId);
        Test.stopTest();   
    }
    @isTest
    static void testGetProfileId(){
        Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.JWTHTTPMock()); 
        Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c  from Sandbox_Allocation__mdt limit 1 ];

        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.GetProfileIdResponse()); 
            String profileId = SRV_DevOps_SalesforceRequest.getProfileId(sandboxDataObject.Organization__c,sandboxDataObject.DeveloperName);
            System.assertNotEquals(null, profileId);
        Test.stopTest();   
    }
    @isTest
    static void testCreateSandboxUser(){
        Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c  from Sandbox_Allocation__mdt limit 1 ];

        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
            gen.writeStringField('FirstName', 'firstName');
            gen.writeStringField('LastName', 'lastName');
            gen.writeStringField('Alias', 'FNLN');
            gen.writeStringField('Email', 'email@test.com');
            gen.writeStringField('Username', 'email@test.com.orgName.sandboxName');
            gen.writeStringField('ProfileId', '00e6A000001GRaPQDW');
            gen.writeStringField('TimeZoneSidKey', 'Asia/Kolkata');
            gen.writeStringField('LocaleSidKey', 'en_US');
            gen.writeStringField('EmailEncodingKey', 'UTF-8');
            gen.writeStringField('LanguageLocaleKey', 'en_US');
            gen.writeStringField('Audit_Employee_Number_Reason__c', 'Sandbox User in test method');
            gen.writeStringField('Change_Request_Ticket_Number__c', '123456');
        gen.writeEndObject();
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.CreateSandboxUserResponse()); 
            HttpResponse createSandboxUserResponse = SRV_DevOps_SalesforceRequest.createSandboxUser(sandboxDataObject.Organization__c,sandboxDataObject.DeveloperName,gen.getAsString());
            System.assertEquals(201, createSandboxUserResponse.getStatusCode());
        Test.stopTest();   
    }

    @isTest
    static void testGetReportId(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
         devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.reportIdResponse()); 
            String reportId = devOpsReqInstance.getReportId('00Of2000006wF7yEAE');
            System.assertEquals(reportId, '00Of2000006wF7yEAE');
        Test.stopTest();   
    }

    @isTest
    static void testGetObjectAPIName(){
        SRV_DevOps_SalesforceRequest devOpsReqInstance;
         devOpsReqInstance = SRV_DevOps_SalesforceRequest.authenticateRequest('TestOrg');
        Test.startTest();
            Test.setMock(HttpCalloutMock.class, new TST_SRV_DevOps_SalesforceRequest.objectAPINameResponse()); 
            String objectAPIName = devOpsReqInstance.getObjectAPIName('Accounts');
            System.assertEquals(objectAPIName, 'Account');
        Test.stopTest(); 
    }
}