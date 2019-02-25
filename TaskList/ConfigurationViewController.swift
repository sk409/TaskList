import UIKit

class ConfigurationViewController: UIViewController {
    
    
    @IBOutlet weak var mUserName: UITextField!
    @IBOutlet weak var mPassword: UITextField!
    @IBOutlet weak var mDatabaseName: UITextField!
    @IBOutlet weak var mTableName: UITextField!
    @IBOutlet weak var mServerHost: UITextField!
    @IBOutlet weak var mDatabaseHost: UITextField!
    
    private var mNotificationMessageQueue: [String] = []
    private var mAlertFunctions: [(UIViewController, String, ((UIAlertAction) -> Void)?) -> Void] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let configuration = Application.shared.databaseConfiguration
        mUserName.text = configuration.userName
        mPassword.text = configuration.password
        mDatabaseName.text = configuration.databaseName
        mServerHost.text = configuration.serverHost
        mDatabaseHost.text = configuration.databaseHost
        mTableName.text = configuration.tableName
        mNotificationMessageQueue.reserveCapacity(2)
        mAlertFunctions.reserveCapacity(2)
    }
    
    
    @IBAction func save(_ sender: Any) {
        guard let userName = mUserName.text,
              let password = mPassword.text,
              let databaseName = mDatabaseName.text,
              let serverHost = mServerHost.text,
              let databaseHost = mDatabaseHost.text,
              let tableName = mTableName.text
        else {
            return
        }
        let newConfiguration = DatabaseConfiguration(userName: userName, password: password, databaseName: databaseName, serverHost: serverHost, databaseHost: databaseHost, tableName: tableName)
        let successful = createDatabaseAndTableIfNotExist(newConfiguration: newConfiguration)
        notifyUser(successful: successful, newConfiguration: newConfiguration)
    }
    
    private func createDatabaseAndTableIfNotExist(newConfiguration: DatabaseConfiguration) -> Bool {
        mNotificationMessageQueue.removeAll()
        var successful = true
        let isExistDatabase = DatabaseManager.isExistDatabase(configuration: newConfiguration)
        if isExistDatabase {
            let isExistTable = DatabaseManager.isExitTable(configuration: newConfiguration)
            if !isExistTable {
                successful = DatabaseManager.createTable(configuration: newConfiguration)
                if successful {
                    mNotificationMessageQueue.append("テーブルの作成に成功しました")
                    mAlertFunctions.append(Application.shared.notification)
                } else {
                    mNotificationMessageQueue.append("テーブルの作成に失敗しました")
                    mAlertFunctions.append(Application.shared.warning)
                }
            }
        } else {
            successful = DatabaseManager.createDataBase(configuration: newConfiguration)
            if successful {
                mNotificationMessageQueue.append("データベースの作成に成功しました")
                mAlertFunctions.append(Application.shared.notification)
                successful = DatabaseManager.createTable(configuration: newConfiguration)
                if successful {
                    mNotificationMessageQueue.append("テーブルの作成に成功しました")
                    mAlertFunctions.append(Application.shared.notification)
                } else {
                    mNotificationMessageQueue.append("テーブルの作成に失敗しました")
                    mAlertFunctions.append(Application.shared.warning)
                }
            } else {
                mNotificationMessageQueue.append("データベースの作成に失敗しました")
                mAlertFunctions.append(Application.shared.warning)
            }
        }
        return successful
    }
    
    private func notifyUser(successful: Bool, newConfiguration: DatabaseConfiguration) {
        if successful {
            Application.shared.saveDatabaseConfiguration(newConfiguration)
            Application.shared.loadDatabaseConfiguration()
            mNotificationMessageQueue.append("データベースの設定を保存しました")
            mAlertFunctions.append(Application.shared.notification)
        }
        DispatchQueue.global().async {
            for messageIndex in 0..<self.mNotificationMessageQueue.count {
                let semaphore = DispatchSemaphore(value: 0)
                DispatchQueue.main.async {
                    let message = self.mNotificationMessageQueue[messageIndex]
                    let alertFunction = self.mAlertFunctions[messageIndex]
                    alertFunction(self, message) { _ in
                        semaphore.signal()
                        guard messageIndex == (self.mNotificationMessageQueue.count - 1) && successful else {
                            return
                        }
                        guard let navigationController = self.navigationController else {
                            return
                        }
                        navigationController.popViewController(animated: true)
                    }
                }
                semaphore.wait()
            }
        }
    }
    
}
