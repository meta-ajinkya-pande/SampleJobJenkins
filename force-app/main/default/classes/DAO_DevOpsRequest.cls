public class DAO_DevOpsRequest {  
    public class ConfigException extends Exception {} 
    public static void beforeInsert(List<Devops_Request__c> newList) {
        List<DevOps_Request__Share> devopsRequestToShare = new List<DevOps_Request__Share>();
        for(Devops_Request__c devOpsReq : newList) {
            if(devOpsReq.Request_Status__c == 'Submitted' ) {
                Module__mdt module = Module__mdt.getInstance(devOpsReq.Module_Name__c);
                devOpsReq.Approver__c = module.Lead_User_ID__c;
            }
        }
    }
    
    public static void beforeUpdate(Map<Id, Devops_Request__c> newMap, Map<Id,Devops_Request__c> oldMap) {
        List<Devops_Request__c> devopsDataSend = new List<Devops_Request__c>();
        List<Devops_Request__c> devOpsReqToUpdate = new List<Devops_Request__c>();
        Id currentProfileId = UserInfo.getProfileId();
        Id userId = UserInfo.getUserId();
        Devops_Request_Trigger_Handler__c devopsRequestTriggerHandler = Devops_Request_Trigger_Handler__c.getInstance(userId);
        for(Devops_Request__c devOpsReq : newMap.values()) {
            if (devOpsReq.Request_Type__c == 'Data Migration' && devOpsReq.Processing_status__c != oldMap.get(devOpsReq.Id).Processing_status__c) {
                devOpsReq.Request_Status__c = devOpsReq.Processing_status__c;
            }
            List<Profile> adminProfiles = [Select id from Profile where name like 'System Admin%'];
            if (devOpsReq.Request_Status__c != oldMap.get(devOpsReq.Id).Request_Status__c && (devOpsReq.Request_Status__c == 'Approved' || devOpsReq.Request_Status__c == 'In Progress' || devOpsReq.Request_Status__c == 'In DevOps Approval')) {
                for (Profile profile : adminProfiles) {
                    if (profile.Id == currentProfileId && devopsRequestTriggerHandler != null && !devopsRequestTriggerHandler.Allow_System_Admin_Approval__c) {
                        devOpsReq.addError('System Administrator can\'t approve this request');
                    }
                }
            }
            if (devOpsReq.Request_Status__c == 'In Approval' && devOpsReq.Approver__c == devOpsReq.LastModifiedById) {
                devOpsReq.Request_Status__c = 'In DevOps Approval';
            }
            if(devOpsReq.Request_Status__c != oldMap.get(devOpsReq.Id).Request_Status__c && devOpsReq.Request_Status__c == 'Approved' ) {
                devOpsReq.Processing_status__c = 'In Progress';
            }
            if (devOpsReq.Progress_Bar__c > 0 && devOpsReq.Progress_Bar__c < 100) {
                devOpsReq.Request_Status__c = 'In Progress';
            }
        }
    }
    
    public static void beforeDelete(Map<Id,Devops_Request__c> oldMap) {}
    
    public static void afterInsert(Map<Id, Devops_Request__c> newMap) {
        List<Devops_Request__c> devopsDataSend = new List<Devops_Request__c>();
        List<Devops_Request__Share> devopsRequestToShare = new List<Devops_Request__Share>();
        Map<Id,List<Devops_Request__Share>> devopsRequestExistingSharing = new Map<Id,List<Devops_Request__Share>>();
        for (Devops_Request__Share drs : [select Id, ParentId, UserOrGroupId, AccessLevel, RowCause, LastModifiedDate, LastModifiedById, IsDeleted from DevOps_Request__Share WHERE ParentId IN :newMap.keySet()]) {
            List<Devops_Request__Share> devopsRequestShare;
            if (devopsRequestExistingSharing.containsKey(drs.ParentId)) {
                devopsRequestShare = devopsRequestExistingSharing.get(drs.ParentId);
            } else {
                devopsRequestShare = new List<Devops_Request__Share>();
            }
            devopsRequestShare.add(drs);
            devopsRequestExistingSharing.put(drs.ParentId, devopsRequestShare);
        }
        Map<String, String> devOpsRequestMap = new Map<String, String>();
        for(Devops_Request__c devOpsReq : newMap.values()) {
            Boolean isShared = false;
            for (DevOps_Request__Share exitingDevopsRequestShare : devopsRequestExistingSharing.get(devOpsReq.Id)) {
                if (exitingDevopsRequestShare.UserOrGroupId == devOpsReq.Approver__c) {
                    isShared = true;
                }
            }
            if(devOpsReq.Request_Status__c == 'Submitted' && !isShared) {
                DevOps_Request__Share tlShare= new DevOps_Request__Share();
                tlShare.ParentId = devOpsReq.Id;
                tlshare.UserOrGroupId = devOpsReq.Approver__c;
                tlshare.AccessLevel = 'edit';
                devopsRequestToShare.add(tlShare);
            }
            
            if(devOpsReq.Request_Status__c == 'Approved' && devOpsReq.Is_Child__c) {
                devopsDataSend.add(devOpsReq);
            }
        }
        
        if (devopsRequestToShare.size() > 0) {
            Database.SaveResult[] lsr = Database.insert(devopsRequestToShare,false);
            Integer i=0;
            for(Database.SaveResult sr : lsr){
                if(!sr.isSuccess()){
                    Database.Error err = sr.getErrors()[0];
                    if(!(err.getStatusCode() == StatusCode.FIELD_FILTER_VALIDATION_EXCEPTION &&  err.getMessage().contains('AccessLevel'))){
                        newMap.get(devopsRequestToShare[i].ParentId).addError('Unable to grant sharing access due to following exception: '+ err.getMessage());
                    }
                }
                i++;
            }
        }
        
        for (DevOps_Request__c devOpsReq : devopsDataSend) {
            String bool = 'false';
            if (devOpsReq.Auto_Active__c) {
                bool = 'true';
            }
            devOpsRequestMap.put('Id', devOpsReq.Id);
            devOpsRequestMap.put('requestedFor', devOpsReq.Requested_For__c);
            devOpsRequestMap.put('email', devOpsReq.EmailId__c);
            devOpsRequestMap.put('firstName', devOpsReq.FirstName__c);
            devOpsRequestMap.put('lastName', devOpsReq.LastName__c);
            devOpsRequestMap.put('module', devOpsReq.Module_Name__c);
            devOpsRequestMap.put('organization', devOpsReq.Organization__c);
            devOpsRequestMap.put('sandboxName', devOpsReq.Sandbox_Name__c);
            devOpsRequestMap.put('sandboxType', devOpsReq.Sandbox_Type__c);
            devOpsRequestMap.put('autoActivate', bool);
            devOpsRequestMap.put('sourceId', devOpsReq.SourceId__c);
            devOpsRequestMap.put('classId', devOpsReq.ClassId__c);
            devOpsRequestMap.put('createFrom', devOpsReq.Create_From__c);
            devOpsRequestMap.put('description', devOpsReq.Sandbox_Description__c);
            devOpsRequestMap.put('oldSandboxName', devOpsReq.Old_Sandbox_Name__c);
            devOpsRequestMap.put('bitbucketGroup', devOpsReq.Bitbucket_Group__c);
            devOpsRequestMap.put('jenkinsRole', devOpsReq.Jenkins_Roles__c);
            if (devOpsReq.Request_Type__c == 'New Sandbox') {
                createSandbox(devOpsRequestMap);
            } else if (devOpsReq.Request_Type__c == 'New Bitbucket Request') {
                createBitbucketUser(devOpsRequestMap);
            } else if (devOpsReq.Request_Type__c == 'New Jenkins Request') {
                createJenkinsUser(devOpsRequestMap);
            } else if (devOpsReq.Request_Type__c == 'Offboarding Sandbox Request') {
                removeSandbox(devOpsReq.Sandbox_Name__c, devOpsReq.Organization__c, devOpsReq.Id);
            } else if (devOpsReq.Request_Type__c == 'Offboarding Bitbucket Request') {
                removeBitbucketUser(devOpsRequestMap);
            } else if (devOpsReq.Request_Type__c == 'Offboarding Jenkins Request') {
                removeJenkinsUser(devOpsRequestMap);
            }
        }
    }
    
    public static void afterUpdate(Map<Id, Devops_Request__c> newMap, Map<Id,Devops_Request__c> oldMap) {
        List<Devops_Request__c> devopsDataSend = new List<Devops_Request__c>();
        List<DevOps_Request__Share> devopsRequestToShare = new List<DevOps_Request__Share>();
        Map<String, String> devOpsRequestCompletedMap = new Map<String, String>();
        for(Devops_Request__c devOpsReq : newMap.values()) {
            if(devOpsReq.Request_Status__c != oldMap.get(devOpsReq.Id).Request_Status__c && devOpsReq.Request_Status__c == 'Approved' ) {
                devopsDataSend.add(devOpsReq);
            }
        }
        Map<String, String> devOpsRequestMap = new Map<String, String>();
        List<Devops_Request__c> childDevOpsRequestlist = new List<Devops_Request__c>();
        for (DevOps_Request__c devOpsReq : devopsDataSend) {
            String bool = 'false';
            if (devOpsReq.Auto_Active__c) {
                bool = 'true';
            }
            devOpsRequestMap.put('Id', devOpsReq.Id);
            devOpsRequestMap.put('requestedFor', devOpsReq.Requested_For__c);
            devOpsRequestMap.put('email', devOpsReq.EmailId__c);
            devOpsRequestMap.put('firstName', devOpsReq.FirstName__c);
            devOpsRequestMap.put('lastName', devOpsReq.LastName__c);
            devOpsRequestMap.put('module', devOpsReq.Module_Name__c);
            devOpsRequestMap.put('organization', devOpsReq.Organization__c);
            devOpsRequestMap.put('sandboxName', devOpsReq.Sandbox_Name__c);
            devOpsRequestMap.put('sandboxType', devOpsReq.Sandbox_Type__c);
            devOpsRequestMap.put('autoActivate', bool);
            devOpsRequestMap.put('sourceId', devOpsReq.SourceId__c);
            devOpsRequestMap.put('classId', devOpsReq.ClassId__c);
            devOpsRequestMap.put('createFrom', devOpsReq.Create_From__c);
            devOpsRequestMap.put('description', devOpsReq.Sandbox_Description__c);
            devOpsRequestMap.put('oldSandboxName', devOpsReq.Old_Sandbox_Name__c);
            devOpsRequestMap.put('bitbucketGroup', devOpsReq.Bitbucket_Group__c);
            devOpsRequestMap.put('jenkinsRole', devOpsReq.Jenkins_Roles__c);
            if (devOpsReq.Request_Type__c == 'New Sandbox') {
                createSandbox(devOpsRequestMap);
            } else if (devOpsReq.Request_Type__c == 'Onboarding Request') {
                createDevOpsResourceMetadata(devOpsRequestMap);
                if (devOpsReq.Is_Sandbox_Required__c && !devOpsReq.Is_Child__c) {
                    //createSandbox(devOpsRequestMap);
                    DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                    childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                    childDevOpsRequest.Is_Child__c = true;
                    childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                    childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                    childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                    childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                    childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                    childDevOpsRequest.Request_Type__c = 'New Sandbox';
                    childDevOpsRequest.Request_Status__c = 'Approved';
                    childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                    childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                    childDevOpsRequest.Create_From__c = devOpsReq.Create_From__c;
                    childDevOpsRequest.Sandbox_Description__c = devOpsReq.Sandbox_Description__c;
                    childDevOpsRequest.Sandbox_Type__c = devOpsReq.Sandbox_Type__c;
                    childDevOpsRequest.Auto_Active__c = devOpsReq.Auto_Active__c;
                    childDevOpsRequest.SourceId__c = devOpsReq.SourceId__c;
                    childDevOpsRequest.ClassId__c = devOpsReq.ClassId__c;
                    childDevOpsRequest.Sandbox_Name__c = devOpsReq.Sandbox_Name__c;
                    childDevOpsRequest.Organization__c = devOpsReq.Organization__c;
                    childDevOpsRequest.Processing_status__c = 'In Progress';
                    childDevOpsRequestlist.add(childDevOpsRequest);
                }
                if (devOpsReq.Is_Jenkins_User__c && !devOpsReq.Is_Child__c) {
                    // createJenkinsUser(devOpsRequestMap);
                    DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                    childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                    childDevOpsRequest.Is_Child__c = true;
                    childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                    childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                    childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                    childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                    childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                    childDevOpsRequest.Request_Type__c = 'New Jenkins Request';
                    childDevOpsRequest.Request_Status__c = 'Approved';
                    childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                    childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                    childDevOpsRequest.Organization__c = devOpsReq.Organization__c;
                    childDevOpsRequest.Jenkins_Roles__c = devOpsReq.Jenkins_Roles__c;
                    childDevOpsRequest.Processing_status__c = 'In Progress';
                    childDevOpsRequestlist.add(childDevOpsRequest);
                }
                if (devOpsReq.Is_Bitbucket_User__c && !devOpsReq.Is_Child__c) {
                    //createBitbucketUser(devOpsRequestMap);
                    DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                    childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                    childDevOpsRequest.Is_Child__c = true;
                    childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                    childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                    childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                    childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                    childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                    childDevOpsRequest.Request_Type__c = 'New Bitbucket Request';
                    childDevOpsRequest.Request_Status__c = 'Approved';
                    childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                    childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                    childDevOpsRequest.Organization__c = devOpsReq.Organization__c;
                    childDevOpsRequest.Bitbucket_Group__c = devOpsReq.Bitbucket_Group__c;
                    childDevOpsRequest.Processing_status__c = 'In Progress';
                    childDevOpsRequestlist.add(childDevOpsRequest);
                }
            } else if (devOpsReq.Request_Type__c == 'Offboarding Request') {
                Devops_Resource__mdt devOpsResource = Devops_Resource__mdt.getInstance(devOpsReq.Requested_For__c);
                if (devOpsResource != null) {
                    if (devOpsReq.Is_Bitbucket_User_Offboard__c && !devOpsReq.Is_Child__c) {
                        DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                        childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                        childDevOpsRequest.Is_Child__c = true;
                        childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                        childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                        childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                        childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                        childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                        childDevOpsRequest.Request_Type__c = 'Offboarding Bitbucket Request';
                        childDevOpsRequest.Request_Status__c = 'Approved';
                        childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                        childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                        childDevOpsRequest.Organization__c = devOpsReq.Organization__c;
                        childDevOpsRequest.Bitbucket_Group__c = devOpsReq.Bitbucket_Group__c;
                        childDevOpsRequest.Processing_status__c = 'In Progress';
                        childDevOpsRequestlist.add(childDevOpsRequest);
                    } 
                    if (devOpsReq.Is_Sandbox_Offboard_Required__c && !devOpsReq.Is_Child__c && devOpsReq.Sandbox_to_remove__c != null) {
                        List<String> sandboxNameToRemove = devOpsReq.Sandbox_to_remove__c.split(';');
                        for (String sandboxName : sandboxNameToRemove) {
                            Sandbox_Allocation__mdt sandboxAllocation = Sandbox_Allocation__mdt.getInstance(sandboxName);
                            System.debug('delete sandbox ->'+sandboxAllocation.Devops_Resource__c+' id -> '+devOpsResource.Id+' prevent deletion -> '+sandboxAllocation.Prevent_Deletion__c);
                            if (sandboxAllocation.Devops_Resource__c == devOpsResource.Id && !sandboxAllocation.Prevent_Deletion__c) {
                                DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                                childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                                childDevOpsRequest.Is_Child__c = true;
                                childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                                childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                                childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                                childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                                childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                                childDevOpsRequest.Request_Type__c = 'Offboarding Sandbox Request';
                                childDevOpsRequest.Request_Status__c = 'Approved';
                                childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                                childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                                childDevOpsRequest.Organization__c = sandboxAllocation.Organization__c;
                                childDevOpsRequest.Sandbox_Name__c = sandboxAllocation.Label;
                                childDevOpsRequest.Processing_status__c = 'In Progress';
                                childDevOpsRequestlist.add(childDevOpsRequest);
                            }
                        }
                    } 
                    if (devOpsReq.Is_Jenkins_User_Offboard__c && !devOpsReq.Is_Child__c) {
                        DevOps_Request__c childDevOpsRequest = new DevOps_Request__c();
                        childDevOpsRequest.Parent_Request__c = devOpsReq.Id;
                        childDevOpsRequest.Is_Child__c = true;
                        childDevOpsRequest.Approval_Date_Time__c = devOpsReq.Approval_Date_Time__c;
                        childDevOpsRequest.Requested_For__c = devOpsReq.Requested_For__c;
                        childDevOpsRequest.EmailId__c = devOpsReq.EmailId__c;
                        childDevOpsRequest.FirstName__c = devOpsReq.FirstName__c;
                        childDevOpsRequest.LastName__c = devOpsReq.LastName__c;
                        childDevOpsRequest.Request_Type__c = 'Offboarding Jenkins Request';
                        childDevOpsRequest.Request_Status__c = 'Approved';
                        childDevOpsRequest.Approver__c = devOpsReq.Approver__c;
                        childDevOpsRequest.Module_Name__c = devOpsReq.Module_Name__c;
                        childDevOpsRequest.Organization__c = devOpsReq.Organization__c;
                        childDevOpsRequest.Processing_status__c = 'In Progress';
                        childDevOpsRequestlist.add(childDevOpsRequest);
                    }
                }
            } else if (devOpsReq.Request_Type__c == 'Sandbox Refresh') {
                refreshSandbox(devOpsRequestMap);
            } 
        }
        if (childDevOpsRequestlist.size() > 0) {
            insert childDevOpsRequestlist;
        }
    }
    
    @future(callout=true)
    private static void createSandbox(Map<String, String> devOpsRequestMap) {
        System.debug('devops map in dao --> '+devOpsRequestMap.get('sandboxName'));
        SRV_DevOps_SalesforceRequest sandboxRequest = SRV_DevOps_SalesforceRequest.authenticateRequest(devOpsRequestMap.get('organization'));
        String sandboxName = devOpsRequestMap.get('sandboxName');
        String sandboxType = devOpsRequestMap.get('sandboxType');
        Boolean autoActivate;
        if (devOpsRequestMap.get('autoActivate') == 'false') {
            autoActivate = false;
        } else {
            autoActivate = true;
        }
        String sourceId = devOpsRequestMap.get('sourceId');
        String classId = devOpsRequestMap.get('classId');
        String description = devOpsRequestMap.get('description');
        HttpResponse response = sandboxRequest.createSandbox(sandboxName, sandboxType, autoActivate, sourceId, classId, description);
        if (response.getStatusCode() == 201) {
            String createFrom = devOpsRequestMap.get('createFrom');
            if (createFrom == 'Production') {
                createFrom = devOpsRequestMap.get('organization') + '_Production';
            }
            Sandbox_Allocation__mdt createFromSandbox = Sandbox_Allocation__mdt.getInstance(createFrom);
            String name = 'Sandbox_Allocation';
            String label = devOpsRequestMap.get('sandboxName');
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            fieldWithValuesMap.put('Devops_Resource__c', devOpsRequestMap.get('requestedFor'));
            fieldWithValuesMap.put('Organization__c', devOpsRequestMap.get('organization'));
            fieldWithValuesMap.put('Sandbox_Description__c', description);
            fieldWithValuesMap.put('Sandbox_Type__c', sandboxType);
            if (createFromSandbox != null) {
                fieldWithValuesMap.put('Username__c', createFromSandbox.Username__c);
                fieldWithValuesMap.put('PasswordWithTocken__c', createFromSandbox.PasswordWithTocken__c);
            }
            UTL_DevOps_MetadataInsertUpdate.handleInsertAndUpdate(name, label, fieldWithValuesMap);
            //added by Akash
            //String instanceUrl = 'https://' + devOpsRequestMap.get('organization') + '--' + sandboxName + '.sandbox.my.salesforce.com';
            //UTL_DevOps_SandboxAuthentication.getInstance(devOpsRequestMap.get('organization'), sandboxName).checkAndCreateRemoteSiteSetting(instanceUrl);
            
        } else {
            DevOps_Request__c devOpsReq = new DevOps_Request__c();
            devOpsReq.Id = devOpsRequestMap.get('Id');
            devOpsReq.Request_Status__c = 'Failed';
            devOpsReq.Processing_status__c = 'Failed';
            devOpsReq.Failed_Reason__c = response.getBody();
            update devOpsReq;
        }
    }
    
    @future(callout=true)
    private static void refreshSandbox(Map<String, String> devOpsRequestMap) {
        SRV_DevOps_SalesforceRequest sandboxRequest = SRV_DevOps_SalesforceRequest.authenticateRequest(devOpsRequestMap.get('organization'));
        String sandboxName = devOpsRequestMap.get('sandboxName');
        String oldSandboxName = devOpsRequestMap.get('oldSandboxName');
        UTL_DevOps_SandboxJSON2Apex sandboxObj = UTL_DevOps_SandboxJSON2Apex.parse(sandboxRequest.getSandboxByName(oldSandboxName));
        String sandboxId = sandboxObj.records[0].Id;
        String sandboxType = devOpsRequestMap.get('sandboxType');
        Boolean autoActivate;
        if (devOpsRequestMap.get('autoActivate') == 'false') {
            autoActivate = false;
        } else {
            autoActivate = true;
        }
        String sourceId = devOpsRequestMap.get('sourceId');
        String classId = devOpsRequestMap.get('classId');
        String description = devOpsRequestMap.get('description');
        HttpResponse response = sandboxRequest.refreshSandbox(sandboxName, sandboxId, sandboxType, autoActivate, sourceId, classId, description);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 202 || response.getStatusCode() == 204) {
            String createFrom = devOpsRequestMap.get('createFrom');
            if (createFrom == 'Production') {
                createFrom = devOpsRequestMap.get('organization') + '_Production';
            }
            Sandbox_Allocation__mdt createFromSandbox = Sandbox_Allocation__mdt.getInstance(createFrom);
            String name = 'Sandbox_Allocation';
            String label = sandboxName;
            Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
            fieldWithValuesMap.put('Devops_Resource__c', devOpsRequestMap.get('requestedFor'));
            fieldWithValuesMap.put('Organization__c', devOpsRequestMap.get('organization'));
            fieldWithValuesMap.put('Sandbox_Description__c', description);
            fieldWithValuesMap.put('Sandbox_Type__c', sandboxType);
            if (createFromSandbox != null) {
                fieldWithValuesMap.put('Username__c', createFromSandbox.Username__c);
                fieldWithValuesMap.put('PasswordWithTocken__c', createFromSandbox.PasswordWithTocken__c);
            }
            UTL_DevOps_MetadataInsertUpdate.handleInsertAndUpdate(name, label, fieldWithValuesMap);
            //added by Ajinkya
            //String instanceUrl = 'https://' + devOpsRequestMap.get('organization') + '--' + sandboxName + '.sandbox.my.salesforce.com';
            //UTL_DevOps_SandboxAuthentication.getInstance(devOpsRequestMap.get('organization'), sandboxName).checkAndCreateRemoteSiteSetting(instanceUrl);
        } else {
            DevOps_Request__c devOpsReq = new DevOps_Request__c();
            devOpsReq.Id = devOpsRequestMap.get('Id');
            devOpsReq.Request_Status__c = 'Failed';
            devOpsReq.Processing_status__c = 'Failed';
            devOpsReq.Failed_Reason__c = response.getBody();
            update devOpsReq;
        }
    }
    
    @future(callout=true)
    private static void createJenkinsUser(Map<String, String> devOpsRequestMap) {
        System.debug('dao create jenkins user -->'+devOpsRequestMap);
        String username = devOpsRequestMap.get('firstName').toLowerCase() + devOpsRequestMap.get('lastName').toLowerCase();
        String jenkinsPassword = devOpsRequestMap.get('firstName').toLowerCase() + devOpsRequestMap.get('lastName').toLowerCase() + '@123';
        String email = devOpsRequestMap.get('email');
        String fullName = devOpsRequestMap.get('firstName') + ' ' + devOpsRequestMap.get('lastName');
        String projectRole = devOpsRequestMap.get('module');
        String globalRole = devOpsRequestMap.get('jenkinsRole');
        String organization = devOpsRequestMap.get('organization');
        System.debug(globalRole);
        SRV_DevOps_Jenkins jenkinsAuth = SRV_DevOps_Jenkins.authenticateJenkins(organization);
        HttpResponse response = jenkinsAuth.createJenkinsUser(username, jenkinsPassword, email, fullName, projectRole, globalRole);
        if (response.getStatusCode() == 201) {
            String location  = response.getHeader('Location');
            String uri = '/queue/item/' + location.substringAfter('queue/item/');
            DevOps_Request__c devopsReq = new DevOPs_Request__c();
            devopsReq.Id = devOpsRequestMap.get('Id');
            devopsReq.Jenkins_Queue_URI__c = uri;
            update devopsReq;
        }
    }
    
    @future(callout=true)
    private static void createBitbucketUser(Map<String, String> devOpsRequestMap) {
        String groupName = devOpsRequestMap.get('bitbucketGroup');
        String email = devOpsRequestMap.get('email');
        String organization = devOpsRequestMap.get('organization');        
        SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest(organization);
        HTTPResponse response = bitbucketAuth.sendEmailInviteToNewUser(groupName, email);
        if (response.getStatusCode() != 200) {
            DevOps_Request__c devopsReq = new DevOps_Request__c();
            devopsReq.Id = devOpsRequestMap.get('Id');
            devopsReq.Request_Status__c = 'Failed';
            devopsReq.Processing_status__c = 'Failed';
            devopsReq.Failed_Reason__c = response.getBody();
            update devopsReq;
        }
    }
    
    @future
    private static void createDevOpsResourceMetadata(Map<String, String> devOpsRequestMap) {
        String name = 'Devops_Resource';
        String apiName = devOpsRequestMap.get('requestedFor');
        String label = devOpsRequestMap.get('firstName') + ' ' + devOpsRequestMap.get('lastName');
        Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
        fieldWithValuesMap.put('Email_Id__c', devOpsRequestMap.get('email'));
        fieldWithValuesMap.put('First_Name__c', devOpsRequestMap.get('firstName'));
        fieldWithValuesMap.put('Last_Name__c', devOpsRequestMap.get('lastName'));
        fieldWithValuesMap.put('Bitbucket_Group__c', devOpsRequestMap.get('bitbucketGroup'));
        fieldWithValuesMap.put('Module__c', devOpsRequestMap.get('module'));
        UTL_DevOps_MetadataInsertUpdate.handleInsertAndUpdateWithName(name, apiName, label, fieldWithValuesMap);
    }
    
    @future(callout=true)
    private static void removeSandbox(String sandboxName, String orgName, Id devOpsReqId) {
        SRV_DevOps_SalesforceRequest sandboxRequest = SRV_DevOps_SalesforceRequest.authenticateRequest(orgName);
        HttpResponse response = sandboxRequest.deleteSandbox(sandboxName);
        if (response.getStatusCode() == 200 || response.getStatusCode() == 204) {
            DevOps_Request__c devopsReq = new DevOps_Request__c();
            devopsReq.Id = devOpsReqId;
            devopsReq.Request_Status__c = 'In Progress';
            update devopsReq;
        } else {
            DevOps_Request__c devopsReq = new DevOps_Request__c();
            devopsReq.Id = devOpsReqId;
            devopsReq.Request_Status__c = 'Failed';
            devopsReq.Failed_Reason__c = response.getBody();
            update devopsReq;
        }
    }
    
    @future(callout=true)
    private static void removeBitbucketUser(Map<String, String> devOpsRequestMap) {
        DevOps_Resource__mdt devOpsResource = DevOps_Resource__mdt.getInstance(devOpsRequestMap.get('requestedFor'));
        String organization = devOpsRequestMap.get('organization');
        
        if (devOpsResource == null) {
            DevOps_Request__c devOpsReq = new DevOps_Request__c();
            devOpsReq.Id = devOpsRequestMap.get('Id');
            devOpsReq.Request_Status__c = 'Failed';
            devOpsReq.Processing_status__c = 'Failed';
            devOpsReq.Failed_Reason__c = 'DevOps Resource not found';
            update devOpsReq;
        } else if (devOpsResource.Bitbucket_AccountId__c == null || devOpsResource.Bitbucket_Group__c == null) {
            DevOps_Request__c devOpsReq = new DevOps_Request__c();
            devOpsReq.Id = devOpsRequestMap.get('Id');
            devOpsReq.Request_Status__c = 'Failed';
            devOpsReq.Processing_status__c = 'Failed';
            devOpsReq.Failed_Reason__c = 'Bitbucket configuration in DevOps Resource not found';
            update devOpsReq;
        } else {
            String bitbucketGroup = devOpsResource.Bitbucket_Group__c;
            String acountId = devOpsResource.Bitbucket_AccountId__c;
            SRV_DevOps_Bitbucket bitbucketAuth = SRV_DevOps_Bitbucket.authenticateRequest(organization);
            HttpResponse response = bitbucketAuth.removeUser(bitbucketGroup, acountId);
            if (response.getStatusCode() == 204) {
                DevOps_Request__c devOpsReq = new DevOps_Request__c();
                devOpsReq.Id = devOpsRequestMap.get('Id');
                devOpsReq.Request_Status__c = 'Completed';
                devOpsReq.Processing_status__c = 'Completed';
                devOpsReq.Progress_Bar__c = 100;
                update devOpsReq;
            } else {
                DevOps_Request__c devOpsReq = new DevOps_Request__c();
                devOpsReq.Id = devOpsRequestMap.get('Id');
                devOpsReq.Request_Status__c = 'Failed';
                devOpsReq.Processing_status__c = 'Failed';
                devOpsReq.Failed_Reason__c = response.getBody();
                update devOpsReq;
            }
        }
    }
    
    @future(callout=true)
    private static void removeJenkinsUser(Map<String, String> devOpsRequestMap) {
        DevOps_Resource__mdt devOpsResource = DevOps_Resource__mdt.getInstance(devOpsRequestMap.get('requestedFor'));
        String username = devOpsResource.First_Name__c.toLowerCase() + devOpsResource.Last_Name__c.toLowerCase();
        String organization = devOpsRequestMap.get('organization');
        SRV_DevOps_Jenkins jenkinsAuth = SRV_DevOps_Jenkins.authenticateJenkins(organization);
        HttpResponse response = jenkinsAuth.removeUser(username);
        if (response.getStatusCode() == 200) {
            DevOps_Request__c devOpsReq = new DevOps_Request__c();
            devOpsReq.Id = devOpsRequestMap.get('Id');
            devOpsReq.Request_Status__c = 'Completed';
            devOpsReq.Processing_status__c = 'Completed';
            devOpsReq.Progress_Bar__c = 100;
            update devOpsReq;
        }
    }
}