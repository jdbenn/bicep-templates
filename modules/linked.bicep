param dataFactoryName string
@secure()
param sftpHost string
@secure()
param sftpUsername string
@secure()
param sftpPassword string
@secure() 
param connectionString string
param port int = 65002

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource sftpLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'SftpLinkedService'
  properties: {
    type: 'Sftp'
    typeProperties: {
      host: sftpHost
      port: port
      authenticationType: 'Basic'
      skipHostKeyValidation: true
      userName: sftpUsername
      password: {
        type: 'SecureString'
        value: sftpPassword
      }
    }
  }
}

resource sqlLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'AzureSqlDatabaseLinkedService'
  properties: {
    type: 'AzureSqlDatabase'
    typeProperties: {
      authenticationType: 'SQL'
      connectionString: {
        type: 'SecureString'
        value: connectionString
      }
    }
  }
}

output sftpLinkedServiceName string = sftpLinkedService.name
output sqlLinkedServiceName string = sqlLinkedService.name
