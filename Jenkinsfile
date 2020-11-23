pipeline {
    agent any
        stages {
            stage('One') {
		steps {
			echo 'Hi, this is sample declarative project'
		}
	    }
	    stage('Two') {
		steps {
			echo "Hey bud, I am in master"
			sh 'git checkout feature/test-jenkins-pipeline'
			sh 'python3 output.py'
		}
	    }
	    stage('Three') {
		when {
		    not {
			branch "master"
		    }
		}
	        steps {
			echo "Hello"
		}
	    }
	    stage('Four') {
	        parallel {
		    stage('Unit test') {
			steps {
				echo "Running unit test..."
			}
		    }
		    stage('Integration test') {
			steps {
				echo "Running integration test"
			}
		    }
		}
	    }
}
}
