

class DatabaseManager {
    
    static func isExistDatabase(configuration: DatabaseConfiguration) -> Bool {
        let userName = configuration.userName
        let password = configuration.password
        let serverHost = configuration.serverHost
        let databaseHost = configuration.databaseHost
        let databaseName = configuration.databaseName
        return isExist(intermediate: "check_existence_database.php",
                       serverHost: serverHost,
                       queries: ["userName": userName,
                                 "password": password,
                                 "databaseHost": databaseHost,
                                 "databaseName": databaseName
            ])
    }
    
    static func isExitTable(configuration: DatabaseConfiguration) -> Bool {
        let userName = configuration.userName
        let password = configuration.password
        let serverHost = configuration.serverHost
        let databaseHost = configuration.databaseHost
        let databaseName = configuration.databaseName
        let tableName = configuration.tableName
        return isExist(intermediate: "check_existence_table.php",
                       serverHost: serverHost,
                       queries: ["userName": userName,
                                 "password": password,
                                 "databaseHost": databaseHost,
                                 "databaseName": databaseName,
                                 "tableName": tableName
            ])
    }
    
    static func createDataBase(configuration: DatabaseConfiguration) -> Bool {
        let userName = configuration.userName
        let password = configuration.password
        let serverHost = configuration.serverHost
        let databaseHost = configuration.databaseHost
        let databaseName = configuration.databaseName
        return create(
            intermediate: "create_database.php",
            serverHost: serverHost,
            queries: ["userName": userName,
                      "password": password,
                      "databaseHost": databaseHost,
                      "databaseName": databaseName,
                      ],
            target: "Database")
    }
    
    static func createTable(configuration: DatabaseConfiguration) -> Bool {
        let userName = configuration.userName
        let password = configuration.password
        let serverHost = configuration.serverHost
        let databaseHost = configuration.databaseHost
        let databaseName = configuration.databaseName
        let tableName = configuration.tableName
        return create(
            intermediate: "create_table.php",
            serverHost: serverHost,
            queries: ["userName": userName,
                      "password": password,
                      "databaseHost": databaseHost,
                      "databaseName": databaseName,
                      "tableName": tableName,
                      ],
            target: "Table")
    }
    
    static private func isExist(intermediate: String, serverHost: String, queries: [String: String]) -> Bool {
        let stringURL = "http://\(serverHost)/\(intermediate)"
        guard var session = DatabaseSession(with: stringURL) else {
            return false
        }
        let response = session.sync(queries: queries, method: .get)
        guard let data = response.data else {
            return false
        }
        guard let text = String(data: data, encoding: .utf8) else {
            return false
        }
        guard let isExist = Bool(text) else {
            return false
        }
        return isExist
    }
    
    static private func create(intermediate: String, serverHost: String, queries: [String: String], target: String) -> Bool {
        let stringURL = "http://\(serverHost)/\(intermediate)"
        guard var session = DatabaseSession(with: stringURL) else {
            return false
        }
        let response = session.sync(queries: queries, method: .post)
        guard let data = response.data else {
            return false
        }
        guard let result = String(data: data, encoding: .utf8) else {
            return false
        }
        let successful = result == "OK"
        return successful
    }
    
    private init() {
        
    }
    
}
