@isTest
public with sharing class TST_UTL_DevOps_MetadataInsertUpdate {
  public with sharing class CallOutMockCreate implements WebServiceMock{
    public void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType) {      
      UTL_DevOps_MetadataInsertUpdate.createResponse_element metadataResponse = new UTL_DevOps_MetadataInsertUpdate.createResponse_element();
      UTL_DevOps_MetadataInsertUpdate.AsyncResult saveresult = new UTL_DevOps_MetadataInsertUpdate.AsyncResult();
      saveresult.done = true;
      metadataResponse.result = new List<UTL_DevOps_MetadataInsertUpdate.AsyncResult>();
      metadataResponse.result.add(saveresult);
      response.put('response_x', metadataResponse); 
    }
  }

  public with sharing class CallOutMockCheckStatus implements WebServiceMock{
    public void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType) {
      UTL_DevOps_MetadataInsertUpdate.checkStatusResponse_element metadataResponse = new UTL_DevOps_MetadataInsertUpdate.checkStatusResponse_element();
      UTL_DevOps_MetadataInsertUpdate.AsyncResult saveresult = new UTL_DevOps_MetadataInsertUpdate.AsyncResult();
      saveresult.done = true;
      metadataResponse.result = new List<UTL_DevOps_MetadataInsertUpdate.AsyncResult>();
      metadataResponse.result.add(saveresult);
      response.put('response_x', metadataResponse); 
    }
  }

  public with sharing class CallOutMockDeleteMetadata implements WebServiceMock{
    public void doInvoke(
    Object stub,
    Object request,
    Map<String, Object> response,
    String endpoint,
    String soapAction,
    String requestName,
    String responseNS,
    String responseName,
    String responseType) {
      UTL_DevOps_MetadataInsertUpdate.deleteMetadataResponse_element metadataResponse = new UTL_DevOps_MetadataInsertUpdate.deleteMetadataResponse_element();
      UTL_DevOps_MetadataInsertUpdate.DeleteResult saveresult = new UTL_DevOps_MetadataInsertUpdate.DeleteResult();
      saveresult.fullName = 'TestApp';
      saveresult.success = true;
      metadataResponse.result = new List<UTL_DevOps_MetadataInsertUpdate.DeleteResult>();
      metadataResponse.result.add(saveresult);
      response.put('response_x', metadataResponse); 
    }
  }

  @testSetup 
  static void setup() {        

  }

  @isTest
  static void testcreate(){
    String accessToken1='Authentoicate sandbox';
    String instanceURL = 'https://test.sandbox.salesforce.com';
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
    Test.startTest();
      Test.setMock(WebServiceMock.class, new TST_UTL_DevOps_MetadataInsertUpdate.CallOutMockCreate());
      UTL_DevOps_MetadataInsertUpdate.AsyncResult[] results = service.create(new List<UTL_DevOps_MetadataInsertUpdate.Metadata> { remoteSiteSettings });
      System.assertEquals(true, results[0].done);
    Test.stopTest();
  }
  @isTest
  static void testcheckStatus(){
    String accessToken1='Authentoicate sandbox';
    String instanceURL = 'https://test.sandbox.salesforce.com';
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
    Test.setMock(WebServiceMock.class, new TST_UTL_DevOps_MetadataInsertUpdate.CallOutMockCheckStatus());
    List<UTL_DevOps_MetadataInsertUpdate.AsyncResult> results ;//= service.create(new List<UTL_DevOps_MetadataInsertUpdate.Metadata> { remoteSiteSettings });
    Id resultId ='0AfD400000lDelB';
    Test.startTest();
      UTL_DevOps_MetadataInsertUpdate.AsyncResult[] checkResults = service.checkStatus(new List<string> {string.ValueOf(resultId)});
      System.assertEquals(true, checkResults[0].done);
    Test.stopTest();
  }

  @isTest
  static void testDeleteMetadata(){
    List<String> recordsToDelete = new List<String>();        
    UTL_DevOps_MetadataInsertUpdate.MetadataPort service = new UTL_DevOps_MetadataInsertUpdate.MetadataPort();
    service.SessionHeader = new UTL_DevOps_MetadataInsertUpdate.SessionHeader_element();
    service.SessionHeader.sessionId = UserInfo.getSessionId();
    recordsToDelete.add('Sandbox_Allocation.'+'TestSand');
    Test.setMock(WebServiceMock.class, new TST_UTL_DevOps_MetadataInsertUpdate.CallOutMockDeleteMetadata());
    Test.startTest();
      UTL_DevOps_MetadataInsertUpdate.DeleteResult[] results = service.deleteMetadata('CustomMetadata', recordsToDelete);
      System.assertEquals(true, results[0].success);
    Test.stopTest();
  }

  @isTest
  static void testHandleInsertAndUpdate1() {
    Map<String, Object> fieldWithValuesMap = new Map<String, Object>();
    fieldWithValuesMap.put('Field1', 'Value1');
    fieldWithValuesMap.put('Field2', 'Value2');
    Test.startTest();
      UTL_DevOps_MetadataInsertUpdate.handleInsertAndUpdate('CustomObject', 'Custom Label', fieldWithValuesMap);
      System.assertNotEquals(null, fieldWithValuesMap);
    Test.stopTest();
  }

  @isTest
  static void testHandleResult_Failure() {
    Metadata.DeployResult result = new Metadata.DeployResult();
    result.status = Metadata.DeployStatus.Failed;
    UTL_DevOps_MetadataInsertUpdate metadataInsertUpdate = new UTL_DevOps_MetadataInsertUpdate();
    Test.startTest();
      metadataInsertUpdate.handleResult(result, null);
      System.assertEquals(Metadata.DeployStatus.Failed, result.status);
    Test.stopTest();
  }

  @isTest
  static void testClasses(){
    Test.startTest();
      UTL_DevOps_MetadataInsertUpdate.PackageTypeMembers packageTypeMember = new UTL_DevOps_MetadataInsertUpdate.PackageTypeMembers();
      UTL_DevOps_MetadataInsertUpdate.DebuggingHeader_element debugHeader = new UTL_DevOps_MetadataInsertUpdate.DebuggingHeader_element();
      UTL_DevOps_MetadataInsertUpdate.LogInfo logInfo = new UTL_DevOps_MetadataInsertUpdate.LogInfo();
      UTL_DevOps_MetadataInsertUpdate.retrieveResponse_element retrieveResp = new UTL_DevOps_MetadataInsertUpdate.retrieveResponse_element();
      UTL_DevOps_MetadataInsertUpdate.DebuggingInfo_element debugInfoElement = new UTL_DevOps_MetadataInsertUpdate.DebuggingInfo_element();
      UTL_DevOps_MetadataInsertUpdate.CallOptions_element calloutOpt = new UTL_DevOps_MetadataInsertUpdate.CallOptions_element();
      UTL_DevOps_MetadataInsertUpdate.checkDeployStatus_element checkDepl = new UTL_DevOps_MetadataInsertUpdate.checkDeployStatus_element();
      UTL_DevOps_MetadataInsertUpdate.Error errorObj = new UTL_DevOps_MetadataInsertUpdate.Error();
      UTL_DevOps_MetadataInsertUpdate.ExtendedErrorDetails errordetail = new UTL_DevOps_MetadataInsertUpdate.ExtendedErrorDetails();
      System.assertNotEquals(null, errordetail);
    Test.stopTest();
  }                    
}