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
			input('Do you want to proceed?')
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
			echo "Not in master branch"
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
