public with sharing class BCH_DevOps_RequestProgress implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    Map<String, List<String>> metadataToupdate = new Map<String, List<String>>();
    List<Devops_Request__c> childRequestToUpdate = new List<DevOps_Request__c>();
    List<Devops_Request__c> parentRequestToUpdate = new List<DevOps_Request__c>();
    public Database.QueryLocator start(Database.BatchableContext info){ 
        String query = 'Select id, Sandbox_Name__c, Organization__c, Progress_Bar__c, Requested_For__c, Request_Type__c, Request_Status__c, Processing_status__c, Is_Sandbox_Required__c, Jenkins_Queue_URI__c, Bitbucket_Group__c FROM DevOps_Request__c WHERE (Request_Type__c = \'Onboarding Request\' or Request_Type__c = \'New Sandbox\' or Request_Type__c = \'Sandbox Refresh\' or Request_Type__c = \'New Bitbucket Request\' or Request_Type__c = \'New Jenkins Request\' or Request_Type__c = \'Offboarding Sandbox Request\' or Request_Type__c = \'Offboarding Request\' or Request_Type__c = \'Offboarding Jenkins Request\' or Request_Type__c = \'Offboarding Bitbucket Request\') AND (Request_Status__c = \'Approved\' OR Request_Status__c = \'In Progress\') AND Processing_status__c = \'In Progress\'';
        return Database.getQueryLocator(query);
    }     
    
    public void execute(Database.BatchableContext info, List<SObject> devOpsRequestList) {
        List<Devops_Request__c> partialParentRequest = new List<Devops_Request__c>();
        for(DevOps_Request__c devOpsRequest : (List<DevOps_Request__c>)devOpsRequestList){
            if (devOpsRequest.Request_Type__c == 'New Sandbox' || devOpsRequest.Request_Type__c == 'Offboarding Sandbox Request' || devOpsRequest.Request_Type__c == 'Sandbox Refresh') {
                childRequestToUpdate.add(updateSandboxProgress(devOpsRequest));
            } else if (devOpsRequest.Request_Type__c == 'New Bitbucket Request') {
                childRequestToUpdate.add(updateBitbucketProgress(devOpsRequest));
            } else if (devOpsRequest.Request_Type__c == 'New Jenkins Request' || devOpsRequest.Request_Type__c == 'Offboarding Jenkins Request') {
                childRequestToUpdate.add(updateJenkinsProgress(devOpsRequest));
            } else if (devOpsRequest.Request_Type__c == 'Onboarding Request' || devOpsRequest.Request_Type__c == 'Offboarding Request') {
                partialParentRequest.add(devOpsRequest);
            }
        }

        if (childRequestToUpdate.size() > 0) {
            Database.update(childRequestToUpdate,false);
        }

        for (DevOps_Request__c devOpsRequest : partialParentRequest) {
            parentRequestToUpdate.add(updateOnboardingAndOffboardingProgress(devOpsRequest));
        }
        
        if (parentRequestToUpdate.size() > 0) {
            Database.update(parentRequestToUpdate,false);
        }
    }     
    
    public void finish(Database.BatchableContext info){
        for (String devOpsLabel : metadataToupdate.keySet()) {
            String name = 'Devops_Resource';
            String label = devOpsLabel;
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            fieldWithValuesMap.put('Bitbucket_Group__c', metadataToupdate.get(devOpsLabel)[0]);
            fieldWithValuesMap.put('Bitbucket_AccountId__c', metadataToupdate.get(devOpsLabel)[1]);
            UTL_DevOps_MetadataInsertUpdate.handleInsertAndUpdate(name, label, fieldWithValuesMap);
        }
    }

    
    private DevOps_Request__c updateSandboxProgress(DevOps_Request__c devOpsRequest) {
        //DevOps_Request__c devOpsRequest = [Select Id, Sandbox_Name__c, Organization__c, Progress_Bar__c, Requested_For__c, Request_Type__c, Request_Status__c, Processing_status__c FROM DevOps_Request__c WHERE Id=:devOpsRequestId];
        SRV_DevOps_SalesforceRequest sandboxRequest = SRV_DevOps_SalesforceRequest.authenticateRequest(devOpsRequest.Organization__c);
        HTTPResponse response = sandboxRequest.getSandboxProgess(devOpsRequest.Sandbox_Name__c);
        if (response.getStatusCode() == 200) {
            String body = response.getBody();
            Map<String,Object> sandboxDetail = (Map<String,Object>)JSON.deserializeUntyped(body);
            List<object> sandboxRecords = (List<Object>)sandboxDetail.get('records');
            if (sandboxRecords.size() > 0) {
                Map<String,Object> sandboxRecord = (Map<String,Object>)sandboxRecords[0];
                Integer copyProgress = (Integer)sandboxRecord.get('CopyProgress');
                String status = (String) sandboxRecord.get('Status');
                if (copyProgress < 100) {
                    devOpsRequest.Progress_Bar__c = copyProgress;
                }
                if (status == 'Deleted' || status == 'Completed' || copyProgress == 100) {
                    devOpsRequest.Progress_Bar__c = 100;
                    devOpsRequest.Processing_status__c = 'Completed';
                }
                if ((status == 'Deleted' || status == 'Deleting') && copyProgress == 100) {
                    devOpsRequest.Request_Status__c = 'Completed';
                    UTL_DevOps_MetadataInsertUpdate.MetadataPort service = new UTL_DevOps_MetadataInsertUpdate.MetadataPort();
                    service.SessionHeader = new UTL_DevOps_MetadataInsertUpdate.SessionHeader_element();
                    service.SessionHeader.sessionId = UserInfo.getSessionId();

                    List<String> recordsToDelete = new List<String>();
                    recordsToDelete.add('Sandbox_Allocation.'+devOpsRequest.Sandbox_Name__c);
                    UTL_DevOps_MetadataInsertUpdate.DeleteResult[] results = service.deleteMetadata('CustomMetadata', recordsToDelete);
                }
            }
        } else if (response.getStatusCode() == 401) {
            devOpsRequest.Processing_status__c = 'In Progress'; // For Pending Sandbox
        } else {
            devOpsRequest.Failed_Reason__c = response.getBody();
            devOpsRequest.Request_Status__c	= 'Failed';
            devOpsRequest.Processing_status__c	= 'Failed';
        }
        // Creating New User for New or Refreshed Sandbox
        if (devOpsRequest.Request_Status__c == 'In Progress' && devOpsRequest.Processing_status__c == 'Completed' && (devOpsRequest.Request_Type__c == 'New Sandbox' || devOpsRequest.Request_Type__c == 'Sandbox Refresh')) {
            DevOps_Resource__mdt devOpsResource = DevOps_Resource__mdt.getInstance(devOpsRequest.Requested_For__c);
            if (devOpsResource == null) {
                devOpsRequest.Request_Status__c = 'Failed';
                devOpsRequest.Failed_Reason__c = 'Sandbox User Creation Failed due to no DevOps Resource Instance Found';
            } else {
                String firstName = devOpsResource.First_Name__c;
                String lastName = devOpsResource.Last_Name__c;
                String email = devOpsResource.Email_Id__c;
                String orgName = devOpsRequest.Organization__c;
                String sandboxName = devOpsRequest.Sandbox_Name__c;
                String profileId = SRV_DevOps_SalesforceRequest.getProfileId(orgName, sandboxName);
                JSONGenerator gen = JSON.createGenerator(true);
                gen.writeStartObject();
                gen.writeStringField('FirstName', firstName);
                gen.writeStringField('LastName', lastName);
                gen.writeStringField('Alias', firstName.substring(0, 2) + lastName.substring(0, 2));
                gen.writeStringField('Email', email);
                gen.writeStringField('Username', email+'.'+orgName+'.'+sandboxName);
                gen.writeStringField('ProfileId', profileId);
                gen.writeStringField('TimeZoneSidKey', 'Asia/Kolkata');
                gen.writeStringField('LocaleSidKey', 'en_US');
                gen.writeStringField('EmailEncodingKey', 'UTF-8');
                gen.writeStringField('LanguageLocaleKey', 'en_US');
                if (orgName == 'IQVIA') {
                    gen.writeStringField('Audit_Employee_Number_Reason__c', 'Sandbox User for '+firstName + ' ' + lastName);
                    gen.writeStringField('Change_Request_Ticket_Number__c', '123456');
                }
                gen.writeEndObject();
                response = SRV_DevOps_SalesforceRequest.createSandboxUser(orgName, sandboxName, gen.getAsString());
                if (response.getStatusCode() == 200) {
                    devOpsRequest.Request_Status__c = 'Completed';
                } else {
                    devOpsRequest.Request_Status__c = 'Failed';
                    devOpsRequest.Failed_Reason__c = response.getBody();
                }
            }
        }
        return devOpsRequest;
    }

    private DevOps_Request__c updateJenkinsProgress(DevOps_Request__c devOpsRequest) {
        SRV_DevOps_Jenkins jenkinsAuth = SRV_DevOps_Jenkins.authenticateJenkins(devOpsRequest.Organization__c);
        HttpResponse response = jenkinsAuth.getQueueProgress(devOpsRequest.Jenkins_Queue_URI__c);
        if (response.getStatusCode() == 200) {
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            Map<String,Object> executable = (Map<String,Object>)body.get('executable');
            String url = (String)executable.get('url');
            response = jenkinsAuth.getBuildProgress(url);
            if (response.getStatusCode() == 200) {
                body = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                String result = (String) body.get('result');
                if (result == 'SUCCESS') {
                    devOpsRequest.Request_Status__c = 'Completed';
                    devOpsRequest.Processing_status__c = 'Completed';
                    devOpsRequest.Progress_Bar__c = 100;
                } else {
                    devOpsRequest.Request_Status__c = 'Failed';
                    devOpsRequest.Processing_status__c = 'Failed';
                    devOpsRequest.Failed_Reason__c = 'Jenkins User Creation Failed';
                }
            } else {
                devOpsRequest.Request_Status__c = 'Failed';
                devOpsRequest.Processing_status__c = 'Failed';
                devOpsRequest.Failed_Reason__c = 'Jenkins Unable to fetch Status From Build';
            }
        } else if(response.getStatusCode() == 404) {
            response = jenkinsAuth.getBuildRecords();
            if (response.getStatusCode() == 200) {
                Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                List<Object> builds = (List<Object>) body.get('builds');
                for (Object buildObj : builds) {
                    Map<String,Object> build = (Map<String,Object>) buildObj;
                    if (devOpsRequest.Jenkins_Queue_URI__c == '/queue/item/'+build.get('queueId')+'/') {
                        response = jenkinsAuth.getBuildProgress((String)build.get('url'));
                        if (response.getStatusCode() == 200) {
                            body = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
                            String result = (String) body.get('result');
                            if (result == 'SUCCESS') {
                                devOpsRequest.Request_Status__c = 'Completed';
                                devOpsRequest.Processing_status__c = 'Completed';
                                devOpsRequest.Progress_Bar__c = 100;
                            } else {
                                devOpsRequest.Request_Status__c = 'Failed';
                                devOpsRequest.Processing_status__c = 'Failed';
                                devOpsRequest.Failed_Reason__c = 'Jenkins User Creation Failed';
                            }
                        } else {
                            devOpsRequest.Request_Status__c = 'Failed';
                            devOpsRequest.Processing_status__c = 'Failed';
                            devOpsRequest.Failed_Reason__c = 'Jenkins Unable to fetch Status From Build';
                        }
                    }
                }
            } else {
                devOpsRequest.Request_Status__c = 'Failed';
                devOpsRequest.Processing_status__c = 'Failed';
                devOpsRequest.Failed_Reason__c = 'Jenkins Unable to fetch Status From Queue';
            }
        }
        return devOpsRequest;
    }

    private DevOps_Request__c updateBitbucketProgress(DevOps_Request__c devOpsRequest) {
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest(devOpsRequest.Organization__c);
        DevOps_Resource__mdt devOpsResource = DevOps_Resource__mdt.getInstance(devOpsRequest.Requested_For__c);
        HttpResponse response = bitbucketAuth.getAllUsersOfGroup(devOpsRequest.Bitbucket_Group__c);
        if (response.getStatusCode() == 200) {
            Map<String,Object> bitbucketUserDetail = (Map<String,Object>)JSON.deserializeUntyped(response.getBody());
            List<object> bitbucketuserRecords = (List<Object>)bitbucketUserDetail.get('values');         
            for (Object bitbucketUserRecord : bitbucketuserRecords) {
                Map<String,Object> 	userRecord = (Map<String,Object>)bitbucketUserRecord;
                if (userRecord.get('email') == devOpsResource.Email_Id__c) {
                    devOpsRequest.Request_Status__c = 'Completed';
                    devOpsRequest.Processing_status__c = 'Completed';
                    devOpsRequest.Progress_Bar__c = 100;
                    //updateBitbucketMetadata(, , );
                    List<String> metadataRecord = new List<String>();
                    metadataRecord.add(devOpsRequest.Bitbucket_Group__c);
                    metadataRecord.add((String)userRecord.get('uuid'));
                    metadataToupdate.put(devOpsResource.Label, metadataRecord);
                }
            }
        }
        return devOpsRequest;
    }

    private DevOps_Request__c updateOnboardingAndOffboardingProgress(DevOps_Request__c devOpsRequest) {
        List<DevOps_Request__c> childDevOpsRequests = [Select id, Parent_Request__c, Request_Status__c, Request_Type__c from DevOps_Request__c where Parent_Request__c=:devOpsRequest.Id];
        Boolean isRequestCompleted = true;
        Boolean isChildRequestFailed = false;
        Devops_Resource__mdt devOpsResource = Devops_Resource__mdt.getInstance(devOpsRequest.Requested_For__c);
        Boolean deleteSuccess = true;
        String errorMessage = '';
        if (childDevOpsRequests.size() == 0 && (devOpsRequest.Request_Type__c == 'Onboarding Request' && devOpsResource == null)) {
            isRequestCompleted = false;
        } else if (devOpsRequest.Request_Type__c == 'Offboarding Request') {
            devOpsResource = [Select id, (Select id FROM Sandbox_Allocation__r) from DevOps_Resource__mdt WHERE DeveloperName=:devOpsRequest.Requested_For__c];
            if (devOpsResource!= null && devOpsResource.Sandbox_Allocation__r.size() == 0) {
                UTL_DevOps_MetadataInsertUpdate.MetadataPort service = new UTL_DevOps_MetadataInsertUpdate.MetadataPort();
                service.SessionHeader = new UTL_DevOps_MetadataInsertUpdate.SessionHeader_element();
                service.SessionHeader.sessionId = UserInfo.getSessionId();

                List<String> recordsToDelete = new List<String>();
                recordsToDelete.add('Devops_Resource.'+devOpsRequest.Requested_For__c);
                UTL_DevOps_MetadataInsertUpdate.DeleteResult[] results = service.deleteMetadata('CustomMetadata', recordsToDelete);
                for (UTL_DevOps_MetadataInsertUpdate.DeleteResult result : results) {
                    if (result.errors != null && result.errors.size() > 0) {
                        deleteSuccess = false;
                        for (UTL_DevOps_MetadataInsertUpdate.Error error : result.errors) {
                            errorMessage = errorMessage + error.message;
                        }
                    }
                }
            }
        }
        for (DevOps_Request__c devOpsReqChild : childDevOpsRequests) {
            if (devOpsReqChild.Request_Status__c != 'Completed' && devOpsReqChild.Request_Status__c != 'Failed') {
                isRequestCompleted = false;
            } else if (devOpsReqChild.Request_Status__c == 'Failed') {
                isChildRequestFailed = true;
            }
        }

        if (isRequestCompleted && !isChildRequestFailed && errorMessage == '') {
            devOpsRequest.Request_Status__c = 'Completed';
            devOpsRequest.Processing_status__c = 'Completed';
            devOpsRequest.Progress_Bar__c = 100;
        } else if (isChildRequestFailed) {
            devOpsRequest.Request_Status__c = 'Failed';
            devOpsRequest.Processing_status__c = 'Failed';
            devOpsRequest.Failed_Reason__c = 'Child Record Failed';
        } else if (!isRequestCompleted && childDevOpsRequests.size() == 0) {
            devOpsRequest.Request_Status__c = 'Failed';
            devOpsRequest.Processing_status__c = 'Failed';
            devOpsRequest.Failed_Reason__c = 'DevOps Resource Configration Failed';
        } else if(errorMessage != '') {
            devOpsRequest.Request_Status__c = 'Failed';
            devOpsRequest.Processing_status__c = 'Failed';
            devOpsRequest.Failed_Reason__c = errorMessage;
        }
        return devOpsRequest;
    }
}