import { LightningElement, wire, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { CloseActionScreenEvent } from "lightning/actions";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { createRecord } from "lightning/uiRecordApi";
import DEVOPS_REQUEST from "@salesforce/schema/Devops_Request__c";
import SANDBOX_NAME from "@salesforce/schema/Devops_Request__c.Sandbox_Name__c";
import RESOURCE_NAME from "@salesforce/schema/Devops_Request__c.Requested_For__c";
import CREATE_OPTIONS from "@salesforce/schema/Devops_Request__c.Create_From__c";
import REQUEST_TYPE from "@salesforce/schema/Devops_Request__c.Request_Type__c";
import REQUEST_STATUS from "@salesforce/schema/Devops_Request__c.Request_Status__c";
import ORGANIZATION from "@salesforce/schema/Devops_Request__c.Organization__c";
import SANDBOX_DESCRIPTION from "@salesforce/schema/Devops_Request__c.Sandbox_Description__c";
import POST_ACTIVITY_APEXCLASS from "@salesforce/schema/Devops_Request__c.Post_Activity_Apex_Class__c";
import AUTO_ACTIVE from "@salesforce/schema/Devops_Request__c.Auto_Active__c";
import IS_SANDBOX_REQUIRED from "@salesforce/schema/Devops_Request__c.Is_Sandbox_Required__c";
import IS_JENKINS_USER from "@salesforce/schema/Devops_Request__c.Is_Jenkins_User__c";
import IS_BITBUCKET_USER from "@salesforce/schema/Devops_Request__c.Is_Bitbucket_User__c";
import JENKINS_ROLES from "@salesforce/schema/Devops_Request__c.Jenkins_Roles__c";
import BITBUCKET_GROUP from "@salesforce/schema/Devops_Request__c.Bitbucket_Group__c";
import OLD_SANDBOX_NAME from "@salesforce/schema/Devops_Request__c.Old_Sandbox_Name__c";
import MODULE_NAME from "@salesforce/schema/Devops_Request__c.Module_Name__c";
import SOURCE_ORG from "@salesforce/schema/Devops_Request__c.Source_Org__c";
import TARGET_ORG from "@salesforce/schema/Devops_Request__c.Target_Org__c";
import SANDBOX_TYPE from "@salesforce/schema/Devops_Request__c.Sandbox_Type__c";
import CLASS_ID from "@salesforce/schema/Devops_Request__c.ClassId__c";
import SOURCE_ID from "@salesforce/schema/Devops_Request__c.SourceId__c";
import FIRST_NAME from "@salesforce/schema/Devops_Request__c.FirstName__c";
import LAST_NAME from "@salesforce/schema/Devops_Request__c.LastName__c";
import EMAIL_ID from "@salesforce/schema/Devops_Request__c.EmailId__c";
import getUserAllocatedSandboxName from "@salesforce/apex/CNT_DevOps_DevOpsRequest.getUserAllocatedSandboxName";
import getAllModule from "@salesforce/apex/CNT_DevOps_DevOpsRequest.getAllModule";
import metadataDetails from "@salesforce/apex/CNT_DevOps_DevOpsRequest.fetchMetadataDetail";
import getAllDevopsResource from "@salesforce/apex/CNT_DevOps_DevOpsRequest.getAllDevopsResource";
import getAllSandboxes from "@salesforce/apex/CNT_DevOps_DevOpsRequest.getAllSanboxes";
import getClassId from "@salesforce/apex/CNT_DevOps_DevOpsRequest.getClassId";
import IS_SANDBOX_OFFBOARD_REQUIRED from "@salesforce/schema/Devops_Request__c.Is_Sandbox_Offboard_Required__c";
import IS_JENKINS_USER_OFFBOARD from "@salesforce/schema/Devops_Request__c.Is_Jenkins_User_Offboard__c";
import IS_BITBUCKET_USER_OFFBOARD from "@salesforce/schema/Devops_Request__c.Is_Bitbucket_User_Offboard__c";
import SANDBOX_TO_REMOVE from "@salesforce/schema/Devops_Request__c.Sandbox_to_remove__c";

export default class ComboboxBasic extends NavigationMixin(LightningElement) {
  @api isLoaded = false;
  showFirstPage = true;
  showNextButton = true;
  isChecked = true;

  selectedSandboxValue;
  requestTypeChange;
  sandboxtype;
  sandboxName;
  createFrom;
  resourceName;
  sandboxDescription;
  moduleName;
  isLead;
  orgName;
  allSandboxMap;
  allocatedSandBoxes;
  allocatedSandboxMap;
  sourceOrg;
  targetOrg;
  isJenkinsUserRequired;
  isBitbucketUserRequired;
  isSandboxRequired;
  bitbucketRole;
  jenkinsRole;
  classId;
  sourceId;
  disabledSubmitButton;
  firstName;
  lastName;
  email;
  moduleName;
  allDevOpsResource;
  isSandboxRemove;
  isBitbucketUserRemove;
  isJenkinsUserRemove;
  sandboxToRemove;
  
  orgOptions = [];
  teamResourcesOptions = [];
  allocatedSandboxesOptions = [];
  moduleOptions = [];
  sandboxOptions = [];
  sandboxtypes = [];
  sourceOrgOptions = [];
  targetOrgOptions = [];

  get options() {
    return [
      { label: "Sandbox Refresh", value: "Sandbox Refresh" },
      { label: "New Sandbox", value: "New Sandbox" },
      { label: "Onboarding Request", value: "Onboarding Request" },
      { label: "Offboarding Request", value: "Offboarding Request" },
      { label: "Data Migration", value: "Data Migration" }
    ];
  }

  orgOptions = [
    { label: "IQVIA", value: "IQVIA" },
    { label: "Legacy IMS", value: "Legacy IMS" },
    { label: "Legacy Quintiles", value: "Legacy Quintiles" }
  ];

  jenkinsRoleOptions = [
    { label: "View", value: "JenkinsView" },
    { label: "Developer", value: "Developer" },
    { label: "Administrator", value: "Administrator" }
  ];

  bitbucketRoleOptions = [
    { label: "sfdc qi CDA", value: "sfdc-qi-cda" },
    { label: "sfdc qi CLM", value: "sfdc-qi-clm" },
    { label: "sfdc qi CPQ", value: "sfdc-qi-cpq" },
    { label: "sfdc qi CRM", value: "sfdc-qi-crm" },
    { label: "sfdc qi CSM", value: "sfdc-qi-csm" },    
    { label: "sfdc qi OWF", value: "sfdc-qi-owf" },
    { label: "sfdc qi PEP", value: "sfdc-qi-pep" },
    { label: "sfdc qi PSA", value: "sfdc-qi-psa" },
    { label: "sfdc qi TPA", value: "sfdc-qi-tpa" },
    { label: "sfdc qi DevOps", value: "sfdc-qi-devops" },
    { label: "sfdc Test Automation Dev", value: "sfdc-test-automation-dev" }
  ];

  getSandboxListFromSandboxType(sandboxType) {
    let sandboxList = [];
    this.allSandboxMap.records.forEach((sandbox) => {
      if(sandbox.LicenseType == sandboxType){
        let sandboxobj = {};
        sandboxobj.label = sandbox.SandboxName;
        sandboxobj.value = sandbox.SandboxName;
        sandboxList.push(sandboxobj);
      } 
    });
    sandboxList.push({label : 'Production', value: 'Production'});
    return sandboxList;
  }

  getAllSandboxList() {
    let sandboxList = [];
    this.allSandboxMap.records.forEach((sandbox) => {
      let sandboxobj = {};
      sandboxobj.label = sandbox.SandboxName;
      sandboxobj.value = sandbox.SandboxName;
      sandboxList.push(sandboxobj); 
    });
    sandboxList.push({label : 'Production', value: 'Production'});
    return sandboxList;
  }

  handleAllocatedSandboxesChange(event) {
    this.allocatedSandBoxes = event.target.value;
    this.sandboxDescription = this.allocatedSandboxMap[this.allocatedSandBoxes].Sandbox_Description__c;
    this.sandboxName = this.allocatedSandBoxes;
    this.sandboxtype = this.allocatedSandboxMap[this.allocatedSandBoxes].Sandbox_Type__c;
    this.sandboxOptions = this.getSandboxListFromSandboxType(this.allocatedSandboxMap[this.allocatedSandBoxes].Sandbox_Type__c);
  }
  

  handleOrgOptionsChange(event) {
    this.orgName = event.target.value;
    this.allocatedSandboxesOptions = [];
    this.sandboxDescription = null;
    this.sandboxName = null;
    this.sandboxOptions = [];
    this.resourceName = null;
    this.sandboxtypes = [];
    if (this.orgName == "IQVIA") {
      this.apexFunctionCall = 'CallSampleDataLoader';
    } else {
      this.apexFunctionCall = '';
    }
    let developerType =  { label: "Developer", value: "DEVELOPER" };
    let developerProType = { label: "Developer Pro", value: "DEVELOPER_PRO" };
    let partialType = { label: "Partial copy", value: "PARTIAL" };
    let fullType = { label: "Full copy", value: "FULL" };

    getAllSandboxes({orgName: this.orgName})
    .then((data) => {
      this.allSandboxMap = data.sandbox;
      if ((this.getSandboxListFromSandboxType("DEVELOPER").length-1) < data.sandboxTypeLimit.Devloper_SandboxType_Limit__c) {
        this.sandboxtypes.push(developerType);
      }
      if ((this.getSandboxListFromSandboxType("DEVELOPER_PRO").length-1) < data.sandboxTypeLimit.DevloperPro_SandboxType_Limit__c) {
        this.sandboxtypes.push(developerProType);
      }
      if ((this.getSandboxListFromSandboxType("PARTIAL").length-1) < data.sandboxTypeLimit.Partial_SandboxType_Limit__c) {
        this.sandboxtypes.push(partialType);
      }
      if ((this.getSandboxListFromSandboxType("FULL").length-1) < data.sandboxTypeLimit.Full_SandboxType_Limit__c) {
        this.sandboxtypes.push(fullType);
      }
      this.sandboxtypes = JSON.parse(JSON.stringify(this.sandboxtypes));
      if(this.requestTypeChange == "Data Migration") {
        this.sourceOrgOptions = this.getAllSandboxList();
        this.targetOrgOptions = this.getAllSandboxList();
      }
      this.sourceOrgOptions = JSON.parse(JSON.stringify(this.sourceOrgOptions));
      this.targetOrgOptions = JSON.parse(JSON.stringify(this.targetOrgOptions));
    })
    .catch((error)=> {
      console.log(error);
    });
  }

  isSandboxNameDuplicate(sandboxName) {
    let isDuplicate = false;
    this.allSandboxMap.records.forEach((sandbox) => {
      if(sandboxName.toUpperCase() == sandbox.SandboxName.toUpperCase()) {
        isDuplicate = true;
        this.break;
      }
    });
    return isDuplicate;
  }

  allocateNewSandboxName(sandboxName){
    if(this.isSandboxNameDuplicate(sandboxName) && sandboxName.length <= 10){
      if (sandboxName.length < 10) {
        sandboxName = sandboxName + '1';
        sandboxName = this.allocateNewSandboxName(sandboxName);
      } else if(sandboxName.length == 10){
        let lastChar = sandboxName.charAt(sandboxName.length-1);
        lastChar++;
        sandboxName = sandboxName.substring(0,9) + lastChar;
        console.log(sandboxName);
        sandboxName = this.allocateNewSandboxName(sandboxName);
      }
    }
    return sandboxName;
  }

  handleTeamResourcesOptionsChange(event) {
    this.resourceName = event.target.value;
    this.allocatedSandboxesOptions = [];
    this.sandboxName = null;
    this.sandboxDescription = null;
    this.sandboxOptions = [];
    getUserAllocatedSandboxName({selectedUsername: this.resourceName, Organization: this.orgName})
      .then((userData) => {
        console.log(userData);
        this.allocatedSandboxMap = userData.allocatedSandbox;
        for (var sandboxName in userData.allocatedSandbox) {
          let sandboxObj = {};
          sandboxObj.label = userData.allocatedSandbox[sandboxName].Label;
          sandboxObj.value = userData.allocatedSandbox[sandboxName].Label;
          this.allocatedSandboxesOptions.push(sandboxObj);
        }
        this.allocatedSandboxesOptions = JSON.parse(JSON.stringify(this.allocatedSandboxesOptions));
        if (this.requestTypeChange == "New Sandbox" && this.isSandboxNameDuplicate(userData.defaultSandboxName)) {
          this.sandboxName = this.allocateNewSandboxName(userData.defaultSandboxName);
        } else if (this.requestTypeChange == "New Sandbox") {
          this.sandboxName = userData.defaultSandboxName;
        }
        console.log(this.allocatedSandboxesOptions);
      })
      .catch((error) => {
        console.log(error);
        this.showToast("Load Fail", "No options fetched in user allocated sandbox name", "error");
      });
  }

  @wire(metadataDetails)
  leadResources({ error, data }) {
    if (data) {
      data.teamdata.forEach((resource) => {
        let resourceObj = {};
        resourceObj.label = resource.Label;
        resourceObj.value = resource.DeveloperName;
        this.teamResourcesOptions.push(resourceObj);
      });
      this.moduleName = data.teamModuleData.Label;
    } else if (error) {
      console.log(error);
      this.showToast("Load Fail", "No options are fetched on lead details", "error");
    }
  }

  @wire(getAllDevopsResource)
  getAllDevopsResourceList({ error, data }) {
    if (data) {
      this.allDevOpsResource = data;
      console.log(data);
    } else if (error) {
      console.log(error);
      console.log('GetAllDevOpsResource');
    }
  }

  handleModuleChange(event) {
    this.moduleName = event.target.value;
  }

  handleActivateChange(event) {
    this.isChecked = event.target.checked;
  }

  handleApexChange(event) {
    this.apexFunctionCall = event.target.value;
    this.classId = null;
  }

  closeModal(event) {
    this.dispatchEvent(new CloseActionScreenEvent());
    this[NavigationMixin.Navigate]({
      type: "standard__objectPage",
      attributes: {
        objectApiName: "Devops_Request__c",
        actionName: "home"
      }
    });
  }

  handleDescriptionChange(event) {
    this.sandboxDescription = event.target.value;
  }

  showToast(title, message, variant) {
    const event = new ShowToastEvent({
      title: title,
      message: message,
      variant: variant
    });
    this.dispatchEvent(event);
  }

  handlePreviousClick(event) {
    this.showFirstPage = true;
    this.showSecondPage = false;
    this.showSandboxRefreshForm = false;
    this.showSubmitButton = false;
    this.showOnboardingForm = false;
    this.showOffboardingForm = false;
    this.showDataMigrationForm = false;
    this.showNextButton = true;
    this.isChecked = false;
    this.isJenkinsUserRequired = false;
    this.isBitbucketUserRequired = false;
    this.isSandboxRequired = false;

    this.requestTypeChange = null;
    this.selectedSandboxValue = null;
    this.sandboxtype = null;
    this.sandboxName = null;
    this.createFrom = null;
    this.resourceName = null;
    this.sandboxDescription = null;
    this.orgName = null;
    this.targetOrg = null;
    this.sourceOrg = null;
    this.allocatedSandBoxes = null;
    this.allocatedSandboxMap = null;
    this.allSandboxMap = null;
    this.jenkinsRole = null;
    this.bitbucketRole = null;
    this.classId = null;
    this.sourceId = null;
    this.firstName = null;
    this.lastName = null;
    this.email = null;
    this.moduleName = null;

    this.moduleOptions = [];
    this.sandboxOptions = [];
    this.allocatedSandboxesOptions = [];
    this.sandboxtypes = [];
    this.sourceOrgOptions = [];
    this.targetOrgOptions = [];
  }

  handleNewSandboxValidity() {
    let validity = true;
    let organizationRef = this.refs.organizationRef;
    if (!organizationRef.value) {
      organizationRef.setCustomValidity('Please Enter the ' + organizationRef.label);
      validity = false;
    } else {
      organizationRef.setCustomValidity("");
    }
    let resourceNameRef = this.refs.resourceNameRef;
    if (!resourceNameRef.value) {
      resourceNameRef.setCustomValidity('Please Enter the ' + resourceNameRef.label);
      validity = false;
    } else {
      resourceNameRef.setCustomValidity("");
    }
    let sandboxNameRef = this.refs.sandboxNameRef;
    if (!sandboxNameRef.value) {
      sandboxNameRef.setCustomValidity('Please Enter the ' + sandboxNameRef.label);
      validity = false;
    } else {
      sandboxNameRef.setCustomValidity("");
    }
    let sandboxDescriptionRef = this.refs.sandboxDescriptionRef;
    if (!sandboxDescriptionRef.value) {
      sandboxDescriptionRef.setCustomValidity('Please Enter the ' + sandboxDescriptionRef.label);
      validity = false;
    } else {
      sandboxDescriptionRef.setCustomValidity("");
    }
    let sandboxTypeRef = this.refs.sandboxTypeRef;
    if (!sandboxTypeRef.value) {
      sandboxTypeRef.setCustomValidity('Please Enter the ' + sandboxTypeRef.label);
      validity = false;
    } else {
      sandboxTypeRef.setCustomValidity("");
    }
    let createFromRef = this.refs.createFromRef;
    if (!createFromRef.value) {
      createFromRef.setCustomValidity('Please Enter the ' + createFromRef.label);
      validity = false;
    } else {
      createFromRef.setCustomValidity("");
    }
    let apexFunctionRef = this.refs.apexFunctionRef;
    if (apexFunctionRef.value && !this.classId) {
      apexFunctionRef.setCustomValidity('Please Enter the correct class name');
      validity = false;
    } else {
      apexFunctionRef.setCustomValidity("");
    }
    organizationRef.reportValidity();
    resourceNameRef.reportValidity();
    sandboxNameRef.reportValidity();
    sandboxDescriptionRef.reportValidity();
    sandboxTypeRef.reportValidity();
    createFromRef.reportValidity();
    apexFunctionRef.reportValidity();
    return validity;
  }

  handleRefreshSandboxValidity() {
    let validity = true;
    let organizationRef1 = this.refs.organizationRef1;
    if (!organizationRef1.value) {
      organizationRef1.setCustomValidity('Please Enter the ' + organizationRef1.label);
      validity = false;
    } else {
      organizationRef1.setCustomValidity("");
    }
    let resourceRef1 = this.refs.resourceRef1;
    if (!resourceRef1.value) {
      resourceRef1.setCustomValidity('Please Enter the ' + resourceRef1.label);
      validity = false;
    } else {
      resourceRef1.setCustomValidity("");
    }
    let allocatedSandBoxesRef = this.refs.allocatedSandBoxesRef;
    if (!allocatedSandBoxesRef.value) {
      allocatedSandBoxesRef.setCustomValidity('Please Enter the ' + allocatedSandBoxesRef.label);
      validity = false;
    } else {
      allocatedSandBoxesRef.setCustomValidity("");
    }
    let newSandboxNameRef = this.refs.newSandboxNameRef;
    if (!newSandboxNameRef.value) {
      newSandboxNameRef.setCustomValidity('Please Enter the ' + newSandboxNameRef.label);
      validity = false;
    } else {
      newSandboxNameRef.setCustomValidity("");
    }
    let sandboxDescriptionRef1 = this.refs.sandboxDescriptionRef1;
    if (!sandboxDescriptionRef1.value) {
      sandboxDescriptionRef1.setCustomValidity('Please Enter the ' + sandboxDescriptionRef1.label);
      validity = false;
    } else {
      sandboxDescriptionRef1.setCustomValidity("");
    }
    let refreshFromRef = this.refs.refreshFromRef;
    if (!refreshFromRef.value) {
      refreshFromRef.setCustomValidity('Please Enter the ' + refreshFromRef.label);
      validity = false;
    } else {
      refreshFromRef.setCustomValidity("");
    }
    let apexFunctionRef = this.refs.apexFunctionRef;
    if (apexFunctionRef.value && !this.classId) {
      apexFunctionRef.setCustomValidity('Please Enter the correct class name');
      validity = false;
    } else {
      apexFunctionRef.setCustomValidity("");
    }
    organizationRef1.reportValidity();
    resourceRef1.reportValidity();
    allocatedSandBoxesRef.reportValidity();
    newSandboxNameRef.reportValidity();
    sandboxDescriptionRef1.reportValidity();
    refreshFromRef.reportValidity();
    apexFunctionRef.reportValidity();
    return validity;
  }

  handleOnboardingRequestValidity() {
    let validity = true;
    let firstnameRef = this.refs.firstnameRef;
    let lastNameRef = this.refs.lastNameRef;
    let emailRef = this.refs.emailRef;
    let organizationRef = this.refs.OB_organizationRef;
    let moduleRef = this.refs.moduleRef;
    let bitbucketRoleRef = this.refs.bitbucketRoleRef;
    let jenkinsRoleRef = this.refs.jenkinsRoleRef;
    if (!firstnameRef.value) {
      firstnameRef.setCustomValidity('Please Enter the ' + firstnameRef.label);
      validity = false;
    } else {
      firstnameRef.setCustomValidity("");
    }
    if (!lastNameRef.value) {
      lastNameRef.setCustomValidity('Please Enter the ' + lastNameRef.label);
      validity = false;
    } else {
      lastNameRef.setCustomValidity("");
    }
    if (!emailRef.value) {
      emailRef.setCustomValidity('Please Enter the ' + emailRef.label);
      validity = false;
    } else{
      const emailRegex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
      if (emailRef.value.match(emailRegex)) {
        emailRef.setCustomValidity("");
      } else {
        validity = false;
        emailRef.setCustomValidity('Please Enter the valid Email');
      }
    }
    if (!organizationRef.value) {
      organizationRef.setCustomValidity('Please Enter the ' + organizationRef.label);
      validity = false;
    } else {
      organizationRef.setCustomValidity("");
    }
    if (!moduleRef.value) {
      moduleRef.setCustomValidity('Please Enter the ' + moduleRef.label);
      validity = false;
    } else {
      moduleRef.setCustomValidity("");
    }
    if (this.isBitbucketUserRequired && !bitbucketRoleRef.value) {
      bitbucketRoleRef.setCustomValidity('Please Enter the ' + bitbucketRoleRef.label);
      validity = false;
    } else if(this.isBitbucketUserRequired){
      bitbucketRoleRef.setCustomValidity("");
    }
    if (this.isJenkinsUserRequired && !jenkinsRoleRef.value) {
      jenkinsRoleRef.setCustomValidity('Please Enter the ' + jenkinsRoleRef.label);
      validity = false;
    } else if(this.isJenkinsUserRequired){
      jenkinsRoleRef.setCustomValidity("");
    }
    firstnameRef.reportValidity();
    lastNameRef.reportValidity();
    emailRef.reportValidity();
    moduleRef.reportValidity();
    if (this.isBitbucketUserRequired) {
      bitbucketRoleRef.reportValidity();
    }
    if (this.isJenkinsUserRequired) {
      jenkinsRoleRef.reportValidity(); 
    }
    return validity;
  }

  handleOffboardingRequestValidity() {
    let validity = true;
    let resourceNameOffRef = this.refs.resourceNameOffRef;
    if (!resourceNameOffRef.value) {
      resourceNameOffRef.setCustomValidity('Please Enter the ' + resourceNameOffRef.label);
      validity = false;
    } else {
      resourceNameOffRef.setCustomValidity("");
    }
    resourceNameOffRef.reportValidity();
    return validity;
  }

  handleDataMigrationValidity() {
    let validity = true;
    let organizationDmRef = this.refs.organizationDmRef;
    if (!organizationDmRef.value) {
      organizationDmRef.setCustomValidity('Please Enter the ' + organizationDmRef.label);
      validity = false;
    } else {
      organizationDmRef.setCustomValidity("");
    }
    organizationDmRef.reportValidity();
    let sourceOrgRef = this.refs.sourceOrgRef;
    if (!sourceOrgRef.value) {
      sourceOrgRef.setCustomValidity('Please Enter the ' + sourceOrgRef.label);
      validity = false;
    } else {
      sourceOrgRef.setCustomValidity("");
    }
    sourceOrgRef.reportValidity();
    let targetOrgRef = this.refs.targetOrgRef;
    if (!targetOrgRef.value) {
      targetOrgRef.setCustomValidity('Please Enter the ' + targetOrgRef.label);
      validity = false;
    } else {
      targetOrgRef.setCustomValidity("");
    }
    targetOrgRef.reportValidity();
    return validity;
  }

  handleClassId() {
    this.isLoaded = true;
    getClassId({className: this.apexFunctionCall, sourceSandboxName: this.createFrom, orgName: this.orgName})
    .then((data) => {
      this.classId = data;
      console.log(data);
      this.isLoaded = false;
      return true;
    })
    .catch((error) => {
      console.log(error);
      this.isLoaded = false;
      return false;
    });
  }

  handleNoSpace(event) {
    if((event.keyCode < 65 || event.keyCode > 90) && (event.keyCode < 97 || event.keyCode > 122)) { 
      event.returnValue = false; 
      return false; 
    }
  }

  handleFirstNameChange(event) {
    let firstNameValue = event.target.value;
    this.firstName = firstNameValue.trim();
  }

  handleLastNameChange(event) {
    let lastNameValue = event.target.value;
    this.lastName = lastNameValue.trim();
  }

  handleEmailChange(event) {
    this.email = event.target.value;
  }

  handleModuleChange(event) {
    this.moduleName = event.target.value;
  }

  handlesandboxNameChange(event) {
    this.sandboxName = this.allocateNewSandboxName(event.target.value);
  }

  isResourceNameDuplicate(resourceName) {
    let isDuplicate = false;
    this.allDevOpsResource.forEach(element => {
      if (element.DeveloperName == resourceName) {
        isDuplicate = true;
      }
    });
    return isDuplicate;
  }

  allocateNewResourceName(resourceName) {
    if(this.isResourceNameDuplicate(resourceName)) {
      let lastChar = resourceName.charAt(resourceName.length-1);
      console.log(lastChar);
      if(!isNaN(lastChar)) {
        lastChar++;
        resourceName = resourceName.substring(0,resourceName.length-1) + lastChar;
      }else {
        resourceName = resourceName + '1';
      }
      resourceName = this.allocateNewResourceName(resourceName);
    }
    return resourceName;
  }

  handleButtonClick(event) {
    let validity = true;
    if (this.requestTypeChange == "New Sandbox") {
      validity = this.handleNewSandboxValidity();
    } else if(this.requestTypeChange == "Sandbox Refresh"){
      validity = this.handleRefreshSandboxValidity();
    } else if (this.requestTypeChange == "Onboarding Request") {
      validity = this.handleOnboardingRequestValidity();
    } else if (this.requestTypeChange == "Offboarding Request") {
      validity = this.handleOffboardingRequestValidity();
      this.isChecked = false;
    } else if (this.requestTypeChange == "Data Migration") {
      validity = this.handleDataMigrationValidity();
      this.isChecked = false;
    }
    
    
    if (validity) {
      this.isLoaded = true;
      this.disabledSubmitButton = true;
      if (this.requestTypeChange == "Onboarding Request") {
        this.resourceName = this.firstName + '_' + this.lastName;
        this.resourceName = this.allocateNewResourceName(this.resourceName);
        this.isChecked = false;
        if (this.isSandboxRequired) {
          this.createFrom = 'Production';
          let tempsandboxName = this.moduleName + 'x' + this.firstName.charAt(0) + this.lastName.charAt(0);
          this.sandboxName = this.allocateNewSandboxName(tempsandboxName);
          this.sandboxDescription = 'Developer Sandbox for resource ' + this.resourceName + '(' + this.email + ')';
          this.sandboxtype = 'DEVELOPER';
          this.sourceId = null;
          this.isChecked = true;
        }
      }
      const fields = {};
      fields[REQUEST_TYPE.fieldApiName] = this.requestTypeChange;
      fields[SANDBOX_NAME.fieldApiName] = this.sandboxName;
      fields[RESOURCE_NAME.fieldApiName] = this.resourceName;
      fields[CREATE_OPTIONS.fieldApiName] = this.createFrom;
      fields[ORGANIZATION.fieldApiName] = this.orgName;
      fields[SANDBOX_DESCRIPTION.fieldApiName] = this.sandboxDescription;
      fields[POST_ACTIVITY_APEXCLASS.fieldApiName] = this.apexFunctionCall;
      fields[AUTO_ACTIVE.fieldApiName] = this.isChecked;
      fields[OLD_SANDBOX_NAME.fieldApiName] = this.allocatedSandBoxes;
      fields[REQUEST_STATUS.fieldApiName] = 'Submitted';
      fields[MODULE_NAME.fieldApiName] = this.moduleName;
      fields[FIRST_NAME.fieldApiName] = this.firstName;
      fields[LAST_NAME.fieldApiName] = this.lastName;
      fields[EMAIL_ID.fieldApiName] = this.email;
      fields[SOURCE_ORG.fieldApiName] = this.sourceOrg;
      fields[TARGET_ORG.fieldApiName] = this.targetOrg;
      fields[IS_SANDBOX_REQUIRED.fieldApiName] = this.isSandboxRequired;
      fields[IS_JENKINS_USER.fieldApiName] = this.isJenkinsUserRequired;
      fields[IS_BITBUCKET_USER.fieldApiName] = this.isBitbucketUserRequired;
      fields[JENKINS_ROLES.fieldApiName] = this.jenkinsRole;
      fields[BITBUCKET_GROUP.fieldApiName] = this.bitbucketRole;
      fields[SANDBOX_TYPE.fieldApiName] = this.sandboxtype;
      fields[CLASS_ID.fieldApiName] = this.classId;
      fields[SOURCE_ID.fieldApiName] = this.sourceId;
      fields[IS_SANDBOX_OFFBOARD_REQUIRED.fieldApiName] = this.isSandboxRemove;
      fields[IS_JENKINS_USER_OFFBOARD.fieldApiName] = this.isJenkinsUserRemove;
      fields[IS_BITBUCKET_USER_OFFBOARD.fieldApiName] = this.isBitbucketUserRemove;
      fields[SANDBOX_TO_REMOVE.fieldApiName] = this.sandboxToRemove;
      const recordInput = { apiName: DEVOPS_REQUEST.objectApiName, fields };
      createRecord(recordInput)
        .then((record) => {
          this.recordId = record.id;
          this[NavigationMixin.Navigate]({
            type: "standard__recordPage",
            attributes: {
              recordId: this.recordId,
              objectApiName: DEVOPS_REQUEST.objectApiName,
              actionName: "view"
            }
          });
          this.isLoaded = false;
          this.showToast("Success", "Record Created Successfully", "success");
        })
        .catch((error) => {
          console.log(error);
          this.disabledSubmitButton = false;
          this.isLoaded = false;
        }); 
    }
  }

  handleNextClick(event) {
    if (this.requestTypeChange != undefined) {
      this.showFirstPage = false;
      this.showNextButton = false;

      if (this.requestTypeChange == "New Sandbox") {
        this.showSecondPage = true;
        this.showSubmitButton = true;
      } else if (this.requestTypeChange == "Sandbox Refresh") {
        this.showSandboxRefreshForm = true;
        this.showSubmitButton = true;
      } else if (this.requestTypeChange == "Onboarding Request") {
        this.showOnboardingForm = true;
        this.showSubmitButton = true;
      } else if (this.requestTypeChange == "Offboarding Request") {
        this.showOffboardingForm = true;
        this.showSubmitButton = true;
      } else if (this.requestTypeChange == "Data Migration") {
        this.showDataMigrationForm = true;
        this.showSubmitButton = true;
      } else {
        this.showToast("Required Field", "Kindly select a request type", "error");
      }
    } else {
      this.showToast("Required Field", "Kindly select a request type", "error");
    }
  }

  handleOptionChange(event) {
    this.isLoaded = true;
    this.createFrom = event.target.value;
    this.allSandboxMap.records.forEach((sandbox) => {
      if(sandbox.SandboxName == this.createFrom){
        this.sourceId = sandbox.Id;
        console.log(sandbox.Id);
      } 
    });
    getClassId({className: this.apexFunctionCall, sourceSandboxName: this.createFrom, orgName: this.orgName})
    .then((data) => {
      this.classId = data;
      this.isLoaded = false;
    })
    .catch((error) => {
      console.log(error);
      this.isLoaded = false;
    });

  }

  handlerequestChange(event) {
    this.requestTypeChange = event.target.value;
    if (this.requestTypeChange == "Onboarding Request") {
      getAllModule()
      .then((data) => {
        let moduleList = [];
        data.forEach((module) => {
          let moduleObj = {};
          moduleObj.label = module.Label;
          moduleObj.value = module.Label;
          moduleList.push(moduleObj);
        });
        this.moduleOptions = moduleList;
      })
      .catch((error) => {
        console.log(error);
      });
    }
  }

  handleSourceOrgChange(event) {
    this.sourceOrg = event.target.value;
  }

  handleTargetOrgChange(event) {
    this.targetOrg = event.target.value;
  }

  handleBitbucketRoleChange(event) {
    this.bitbucketRole = event.target.value;
  }

  handleJenkinsRoleChange(event) {
    this.jenkinsRole = event.target.value;
  }

  handleTypeChange(event) {
    this.sandboxtype = event.target.value;
    let sandboxList = this.getSandboxListFromSandboxType(this.sandboxtype)
    this.sandboxOptions = sandboxList;
    console.log(sandboxList);
  }

  handleSandboxRequiredChange(event) {
    this.isSandboxRequired = event.target.checked;
    this.isLoaded = true;
    getClassId({className: this.apexFunctionCall, sourceSandboxName: 'Production', orgName: this.orgName})
    .then((data) => {
      this.classId = data;
      this.isLoaded = false;
    })
    .catch((error) => {
      console.log(error);
      this.isLoaded = false;
    });
  }

  handleBitbucketUserRequiredChange(event) {
    this.isBitbucketUserRequired = event.target.checked;
  }

  handleJenkinsUserRequiredChange(event) {
    this.isJenkinsUserRequired = event.target.checked;
  }

  handleSandboxRemoveChange(event) {
    this.isSandboxRemove = event.target.checked;
  }

  handleBitbucketUserRemovedChange(event) {
    this.isBitbucketUserRemove = event.target.checked;
  }

  handleJenkinsUserRemovedChange(event) {
    this.isJenkinsUserRemove = event.target.checked;
  }

  handleSandboxToRemove(event) {
    this.sandboxToRemove = event.detail.value;
    if(Array.isArray(this.sandboxToRemove)) {
      this.sandboxToRemove = this.sandboxToRemove.join(';');
    }
  }
}