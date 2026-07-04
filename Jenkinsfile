pipeline {
    agent any
    parameters {
        string(name: 'THREADS', defaultValue: '10')
        string(name: 'RAMPUP', defaultValue: '30')
        string(name: 'DURATION', defaultValue: '300')
        string(name: 'URL', defaultValue: 'example.test.host')
        string(name: 'THROUGHPUT', defaultValue: '100')
        string(name: 'TEST_PLAN', defaultValue: 'load_test.jmx')
    }
    stages {
        stage('Show Parameters') {
            steps {
                echo "Threads: ${params.THREADS}"
                echo "RampUp: ${params.RAMPUP}"
                echo "Duration: ${params.DURATION}"
                echo "URL: ${params.URL}"
                echo "Throughput: ${params.THROUGHPUT}"
            }
        }
    }
}
