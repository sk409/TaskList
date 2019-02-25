import Foundation
import UIKit

class Application: NSObject {
    
    static let sShared = Application()
    static var shared: Application {
        get { return sShared }
    }
    
    private var mLogger: Logger = ConsoleLogger()
    private var mDatabaseConfiguration = DatabaseConfiguration()
    var logger: Logger {
        get { return mLogger }
        set { mLogger = newValue }
    }
    var databaseConfiguration: DatabaseConfiguration {
        get { return mDatabaseConfiguration }
        set { mDatabaseConfiguration = newValue }
    }
    
    static func getCurrentViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return getCurrentViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getCurrentViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return getCurrentViewController(controller: presented)
        }
        return controller
    }
    
    func initialize() {
        loadDatabaseConfiguration()
        if DatabaseManager.isExistDatabase(configuration: mDatabaseConfiguration) {
            if !DatabaseManager.isExitTable(configuration: mDatabaseConfiguration) {
                _ = DatabaseManager.createTable(configuration: mDatabaseConfiguration)
            }
        } else {
            _ = DatabaseManager.createDataBase(configuration: mDatabaseConfiguration)
            _ = DatabaseManager.createTable(configuration: mDatabaseConfiguration)
        }
    }
    
    func loadDatabaseConfiguration() {
        guard let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let path = url.appendingPathComponent("DatabaseConfiguration.json").path
        if !FileManager.default.fileExists(atPath: path) {
            saveDatabaseConfiguration(DatabaseConfiguration.default)
        }
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)) else {
            return
        }
        guard let databaseConfiguration = try? JSONDecoder().decode(DatabaseConfiguration.self, from: data) else {
            return
        }
        mDatabaseConfiguration = databaseConfiguration
    }
    
    func saveDatabaseConfiguration(_ configuration: DatabaseConfiguration) {
        guard let url = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first else {
            return
        }
        let path = url.appendingPathComponent("DatabaseConfiguration.json").path
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(configuration)
            guard let json = String(data: data, encoding: .utf8) else {
                return
            }
            try json.write(toFile: path, atomically: true, encoding: .utf8)
        } catch {
            self.log(message: "DatabaseConfiguration.jsonの保存に失敗しました")
            self.log(message: error.localizedDescription)
        }
    }
    
    func saveDatabaseConfiguration(userName: String, password: String, dataBaseName: String, serverHost: String, dataBaseHost: String, tableName: String) {
        saveDatabaseConfiguration(DatabaseConfiguration(userName: userName, password: password, databaseName: dataBaseName, serverHost: serverHost, databaseHost: dataBaseHost, tableName: tableName))
    }
    
    func notification(funcdation: UIViewController, title: String, message: String) {
        notification(foundation: funcdation, title: title, message: message, actionHandler: nil)
    }
    
    func notification(foundation: UIViewController, title: String, message: String, actionHandler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let closeButton = UIAlertAction(title: "閉じる", style: .default, handler: actionHandler)
        alert.addAction(closeButton)
        foundation.present(alert, animated: true)
    }
    
    func notification(foundation: UIViewController, message: String) {
        notification(foundation: foundation, title: "", message: message, actionHandler: nil)
    }
    
    func notification(foundation: UIViewController, message: String, actionHandler: ((UIAlertAction) -> Void)?) {
        notification(foundation: foundation, title: "", message: message, actionHandler: actionHandler)
    }
    
    func warning(foundation: UIViewController, message: String) {
        warning(foundation: foundation, message: message, actionHandler: nil)
    }
    
    func warning(foundation: UIViewController, message: String, actionHandler: ((UIAlertAction) -> Void)?) {
        notification(foundation: foundation, title: "警告", message: message, actionHandler: actionHandler)
    }
    
    func error(foundation: UIViewController, message: String) {
        error(foundation: foundation, message: message, actionHandler: nil)
    }
    
    func error(foundation: UIViewController, message: String, actionHandler: ((UIAlertAction) -> Void)?) {
        notification(foundation: foundation, title: "エラー", message: message, actionHandler: actionHandler)
    }
    
    func log(message: String) {
        mLogger.write(message: message)
    }
    
    private override init() {
        
    }
    
}
