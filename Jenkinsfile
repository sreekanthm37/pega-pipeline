pipeline {
    agent {label 'master'}

    properties([
      parameters([
        string(name: 'productName', defaultValue: ''),
        string(name: 'productVersion', defaultValue: ''),
        string(name: 'applicationName', defaultValue: ''),
        string(name: 'applicationVersion', defaultValue: ''),
      ])
    ])

    environment {
       SourceHost = "<Pega Dev Server>"
    }

    stages {

        // Use Pega OOTB functionality to get the compliance score
        stage('Get the Compliance score') {
            steps {
                script {
                    echo 'getting compliance score'
                    def response = httpRequest httpMode: 'POST', authentication: 'PEGA_DEV_USER_EXPORT', url: 'http://<server IP>:<port>/prweb/PRRestService/PegaUnit/Pega-Landing-Application/pzGetApplicationQualityDetails?AccessGroup=<accessgroup>', outputFile: 'compliance_score.xml'
                    println('Status: '+response.status)
                    println('Response: '+response.content)
                    def Metrics= new XmlSlurper().parse("${env.WORKSPACE}/compliance_score.xml")
                    println "Compliance score is  : ${Metrics.Guardrails.Compliancescore}"
                }
            }
        }

        // Pega Unit Testing stage, uses junit plugin to publish the testing results
        stage('Running Junit Test results') {
            steps {
                script {
                    echo 'Running Junit test cases'
                    def response = httpRequest httpMode: 'POST', authentication: 'PEGA_UNIT_TEST_USER_DEV', url: 'http://<server IP>:<port>/prweb/PRRestService/PegaUnit/Rule-Test-Unit-Case/pzExecuteTests?ApplicationInformation?=ApplicationInformation:<ApplicationName:ApplicationVersion>', outputFile: 'tests/results/test_result.xml'
                    println('Status: '+response.status)
                    println('Response: '+response.content)
                    junit testResults: 'tests/results/*.xml', allowEmptyResults: false, healthScaleFactor: 1.0
                    echo 'testing completed'
                 }
            }
        }

        // Exporting the PEGA RAP from Dev environment
        stage('Export from Dev') {
            steps {
                script {
                    echo 'Exporting application from Dev environment : ' + env.SourceHost
                    echo 'PEGA home is: ' + env.PEGA_HOME
                    def antVersion = 'Ant1.10.5'
                    withEnv( ["ANT_HOME=${tool antVersion}"] ) {
                        sh "ant -f ${env.PEGA_HOME}/scripts/samples/jenkins/build.xml -DapplicationVersion=${params.applicationVersion} -DproductVersion=${params.productVersion} -DproductName=${params.productName} -DapplicationName=${params.applicationName} exportprops"
                    }
                    sh "${env.PEGA_HOME}/scripts/utils/prpcServiceUtils.sh export --connPropFile ${env.WORKSPACE}/${env.SystemName}_export.properties --artifactsDir ${env.WORKSPACE}"
                }
           }
        }

        // Saves the exported PEGA RAP to JFrog Artifactory repo
        stage('Publish to Artifactory') {
            steps {
               script {
                        echo 'Publishing to Artifactory'
                        def server = Artifactory.server 'AISLCPJFAAPP001'
                        def uploadSpec = """{
                                "files": [
                                {
                                        "pattern": "/${env.WORKSPACE}/**/**/*.zip",
                                        "target": "e-pragati-PEGA-local/${params.applicationName}/${params.applicationVersion}/"
                                }
                                ]
                        }"""

                        server.upload(uploadSpec)
                 }
            }
        }
        
        // Retrieves the pega RAP from artifactory repo for importing to higher environments
        stage('Retrieve from Artifactory') {
            steps {
               script {
					echo 'Retrieving from Artifactory' 
					def server = Artifactory.server 'AISLCPJFAAPP001'
					def downloadSpec = """{
						"files": [
						{
							"pattern": "e-pragati-PEGA-local/${params.applicationName}/${params.applicationVersion}/*.zip",
							"target": "${env.PEGA_HOME}/destination/${params.applicationName}/",
							"flat": "true"
						}
						]
					}"""
					server.download(downloadSpec)
				}
			}
		}

        // Added stage Importing to environments - QA. Can be extended incrementally to UAT, Pre-Prod as well.
        stage('Import to environments - QA') {
            when {
                expression { params.environment == 'QA'}
            }
                
			steps {
			   script {
			        echo 'Importing to environment' + params.environment   
   				    def antVersion = 'Ant1.10.5'
                    withEnv( ["ANT_HOME=${tool antVersion}"] ) {
                        sh "ant -f ${env.PEGA_HOME}/scripts/samples/jenkins/build.xml -DTargetHost='http://<server>' -DTargetUser='<user>' -DTargetPassword='<password>' -DapplicationName=${params.applicationName} importprops"
                    }
                    sh "${env.PEGA_HOME}/scripts/utils/prpcServiceUtils.sh import --connPropFile ${env.WORKSPACE}/${env.SystemName}_import.properties --artifactsDir ${env.WORKSPACE}"
				}
			}
		}
   }

   post {

        success {
            echo 'Job executed successfully'
            emailext body: '''${SCRIPT, template="jenkins-mygroovy-html.template"}''',
                    mimeType: 'text/html',
                    subject: "[SUCCESS] Jenkins: PEGA RAP for ${params.applicationName}:${params.applicationVersion} Deployed ${currentBuild.fullDisplayName}",
                    to: "<email list>"
        }
        failure {
            echo 'Job failed'
            emailext body: '''${SCRIPT, template="jenkins-mygroovy-html.template"}''',
                    mimeType: 'text/html',
                    subject: "[FAILURE] Jenkins: PEGA RAP for ${params.applicationName}:${params.applicationVersion} FAILED ${currentBuild.fullDisplayName}",
                    to: "<email-List>"
        }
        unstable {
            echo 'Build is unstable'
            emailext body: '''${SCRIPT, template="jenkins-mygroovy-html.template"}''',
                    mimeType: 'text/html',
                    subject: "Jenkins: PEGA RAP for ${params.applicationName}:${params.applicationVersion} COMPLIANCE SCORE CHECK FAILED ${currentBuild.fullDisplayName}",
                    to: "<email-list>"
        }
        always {
            echo 'Cleaning up the workspace'
            deleteDir()
        }
   }
}

