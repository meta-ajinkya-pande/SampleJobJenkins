/**
* Batch to remove MFA permission set assignment from users.
*/ 
public class BCH_Devops_PostSandboxCreationActivities implements Database.Batchable<Sobject>,Database.Stateful {
	public Database.QueryLocator start(Database.BatchableContext context) {
      	String permSetId = [SELECT Id FROM PermissionSet WHERE Label = '	Multi-Factor Authentication for UI Login' LIMIT 1].Id;
      	String query = '';
      	If (permSetId != null) {
            query = 'SELECT Id from PermissionSetAssignment WHERE PermissionSetId = : ' + permSetId + ' AND AssigneeId';
            if(Test.isRunningTest()){
            	query += ' LIMIT 1';
        	}
      	}
        System.debug(query);
        return Database.getQueryLocator(query);
    }
    
    
    public void execute(Database.BatchableContext context, list<PermissionSetAssignment> records) {
        try {
        	delete records;
        } catch(Exception e) {
            System.debug(e.getMessage());
        }
    }
    
    public void finish(Database.BatchableContext context) {     
    }
}