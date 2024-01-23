@isTest

public with sharing class TST_UTL_DevOps_SandboxJSON2Apex {
    
    @testSetup 
    static void setup() {
    }

    @isTest
    static void testParse(){
        Test.startTest();

        String jsonString= '{"size":3,"totalSize":3,"done":true,"queryLocator":null,"entityTypeName":"SandboxInfo","records":[{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEo9WAG"},"Id":"0GQ2K000000PEo9WAG","SandboxName":"APIUSAGE","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"to verify API Security and control . Requested from Arun James.","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEzNWAW"},"Id":"0GQ2K000000PEzNWAW","SandboxName":"CBEXxST","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":"01p2K000003yzvaQAA","Description":"Developer sandbox for Saivamshi Takkadpelly (saivamshi.takkadapelly@iqvia.com)","SourceId":null},{"attributes":{"type":"SandboxInfo","url":"/services/data/v57.0/tooling/sobjects/SandboxInfo/0GQ2K000000PEw9WAG"},"Id":"0GQ2K000000PEw9WAG","SandboxName":"CBEXxSVT1","LicenseType":"DEVELOPER","AutoActivate":false,"ApexClassId":null,"Description":"New Sandbox for CBEx team for SVT1 env setup","SourceId":null}]}';
        UTL_DevOps_SandboxJSON2Apex parseData = UTL_DevOps_SandboxJSON2Apex.parse(jsonString);
        System.debug('json object -> '+parseData.size);
        System.assertEquals(3, parseData.size);
        Test.stopTest();


    }
}