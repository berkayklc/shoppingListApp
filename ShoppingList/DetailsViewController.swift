//
//  DetailsViewController.swift
//  ShoppingList
//
//  Created by Berkay KILIÇ on 6.11.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var sizeTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    
    
    var selectedProductName = ""
    var selectedProductID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedProductName != "" {
            
            saveButton.isHidden = true
            //Core Data seçilen ürün bilgilerini göster
            if let uuidString = selectedProductID?.uuidString {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
                
                do{
                    let results = try context.fetch(fetchRequest)
                    
                    if results.count > 0 {
                        
                        for sonuc in results as! [NSManagedObject] {
                            if let name = sonuc.value(forKey: "name") as? String {
                                nameTextField.text = name
                            }
                            if let price = sonuc.value(forKey: "price") as? Int {
                                priceTextField.text = String(price)
                            }
                            if let size = sonuc.value(forKey: "size") as? String {
                                sizeTextField.text = size
                            }
                            if let pictureData = sonuc.value(forKey: "image") as? Data {
                                let image = UIImage(data: pictureData)
                                imageView.image = image
                            }
                        }
                        
                    }
                    
                }catch{
                    print("Error Detected")
                }
                
                
                
                
                
                
            }
            
        }
        else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            nameTextField.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
            
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewClicked))
        imageView.addGestureRecognizer(imageGestureRecognizer)

       
    }
    @objc func imageViewClicked() {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @objc func closeKeyboard () {
        
        view.endEditing(true)
    }
    
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        
        shopping.setValue(nameTextField.text!, forKey: "name")
        shopping.setValue(sizeTextField.text!, forKey: "size")
        
        if let price = Int(priceTextField.text!){
            shopping.setValue(price, forKey: "price")
        }
        // universal unique id
        
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("Data Saved")
        }
        catch {
            print("Error Detected")
        }
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "veriGirildi"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
        
        
    }
    

   


}
