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
