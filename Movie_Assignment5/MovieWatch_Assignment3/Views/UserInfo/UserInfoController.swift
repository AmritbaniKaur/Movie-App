//
//  UserInfoController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/12/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

class UserInfoController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var userInfoView: UserInfoViewCellCollection!
    var defaults = UserDefaults.standard
    var ref: DatabaseReference!
    var profileurl: String?
    //let picker = UIImagePickerController()

    var appUser: AppUser?
    {
        didSet
        {
            //print("Value Set")
            //guard let username = appUser?.username else { return }
            //guard let profileurl = appUser?.profileurl else { return }
            
            //setupNavBarItems()
            //navigationItem.title = username
        }
    }
    
    func fetchUserInfo()
    {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        print("userId: ",userId)
        ref.child("users").child(userId).observeSingleEvent(of: .value){ (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            print("Data from user info: ", data)
            guard let username = data["username"] as? String else { return }
            guard let email = data["email"] as? String else { return }
            guard let profileurl = data["profileurl"] as? String else { return }
            self.appUser = AppUser(username: username, uid: userId, email: email, profileurl: profileurl)
        }
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ref = Database.database().reference()
        fetchUserInfo()

        view.backgroundColor = UIColor.brown
        // Do any additional setup after loading the view.
        //navigationItem.hide
        setupViews()

        //navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: nil, action: #selector(handleGoBack))
    }

    func setupViews()
    {
        //guard let username = appUser?.username else { return }

        let signUpView = UserInfoViewCellCollection(frame: self.view.frame)
        self.userInfoView = signUpView
        self.userInfoView.submitAction = submitPressed
        self.userInfoView.cancelAction = cancelPressed
        self.userInfoView.uploadImageAction = uploadImagePressed
        
        view.addSubview(userInfoView)
        
        //let userId = Auth.auth().currentUser?.uid
        self.userInfoView.emailTextField.text = appUser?.email!
        self.userInfoView.nameTextField.text = appUser?.username!
        
        if let profileImageUrl = appUser?.profileurl{
            self.userInfoView.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
        }
        
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
            self.userInfoView.profileImageView.image = selectedImage
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
        //guard let email = userInfoView.emailTextField.text else { return }
        //guard let password = userInfoView.passwordTextField.text else { return }
        guard let name = userInfoView.nameTextField.text else { return }
        
        // upload profile image
        let imageName = UUID().uuidString
        print("imageName: ", imageName)
        
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        print("storageRef: ", storageRef)
        print("self.signUpView.profileImageView.image: ", self.userInfoView.profileImageView.image!)
        
        // Compress Image into JPEG type
        if let profileImage = self.userInfoView.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1)
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
                
                let uid = Auth.auth().currentUser!.uid
                print("UserInfo Uid: ", uid)
                
                let usersReference = self.ref.child("users").child(uid)
                let values = ["username": name]
                
                usersReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
                    
                    if err != nil {
                        print(err ?? "")
                        return
                    }
                    print("Value Updated!")
                    self.dismiss(animated: true, completion: nil)
                })
                /*
                let userData: [String: Any] = [
                    "username" : name,
                    "email" : email,
                    "password" : password,
                    "profileurl" : self.profileurl
                ]
              
                        guard let uid = Auth.auth().currentUser?.uid else { return }
                        print("uid: ", uid)
                        self.ref.child("users/\(uid)").setValue(userData)
                        self.defaults.set(false, forKey: "UserIsLoggedIn")
                        print("Successfully created a user:", uid)
                        self.dismiss(animated: true, completion: nil)
                //    }
                    */
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
    @objc func handleGoBack()
    {
        print("Back to Table View!")
        //do{
        let goBackCon = UINavigationController(rootViewController: MovieTableViewController())
        present(goBackCon, animated: true, completion: nil)
        //}
        //catch let err
        //{
        //    print(err.localizedDescription)
        //}
    }*/
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
