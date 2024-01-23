@isTest
public class TST_BCH_DevOps_RequestProgress {

    @TestSetup
    static void setup(){
        DevOps_Request_Settings__c settings = new DevOps_Request_Settings__c();
        settings.Name = 'IQVIA';
        settings.Jenkins_Username__c = 'testUsername';
        settings.Jenkins_API_Key__c = 'testApiKey';
        settings.Jenkins_Endpoint__c = 'https://jenkins.example.com';
        settings.Jenkins_BuildName__c = 'testBuild';
        settings.Salesforce_ClientID__c ='3MVG9CEn_O3jvv0zYtGcwYwOmF9J._DzktHtczwTuzH_Kd0frn4KwyjI2wWlmJ4.GlqcYDkrLYXN4KNyAM3uqas';
        settings.Salesforce_CertificateName__c ='devopsrequestservercertificatetoupload1';
        settings.Salesforce_HostName__c ='https://login.salesforce.com';
        settings.Salesforce_UserName__c = 'testuser@test.com';
        settings.Salesforce_EndPointName__c ='https://iqvia.my.salesforce.com/services/data/v57.0/';
        settings.Salesforce_TokenEndPoint__c = 'https://login.salesforce.com/services/oauth2/token';
        settings.Sandbox_ClientID__c = '1234567981235';
        settings.Sandbox_Client_Secrate__c = '1234569875312';
        settings.PasswordWithToken__c = '132469873213216464';
        settings.Username__c = 'test@test.com.devopsxap';
        insert settings;
    }

    public with sharing class CallOutMockDeleteMetadata implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {
          UTL_DevOps_MetadataInsertUpdate.deleteMetadataResponse_element metadataResponse = new UTL_DevOps_MetadataInsertUpdate.deleteMetadataResponse_element();
          UTL_DevOps_MetadataInsertUpdate.DeleteResult saveresult = new UTL_DevOps_MetadataInsertUpdate.DeleteResult();
          saveresult.fullName = 'TestApp';
          saveresult.success = true;
          metadataResponse.result = new List<UTL_DevOps_MetadataInsertUpdate.DeleteResult>();
          metadataResponse.result.add(saveresult);
          response.put('response_x', metadataResponse); 
        }
    }

    public with sharing class CallOutMockInsertAndUpdateMetadata implements WebServiceMock{
        public void doInvoke(Object stub, Object request, Map<String, Object> response, String endpoint, String soapAction, String requestName, String responseNS, String responseName, String responseType) {      
            UTL_DevOps_MetadataInsertUpdate.createResponse_element metadataResponse = new UTL_DevOps_MetadataInsertUpdate.createResponse_element();
            UTL_DevOps_MetadataInsertUpdate.AsyncResult saveresult = new UTL_DevOps_MetadataInsertUpdate.AsyncResult();
            saveresult.done = true;
            metadataResponse.result = new List<UTL_DevOps_MetadataInsertUpdate.AsyncResult>();
            metadataResponse.result.add(saveresult);
            response.put('response_x', metadataResponse);
        }
    }

    public class SandboxInfoResponse implements HttpCalloutMock {
        String query='Select id from Profile where name = \'System Administrator\'';
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token'){
                HttpResponse res = new HttpResponse();            
                res.setHeader('Content-Type', 'application/json');            
                res.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://iqvia.my.salesforce.com/services/data/v57.0/"}');            
                res.setStatusCode(200);            
                return res;  
            } else if (req.getEndpoint() == 'https://iqvia.my.salesforce.com/services/data/v57.0/query/?q='+EncodingUtil.urlEncode(query, 'UTF-8')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
                response.setStatusCode(200);
                return response;
            } else if (req.getEndpoint().containsIgnoreCase('sobjects/User') && !req.getEndpoint().containsIgnoreCase('password')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
                response.setStatusCode(201);
                return response;
            } else if (req.getEndpoint().containsIgnoreCase('sobjects/User') && req.getEndpoint().containsIgnoreCase('password')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                return response;
            } else {
                HttpResponse res = new HttpResponse();            
                res.setHeader('Content-Type', 'application/json');            
                res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxProcess","records":[{"attributes":{"type":"SandboxProcess","url":"/services/data/v57.0/tooling/sobjects/SandboxProcess/0GR2K000000bmNkWAI"},"Id":"0GR2K000000bmNkWAI","SandboxInfoId":null,"SandboxName":"DEVOPSxAK","LicenseType":"DEVELOPER","AutoActivate":false,"StartDate":"2023-05-23T07:20:26.000+0000","EndDate":"2023-05-23T10:15:46.000+0000","Description":"Dev org for Akash Khichi","CopyProgress":100,"Status":"Completed","SourceId":"0GQ2K000000PEzcWAG"}]}');            
                res.setStatusCode(200);            
                return res;
            }            
        }
    }

    public class SandboxInfoDeleteStatusResponse implements HttpCalloutMock {
        String query='Select id from Profile where name = \'System Administrator\'';
        public HTTPResponse respond(HTTPRequest req) {
            if (req.getEndpoint() == 'https://test.salesforce.com/services/oauth2/token'){
                HttpResponse res = new HttpResponse();            
                res.setHeader('Content-Type', 'application/json');            
                res.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://iqvia.my.salesforce.com/services/data/v57.0/"}');            
                res.setStatusCode(200);            
                return res;  
            } else if (req.getEndpoint() == 'https://iqvia.my.salesforce.com/services/data/v57.0/query/?q='+EncodingUtil.urlEncode(query, 'UTF-8')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
                response.setStatusCode(200);
                return response;
            } else if (req.getEndpoint().containsIgnoreCase('sobjects/User') && !req.getEndpoint().containsIgnoreCase('password')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"totalSize":1,"done":true,"records":[{"attributes":{"type":"Profile","url":"/services/data/v57.0/sobjects/Profile/00e6A000001GAaPQAW"},"Id":"00e6A000001GAaPQAW"}]}');
                response.setStatusCode(201);
                return response;
            } else if (req.getEndpoint().containsIgnoreCase('sobjects/User') && req.getEndpoint().containsIgnoreCase('password')) {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setStatusCode(200);
                return response;
            } else {
                HttpResponse res = new HttpResponse();            
                res.setHeader('Content-Type', 'application/json');            
                res.setBody('{"size":1,"totalSize":1,"done":true,"queryLocator":null,"entityTypeName":"SandboxProcess","records":[{"attributes":{"type":"SandboxProcess","url":"/services/data/v57.0/tooling/sobjects/SandboxProcess/0GR2K000000bmNkWAI"},"Id":"0GR2K000000bmNkWAI","SandboxInfoId":null,"SandboxName":"DEVOPSxAK","LicenseType":"DEVELOPER","AutoActivate":false,"StartDate":"2023-05-23T07:20:26.000+0000","EndDate":"2023-05-23T10:15:46.000+0000","Description":"Dev org for Akash Khichi","CopyProgress":100,"Status":"Deleted","SourceId":"0GQ2K000000PEzcWAG"}]}');            
                res.setStatusCode(200);            
                return res;
            }            
        }
    }

    public class UpdateJenkinsProdgress200StatusCodePass implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"result":"SUCCESS","executable":{"access_token":"dddsadasxsaxasxasx","url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}}');            
            response.setStatusCode(200);
            return response; 
        }
    }

    public class UpdateJenkinsProdgress200StatusCodeFailedBuildStatus implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"result":"SUCCESS","executable":{"access_token":"dddsadasxsaxasxasx","url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}}');            
            if(request.getEndpoint()=='https://TestOrg.my.salesforce.com/services/data/v57.0/api/json')
                response.setStatusCode(20);
            response.setStatusCode(200);
            
            return response; 
        }
    }

    public class UpdateJenkinsProdgress200StatusCodeFailed implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
            response.setBody('{"executable":{"access_token":"dddsadasxsaxasxasx","url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}}');            
            response.setStatusCode(200);
            return response; 
        }
    }

    public class NewJenkinsRequestFailedQueueMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            DevOps_Request_Settings__c devOpsRequest = DevOps_Request_Settings__c.getInstance('IQVIA');
            if (request.getEndpoint() == devOpsRequest.Jenkins_Endpoint__c+'/job/'+devOpsRequest.Jenkins_BuildName__c+'/api/json?tree=builds[queueId,url]') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowJob","builds":[{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","queueId":8342,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/"},{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","queueId":8341,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/"}]}');            
                response.setStatusCode(200);
                return response;
            } else if (request.getEndpoint() == 'https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/api/json') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","actions":[{"_class":"hudson.model.ParametersAction","parameters":[{"_class":"hudson.model.StringParameterValue","name":"username","value":"test1234"},{"_class":"hudson.model.PasswordParameterValue","name":"password"},{"_class":"hudson.model.StringParameterValue","name":"email","value":"ajinkya.pande@metacube.com"},{"_class":"hudson.model.StringParameterValue","name":"fullName","value":"Test Test"},{"_class":"hudson.model.StringParameterValue","name":"globalRole","value":"admin"},{"_class":"hudson.model.TextParameterValue","name":"projectRoles","value":"CPQ"}]},{"_class":"hudson.model.CauseAction","causes":[{"_class":"hudson.model.Cause$UserIdCause","shortDescription":"Started by user Ajinkya Pande","userId":"ajinkyapande","userName":"Ajinkya Pande"}]},{"_class":"jenkins.metrics.impl.TimeInQueueAction","blockedDurationMillis":0,"blockedTimeMillis":0,"buildableDurationMillis":0,"buildableTimeMillis":0,"buildingDurationMillis":266,"executingTimeMillis":266,"executorUtilization":1.0,"subTaskCount":0,"waitingDurationMillis":7870,"waitingTimeMillis":7870},{"_class":"org.jenkinsci.plugins.workflow.cps.EnvActionImpl"},{},{"_class":"org.jenkinsci.plugins.displayurlapi.actions.RunDisplayAction"},{},{"_class":"org.jenkinsci.plugins.workflow.job.views.FlowGraphAction"},{},{},{}],"artifacts":[],"building":false,"description":null,"displayName":"#19","duration":266,"estimatedDuration":245,"executor":null,"fullDisplayName":"CreateUserAndAssignRole #19","id":"19","keepLog":false,"number":19,"queueId":8342,"result":"SUCCESS","timestamp":1692008111795,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/","changeSets":[],"culprits":[],"inProgress":false,"nextBuild":null,"previousBuild":{"number":18,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/"}}');
                response.setStatusCode(200);
                return response;
            } else if (request.getEndpoint() == 'https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/api/json') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","actions":[{"_class":"hudson.model.ParametersAction","parameters":[{"_class":"hudson.model.StringParameterValue","name":"username","value":"test1234"},{"_class":"hudson.model.PasswordParameterValue","name":"password"},{"_class":"hudson.model.StringParameterValue","name":"email","value":"ajinkya.pande@metacube.com"},{"_class":"hudson.model.StringParameterValue","name":"fullName","value":"Test Test"},{"_class":"hudson.model.StringParameterValue","name":"globalRole","value":"admin"},{"_class":"hudson.model.TextParameterValue","name":"projectRoles","value":"CPQ"}]},{"_class":"hudson.model.CauseAction","causes":[{"_class":"hudson.model.Cause$UserIdCause","shortDescription":"Started by user Ajinkya Pande","userId":"ajinkyapande","userName":"Ajinkya Pande"}]},{"_class":"jenkins.metrics.impl.TimeInQueueAction","blockedDurationMillis":0,"blockedTimeMillis":0,"buildableDurationMillis":0,"buildableTimeMillis":0,"buildingDurationMillis":235,"executingTimeMillis":235,"executorUtilization":1.0,"subTaskCount":0,"waitingDurationMillis":7647,"waitingTimeMillis":7647},{"_class":"org.jenkinsci.plugins.workflow.cps.EnvActionImpl"},{},{"_class":"org.jenkinsci.plugins.displayurlapi.actions.RunDisplayAction"},{},{"_class":"org.jenkinsci.plugins.workflow.job.views.FlowGraphAction"},{},{},{}],"artifacts":[],"building":false,"description":null,"displayName":"#18","duration":235,"estimatedDuration":245,"executor":null,"fullDisplayName":"CreateUserAndAssignRole #18","id":"18","keepLog":false,"number":18,"queueId":8341,"result":"FAILURE","timestamp":1692008091760,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/","changeSets":[],"culprits":[],"inProgress":false,"nextBuild":{"number":19,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/"},"previousBuild":{"number":17,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/17/"}}');
                response.setStatusCode(200);
                return response;
            } else {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
                response.setStatusCode(404);
                return response;
            }
        }
    }

    public class NewJenkinsRequestFailedQueueFailedReqMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            DevOps_Request_Settings__c devOpsRequest = DevOps_Request_Settings__c.getInstance('IQVIA');
            if (request.getEndpoint() == devOpsRequest.Jenkins_Endpoint__c+'/job/'+devOpsRequest.Jenkins_BuildName__c+'/api/json?tree=builds[queueId,url]') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowJob","builds":[{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","queueId":8342,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/"},{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","queueId":8341,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/"}]}');            
                response.setStatusCode(200);
                return response;
            } else if (request.getEndpoint() == 'https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/api/json') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"_class":"org.jenkinsci.plugins.workflow.job.WorkflowRun","actions":[{"_class":"hudson.model.ParametersAction","parameters":[{"_class":"hudson.model.StringParameterValue","name":"username","value":"test1234"},{"_class":"hudson.model.PasswordParameterValue","name":"password"},{"_class":"hudson.model.StringParameterValue","name":"email","value":"ajinkya.pande@metacube.com"},{"_class":"hudson.model.StringParameterValue","name":"fullName","value":"Test Test"},{"_class":"hudson.model.StringParameterValue","name":"globalRole","value":"admin"},{"_class":"hudson.model.TextParameterValue","name":"projectRoles","value":"CPQ"}]},{"_class":"hudson.model.CauseAction","causes":[{"_class":"hudson.model.Cause$UserIdCause","shortDescription":"Started by user Ajinkya Pande","userId":"ajinkyapande","userName":"Ajinkya Pande"}]},{"_class":"jenkins.metrics.impl.TimeInQueueAction","blockedDurationMillis":0,"blockedTimeMillis":0,"buildableDurationMillis":0,"buildableTimeMillis":0,"buildingDurationMillis":266,"executingTimeMillis":266,"executorUtilization":1.0,"subTaskCount":0,"waitingDurationMillis":7870,"waitingTimeMillis":7870},{"_class":"org.jenkinsci.plugins.workflow.cps.EnvActionImpl"},{},{"_class":"org.jenkinsci.plugins.displayurlapi.actions.RunDisplayAction"},{},{"_class":"org.jenkinsci.plugins.workflow.job.views.FlowGraphAction"},{},{},{}],"artifacts":[],"building":false,"description":null,"displayName":"#19","duration":266,"estimatedDuration":245,"executor":null,"fullDisplayName":"CreateUserAndAssignRole #19","id":"19","keepLog":false,"number":19,"queueId":8342,"result":"SUCCESS","timestamp":1692008111795,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/19/","changeSets":[],"culprits":[],"inProgress":false,"nextBuild":null,"previousBuild":{"number":18,"url":"https://jenkins.work.iqvia.com/job/CreateUserAndAssignRole/18/"}}');
                response.setStatusCode(404);
                return response;
            }else {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setHeader('Location', 'https://jenkins.test.com/queue/item/');
                response.setBody('{"access_token":"dddsadasxsaxasxasx","instance_url":"https://TestOrg.my.salesforce.com/services/data/v57.0/"}');            
                response.setStatusCode(404);
                return response;
            }
        }
    }

    public class NewBitbucketRequest implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            if (request.getEndpoint() == 'https://bitbucket.org/api/internal/workspaces/qiesp/groups/sfdc-qi-devops/members') {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"values": [{"display_name": "Ajinkya Pande", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B06b50388-1bb3-49eb-9606-6295be7e225c%7D"}, "avatar": {"href": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/557058:2c27e533-d826-48ff-a5e0-649404342261/5196af67-dbc3-4621-bffd-ed49016079cd/128"}, "html": {"href": "https://bitbucket.org/%7B06b50388-1bb3-49eb-9606-6295be7e225c%7D/"}}, "is_active": true, "type": "user", "uuid": "{06b50388-1bb3-49eb-9606-6295be7e225c}", "account_id": "557058:2c27e533-d826-48ff-a5e0-649404342261", "nickname": "qi-ajinkyapande", "email": "apande@us.imshealth.com"}, {"display_name": "Akash Khichi", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de%7D"}, "avatar": {"href": "https://secure.gravatar.com/avatar/348c98ec45d4385b51eda94a7fe0492f?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FAK-6.png"}, "html": {"href": "https://bitbucket.org/%7B3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de%7D/"}}, "is_active": true, "type": "user", "uuid": "{3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de}", "account_id": "637494d85fce844d60671210", "nickname": "Akash Khichi", "email": "akash.khichi@iqvia.com"}, {"display_name": "Dheeraj Kumar", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B425123c5-9995-4a5d-ae67-4c825197b9a0%7D"}, "avatar": {"href": "https://secure.gravatar.com/avatar/e2a94d7a51b28b982c7f152eb7701b05?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FDK-1.png"}, "html": {"href": "https://bitbucket.org/%7B425123c5-9995-4a5d-ae67-4c825197b9a0%7D/"}}, "is_active": true, "type": "user", "uuid": "{425123c5-9995-4a5d-ae67-4c825197b9a0}", "account_id": "557058:9f5175e0-4442-4e57-b0a8-5a000ac134a7", "nickname": "qi-dheerajkumar", "email": "dheeraj.kumar1@metacube.com"}], "pagelen": 3, "size": 4, "page": 1, "next": "https://bitbucket.org/api/internal/workspaces/qiesp/groups/sfdc-qi-devops/members?pagelen=3&page=2"}');
                response.setStatusCode(200);
                return response;
            } else {
                HttpResponse response = new HttpResponse();
                response.setHeader('Content-Type', 'application/json');
                response.setBody('{"values": [{"display_name": "Ajinkya Pande", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B06b50388-1bb3-49eb-9606-6295be7e225c%7D"}, "avatar": {"href": "https://avatar-management--avatars.us-west-2.prod.public.atl-paas.net/557058:2c27e533-d826-48ff-a5e0-649404342261/5196af67-dbc3-4621-bffd-ed49016079cd/128"}, "html": {"href": "https://bitbucket.org/%7B06b50388-1bb3-49eb-9606-6295be7e225c%7D/"}}, "is_active": true, "type": "user", "uuid": "{06b50388-1bb3-49eb-9606-6295be7e225c}", "account_id": "557058:2c27e533-d826-48ff-a5e0-649404342261", "nickname": "qi-ajinkyapande", "email": "apande@us.imshealth.com"}, {"display_name": "Akash Khichi", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de%7D"}, "avatar": {"href": "https://secure.gravatar.com/avatar/348c98ec45d4385b51eda94a7fe0492f?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FAK-6.png"}, "html": {"href": "https://bitbucket.org/%7B3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de%7D/"}}, "is_active": true, "type": "user", "uuid": "{3f5f0dcc-08b6-4e9e-985c-e78c16b1d8de}", "account_id": "637494d85fce844d60671210", "nickname": "Akash Khichi", "email": "akash.khichi@iqvia.com"}, {"display_name": "Dheeraj Kumar", "links": {"self": {"href": "https://bitbucket.org/!api/2.0/users/%7B425123c5-9995-4a5d-ae67-4c825197b9a0%7D"}, "avatar": {"href": "https://secure.gravatar.com/avatar/e2a94d7a51b28b982c7f152eb7701b05?d=https%3A%2F%2Favatar-management--avatars.us-west-2.prod.public.atl-paas.net%2Finitials%2FDK-1.png"}, "html": {"href": "https://bitbucket.org/%7B425123c5-9995-4a5d-ae67-4c825197b9a0%7D/"}}, "is_active": true, "type": "user", "uuid": "{425123c5-9995-4a5d-ae67-4c825197b9a0}", "account_id": "557058:9f5175e0-4442-4e57-b0a8-5a000ac134a7", "nickname": "qi-dheerajkumar", "email": "dheeraj.kumar1@metacube.com"}], "pagelen": 3, "size": 4, "page": 1, "next": "https://bitbucket.org/api/internal/workspaces/qiesp/groups/sfdc-qi-devops/members?pagelen=3&page=2"}');
                response.setStatusCode(200);
                return response;
            }
        }
    }
    
    @isTest
    static void testUpdateSandboxProgress() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Sandbox',
            Request_Status__c = 'Approved',
            Processing_status__c = 'In Progress',
            Sandbox_Name__c = 'DEVOPSxAK',
            Organization__c = 'IQVIA',
            Requested_For__c = 'Test_User'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(WebServiceMock.class, new TST_BCH_DevOps_RequestProgress.CallOutMockDeleteMetadata());
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.SandboxInfoResponse());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testUpdateSandboxProgressWithProccessingStatusCompleted() {
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt limit 1];
        Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c, Devops_Resource__c  from Sandbox_Allocation__mdt where Devops_Resource__c = :devopsResource.Id limit 1];
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Sandbox',
            Request_Status__c = 'In Progress',
            Processing_status__c = 'In Progress',
            Sandbox_Name__c = sandboxDataObject.DeveloperName,
            Organization__c = 'IQVIA',
            Requested_For__c = devopsResource.DeveloperName
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        // Test.setMock(WebServiceMock.class, new TST_BCH_DevOps_RequestProgress.CallOutMockDeleteMetadata());
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.SandboxInfoResponse());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testUpdateSandboxProgressWithProccessingStatusDeleted() {
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt limit 1];
        Sandbox_Allocation__mdt sandboxDataObject = [select Id,DeveloperName, Organization__c, Devops_Resource__c  from Sandbox_Allocation__mdt where Devops_Resource__c = :devopsResource.Id limit 1];
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Sandbox',
            Request_Status__c = 'In Progress',
            Processing_status__c = 'In Progress',
            Sandbox_Name__c = sandboxDataObject.DeveloperName,
            Organization__c = 'IQVIA',
            Requested_For__c = devopsResource.DeveloperName
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(WebServiceMock.class, new TST_BCH_DevOps_RequestProgress.CallOutMockDeleteMetadata());
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.SandboxInfoDeleteStatusResponse());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testUpdateJenkinsProgress200StatusCodePass() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.UpdateJenkinsProdgress200StatusCodePass());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }
    @isTest
    static void testUpdateJenkinsProgress200StatusCodeFailedBuildStatus() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.UpdateJenkinsProdgress200StatusCodeFailedBuildStatus());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testUpdateJenkinsProgress200StatusCodeFailed() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.UpdateJenkinsProdgress200StatusCodeFailed());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }
    
    @isTest
    static void testNewJenkinsFailed() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User',
            Jenkins_Queue_URI__c = '/queue/item/8342/'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.NewJenkinsRequestFailedQueueMock());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testNewJenkinsFailedProccesing() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User',
            Jenkins_Queue_URI__c = '/queue/item/8342/'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.NewJenkinsRequestFailedQueueFailedReqMock());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testNewJenkinsFailedUserCreation() {
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = 'test@mail.com',
            FirstName__c = 'Test',
            Jenkins_Roles__c = 'Developer',
            LastName__c ='User',
            Module_Name__c ='DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c ='Test_User',
            Jenkins_Queue_URI__c = '/queue/item/8341/'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.NewJenkinsRequestFailedQueueMock());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testNewBitbucketUserCreation() {
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt WHERE Email_Id__c = 'akash.khichi@iqvia.com' limit 1];
        // Create test data
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'New Bitbucket Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c = devopsResource.DeveloperName,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        insert testRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(WebServiceMock.class, new TST_BCH_DevOps_RequestProgress.CallOutMockInsertAndUpdateMetadata());
        Test.setMock(HttpCalloutMock.class, new TST_BCH_DevOps_RequestProgress.NewBitbucketRequest());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testOnBoardingRequestProgress() {
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt WHERE Email_Id__c = 'akash.khichi@iqvia.com' limit 1];
        // Create test data
        List<Devops_Request__c> childDevOpsRequest = new List<Devops_Request__c>();
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'Onboarding Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c = devopsResource.DeveloperName,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        insert testRequest;

        DevOps_Request__c testRequest1 = new DevOps_Request__c(
            Request_Type__c = 'New Bitbucket Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'Completed',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Requested_For__c = devopsResource.DeveloperName,
            Parent_Request__c = testRequest.Id,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        childDevOpsRequest.add(testRequest1);

        DevOps_Request__c testRequest2 = new DevOps_Request__c(
            Request_Type__c = 'New Jenkins Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Processing_status__c = 'Completed',
            Requested_For__c = devopsResource.DeveloperName,
            Parent_Request__c = testRequest.Id,
            Jenkins_Roles__c = 'Developer',
            Jenkins_Queue_URI__c = '/queue/item/8341/'
        );
        childDevOpsRequest.add(testRequest2);

        DevOps_Request__c testRequest3 = new DevOps_Request__c(
            Request_Type__c = 'New Sandbox',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Processing_status__c = 'Completed',
            Parent_Request__c = testRequest.Id,
            Requested_For__c = devopsResource.DeveloperName
        );
        childDevOpsRequest.add(testRequest3);
        insert childDevOpsRequest;

        // Call the batch class
        Test.startTest();
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }

    @isTest
    static void testOffBoardingRequestProgress() {
        DevOps_Resource__mdt devopsResource = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt WHERE Id IN (SELECT Devops_Resource__c FROM Sandbox_Allocation__mdt) limit 1];
        DevOps_Resource__mdt devopsResourceNotHaveChild = [Select Id, DeveloperName, MasterLabel, Language, NamespacePrefix, Label, QualifiedApiName, SystemModstamp, First_Name__c, Last_Name__c, Bitbucket_Group__c, Bitbucket_AccountId__c, Module__c, Email_Id__c from DevOps_Resource__mdt WHERE Id NOT IN (SELECT Devops_Resource__c FROM Sandbox_Allocation__mdt) limit 1];
        // Create test data
        List<Devops_Request__c> childDevOpsRequest = new List<Devops_Request__c>();
        List<Devops_Request__c> parentDevOpsRequest = new List<Devops_Request__c>();
        DevOps_Request__c testRequest = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c = devopsResource.DeveloperName,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );

        DevOps_Request__c testRequest1 = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c = devopsResourceNotHaveChild.DeveloperName,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );

        DevOps_Request__c testRequest2 = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'In Progress',
            Organization__c ='IQVIA',
            Request_Status__c ='Approved',
            Requested_For__c = devopsResourceNotHaveChild.DeveloperName,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        parentDevOpsRequest.add(testRequest);
        parentDevOpsRequest.add(testRequest1);
        parentDevOpsRequest.add(testRequest2);
        insert parentDevOpsRequest;

        DevOps_Request__c childTestRequest = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Bitbucket Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'Failed',
            Organization__c ='IQVIA',
            Request_Status__c ='Failed',
            Requested_For__c = devopsResource.DeveloperName,
            Parent_Request__c = testRequest2.Id,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        childDevOpsRequest.add(childTestRequest);
        
        DevOps_Request__c childTestRequest1 = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Bitbucket Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Processing_status__c = 'Completed',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Requested_For__c = devopsResource.DeveloperName,
            Parent_Request__c = testRequest.Id,
            Bitbucket_Group__c = 'sfdc-qi-devops'
        );
        childDevOpsRequest.add(childTestRequest1);

        DevOps_Request__c childTestRequest2 = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Jenkins Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Processing_status__c = 'Completed',
            Requested_For__c = devopsResource.DeveloperName,
            Parent_Request__c = testRequest.Id,
            Jenkins_Roles__c = 'Developer',
            Jenkins_Queue_URI__c = '/queue/item/8341/'
        );
        childDevOpsRequest.add(childTestRequest2);

        DevOps_Request__c childTestRequest3 = new DevOps_Request__c(
            Request_Type__c = 'Offboarding Sandbox Request',                                                          // Request Type
            EmailId__c = devopsResource.Email_Id__c,
            FirstName__c = 'Test',
            LastName__c ='LastName',
            Module_Name__c = 'DEVOPS',
            Organization__c ='IQVIA',
            Request_Status__c ='Completed',
            Processing_status__c = 'Completed',
            Parent_Request__c = testRequest.Id,
            Requested_For__c = devopsResource.DeveloperName
        );
        childDevOpsRequest.add(childTestRequest3);
        insert childDevOpsRequest;

        // Call the batch class
        Test.startTest();
        Test.setMock(WebServiceMock.class, new TST_BCH_DevOps_RequestProgress.CallOutMockDeleteMetadata());
        Database.executeBatch(new BCH_DevOps_RequestProgress());
        Test.stopTest();
    }
}