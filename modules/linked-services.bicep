param dataFactoryName string
@secure()
param sftpHost string
@secure() 
param connectionString string
@secure()
param sshKey string
param sshKeyPassphrase string
param sshUsername string
param port int = 65002

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource blobStorage 'Microsoft.Storage/storageAccounts@2024-01-01' = {
  name: '${dataFactoryName}logstorage'
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: '${dataFactoryName}keyvault'
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    accessPolicies: [
      {
        tenantId: subscription().tenantId
        objectId: dataFactory.identity.principalId
        permissions: {
          keys: [
            'get'
            'list'
          ]
          secrets: [
            'get'
            'list'
          ]
          certificates: [
            'get'
            'list'
          ]
        }
      }
    ]
  }
}

var sshPrivateKeyName = '${dataFactoryName}-sftp-private-key'
var sshPrivateKeyPassphraseName = '${dataFactoryName}-sftp-private-key-passphrase'
var sqlConnectionSecretName = '${dataFactoryName}-sql-connection-string'

resource sshPrivateKey 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: sshPrivateKeyName
  properties: {
    value: sshKey
  }
}

resource sshPrivateKeyPassphrase 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: sshPrivateKeyPassphraseName
  properties: {
    value: sshKeyPassphrase
  }
}

resource sqlConnectionSecret 'Microsoft.KeyVault/vaults/secrets@2024-11-01' = {
  parent: keyVault
  name: sqlConnectionSecretName
  properties: {
    value: connectionString
  }
}

resource keyVaultLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'KeyVaultLinkedService'
  properties: {
    type: 'AzureKeyVault'
    typeProperties: {
      baseUrl: keyVault.properties.vaultUri
    }
  }
}

resource blobContainer 'Microsoft.Storage/storageAccounts/blobServices/containers@2024-01-01' = {
  name: '${blobStorage.name}/default/logs'
}

var storageKeys = blobStorage.listKeys()
var storageKey = storageKeys.keys[0].value
var blobConnection = 'DefaultEndpointsProtocol=https;AccountName=${blobStorage.name};AccountKey=${storageKey};EndpointSuffix=core.windows.net'


resource blobStorageLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'BlobStorageLinkedService'
  properties: {
    type: 'AzureBlobStorage'
    typeProperties: {
      connectionString: blobConnection
    }
  }
}

resource sftpLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' = {
  parent: dataFactory
  name: 'SftpLinkedService'
  properties: {
    type: 'Sftp'
    typeProperties: {
      host: sftpHost
      port: port
      userName: sshUsername
      authenticationType: 'SshPublicKey'
      skipHostKeyValidation: true
      privateKeyContent: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: keyVaultLinkedService.name
          type: 'LinkedServiceReference'
        }
        secretName: sshPrivateKeyName
      }
      passPhrase: {
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: keyVaultLinkedService.name
          type: 'LinkedServiceReference'
        }
        secretName: sshPrivateKeyPassphraseName
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
        type: 'AzureKeyVaultSecret'
        store: {
          referenceName: keyVaultLinkedService.name
          type: 'LinkedServiceReference'
        }
        secretName: sqlConnectionSecretName
      }
    }
  }
}

output sftpLinkedServiceName string = sftpLinkedService.name
output sqlLinkedServiceName string = sqlLinkedService.name
output blobStorageLinkedServiceName string = blobStorageLinkedService.name

