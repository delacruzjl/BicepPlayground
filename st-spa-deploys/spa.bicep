param name string
param location string


resource spa 'Microsoft.Web/staticSites@2021-02-01' = {
  name: name
  location: location
}
