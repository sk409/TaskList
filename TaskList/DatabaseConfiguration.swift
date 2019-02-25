import Foundation

struct DatabaseConfiguration: Codable {
    
    static let `default` = DatabaseConfiguration(userName: "root", password: "root", databaseName: "taskdb", serverHost: "localhost:80", databaseHost: "localhost:3306", tableName: "task")
    
    let userName: String
    let password: String
    let databaseName: String
    let serverHost: String
    let databaseHost: String
    let tableName: String
    
    init() {
        self.userName = ""
        self.password = ""
        self.databaseName = ""
        self.serverHost = ""
        self.databaseHost = ""
        self.tableName = ""
    }
    
    init (userName: String, password: String, databaseName: String, serverHost: String, databaseHost: String, tableName: String) {
        self.userName = userName
        self.password = password
        self.databaseName = databaseName
        self.serverHost = serverHost
        self.databaseHost = databaseHost
        self.tableName = tableName
    }
    
    func getURLString(with intermediate: String) -> String {
        return "http://\(serverHost)/\(intermediate)"
    }
    
    func getQueries() -> [String: String] {
        return ["userName": userName, "password": password, "databaseName": databaseName, "databaseHost": databaseHost, "tableName": tableName]
    }
    
    func getQueries(merge: [String: String]) -> [String: String] {
        var queries = getQueries()
        queries.merge(merge, uniquingKeysWith: {(old, new) in new })
        return queries
    }
    
}
