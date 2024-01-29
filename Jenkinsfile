#!groovy

import groovy.json.JsonSlurperClassic

node {
    
    def SF_CONSUMER_KEY=env.SF_CONSUMER_KEY
    def SF_USERNAME=env.SF__DEV_USERNAME
    def SERVER_KEY_CREDENTIALS_ID=env.SERVER_KEY_CREDENTIALS_ID
    def TEST_LEVEL='RunLocalTests'
    def SF_INSTANCE_URL = env.SF_INSTANCE_URL ?: "https://test.salesforce.com"
    def MANIFESTDIR = './manifest'
    def toolbelt = tool 'salesforcecli'
    def jsonObj;
    stage('checkout source') {
        checkout scm
    }

    stage('read propertyfile') {
        jsonObj = readJSON file: "./build/property.json"
        // echo "${jsonObj.credentials[0]}"
    }
    
    withEnv(["HOME=${env.WORKSPACE}"]) {
        withCredentials([file(credentialsId: "${jsonObj.credentials[0].SERVERKEYCREDENTIALSID}", variable: 'server_key_file')]) {
            stage('Authorize to Salesforce') {
                rc = command "sf org login jwt --instance-url ${SF_INSTANCE_URL} --client-id ${jsonObj.credentials[0].SFCONSUMERKEY} --jwt-key-file ${server_key_file} --username ${jsonObj.credentials[0].SFUSERNAME} --alias devxap"
                if (rc != 0) {
                    error 'Salesforce org authorization failed.'
                }
            }

            // stage('Deploy and Run Tests') {
            //     rc = command "sf project deploy start --manifest ${MANIFESTDIR}/package.xml --wait 10 --target-org devxap --test-level ${TEST_LEVEL}"
            //     if (rc != 0) {
            //         error 'Salesforce deploy and test run failed.'
            //     }
            // }
        }
    }
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
        return bat(returnStatus: true, script: script);
    }
}
