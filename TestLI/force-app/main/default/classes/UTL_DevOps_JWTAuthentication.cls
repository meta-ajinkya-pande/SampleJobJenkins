public class UTL_DevOps_JWTAuthentication
{

    public class TargetOrgException extends Exception {} 
    private String jwtUsername {get; set;}
    private String clientId {get; set;}
    private String jwtSigningCertificateName {get; set;}
    private String jwtHostname {get; set;}
    private String tokenEndpoint {get; set;}

    public UTL_DevOps_JWTAuthentication(String targetOrg){
        try{
            DevOps_Request_Settings__c customSettingObj= DevOps_Request_Settings__c.getValues(targetOrg);
            System.debug('org name'+customSettingObj);

            if(customSettingObj==null){
                System.debug('Target org error');
				throw new TargetOrgException('target org not found in custom setting records please contact system admin');
            }
            this.jwtUsername = customSettingObj.Salesforce_UserName__c;
            this.clientId = customSettingObj.Salesforce_ClientID__c;
            this.jwtSigningCertificateName = customSettingObj.Salesforce_CertificateName__c;
            this.jwtHostname = customSettingObj.Salesforce_HostName__c;
            this.tokenEndpoint= customSettingObj.Salesforce_TokenEndPoint__c;
            
        }catch (TargetOrgException e) { 

        }            
    }

    public String getAccessToken(){
        String accessToken='';
        try {
            Auth.JWT jwt = new Auth.JWT();
            jwt.setSub(jwtUsername);
            jwt.setAud(jwtHostname); 
            jwt.setIss(clientId);
            Auth.JWTBearerTokenExchange bearer;
            //jwt.setExp('123456');
        
            //Create the object that signs the JWT bearer token
            Auth.JWS jws = new Auth.JWS(jwt,jwtSigningCertificateName);
            String token = jws.getCompactSerialization();
        
            bearer = new Auth.JWTBearerTokenExchange(tokenEndpoint, jws); 
            System.debug('bearer -> '+bearer);
            accessToken = bearer.getAccessToken();  
        } catch (Exception e) {
            System.debug(e.getMessage());
        }
        
                
        
        return accessToken;
    }
    
}