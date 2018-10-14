import UIKit
import RealmSwift

class ViewController: UIViewController {
    private var realm: Realm!
    private var todoList: Results<TodoModel>!
    private var token: NotificationToken!
    @IBOutlet weak var tableView: UITableView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // RealmのTodoリストを取得し，更新を監視
        realm = try! Realm()
        todoList = realm.objects(TodoItem.self)
        token = todoList.observe { [weak self] _ in
            self?.reload()
        }
    }
    
    deinit {
        token.invalidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func addTodo(_ sender: Any) {
        // 新規Todo追加用のダイアログを表示
        let alert = UIAlertController(title: "新規Todo", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: nil)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let t = alert.textFields![0].text,
                !t.isEmpty {
                self.addTodoItem(title: t)
            }
        }))
        present(alert, animated: true)
    }
    
    func addTodoItem(title: String) {
        try! realm.write {
            realm.add(TodoItem(value: ["title": title]))
        }
    }
    
    func deleteTodoItem(at index: Int) {
        try! realm.write {
            realm.delete(todoList[index])
        }
    }
    
    func reload() {
        tableView.reloadData()
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoItem", for: indexPath)
        cell.textLabel?.text = todoList[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        deleteTodoItem(at: indexPath.row)
    }
}

