param dataFactoryName string
@secure()
param sqlServerName string
@secure()
param administratorLogin string
@secure()
param administratorPassword string
@secure()
param databaseName string

targetScope = 'subscription'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' =  {
  name: 'data-pros'
  location: 'centralus'
}

module database 'modules/database.bicep' = {
  name: 'datapros-database'
  scope: resourceGroup
  params: {
    sqlServerName: sqlServerName
    administratorLogin: administratorLogin
    administratorPassword: administratorPassword
    databaseName: databaseName
  }
}

module factory 'modules/factory.bicep' = {
  name: 'datapros-factory'
  scope: resourceGroup
  params: {
    dataFactoryName: dataFactoryName
  }
}
