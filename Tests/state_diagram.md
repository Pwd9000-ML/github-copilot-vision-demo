
architecture-beta
    group api(cloud)[API]
    service master(databases)[databases] in api
    service pwd900webappdemo13577(sites)[sites] in api
    service webappdemo-db13577(databases)[databases] in api
    service webappdemo-plan-13577(serverfarms)[serverfarms] in api
    service webappdemo13577(storageAccounts)[storageAccounts] in api
    service webappdemosqlserver13577(servers)[servers] in api

    db:L -- R:server
    disk1:T -- B:server
    disk2:T -- B:db
