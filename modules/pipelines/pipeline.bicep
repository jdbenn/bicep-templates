param pipelineName string
param dataFactoryName string

param directory string
param fileName string
param sftpLinkedServiceName string
param fileSchema array = []

param sqlLinkedServiceName string
param tableSchemaName string
param tableName string
param tableSchema array = []

param mapping array = []

param triggerTime string = '00:00'
param triggerTimeZone string = 'Eastern Standard Time'
param triggerStartDate string = utcNow('yyyy-MM-dd')

param typeConversionSettings object = {
    allowTypePromotion: true
    allowTypeDemotion: true
    allowImplicitConversion: true
    treatBooleanAsNumber: true
}

param blobLinkedServiceName string

var ftpDatasetName = 'ftp${pipelineName}'
var sqlDatasetName = 'sql${pipelineName}'

resource dataFactory 'Microsoft.DataFactory/factories@2018-06-01' existing = {
  name: dataFactoryName
}

resource sftpLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' existing = {
  name: sftpLinkedServiceName
}

resource sqlLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' existing = {
  name: sqlLinkedServiceName
}

resource blobStorageLinkedService 'Microsoft.DataFactory/factories/linkedservices@2018-06-01' existing = {
  name: blobLinkedServiceName
}

resource ftpDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01'= {
  parent: dataFactory
  name: ftpDatasetName
  properties: {
    type: 'DelimitedText'
    linkedServiceName: {
      referenceName: sftpLinkedService.name
      type: 'LinkedServiceReference'
    }
    schema: empty(fileSchema) ? null : fileSchema
    typeProperties: {
      location: {
        type: 'FtpServerLocation'
        folderPath: directory
        fileName: fileName
      }
      columnDelimiter: ','
      escapeChar: '\\'  
      firstRowAsHeader: true
    }
  }
}

resource sqlDataset 'Microsoft.DataFactory/factories/datasets@2018-06-01' = {
  parent: dataFactory
  name: sqlDatasetName
  properties: {
    type: 'AzureSqlTable'
    linkedServiceName: {
      referenceName: sqlLinkedService.name
      type: 'LinkedServiceReference'
    }
    schema: empty(tableSchema) ? null : tableSchema
    typeProperties: {
      schema: tableSchemaName
      tableName: tableName
    }
  }
}

resource pipeline 'Microsoft.DataFactory/factories/pipelines@2018-06-01' = {
  parent: dataFactory
  name: pipelineName
  properties: {
    activities: [
      {
        name: 'Copy from FTP'
        type: 'Copy'
        inputs: [
          {
            referenceName: ftpDataset.name
            type: 'DatasetReference'
          }
        ]
        outputs: [
          {
            referenceName: sqlDataset.name
            type: 'DatasetReference'
          }
        ]
        typeProperties: {
          enableSkipIncompatibleRow: true
          logSettings: {
            enableCopyActivityLog: true
            copyActivityLogSettings: {
              logLevel: 'Warning'
            }
            logLocationSettings: {
              linkedServiceName: {
                referenceName: blobStorageLinkedService.name
                type: 'LinkedServiceReference'
              }
              path: 'logs/${pipelineName}'
            }
          }
          source: {
            type: 'DelimitedTextSource'
          }
          sink: {
            type: 'AzureSqlSink'
            preCopyScript: 'TRUNCATE TABLE ${tableSchemaName}.${tableName}'
          }
          translator: {
            type: 'TabularTranslator'
            mappings: empty(mapping) ? null : mapping
            typeConversionSettings: typeConversionSettings
          }
        }
      }
    ]
  }
}

resource scheduleTrigger 'Microsoft.DataFactory/factories/triggers@2018-06-01' = {
  parent: dataFactory
  name: '${pipelineName}-trigger'
  properties: {
    type: 'ScheduleTrigger'
    description: 'Daily trigger for ${pipelineName} pipeline'
    pipelines: [
      {
        pipelineReference: {
          referenceName: pipeline.name
          type: 'PipelineReference'
        }
        parameters: {}
      }
    ]
    typeProperties: {
      recurrence: {
        frequency: 'Day'
        interval: 1
        startTime: '${triggerStartDate}T${triggerTime}:00Z'
        timeZone: triggerTimeZone
      }
    }
  }
}

