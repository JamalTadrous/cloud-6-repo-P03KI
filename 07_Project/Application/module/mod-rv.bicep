param clientVar object
param webVmId string
//param admVmId string
//param mngName string
param recVltName string
//param kvUri string
param tags object
param webSrvName string
//param admSrvName string
var backupFabric = 'Azure'
//var protectionContainer = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${admSrvName}'
//var protectedItem = 'vm;iaasvmcontainerv2;${resourceGroup().name};${admSrvName}'
var protectionContainer2 = 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${webSrvName}'
var protectedItem2 = 'vm;iaasvmcontainerv2;${resourceGroup().name};${webSrvName}'

resource recoveryvault 'Microsoft.RecoveryServices/vaults@2021-08-01' = {
  name: recVltName
  location: clientVar.location
  tags:tags
  sku: {
    name: 'RS0'
    tier: 'Standard'
  }
    //properties: {
    // encryption:{
    //   // ------------  learn account limitation --------------
    //   // kekIdentity:{
    //   //   useSystemAssignedIdentity:true
    //   // }
    //   keyVaultProperties:{
    //     keyUri: kvUri
    //   }
    //}
  //}
  // identity:{
  //   type: 'SystemAssigned'
  // }
}

// resource backupAdmin 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
//   name: '${recoveryvault.name}/${backupFabric}/${protectionContainer}/${protectedItem}'
//   properties: {
//     protectedItemType: 'Microsoft.Compute/virtualMachines'
//     policyId: backupPolicyW.id
//     sourceResourceId: admVmId
//   }
//    dependsOn:[
//    backupWeb
//    ]
// } 
resource backupWeb 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2021-12-01' = {
  name: '${recVltName}/${backupFabric}/${protectionContainer2}/${protectedItem2}'
  location: clientVar.location
  properties: {
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    policyId: backupPolicy.id
    sourceResourceId: webVmId
    backupManagementType:'AzureIaasVM'
    backupSetName: 'LinuxBackup'
    containerName: 'LinuxBackup'
    createMode:'Default'
    workloadType:'VM'
  }
}
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2019-05-13' = {
  name: 'BackupPolicy'
  location: clientVar.location
  parent: recoveryvault
  properties: {
    backupManagementType: 'AzureIaasVM'
    instantRpRetentionRangeInDays:2
    retentionPolicy: {
      retentionPolicyType:'LongTermRetentionPolicy'
      dailySchedule:{
        retentionDuration:{
          count:7
          durationType:'Days'
        }
        retentionTimes:[
          '1'
        ]
      }
    }
    schedulePolicy: {
      schedulePolicyType:'SimpleSchedulePolicy'
      scheduleRunFrequency:'Daily'
      scheduleRunTimes:[
        '2022-03-01T01:00:00.00Z'
      ]
      scheduleWeeklyFrequency:0
      scheduleRunDays:[
        'Friday'
        'Monday'
        'Saturday'
        'Sunday'
        'Thursday'
        'Tuesday'
        'Wednesday'
      ]
  }
  timeZone: 'UTC'
  }
}
// resource backupPolicyW 'Microsoft.RecoveryServices/vaults/backupPolicies@2019-05-13' = {
//   name: 'BackupPolicyW'
//   location: clientVar.location
//   parent: recoveryvault
//   properties: {
//     protectedItemsCount: 1
//     backupManagementType: 'AzureIaasVM'
//     //instantRpRetentionRangeInDays: 1
//     retentionPolicy: {
//       retentionPolicyType:'LongTermRetentionPolicy'
//      dailySchedule:{
//        retentionDuration:{
//          count: 7
//          durationType:'Days'
//        }
//        retentionTimes:[
//          '1'
//        ]
//      }
//     }
//     schedulePolicy: {
//       schedulePolicyType:'LongTermSchedulePolicy'
//     }
//   timeZone: 'UTC'
//   }
// }
