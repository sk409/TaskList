import UIKit

class TaskListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak private var tableView: UITableView!
    @IBOutlet weak var sideMenuTrailingConstraint: NSLayoutConstraint!
    @IBOutlet var searchConditions: [UITextField]!
    @IBOutlet weak var searchConditionOfTitle: UITextField!
    @IBOutlet weak var searchConditionOfContents: UITextField!
    private var isHiddenSideMenu = true
    private var taskArray: [Task] = []
    private var sideMenuBottomBorders: [CALayer] = []
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        configureSearchConditions()
        hideSideMenu()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let editViewController = segue.destination as? EditViewController {
            if segue.identifier == "Adding" {
                editViewController.setTask(task: Task(), isNew: true)
            } else {
                let indexPath = self.tableView.indexPathForSelectedRow
                let task = taskArray[indexPath!.row]
                editViewController.setTask(task: task, isNew: false)
            }
        }
    }
    
    @IBAction func toggleSideMenu(_ sender: Any) {
        if isHiddenSideMenu {
            showSideMenu()
        }else {
            hideSideMenu()
        }
        isHiddenSideMenu = !isHiddenSideMenu
        UIView.animate(withDuration: 0.3) {
            self.view.layer.layoutIfNeeded()
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        cell.detailTextLabel?.text = dateFormatter.string(from: task.date)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "Editing", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let configuration = Application.shared.databaseConfiguration
        if editingStyle == .delete {
            guard var session = DatabaseSession(with: configuration.getURLString(with: "delete.php")) else {
                return
            }
            let task = taskArray[indexPath.row]
            session.async(queries: configuration.getQueries(merge: ["id": String(task.id)]), method: .post) { data, response, error in
                guard let response = response as? HTTPURLResponse else {
                    return
                }
                if response.statusCode == HTTPResponseStatusCode.ok.rawValue && error == nil {
                    return
                }
                Application.shared.log(message: "タスクの削除中にエラーが発生しました。")
                Application.shared.log(message: "response: \(response)")
                Application.shared.log(message: "error: \(String(describing: error))")
                DispatchQueue.main.async {
                    Application.shared.warning(foundation: self, message: "タスクの削除に失敗しました")
                }
            }
            taskArray.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    private func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func configureSearchConditions() {
        searchConditions.forEach { (condition) in
            condition.addTarget(self, action: #selector(searchConditionChanged(_:)), for: .editingChanged)
        }
    }
    
    private func loadData() {
        let configuration = Application.shared.databaseConfiguration
        guard let titleCondition = searchConditionOfTitle.text else {
            return
        }
        guard let contentsCondition = searchConditionOfContents.text else {
            return
        }
        guard var session = DatabaseSession(with: configuration.getURLString(with: "get.php")) else {
            return
        }
        let queries = ["title": titleCondition, "contents": contentsCondition]
        session.async(queries: configuration.getQueries(merge: queries), method: .get) { data, _, _ in
            guard let data = data else {
                return
            }
            guard let text = String(data: data, encoding: .utf8) else {
                return
            }
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let json = (text).data(using: .utf8)!
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
            guard let taskArray = try? decoder.decode([Task].self, from: json) else {
                return
            }
            self.taskArray = taskArray
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @objc private func searchConditionChanged(_ textField: UITextField) {
        loadData()
    }
    
    private func hideSideMenu() {
        sideMenuTrailingConstraint.constant = -view.bounds.width
    }
    
    private func showSideMenu() {
        sideMenuTrailingConstraint.constant = 0
    }

}

