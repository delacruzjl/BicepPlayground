param name string
param location string
param vmId string
param dailyOcurrenceTime string
param enableNotification bool = false
param notificationEmail string

resource scheduler 'microsoft.devtestlab/schedules@2018-09-15' = {
  name: name
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: dailyOcurrenceTime
    }
    timeZoneId: 'Eastern Standard Time'
    notificationSettings: {
      status: enableNotification ? 'Enabled' : 'Disabled'
      timeInMinutes: 30
      emailRecipient: notificationEmail
      notificationLocale: 'en'
    }
    targetResourceId: vmId
  }
}
