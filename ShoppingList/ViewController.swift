//
//  ViewController.swift
//  ShoppingList
//
//  Created by Berkay KILIÇ on 1.11.2022.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var selectedName = ""
    var selectedID : UUID?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
    }
    
    
    @objc func getData() {
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for sonuc in results as! [NSManagedObject] {
                    if let name = sonuc.value(forKey: "name") as? String {
                        nameArray.append(name)
                    }
                    if let id = sonuc.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                    
                
                }
                tableView.reloadData()
            }
            
        }catch {
            print("Error Detected")
        }
        
    }
    
    @objc func addButtonClicked() {
        selectedName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.selectedProductName = selectedName
            destinationVC.selectedProductID = selectedID
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedName = nameArray[indexPath.row]
        selectedID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            
            let uuidString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                    
                    for sonuc in results as! [NSManagedObject] {
                        
                        if let id = sonuc.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row] {
                                
                                context.delete(sonuc)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
                                
                                self.tableView.reloadData()
                                
                                do{
                                    try context.save()
                                }
                                catch{
                                    
                                }
                                break
                                
                            }
                        }
                        
                    }
                    
                }
            }catch{
                print("Error detected")
            }
        }
    }
    


}

