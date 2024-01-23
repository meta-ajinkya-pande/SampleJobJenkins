public class SRV_DevOps_Bitbucket {
    
    public class BitbucketException extends Exception {} 
    private String endPointName;
    //private UTL_DevOps_JWTAuthentication jwtDevOps ; 
    private UTL_DevOps_BitbucketAuthentication bitbucketAuth;
    private HttpRequest req;
    private String accessToken;
    //private String targetOrg;
    private static SRV_DevOps_Bitbucket instance = null;
    private static String workspace = 'qiesp';
    DevOps_Request_Settings__c devopsAuthSettingObj;

    
    private SRV_DevOps_Bitbucket(String orgName){
        try {
            devopsAuthSettingObj = DevOps_Request_Settings__c.getValues(orgName);
            req = new HttpRequest(); 
            this.endPointName = devopsAuthSettingObj.BitBucket_Endpoint__c;// 'https://api.bitbucket.org';
            this.bitbucketAuth = new UTL_DevOps_BitbucketAuthentication(orgName);
            this.accessToken = bitbucketAuth.getAccessToken();
            this.req.setHeader('Authorization', 'Bearer '+accessToken);
        }catch (Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public static SRV_DevOps_Bitbucket authenticateRequest(String orgName){
        if(instance == null) {
            instance = new SRV_DevOps_Bitbucket(orgName);
        }
        else{
            System.debug('Existing instance used!');
        }
        return instance;
    }
    
    // Send Email Invite to create new user along with group acccess.
    public HTTPResponse sendEmailInviteToNewUser(String groupName, String email){
        JSONGenerator bodyParameters = JSON.createGenerator(true);
        bodyParameters.writeStartObject();  
        bodyParameters.writeStringField('group_slug', groupName);
        bodyParameters.writeStringField('email', email);
            
        req.setEndpoint(this.endPointName + '/1.0/users/' + workspace + '/invitations');
        req.setBody(bodyParameters.getAsString());
        req.setMethod('PUT');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
    
    //Add existing user(by UUID or Bitbucket Username) to a Bitbucket Group.
    public String addExistingUserToAGroup(String groupName, String userName) {    
        req.setEndpoint(this.endPointName + '/1.0/groups/' + workspace + '/' + groupName + '/members/' + userName);
        req.setMethod('PUT');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res.getBody();
    }
    
    // List all user with details from a workspace
    public HTTPResponse getAllUsers() {
        req.setEndpoint(this.endPointName + '/2.0/workspaces/' + workspace + '/members?pagelen=100');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    public HTTPResponse removeUser(String groupName, String username) {
        req.setEndpoint(this.endPointName + '/1.0/workspaces/' + workspace + '/' + groupName + '/members/' + username);
        req.setMethod('DELETE');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }

    public HTTPResponse getAllUsersOfGroup(String groupName) {
        req.setEndpoint('https://bitbucket.org/api/internal/workspaces/'+workspace+'/groups/'+groupName+'/members');
        req.setMethod('GET');
        Http http = new Http();
        HTTPResponse res = http.send(req);
        return res;
    }
   
}