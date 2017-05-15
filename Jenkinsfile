node('agent') {
  stage 'build'
  openshiftBuild(buildConfig: 'hello-sinatra', showBuildLogs: 'true')
  stage 'deploy'
  openshiftDeploy(deploymentConfig: 'hello-sinatra')
}