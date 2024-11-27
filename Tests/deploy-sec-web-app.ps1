# Log in to Azure
# az login --tenant 'b4fd7cff-510b-4da5-b133-f7aa6f692ee2'

# Declare variables for the deployment powershell script
#$resourceGroupName = "github-copilot-web-apps" ### (Fail back demo)
#$demoNumber = "535774434" ### (Fail back demo)
$resourceGroupName = "github-copilot-web-apps-demo"
$demoNumber = "1169056752"
$location = "uksouth"
$jsonContainerName = "webapp-resources-json"
$storageAccountName = "webappdemo$demoNumber"
$appServicePlanName = "webappdemo-plan-1"
$webAppName = "pwd900webappdemo1"
$sqlServerName = "webappdemosqlserver$demoNumber"
$sqlDatabaseName = "webappdemo-db1"

# Create Resource Group for the deployment based on the declared variables
az group create --name $resourceGroupName --location $location

# Create a blob storage account to store JSON files from the web app deployment
az storage account create --name $storageAccountName --resource-group $resourceGroupName --location $location --sku Standard_LRS

# Retrieve the storage account key
$storageAccountKey = az storage account keys list --resource-group $resourceGroupName --account-name $storageAccountName --query "[0].value" --output tsv

# create a container called "WebApp-resources-JSON" in the storage account to store the JSON files
az storage container create --name $jsonContainerName --account-name $storageAccountName --account-key $storageAccountKey

# Create App Service Plan for the Web App
az appservice plan create --name $appServicePlanName --resource-group $resourceGroupName --sku B1 --is-linux

# Create Web App with Managed Identity using "NODE:20-lts" runtime with the App Service Plan and name declared variables
az webapp create --name $webAppName --resource-group $resourceGroupName --plan $appServicePlanName --assign-identity --runtime "NODE:20-lts"

# Get the System Managed Identity for the web app to use as the SQL Server admin
$webAppPrincipalId = (az webapp identity show --name $webAppName --resource-group $resourceGroupName --query principalId --output tsv)

# Create SQL Server with AAD-only (EntraID-only) authentication and set the retrieved Web Apps managed Identity as admin 
az sql server create --name $sqlServerName --resource-group $resourceGroupName --enable-ad-only-auth --external-admin-principal-type 'Application' --external-admin-name $webAppName --external-admin-sid $webAppPrincipalId

# Create a SQL Database in the SQL Server
az sql db create --resource-group $resourceGroupName --server $sqlServerName --name $sqlDatabaseName --service-objective S0

# Set a sql server firewall-rule to "AllowAzureServices" to access SQL server created
az sql server firewall-rule create --resource-group $resourceGroupName --server $sqlServerName --name "AllowAzureServices" --start-ip-address 0.0.0.0 --end-ip-address 0.0.0.0

# Create a simple HTML file to use as the content for the web app
$htmlContent = @"
<!DOCTYPE html>
<html>
<head>
    <title>Azure Web App</title>
</head>
<body>
    <h1>Hello, Azure!</h1>
</body>
</html>
"@

# Save the HTML to a file named "index.html"
$htmlFile = "index.html"
$htmlContent | Out-File -FilePath $htmlFile

# Deploy the HTML file to the web app created
az webapp deploy source config-zip --name $webAppName --resource-group $resourceGroupName --src $htmlFile