public with sharing class CNT_DevOps_DevOpsRequest {
  //public SRV_DevOps_SalesforceRequest allSandboxes;
  public CNT_DevOps_DevOpsRequest() {}

  public with sharing class SandboxName {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }

    public SandboxName(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  public with sharing class UserAllocatedSandboxName {
    @AuraEnabled
    public String defaultSandboxName { get; set; }
    @AuraEnabled
    public Map<String, Sandbox_Allocation__mdt> allocatedSandbox { get; set; }

    public UserAllocatedSandboxName(String defaultSandboxName, Map<String, Sandbox_Allocation__mdt> allocatedSandbox) {
      this.defaultSandboxName = defaultSandboxName;
      this.allocatedSandbox = allocatedSandbox;
    }
  }

  public with sharing class DevOpsResourceMetadata {
    @AuraEnabled
    public List<Devops_Resource__mdt> teamdata;
    @AuraEnabled
    public Module__mdt teamModuleData;
    public DevOpsResourceMetadata(List<Devops_Resource__mdt> teamdata, Module__mdt teamModuleData) {
      this.teamdata = teamdata;
      this.teamModuleData = teamModuleData;
    }
  }

  public with sharing class SandboxListWithTypeLimit {
    @AuraEnabled
    public UTL_DevOps_SandboxJSON2Apex sandbox;
    @AuraEnabled
    public DevOps_Request_Settings__c sandboxTypeLimit;
    public SandboxListWithTypeLimit(UTL_DevOps_SandboxJSON2Apex sandbox, DevOps_Request_Settings__c sandboxTypeLimit) {
      this.sandbox = sandbox;
      this.sandboxTypeLimit = sandboxTypeLimit;
    }
  }

  @AuraEnabled(Cacheable=true)
  public static DevOpsResourceMetadata fetchMetadataDetail() {
    
    String currentEmail = UserInfo.getUserEmail();
    Map<String, Module__mdt> moduleMap = Module__mdt.getAll();
    Boolean isLead = false;
    String resourceModule;
    for(Module__mdt module: moduleMap.values()) {
      if(module.Lead_Email__c == currentEmail){
        isLead = true;
        resourceModule = module.Label;
        break;
      }
    }
    Map<String, Devops_Resource__mdt> devopsResourceMap = Devops_Resource__mdt.getAll();
    List<Devops_Resource__mdt> teamData = new List<Devops_Resource__mdt>();
    Module__mdt moduleLeadData = Module__mdt.getInstance(resourceModule);
    
    for (Devops_Resource__mdt devopsResource : devopsResourceMap.values()) {
      if(isLead && devopsResource.Module__c == moduleLeadData.Id) {
        teamData.add(devopsResource);
      } else if(!isLead && devopsResource.Email_Id__c == currentEmail) {
        teamData.add(devopsResource);
        moduleLeadData = Module__mdt.getInstance(devopsResource.Module__c);
      }
    }
    DevOpsResourceMetadata devopsResourceMdt = new DevOpsResourceMetadata(teamData, moduleLeadData);
    return devopsResourceMdt;
  }

  @AuraEnabled(Cacheable=true)
  public static UserAllocatedSandboxName getUserAllocatedSandboxName(String selectedUsername, String Organization) {
    UserAllocatedSandboxName userAllocatedSandboxName;
    Devops_Resource__mdt currentDevopsResource = Devops_Resource__mdt.getInstance(selectedUsername);
    List<Sandbox_Allocation__mdt> sandboxAllocationList = Sandbox_Allocation__mdt.getAll().values();
    Map<String, Sandbox_Allocation__mdt> allocatedSandbox= new Map<String, Sandbox_Allocation__mdt>();
    for(Sandbox_Allocation__mdt SandboxAllocation: sandboxAllocationList) {
      if(SandboxAllocation.Devops_Resource__c == currentDevopsResource.Id && SandboxAllocation.Organization__c == Organization) {
        allocatedSandbox.put(SandboxAllocation.Label, SandboxAllocation);
      }
    }
    String fName = currentDevopsResource.First_Name__c;
    String lName = currentDevopsResource.Last_Name__c;
    String module = Module__mdt.getInstance(currentDevopsResource.Module__c).Label;
    String newSandboxName = module + 'x' + fName.substring(0, 1) + lName.substring(0, 1); //DevOpsxRS
    userAllocatedSandboxName = new UserAllocatedSandboxName(newSandboxName, allocatedSandbox);
    return userAllocatedSandboxName;
  }
  
  @AuraEnabled(Cacheable=true)
  public static SandboxListWithTypeLimit getAllSanboxes(String orgName) {
    try {
      DevOps_Request_Settings__c orgLimit = [select DevloperPro_SandboxType_Limit__c,Devloper_SandboxType_Limit__c, Full_SandboxType_Limit__c, Partial_SandboxType_Limit__c from DevOps_Request_Settings__c where Name = :orgName];

      SRV_DevOps_SalesforceRequest allSandboxes = SRV_DevOps_SalesforceRequest.authenticateRequest(orgName);
      String sandboxesJSON = allSandboxes.getAllSandboxes();
      UTL_DevOps_SandboxJSON2Apex sandboxes = UTL_DevOps_SandboxJSON2Apex.parse(sandboxesJSON);
      //DevOpsRequestOrgLimit__c orgLimit = DevOpsRequestOrgLimit__c.getInstance(orgName);
      System.debug('org limit -> '+new SandboxListWithTypeLimit(sandboxes, orgLimit).sandboxTypeLimit);
      return new SandboxListWithTypeLimit(sandboxes, orgLimit);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(Cacheable=true)
  public static List<Module__mdt> getAllModule() {
    try {
      List<Module__mdt> moduleList = Module__mdt.getAll().values();
      return moduleList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled(Cacheable=true)
  public static List<DevOps_Resource__mdt> getAllDevopsResource(){
    try {
      List<Devops_Resource__mdt> devOpsResourceList = Devops_Resource__mdt.getAll().values();
      return devOpsResourceList;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }

  @AuraEnabled
  public static String getClassId(String className, String sourceSandboxName, String orgName) {
    try {
      String classId = SRV_DevOps_SalesforceRequest.getClassIdByClassNameAndOrg(className, orgName, sourceSandboxName);
      return classId;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
  }
}