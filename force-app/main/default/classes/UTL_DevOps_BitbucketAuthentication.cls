public class UTL_DevOps_BitbucketAuthentication {
    public class AuthenticationException extends Exception {} 
	private String clientId; 
    private String clientSecret;
    DevOps_Request_Settings__c devopsAuthSettingObj;
    
	public UTL_DevOps_BitbucketAuthentication(String orgName) 
    {
        devopsAuthSettingObj = DevOps_Request_Settings__c.getValues(orgName);

		clientId = devopsAuthSettingObj.Bitbucket_Client_ID__c;
     	clientSecret = devopsAuthSettingObj.Bitbucket_Client_Secret__c;
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

    public String getAccessToken() {
        String accessToken = '';
        Map<String, String> bodyParameters = new Map<String,String>();
        bodyParameters.put('client_id',this.clientId);
        bodyParameters.put('client_secret',this.clientSecret);
        bodyParameters.put('grant_type','client_credentials');
        try{
            Http h = new Http();
            HttpRequest authReq = new HttpRequest();
            authReq.setEndpoint(devopsAuthSettingObj.Bitbucket_TokenEndpoint__c);
            authReq.setMethod('POST');
            authReq.setTimeout(120000);
            authReq.setBody(getDataString(bodyParameters));
            HttpResponse res = h.send(authReq);
            
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            
            if(res.getStatusCode() == 200){
                accessToken = (String) results.get('access_token');
            }
            else{
                throw new AuthenticationException('Authentication Error, Please contact your System Administrator.');
            }
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        return accessToken;
    }
}