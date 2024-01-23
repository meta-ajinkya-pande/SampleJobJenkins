public without sharing class UTL_DevOps_SandboxAuthentication {
    public class AuthenticationException extends Exception {} 
    private static UTL_DevOps_SandboxAuthentication instance;
    private String targetOrg;
    private String endpoint;
    private String username;
    private String password;
    private String clientId ;
    private String clientSecret ;
    Sandbox_Allocation__mdt sandboxAllocation;

    
    private UTL_DevOps_SandboxAuthentication(String orgName, String targetOrg) {
        this.targetOrg = targetOrg;
        DevOps_Request_Settings__c devopsAuthSettingObj = DevOps_Request_Settings__c.getValues(orgName);
        if(devopsAuthSettingObj != null){
            this.clientId = devopsAuthSettingObj.Sandbox_ClientID__c;
            this.clientSecret = devopsAuthSettingObj.Sandbox_Client_Secrate__c;
        }
        if (targetOrg == 'Production') {
            sandboxAllocation = Sandbox_Allocation__mdt.getInstance(orgName+'_'+targetOrg);
            if(sandboxAllocation != null) {
                this.username = sandboxAllocation.Username__c;
                this.endpoint = 'https://login.salesforce.com';
            }
        } else {
            sandboxAllocation = Sandbox_Allocation__mdt.getInstance(targetOrg);
            if(sandboxAllocation != null){
                this.username = sandboxAllocation.Username__c+'.'+targetOrg;
                this.endpoint = 'https://test.salesforce.com';
            }
        }
        if(sandboxAllocation != null){
            this.password = sandboxAllocation.PasswordWithTocken__c;
        }
        System.debug('UTL Sandbox '+ sandboxAllocation);
    }

    private String getDataString(Map<String, String> params) {
        String result = '';
        boolean first = true;
        for(String entry : params.keySet()){
            if (first)
                first = false;
            else
                result = result + '&';
            result = result + EncodingUtil.urlEncode(entry, 'UTF-8');
            result = result + '=';
            result = result + EncodingUtil.urlEncode(params.get(entry), 'UTF-8');
        }    
        return result;
    }

    public static UTL_DevOps_SandboxAuthentication getInstance(String orgName, String targetOrg) {
        if(instance == null || (instance != null && instance.targetOrg != targetOrg)) {
            instance = new UTL_DevOps_SandboxAuthentication(orgName, targetOrg);
        }
        else{
            System.debug('no new object created');
        }
        return instance;
    }

    public Map<String, String> authenticSandbox(){
        String accessToken='';
        String instanceURL='';
        Map<String, String> params1 = new Map<String,String>();
        params1.put('username',this.username);
        params1.put('password',this.password);
        params1.put('client_id',this.clientId);
        params1.put('client_secret',this.clientSecret);
        params1.put('grant_type','password');

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Accept','application/json');
        req.setEndpoint(this.endpoint+'/services/oauth2/token');
        req.setMethod('POST');
        req.setTimeout(120000);
        req.setBody(getDataString(params1));
        HttpResponse res = h.send(req);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
        Map<String,String> JSONResponse = new Map<String,String>();

        if(res.getStatusCode() == 200){
            accessToken = (String)results.get('access_token');
            instanceURL = (String)results.get('instance_url');
            JSONResponse.put('accessToken', accessToken);
            JSONResponse.put('instanceURL', instanceURL);
            checkAndCreateRemoteSiteSetting(instanceURL);
        }
        else{
            throw new AuthenticationException('Authentication error please contact system admin');
        }
        
        return JSONResponse;
    }
    
    public void checkAndCreateRemoteSiteSetting(String instanceURL){
        String accessToken1='';
        Map<String, String> params1 = new Map<String,String>();
        DevOps_Request_Settings__c customSettingObj = [select Username__c,PasswordWithToken__c from DevOps_Request_Settings__c limit 1];

        params1.put('username',customSettingObj.Username__c);
        params1.put('password',customSettingObj.PasswordWithToken__c);
        params1.put('client_id',this.clientId);
        params1.put('client_secret',this.clientSecret);
        params1.put('grant_type','password');
        Http h = new Http();
        HttpRequest authReq = new HttpRequest();
        authReq.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        authReq.setHeader('Accept','application/json');
        authReq.setEndpoint('https://test.salesforce.com/services/oauth2/token');
        authReq.setMethod('POST');
        authReq.setTimeout(120000);
        authReq.setBody(getDataString(params1));
        HttpResponse res1 = h.send(authReq);
        Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res1.getBody());
        if(res1.getStatusCode() == 200){
            accessToken1 = (String)results.get('access_token');
            String query = 'SELECT Id,EndpointUrl FROM RemoteProxy where EndpointUrl=\''+instanceURL+'\'';//'SELECT ApexClassOrTrigger.Name, NumLinesCovered, NumLinesUncovered FROM ApexCodeCoverageAggregate ORDER BY ApexClassOrTrigger.Name ASC';
            HttpRequest req = new HttpRequest();
            System.debug('instance url==='+instanceURL);
            req.setEndpoint(Url.getSalesforceBaseUrl().toExternalForm()+'/services/data/v57.0/tooling/query?q='+EncodingUtil.urlEncode(query, 'UTF-8'));
            req.setMethod('GET');
            req.setTimeout(120000);
            req.setHeader('Authorization', 'Bearer '+accessToken1);
            Http http = new Http();
            HttpResponse res = http.send(req);
            Map<String,Object> jsonMAP = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
            Integer size=(Integer)jsonMAP.get('size');
            if(size==0){
                createRemoteSiteSettings(instanceURL, accessToken1);
            }
            else{
                System.debug('Remote Site Setting already created');
            }
        }
    }

    public static void createRemoteSiteSettings(String instanceURL, String accessToken1) {   
        String urlToParse = instanceURL;
        String url = urlToParse+'/';
        String domain = url.substringBetween('--', '.sandbox.my.salesforce.com/');
        String orgName = url.substringBetween('https://', '--');
        UTL_DevOps_MetadataInsertUpdate.MetadataPort service = new UTL_DevOps_MetadataInsertUpdate.MetadataPort();
        service.SessionHeader = new UTL_DevOps_MetadataInsertUpdate.SessionHeader_element();
        service.SessionHeader.sessionId = accessToken1;

        UTL_DevOps_MetadataInsertUpdate.RemoteSiteSetting remoteSiteSettings = new UTL_DevOps_MetadataInsertUpdate.RemoteSiteSetting();
        remoteSiteSettings.fullName = orgName + '_' + domain;
        remoteSiteSettings.url = instanceURL;
        remoteSiteSettings.description='Remote Site Setting created from Apex Class by DevOps Team';
        remoteSiteSettings.isActive=true;
        remoteSiteSettings.disableProtocolSecurity=false;
        if(!Test.isRunningTest()){
            UTL_DevOps_MetadataInsertUpdate.AsyncResult[] results = service.create(new List<UTL_DevOps_MetadataInsertUpdate.Metadata> { remoteSiteSettings });
            UTL_DevOps_MetadataInsertUpdate.AsyncResult[] checkResults = service.checkStatus(new List<string> {string.ValueOf(results[0].Id)});
        }
    }
}