//
//  SignUpViewController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/10/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{

    var signUpView: SignUpViewCollection!
    var defaults = UserDefaults.standard
    var ref: DatabaseReference!
    var profileurl: String?
    //let picker = UIImagePickerController()

    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference()
        // Do any additional setup after loading the view.
        setupViews()
        //view.backgroundColor = .red
    }

    func setupViews()
    {
        let signUpView = SignUpViewCollection(frame: self.view.frame)
        self.signUpView = signUpView
        self.signUpView.submitAction = submitPressed
        self.signUpView.cancelAction = cancelPressed
        self.signUpView.uploadImageAction = uploadImagePressed
        
        view.addSubview(signUpView)
        signUpView.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    func uploadImagePressed()
    {
        print("upload Image Pressed!")
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary        
        
        // show Image Picker!!!! (Modally)
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            self.signUpView.profileImageView.image = selectedImage
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func submitPressed()
    {
        //print("Submit Button Pressed!")
        guard let email = signUpView.emailTextField.text else { return }
        guard let password = signUpView.passwordTextField.text else { return }
        guard let name = signUpView.nameTextField.text else { return }
        
        // upload profile image
        let imageName = UUID().uuidString
        print("imageName: ", imageName)
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        print("storageRef: ", storageRef)
        print("self.signUpView.profileImageView.image: ", self.signUpView.profileImageView.image!)
        
        // Compress Image into JPEG type
        if let profileImage = self.signUpView.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
        {
            print("uploadData: ", uploadData)
            //_ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
            _ = storageRef.putData(uploadData, metadata: nil) { (metadata, error) in
                print("metadata: ", metadata)
                guard let metadata = metadata else
                {
                    // Uh-oh, an error occurred!
                    print("Error when uploading profile image")
                    print("Error Details: ", error)
                    return
                }
                // Metadata contains file metadata such as size, content-type, and download URL.
                self.profileurl = metadata.downloadURL()?.absoluteString
                print("Selected Image profileurl: ", self.profileurl)
                
                let userData: [String: Any] = [
                    "username" : name,
                    "email" : email,
                    "password" : password,
                    "profileurl" : self.profileurl
                ]
                
                Auth.auth().createUserAndRetrieveData(withEmail: email, password: password) { (result, err) in
                    if let err = err
                    {
                        print(err.localizedDescription)
                    }
                    else
                    {
                        guard let uid = result?.user.uid else { return }
                        
                        self.ref.child("users/\(uid)").setValue(userData)
                        self.defaults.set(false, forKey: "UserIsLoggedIn")
                        print("Successfully created a user:", uid)
                        self.dismiss(animated: true, completion: nil)
                    }
                    
                }
            }
        }

    }
    
    func cancelPressed()
    {
        dismiss(animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}



