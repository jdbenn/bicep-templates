param dataFactoryName string
@secure()
param sftpHost string
@secure()
param sftpUsername string
@secure()
param connectionString string
@secure()
param sshKey string
@secure()
param sshKeyPassphrase string

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'data-pros'
}

module linkedServices 'modules/linked-services.bicep' = {
  name: 'datapros-linkedservices'
  scope: resourceGroup
  params: {
    dataFactoryName: dataFactoryName
    sftpHost: sftpHost
    connectionString: connectionString
    sshUsername: sftpUsername
    sshKey: sshKey
    sshKeyPassphrase: sshKeyPassphrase
  }
}

module customerPipeline 'modules/pipelines/customer.bicep' = {
  name: 'customer-pipeline'
  scope: resourceGroup
  params: {
    dataFactoryName: dataFactoryName
    sftpLinkedServiceName: linkedServices.outputs.sftpLinkedServiceName
    sqlLinkedServiceName: linkedServices.outputs.sqlLinkedServiceName
    blobLinkedServiceName: linkedServices.outputs.blobStorageLinkedServiceName
  }
}




