// Wrapper Class to parse Json String of Sandboxes Info
public class UTL_DevOps_SandboxJSON2Apex {
  @AuraEnabled
  public Integer size;
  @AuraEnabled
  public Integer totalSize;
  @AuraEnabled
  public Boolean done;
  @AuraEnabled
  public String queryLocator;
  @AuraEnabled
  public String entityTypeName;
  @AuraEnabled
  public List<Records> records;

  public class Attributes {
    public String type;
    public String url;
  }

  public class Records {
    @AuraEnabled
    public Attributes attributes;
    @AuraEnabled
    public String Id;
    @AuraEnabled
    public String SandboxName;
    @AuraEnabled
    public String LicenseType;
    @AuraEnabled
    public Boolean AutoActivate;
    @AuraEnabled
    public String ApexClassId;
    @AuraEnabled
    public String Description;
    @AuraEnabled
    public String SourceId;
  }

  public static UTL_DevOps_SandboxJSON2Apex parse(String json) {
    return (UTL_DevOps_SandboxJSON2Apex) System.JSON.deserialize(json, UTL_DevOps_SandboxJSON2Apex.class);
  }
}