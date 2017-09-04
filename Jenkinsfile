// Tell Jenkins how to build projects from this repository
node {
	try {
		properties([
			[$class: 'BuildDiscarderProperty', strategy: [$class: 'LogRotator', numToKeepStr: '15']]
		])
		
		stage 'Checkout' 
		checkout scm
		dir('build') { deleteDir() }
		
		
		stage 'Build YANG diagram client' 
		dir ('diagram') {
			sh 'ls -la'
			sh 'yarn install --non-interactive --verbose'
			sh 'yarn run setup --non-interactive --verbose'
			sh 'yarn run build --non-interactive --verbose'
		}
		
		stage 'Build YANG Eclipse plug-ins' 
		def mvnHome = tool 'M3'
		dir('yang-eclipse') {
			try {
				wrap([$class:'Xvnc', useXauthority: true]) {
					sh "${mvnHome}/bin/mvn --batch-mode -fae -Dmaven.test.failure.ignore=true -Dmaven.repo.local=.m2/repository clean install"
				}
			} finally {
				step([$class: 'JUnitResultArchiver', testResults: '**/target/surefire-reports/*.xml'])
			}
			archive 'build/**'	
		}	
		if (currentBuild.result == 'UNSTABLE') {
			slackSend color: 'warning', message: "Build Unstable - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
		} else {
			slackSend color: 'good', message: "Build Succeeded - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
		}
	} catch (e) {
		slackSend color: 'danger', message: "Build Failed - ${env.JOB_NAME} ${env.BUILD_NUMBER} (<${env.BUILD_URL}|Open>)"
		throw e
	}
}
