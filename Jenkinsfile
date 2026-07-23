pipeline {
    agent any

    parameters {
        string(name: 'THREADS', defaultValue: '10')
        string(name: 'RAMPUP', defaultValue: '30')
        string(name: 'DURATION', defaultValue: '300')
        string(name: 'URL', defaultValue: 'localhost')
        string(name: 'THROUGHPUT', defaultValue: '100')
        string(name: 'TEST_PLAN', defaultValue: 'load_test.jmx')
    }

    environment {
        SSH_HOST = 'gbutuzov@213.226.127.198'
        REMOTE_DIR = "/opt/jmeter-runs/build-${BUILD_NUMBER}"
    }

    stages {

        stage('Prepare remote dir') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {

                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            mkdir -p ${REMOTE_DIR}
                            rm -rf ${REMOTE_DIR}/*
                        "
                    '''
                }
            }
        }

        stage('Upload project') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {

                    sh '''
                        scp -i ${SSH_KEY} \
                            -o StrictHostKeyChecking=no \
                            -r test-plans properties scripts data \
                            ${SSH_HOST}:${REMOTE_DIR}/
                    '''
                }
            }
        }

        stage('Run JMeter') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {

                    sh '''
                        ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                            cd ${REMOTE_DIR}
                            chmod +x scripts/run_jmeter.sh

                            ./scripts/run_jmeter.sh \
                                ${TEST_PLAN} \
                                ${THREADS} \
                                ${RAMPUP} \
                                ${DURATION} \
                                ${URL} \
                                ${THROUGHPUT}
                        "
                    '''
                }
            }
        }

        stage('Download results') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'host-ssh-key',
                        keyFileVariable: 'SSH_KEY'
                    )
                ]) {

                    sh '''
                        mkdir -p results

                        scp -i ${SSH_KEY} \
                            -o StrictHostKeyChecking=no \
                            -r ${SSH_HOST}:${REMOTE_DIR}/results/* \
                            results/
                    '''
                }
            }
        }
    }

    post {

        always {

            archiveArtifacts(
                artifacts: 'results/**/*',
                allowEmptyArchive: true
            )

        }

    }
}
post {
    aborted {
        withCredentials([
            sshUserPrivateKey(
                credentialsId: 'host-ssh-key',
                keyFileVariable: 'SSH_KEY'
            )
        ]) {
            sh '''
                ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${SSH_HOST} "
                    if command -v shutdown.sh >/dev/null 2>&1; then
                        shutdown.sh || true
                    fi

                    sleep 10

                    if [ -f ${REMOTE_DIR}/run_jmeter.pgid ]; then
                        PGID=\\$(cat ${REMOTE_DIR}/run_jmeter.pgid)

                        kill -TERM -- -\\${PGID} 2>/dev/null || true

                        sleep 5

                        if kill -0 \\${PGID} 2>/dev/null; then
                            kill -KILL -- -\\${PGID} 2>/dev/null || true
                        fi
                    fi
                " || true
            '''
        }
    }

    always {
        withCredentials([
            sshUserPrivateKey(
                credentialsId: 'host-ssh-key',
                keyFileVariable: 'SSH_KEY'
            )
        ]) {
            sh '''
                mkdir -p results

                scp -i ${SSH_KEY} \
                    -o StrictHostKeyChecking=no \
                    -r ${SSH_HOST}:${REMOTE_DIR}/results/* \
                    results/ || true
            '''
        }

        archiveArtifacts(
            artifacts: 'results/**/*',
            allowEmptyArchive: true
        )
    }
}
