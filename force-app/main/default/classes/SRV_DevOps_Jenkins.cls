public with sharing class SRV_DevOps_Jenkins {
    private static SRV_DevOps_Jenkins instance = null;
    DevOps_Request_Settings__c devopsAuthSettingObj;
    private String authHeader;
    

    private SRV_DevOps_Jenkins(String organization) {
        try {
            devopsAuthSettingObj = DevOps_Request_Settings__c.getValues(organization);
            authHeader = createAuthHeader(devopsAuthSettingObj.Jenkins_Username__c, devopsAuthSettingObj.Jenkins_API_Key__c);
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    public static SRV_DevOps_Jenkins authenticateJenkins(String organization){
        if(instance == null) {
            instance = new SRV_DevOps_Jenkins(organization);
        }
        else{
            System.debug('no new object created');
        }
        return instance;
    }
    
    private static String createAuthHeader(String username, String apiToken) {
        String credentials = username + ':' + apiToken;
        Blob credentialsBlob = Blob.valueOf(credentials);
        return EncodingUtil.base64Encode(credentialsBlob);
    }

    public HttpResponse createJenkinsUser(String username,String jenkinsPassword,String email,String fullName,String projectRole,String globalRole){
        String apiEndpoint = devopsAuthSettingObj.Jenkins_Endpoint__c+'/job/test1/buildWithParameters?';
        String queryParam = 'username='+username+'&email='+email+'&fullName='+fullName+'&password='+jenkinsPassword+'&projectRoles='+projectRole+'&globalRole='+globalRole;
        System.debug(queryParam);
        HttpRequest req= new HttpRequest();
        req.setEndpoint(apiEndpoint+queryParam.replace(' ', '%20') );
        System.debug('query -> '+queryParam);
        System.debug('endpoint -> '+apiEndpoint+queryParam.replace(' ', '%20'));
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Content-Length', '0');
        req.setHeader('Authorization', 'Basic '+authHeader);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public HttpResponse getQueueProgress(String uri) {
        String apiEndpoint = devopsAuthSettingObj.Jenkins_Endpoint__c+uri+'api/json';
        System.debug('Endpoints getQueueProgress -> '+apiEndpoint);

        HttpRequest req= new HttpRequest();
        req.setEndpoint(apiEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic '+authHeader);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public HttpResponse getBuildProgress(String url) {
        String apiEndpoint = url+'api/json';
        HttpRequest req= new HttpRequest();
        System.debug('Endpoints -> '+apiEndpoint);
        req.setEndpoint(apiEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic '+authHeader);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public HttpResponse getBuildRecords() {
        String buildName = devopsAuthSettingObj.Jenkins_BuildName__c;
        String apiEndpoint = devopsAuthSettingObj.Jenkins_Endpoint__c+'/job/'+buildName+'/api/json?tree=builds[queueId,url]';
        HttpRequest req= new HttpRequest();
        req.setEndpoint(apiEndpoint);
        req.setMethod('GET');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic '+authHeader);
        HttpResponse resp = new Http().send(req);
        return resp;
    }

    public HttpResponse removeUser(String userName) {
        String apiEndpoint = devopsAuthSettingObj.Jenkins_Endpoint__c+'/user/'+userName+'/doDelete';
        HttpRequest req = new HttpRequest();
        req.setEndpoint(apiEndpoint);
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Basic '+authHeader);
        HttpResponse resp = new Http().send(req);
        return resp;
    }
}