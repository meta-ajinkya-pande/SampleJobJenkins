@isTest
public with sharing class TST_DAO_DevOpsRequest {
    public TST_DAO_DevOpsRequest() {

    }
    public class CreateSandboxResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            response.setStatusCode(201);
            return response; 
        }
    }    
    
    public class OffboardingBitbucketRequestResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
            response.setStatusCode(204);
            return response; 
        }
    }    
    public class OffboardingRequestResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzcWAG"},"Id":"0GQ2K000000PEzcWAG","SandboxName":"UATHotfix","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"UAT hotfix environment create on 13th march 2023 from uthfixchk","SourceId":"0GQ2K000000PEoYWAW"}]}');
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
    @testSetup 
    static void setup(){
        //Devops_Request__c devopsReqObj = new Devops_Request__c();
        DevOps_Request_Settings__c customSettingObj= new DevOps_Request_Settings__c();
        customSettingObj.Name = 'IQVIA';
        customSettingObj.Salesforce_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        customSettingObj.Salesforce_CertificateName__c ='devopsrequestservercertificatetoupload1';
        customSettingObj.Salesforce_HostName__c ='https://login1.salesforce.com';
        customSettingObj.Salesforce_UserName__c = 'testuser@test.com';
        customSettingObj.Salesforce_EndPointName__c ='https://IQVIA.my.salesforce.com/services/data/v57.0/';
        customSettingObj.Salesforce_TokenEndPoint__c = 'https://login1.salesforce.com/services/oauth2/token';
        customSettingObj.Jenkins_API_Key__c = '11f8559f6ae4e957066063es079dasdff4a5';
        customSettingObj.Jenkins_BuildName__c = 'test123';
        customSettingObj.Jenkins_Endpoint__c = 'https://jenkins1-dev1.work1.IQVIA.com' ;
        customSettingObj.Jenkins_Username__c = 'devopsautouser';
        insert customSettingObj;       

    }

    @isTest
    static void testNewSandbox(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_DAO_DevOpsRequest.CreateSandboxResponse()); 
        Devops_Request_Trigger_Handler__c tgrHandlerObj = new Devops_Request_Trigger_Handler__c();
        tgrHandlerObj.Allow_System_Admin_Approval__c = true;
        tgrHandlerObj.SetupOwnerId = userinfo.getUserId();
        insert tgrHandlerObj;
          Devops_Request__c sobj2 = new Devops_Request__c(
            Request_Type__c = 'New Sandbox',                                                          // Request Type
            Organization__c = 'IQVIA',                                                                  // Organization
            Requested_For__c = 'Test_User',                                                          // Requested For
            Request_Status__c = 'Submitted',                                                            // Request Status
            Module_Name__c = 'DEVOPS',                                                                  // Module Name
            Is_Child__c = false,                                                                      // Is Child
            Create_From__c = 'UATHotfix',                                                               // Create From
            Sandbox_Name__c = 'DEVOPSxTU',                                                              // Sandbox Name
            Sandbox_Description__c = 'Developer sandbox for Test User (Test.User@metacube.com)',  // Sandbox Description
            Sandbox_Type__c = 'DEVELOPER',                                                              // Sandbox Type
            SourceId__c = '0GQ2K000000PEzcWAG',                                                         // SourceId
            Post_Activity_Apex_Class__c = 'CallSampleDataLoader',                                       // Post Activity Apex Class
            ClassId__c = '01p2K000003yzvaQAA',                                                          // ClassId
            Auto_Active__c = true,                                                                     // Auto Active
            Is_Bitbucket_User__c = false,                                                               // Is Bitbucket User
            Is_Jenkins_User__c = false,                                                                 // Is Jenkins User
            Is_Sandbox_Required__c = false                                                             // Is Sandbox Required
          );
          insert sobj2;

          sobj2.Request_Status__c = 'Approved';
          update sobj2;

        Test.stopTest();
    }
    @isTest
    static void testNewJenkins(){
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_DAO_DevOpsRequest.CreateSandboxResponse()); 
        Devops_Request_Trigger_Handler__c tgrHandlerObj = new Devops_Request_Trigger_Handler__c();
        tgrHandlerObj.Allow_System_Admin_Approval__c = true;
        tgrHandlerObj.SetupOwnerId = userinfo.getUserId();
        insert tgrHandlerObj;
        Devops_Request__c sobj = new Devops_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Organization__c ='IQVIA',
            Request_Status__c ='Submitted',
            Requested_For__c ='Test_User'
          );

          insert sobj;

          sobj.Request_Status__c = 'Approved';
          update sobj;



        Test.stopTest();
    }
    @isTest
    static void testOnabordingRquest(){
        Test.startTest();

        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt limit 1];
        Module__mdt module = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, Lead_Email__c, Lead_User_ID__c, Lead_Name__c from Module__mdt where Id=:devopsResource.Module__c limit 1];
        
        Test.setMock(HttpCalloutMock.class, new TST_DAO_DevOpsRequest.CreateSandboxResponse()); 
        Devops_Request_Trigger_Handler__c tgrHandlerObj = new Devops_Request_Trigger_Handler__c();
        tgrHandlerObj.Allow_System_Admin_Approval__c = true;
        tgrHandlerObj.SetupOwnerId = userinfo.getUserId();
        insert tgrHandlerObj;
        Devops_Request__c sobj = new Devops_Request__c(
            Request_Type__c = 'Onboarding Request',                                                          // Request Type
            Organization__c = 'IQVIA',                                                                  // Organization
            Requested_For__c = devopsResource.DeveloperName,
            EmailId__c = 'test@mail.com',                                                          // Requested For
            Request_Status__c = 'Submitted',                                                            // Request Status
            Module_Name__c = module.DeveloperName,                                                                  // Module Name
            Is_Child__c = false,                                                                        // Is Child
            Create_From__c = 'UATHotfix',                                                               // Create From
            Sandbox_Name__c = 'DEVOPSTU',                                                              // Sandbox Name
            Sandbox_Description__c = 'Developer sandbox for Test User (Test.User@metacube.com)',  // Sandbox Description
            Sandbox_Type__c = 'DEVELOPER',                                                              // Sandbox Type
            SourceId__c = '0GQ2K000000PEzcWAG',                                                         // SourceId
            Post_Activity_Apex_Class__c = 'CallSampleDataLoader',                                       // Post Activity Apex Class
            ClassId__c = '01p2K000003yzvaQAA',                                                          // ClassId
            Auto_Active__c = true,                                                                     // Auto Active
            Is_Bitbucket_User__c = true,         
            Bitbucket_Group__c ='sfdc-qi-devops',
            Jenkins_Roles__c ='Developer',                                                    // Is Bitbucket User
            Is_Jenkins_User__c = true,                                                                 // Is Jenkins User
            Is_Sandbox_Required__c = false,
            LastName__c =devopsResource.First_Name__c,
            FirstName__c = devopsResource.Last_Name__c
          );
          insert sobj;             
          sobj.Request_Status__c = 'Approved';
          update sobj;
        Test.stopTest();
    }
    @isTest
    static void testSandboxRefresh(){
        
        Test.startTest();
        Devops_Request_Trigger_Handler__c tgrHandlerObj = new Devops_Request_Trigger_Handler__c();
        tgrHandlerObj.Allow_System_Admin_Approval__c = true;
        tgrHandlerObj.SetupOwnerId = userinfo.getUserId();
        insert tgrHandlerObj;
        Test.setMock(HttpCalloutMock.class, new TST_DAO_DevOpsRequest.RefreshSandboxResponse()); 
        Devops_Request__c sobj = new Devops_Request__c(
            Request_Type__c = 'Sandbox Refresh',                                 // Request Type
            Organization__c = 'IQVIA',                                             // Organization
            Requested_For__c = 'Test_User',                                       // Request Status
            Module_Name__c = 'DEVOPS',     
            Request_Status__c = 'Submitted',                                                            // Request Status
            // Processing status
            Is_Child__c = false,                                                   // Is Child
            Create_From__c = 'UATHotfix',                                         // Create From
            Sandbox_Name__c = 'UATHotfix',                                            // Sandbox Name
            Sandbox_Description__c = 'DEV sandbox for Tets.Mail@metacube.com',  // Sandbox Description
            Old_Sandbox_Name__c = 'UATHotfix',                                        // Old Sandbox Name
            Sandbox_Type__c = 'DEVELOPER',                                         // Sandbox Type
            Post_Activity_Apex_Class__c = 'CallSampleDataLoader',                  // Post Activity Apex Class
            ClassId__c = '01p2K000003yzvaQAA',                                     // ClassId
            Auto_Active__c = true,                                                 // Auto Active
            Is_Bitbucket_User__c = false,                                          // Is Bitbucket User
            Is_Jenkins_User__c = false,                                            // Is Jenkins User
            Is_Sandbox_Required__c = false,                                        // Is Sandbox Required
            Is_Bitbucket_User_Offboard__c = false,                                 // Is Bitbucket User Offboard
            Is_Jenkins_User_Offboard__c = false,                                   // Is Jenkins User Offboard
            Is_Sandbox_Offboard_Required__c = false                               // Is Sandbox Offboard Required
        );
        insert sobj;

        sobj.Request_Status__c = 'Approved';
        update sobj;
        Test.stopTest();
    }

    @isTest
    static void testOffboardingRequest(){
        Test.startTest();

        Sandbox_Allocation__mdt sanboxMtd = [select Id, DeveloperName,Organization__c,Devops_Resource__c  from Sandbox_Allocation__mdt where Devops_Resource__c != null limit 1];
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt where Id=:sanboxMtd.Devops_Resource__c limit 1];
        Module__mdt module = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, Lead_Email__c, Lead_User_ID__c, Lead_Name__c from Module__mdt where Id=:devopsResource.Module__c limit 1];
        Devops_Request_Trigger_Handler__c tgrHandlerObj = new Devops_Request_Trigger_Handler__c();
        tgrHandlerObj.Allow_System_Admin_Approval__c = true;
        tgrHandlerObj.SetupOwnerId = userinfo.getUserId();
        insert tgrHandlerObj;
        Test.setMock(HttpCalloutMock.class, new TST_DAO_DevOpsRequest.OffboardingRequestResponse()); 
        Devops_Request__c sobj = new Devops_Request__c(
            Request_Type__c = 'Offboarding Request',             // Request Type
            Organization__c = 'IQVIA',                             // Organization
            Requested_For__c = devopsResource.DeveloperName,                                                                  // Organization
            // Requested For
            Request_Status__c = 'Submitted',                       // Request Status
            Module_Name__c = module.DeveloperName,                             // Module Name
            Approver__c = '00539000003YUUlAAO',    
            EmailId__c = 'test@mail.com',    
            LastName__c =devopsResource.First_Name__c,
            FirstName__c = devopsResource.Last_Name__c,               // Approver
            Is_Child__c = false,                                   // Is Child
            Post_Activity_Apex_Class__c = 'CallSampleDataLoader',  // Post Activity Apex Class
            Auto_Active__c = false,                                // Auto Active
            Is_Bitbucket_User__c = false,                          // Is Bitbucket User
            Is_Jenkins_User__c = false,                            // Is Jenkins User
            Is_Sandbox_Required__c = false,                        // Is Sandbox Required
            Is_Bitbucket_User_Offboard__c = true,                  // Is Bitbucket User Offboard
            Is_Jenkins_User_Offboard__c = true,                    // Is Jenkins User Offboard
            Is_Sandbox_Offboard_Required__c = true,                // Is Sandbox Offboard Required
            Sandbox_to_remove__c = sanboxMtd.DeveloperName                   // Sandbox to remove
        );
        insert sobj;

        sobj.Request_Status__c = 'Approved';
        update sobj;
        Test.stopTest();
        
    }
}