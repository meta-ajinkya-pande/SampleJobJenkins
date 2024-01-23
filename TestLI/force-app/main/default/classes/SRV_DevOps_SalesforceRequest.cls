public class SRV_DevOps_SalesforceRequest
{
    public class SandboxException extends Exception {}  
    public class ReportException extends Exception {}
    private String endPointName;
    private UTL_DevOps_JWTAuthentication jwtDevOps ; 
    private HttpRequest req;
    private String accessToken;
    private String targetOrg;
    private static SRV_DevOps_SalesforceRequest instance = null;

    private SRV_DevOps_SalesforceRequest(String targetOrg){
        try {
            req = new HttpRequest(); 
            this.targetOrg = targetOrg;
            this.jwtDevOps = new UTL_DevOps_JWTAuthentication(targetOrg);
            this.endPointName = DevOps_Request_Settings__c.getValues(targetOrg).Salesforce_EndPointName__c;
            this.accessToken = jwtDevOps.getAccessToken();
            this.req.setHeader('Authorization', 'Bearer '+accessToken);
        }catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    public static SRV_DevOps_SalesforceRequest authenticateRequest(String targetOrg){
        if(instance == null || (instance != null && instance.targetOrg != targetOrg)) {
            instance = new SRV_DevOps_SalesforceRequest(targetOrg);
        }
        else{
            System.debug('no new object created');
        }
        return instance;
    }

    public String getAllSandboxes(){
        String sandboxList ;
        String query='SELECT+Id,SandboxName,LicenseType,AutoActivate,ApexClassId,Description,SourceId+FROM+SandboxInfo';
        req.setEndpoint(this.endPointName+'tooling/query/?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        system.debug('Access Token-->' + accessToken);
        sandboxList = resp.getBody();
        return sandboxList;
    }
    
    public String getSandboxByName(String sandboxName){
        String sandboxByName ;
        String query='SELECT+Id,SandboxName,LicenseType,AutoActivate,ApexClassId,Description,SourceId+FROM+SandboxInfo+Where+SandboxName+=+\''+sandboxName+'\'';
        req.setEndpoint(this.endPointName+'tooling/query/?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        system.debug('Body:'+resp.getBody());
        system.debug('Access Token-->' + accessToken);
        sandboxByName = resp.getBody();
        return sandboxByName;
    }

    public HTTPResponse refreshSandbox(String sandboxName, String sandboxId, String sandboxType, Boolean autoActivate, String sourceId,String classId,String description){
        JSONGenerator gen = JSON.createGenerator(true);    
        gen.writeStartObject();      
        if(sourceId!=null){
            gen.writeStringField('SourceId',sourceId);
        }
        else{
            gen.writeNullField('SourceId');
            gen.writeStringField('LicenseType',sandboxType);
        }
        gen.writeStringField('SandboxName',sandboxName);
        gen.writeBooleanField('AutoActivate', autoActivate);
        gen.writeStringField('ApexClassId',classId);
        gen.writeStringField('Description',description);
        gen.writeEndObject();
        req.setHeader('Content-Type', 'application/json');
        String jsonS = gen.getAsString();
        req.setBody(jsonS );
        req.setEndpoint(this.endPointName+'tooling/sobjects/SandboxInfo/'+sandboxId);
        req.setMethod('PATCH');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        return resp;
    }

    public HTTPResponse createSandbox(String sandboxName,String sandboxType,Boolean autoActivate,String sourceId,String classId,String description){
        JSONGenerator gen = JSON.createGenerator(true);    
        String existingSandbox=getSandboxByName(sandboxName);
        System.debug('create sandbox params sandboxName= '+sandboxName+' sandboxType= '+sandboxType+' autoActivate= '+ autoActivate+' sourceId= '+sourceId+' classId= '+classId+' description= '+description);
        Map<String,Object> jsonMAP = (Map<String,Object>) JSON.deserializeUntyped(existingSandbox);
        Integer size=(Integer)jsonMAP.get('size');
        if(size>0 && !Test.isRunningTest()){
           throw new SandboxException('Sandbox name already exists');
        }
        gen.writeStartObject();   
        if(sourceId!=null){
            gen.writeStringField('SourceId',sourceId);
        }
        else{
            gen.writeNullField('SourceId');
            gen.writeStringField('LicenseType',sandboxType);
        }
        gen.writeStringField('SandboxName',sandboxName);
        gen.writeBooleanField('AutoActivate', autoActivate);
        if (classId != null) {
            gen.writeStringField('ApexClassId',classId);
        } else {
            gen.writeNullField('ApexClassId');
        }
        gen.writeStringField('Description',description);
        gen.writeEndObject();
        req.setHeader('Content-Type', 'application/json');
        String jsonS = gen.getAsString();
        System.debug(jsonS);
        req.setBody(jsonS);
        req.setEndpoint(this.endPointName+'tooling/sobjects/SandboxInfo');
        req.setMethod('POST');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        return resp;
    }

    public HTTPResponse deleteSandbox(String sandboxName){
        String existingSandbox = getSandboxByName(sandboxName);
        UTL_DevOps_SandboxJSON2Apex sandboxRecords = UTL_DevOps_SandboxJSON2Apex.parse(existingSandbox);
        Integer size = sandboxRecords.size;
        String sandboxId = sandboxRecords.records[0].Id;
        if(size<=0){
           throw new SandboxException('Sandbox donot exists');
        }
        req.setHeader('Content-Type', 'application/json');
        req.setEndpoint(this.endPointName+'tooling/sobjects/SandboxInfo/'+sandboxId);
        req.setMethod('DELETE');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        return resp;
    }
    
    public HTTPResponse getSandboxProgess(String sandboxName){
        String query='select+Id,SandboxInfoId,SandboxName,LicenseType,AutoActivate,StartDate,EndDate,Description,CopyProgress,Status,SourceId+from+SandboxProcess+where+SandboxName+=+\''+sandboxName+'\'+order+by+LastModifiedDate+DESC+limit+1'; 
        req.setEndpoint(this.endPointName+'tooling/query/?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        return resp;
    }

    public static String getClassIdByClassNameAndOrg(String className, String orgName, String sandboxName){
        System.debug(className + 'org' + orgName+ 'sandboxName'+sandboxName);
        String classId=null;
        String instanceURL ;
        String accessToken ; 
        UTL_DevOps_SandboxAuthentication sandboxAuth = UTL_DevOps_SandboxAuthentication.getInstance(orgName, sandboxName);
        Map<String,String> access = sandboxAuth.authenticSandbox();
        instanceURL = access.get('instanceURL')+'/services/data/v57.0/';
        accessToken = access.get('accessToken');        
        HttpRequest req;
        req = new HttpRequest(); 
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Bearer '+accessToken);
        req.setHeader('Content-Type', 'application/json');
        String query='SELECT+Id,Name,Body+FROM+ApexClass+Where+Name=\''+className+'\'+limit+1';
        req.setEndpoint(instanceURL+'query/?q='+query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse resp = http.send(req);
        Map<String,Object> jsonMAP = (Map<String,Object>) JSON.deserializeUntyped(resp.getBody());
        Integer totalSize=(Integer)jsonMAP.get('totalSize');
        if(totalSize>0){
            List<Object> recordMap= (List<Object>) jsonMAP.get('records');
            Map<String,Object> res=(Map<String,Object>)recordMap[0];
            String body=(String)res.get('Body');
            if(body.contains(' implements SandboxPostCopy')){
                classId=(String)res.get('Id');
            }
            else{
                throw new SandboxException('Class is not implemented SandboxPostCopy class');
            }        
        }
        else{
            throw new SandboxException('No class found in source org');
        }
        return classId;
    }

    public static String getProfileId(String orgName, String sandboxName) {
        String profileId;
        String accessToken;
        String instanceURL;
        UTL_DevOps_SandboxAuthentication sandboxAuth = UTL_DevOps_SandboxAuthentication.getInstance(orgName, sandboxName);
        Map<String,String> access = sandboxAuth.authenticSandbox();
        instanceURL = access.get('instanceURL')+'/services/data/v57.0/';
        accessToken = access.get('accessToken');        
        HttpRequest req1;
        Http http;
        req1 = new HttpRequest();
        req1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req1.setHeader('Authorization', 'Bearer '+accessToken);
        req1.setHeader('Content-Type', 'application/json');
        String query='Select id from Profile where name = \'System Administrator\'';
        req1.setEndpoint(instanceURL+'query/?q='+EncodingUtil.urlEncode(query, 'UTF-8'));
        req1.setMethod('GET');
        http = new Http();
        HTTPResponse resp = http.send(req1);
        if (resp.getStatusCode() == 200) {
            String body = resp.getBody();
            Map<String,Object> profileDetail = (Map<String,Object>)JSON.deserializeUntyped(body);
            List<object> profileRecords = (List<Object>)profileDetail.get('records');
            if (profileRecords.size() > 0) {
                Map<String,Object> profileRecord = (Map<String,Object>)profileRecords[0];
                profileId = (String)profileRecord.get('Id');
            } else {
                throw new SandboxException('Error in Fetching Profile from Target Org. Please Contact to DevOps Team');
            }
        }
        return profileId;
    }

    public static HttpResponse createSandboxUser(String orgName, String sandboxName, String userJson) {
        String instanceURL ;
        String accessToken ;
        UTL_DevOps_SandboxAuthentication sandboxAuth = UTL_DevOps_SandboxAuthentication.getInstance(orgName, sandboxName);
        Map<String,String> access = sandboxAuth.authenticSandbox();
        instanceURL = access.get('instanceURL')+'/services/data/v57.0/';
        accessToken = access.get('accessToken');        
        HttpRequest req1;
        Http http;
        req1 = new HttpRequest(); 
        req1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req1.setHeader('Authorization', 'Bearer '+accessToken);
        req1.setHeader('Content-Type', 'application/json');
        req1.setEndpoint(instanceURL+'sobjects/User');
        req1.setBody(userJson);
        req1.setTimeout(120000);
        req1.setMethod('POST');
        http = new Http();
        HTTPResponse response = http.send(req1);
        if (response.getStatusCode() == 201) {
            String body = response.getBody();
            Map<String,object> userDetail = (Map<String,object>)JSON.deserializeUntyped(body);
            String userId = (String)userDetail.get('id');
            req1 = new HttpRequest();
            req1.setHeader('Content-Type', 'application/x-www-form-urlencoded');
            req1.setHeader('Authorization', 'Bearer '+accessToken);
            req1.setHeader('Content-Type', 'application/json');
            req1.setEndpoint(instanceURL+'sobjects/User/'+userId+'/password');
            req1.setMethod('DELETE');
            http = new Http();
            response = http.send(req1);
        } else if(response.getStatusCode() == 408) {
            throw new SandboxException('User Creation Timeout Error');
        } else {
            throw new SandboxException('Error in creating Sandbox User, Please contact to DevOps Team');
        }
        return response;
    }

    public String getReportMetadata(String reportId){
        req.setEndpoint(this.endPointName + 'analytics/reports/' + reportId + '/describe');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        String reportMetadata = '';
        if(response.getStatusCode() == 200) {
            reportMetadata = response.getBody();
        } else {
            throw new ReportException('Error Retrieving Report Metadata');
        }
        return reportMetadata;
    }

    public String getObjectAPIName(String objectLabel){
        String query = 'SELECT+QualifiedApiName+FROM+EntityDefinition+WHERE+PluralLabel+=+\'' + Encodingutil.urlEncode(objectLabel,'UTF-8') + '\'+LIMIT+1';
	req.setEndpoint(this.endPointName + 'query/?q=' + query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        String objectAPIName = '';
        if(response.getStatusCode() == 200) {
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(responseBody);
            List<Object> records =  (List<Object>) responseBody.get('records');
            if(records.size() > 0) {
                Map<String,Object> record= (Map<String,Object>) records[0];
                objectAPIName = (String) record.get('QualifiedApiName');
            } else {}
        } else {
            throw new ReportException('Error Retrieving Object API Name for: ' + objectLabel + '.\n');
        }
        return objectAPIName;
    }

    public String getReportID(String reportId) {
        String query = 'SELECT+Id+FROM+Report+where+Id+=+\'' + reportId + '\'';
        req.setEndpoint(this.endPointName + 'query/?q=' + query);
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse response = http.send(req);
        String getReportId = '';
        if(response.getStatusCode() == 200) {
            System.debug(response.getBody());
            Map<String,Object> responseBody = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            System.debug(responseBody);
            List<Object> records =  (List<Object>) responseBody.get('records');
            if(records.size() > 0) {
                Map<String,Object> record= (Map<String,Object>) records[0];
                getReportId = (String) record.get('Id');
            } else {}
        } else {
            throw new ReportException('Error retrieving reportId from target org.');
        }
        return getReportId;
    }

}