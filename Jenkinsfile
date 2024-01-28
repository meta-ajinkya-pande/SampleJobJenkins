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
    
    stage('checkout source') {
        checkout scm
    }

    stage('read propertyfile') {
        def filePath = readFile "./build/property.json"
        def lines = filePath.readLines()
        def jsonObj = readJSON text: lines
        echo ${jsonObj.SF_CONSUMER_KEY}
    }
    
    // withEnv(["HOME=${env.WORKSPACE}"]) {
    //     withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'server_key_file')]) {
    //         stage('Authorize to Salesforce') {
    //             rc = command "sf org login jwt --instance-url ${SF_INSTANCE_URL} --client-id ${SF_CONSUMER_KEY} --jwt-key-file ${server_key_file} --username ${SF_USERNAME} --alias devxap"
    //             if (rc != 0) {
    //                 error 'Salesforce org authorization failed.'
    //             }
    //         }

    //         stage('Deploy and Run Tests') {
    //             rc = command "sf project deploy start --manifest ${MANIFESTDIR}/package.xml --wait 10 --target-org devxap --test-level ${TEST_LEVEL}"
    //             if (rc != 0) {
    //                 error 'Salesforce deploy and test run failed.'
    //             }
    //         }
    //     }
    // }
}

def command(script) {
    if (isUnix()) {
        return sh(returnStatus: true, script: script);
    } else {
        return bat(returnStatus: true, script: script);
    }
}
