param dataFactoryName string
param sftpLinkedServiceName string
param sqlLinkedServiceName string
param blobLinkedServiceName string

var fileSchema = [
  {
    name: 'Customer Id'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'First Name'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Last Name'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Email'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Phone 1'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Phone 2'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'City'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Country'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Company'
    type: 'String'
    physicalType: 'String'
  }
  { 
    name: 'Subscription'
    type: 'DateTime'
    physicalType: 'DateTime'
  }
]

var tableSchema = [
  {
    name: 'Id'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'First'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Last'
    type: 'String'
    physicalType: 'String'
  }
  {
    name: 'Company'
    type: 'String'
    physicalType: 'String'
  }
]

var mapping = [
  {
    source: {
      name: 'Customer Id'
      type: 'String'
      physicalType: 'String'
    }
    sink: {
      name: 'Id'
      type: 'String'
      physicalType: 'String'
    }
  }
  {
    source: {
      name: 'First Name'
      type: 'String'
      physicalType: 'String'
    }
    sink: {
      name: 'First'
      type: 'String'
      physicalType: 'String'
    }
  }
  {
    source: {
      name: 'Last Name'
      type: 'String'
      physicalType: 'String'
    }
    sink: {
      name: 'Last'
      type: 'String'
      physicalType: 'String'
    }
  }
  {
    source: {
      name: 'Company'
      type: 'String'
      physicalType: 'String'
    }
    sink: {
      name: 'Company'
      type: 'String'
      physicalType: 'String'
    }
  }
]

module pipeline './pipeline.bicep' = {
  name: 'customer-pipeline-v2'
  params: {
    pipelineName: 'customer'
    dataFactoryName: dataFactoryName
    directory: '/home/u773941791/domains/thescreaminggoat.xyz/data'
    fileName: 'customers-10000.csv'
    sftpLinkedServiceName: sftpLinkedServiceName
    fileSchema: fileSchema
    sqlLinkedServiceName: sqlLinkedServiceName
    tableName: 'Customer'
    tableSchemaName: 'dbo'
    tableSchema: tableSchema
    mapping: mapping
    blobLinkedServiceName: blobLinkedServiceName
  }
}
