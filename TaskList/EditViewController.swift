import UIKit

class EditViewController: UIViewController {
    
    
    @IBOutlet weak private var taskTitle: UITextField!
    @IBOutlet weak private var taskContents: UITextView!
    @IBOutlet weak private var deadLine: UIDatePicker!
    
    private var mTask: Task!
    private var mIsNewTask = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTitle.text = mTask.title
        taskContents.text = mTask.contents
        deadLine.date = mTask.date
    }
    
    @IBAction func onViewTaped(_ sender: Any) {
        view.endEditing(true)
    }
    
    @IBAction func saveTask(_ sender: Any) {
        let configuration = Application.shared.databaseConfiguration
        let intermediate = mIsNewTask ? "insert.php" : "update.php"
        guard var session = DatabaseSession(with: configuration.getURLString(with: intermediate)) else {
            return
        }
        let queries = configuration.getQueries(merge: getQueries())
        let response = session.sync(queries: queries, method: .post)
        guard let data = response.data else {
            return
        }
        guard let text = String(data: data, encoding: .utf8) else {
            return
        }
        let succeeded = text == "OK"
        let method = mIsNewTask ? "タスクを作成" : "タスクを更新"
        let result = succeeded ? "しました" : "できませんでした"
        let message = method + result
        Application.shared.notification(foundation: self, title: "", message: message) { _ in
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func setTask(task: Task, isNew: Bool) {
        self.mTask = task
        self.mIsNewTask = isNew
    }
    
    private func getQueries() -> [String: String] {
        let title = taskTitle.text!
        let contents = taskContents.text!
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.string(from: deadLine.date)
        var queries = ["title": title, "contents": contents, "date": date]
        if !mIsNewTask {
            queries["id"] = String(mTask.id)
        }
        return queries
    }
    
}
