pipeline {
    agent any

    stages {
        stage('Clone') {
            steps {
                dir('.') {
                    git branch: 'main', credentialsId: 'github_com', url: 'git@github.com:Joel5040/Jenkins-CI-CD--Pipeline.git'
                }
                script {
                    def tag = sh(returnStdout: true, script: "git describe --tags --abbrev=0 2>/dev/null || true").trim()
                    def count = sh(returnStdout: true, script: "git rev-list --count HEAD").trim()
                    def sha  = sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                    env.DYNAMIC_VERSION = tag ? "${tag}.${count}-${sha}" : "0.1.0-${count}-${sha}"
                    echo "Initial computed dynamic version (fallback): ${env.DYNAMIC_VERSION}"
                }
            }
        }

        stage('ResolveVersion') {
            steps {
                script {
                    try {
                        def json = sh(returnStdout: true, script: "docker run --rm -v ${WORKSPACE}:/repo -w /repo gittools/gitversion:5 /repo /output json").trim()
                        def parsed = readJSON text: json
                        env.MAJOR = parsed.Major.toString()
                        env.MINOR = parsed.Minor.toString()
                        env.PATCH = parsed.Patch.toString()
                        env.NEXT_INCREMENTAL = (parsed.Patch + 1).toString()
                        def shortSha = parsed.ShortSha ?: parsed.Sha?.substring(0,7) ?: sh(returnStdout: true, script: "git rev-parse --short HEAD").trim()
                        env.SHORT_SHA = shortSha
                        env.DYNAMIC_VERSION = "${env.MAJOR}.${env.MINOR}.${env.NEXT_INCREMENTAL}-${env.SHORT_SHA}"
                        echo "Version resolved via GitVersion: ${env.DYNAMIC_VERSION}"
                    } catch (err) {
                        echo "GitVersion/Docker not available or failed: ${err}"
                        echo "Using fallback dynamic version: ${env.DYNAMIC_VERSION}"
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'Freestyle-Pass',
                    passwordVariable: 'MVN_PASSWORD',
                    usernameVariable: 'MVN_USERNAME')]) {

                    sh 'chmod +x ./mvnw'

                    sh """
                      echo "Username: ${MVN_USERNAME}"
                      echo "Password length: \${#MVN_PASSWORD}"
                      ./mvnw -B clean deploy -X \
                          -s settings.xml \
                          -Drepo.id=github \
                          -Drepo.login=${MVN_USERNAME} \
                          -Drepo.pwd=${MVN_PASSWORD} \
                          -Drevision=${env.DYNAMIC_VERSION}
                    """
                }
            }
        }

        stage('Post') {
            steps {
                jacoco()
                junit 'target/surefire-reports/*.xml'
                publishIssues issues: [scanForIssues(tool: pmd(pattern: 'target/pmd.xml'))]
            }
        }
    }
}
