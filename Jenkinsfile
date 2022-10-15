pipeline {
    agent any
    stages {
//         stage('Checkout'){
//             steps{
//                 checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [[$class: 'CleanBeforeCheckout', deleteUntrackedNestedRepositories: true], [$class: 'WipeWorkspace']], userRemoteConfigs: [[url: 'https://github.com/SanyaAlexander/kanboard.git']]])
//             }
//         } 
        stage('Build') {
            steps {
                echo 'Downloading php and all dependencies'
                sh '''
                    sudo apt update && sudo apt upgrade -y
                    sudo apt install -y git
                    sudo apt install apache2 -y
                    sudo systemctl enable --now apache2.service
                    sudo apt install -y php7.4 php7.4-mysql php7.4-gd php7.4-mbstring php7.4-common php7.4-opcache php7.4-cli php7.4-sqlite3 php-ldap
                    '''
                echo 'Download completed successfully!'
            }
        }
        stage('Test'){
            when { equals expected: true, actual: Build }
            steps{
                echo 'Running tests'
                sh './vendor/bin/phpunit --config tests/units.mysql.xml'
                echo 'Tests passed!'
            }
        }
        stage('Deploy'){
            steps{
                sshPublisher(publishers: [sshPublisherDesc(configName: 'jenkins-app-server', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''chcon -R -t httpd_sys_content_rw_t /var/www/html/data/
                chown -R apache:apache /var/www/html/data/
                ''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '/var/www/html', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: true)])
            }
        }
        stage('Testing if app is up'){
            steps{
            script {
                    final String url = " http://10.26.0.166"
                    final String response = sh(script: "curl -s -w '%{http_code}' $url", returnStdout: true).trim()
                    if (response == '200' || response == '302') {
                        echo response
                    }else{
                        error "Error code $response"
                    }
                }
        }
    }
}
}
