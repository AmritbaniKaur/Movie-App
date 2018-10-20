//
//  LoginController.swift
//  MovieWatch_Assignment3
//
//  Created by Amritbani Sondhi on 4/9/18.
//  Copyright © 2018 Amritbani Sondhi. All rights reserved.
//

import UIKit
import Firebase

// should call MovieTableViewController
class LoginController: UIViewController
{

    var loginView : LoginViewCollection!
    var defaults = UserDefaults.standard
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.cyan
        setupView()
    }

    func setupView()
    {
        let mainView = LoginViewCollection(frame: self.view.frame)
        self.loginView = mainView
        self.loginView.loginAction = loginPressed
        self.loginView.signupAction = signupPressed
        
        self.view.addSubview(loginView)
        loginView.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loginPressed()
    {
        //print("Login Button Pressed!")
        guard let email = loginView.emailTextField.text else { return }
        guard let password = loginView.passwordTextField.text else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error
            {
                print(err.localizedDescription)
            }
            else
            {
                print("User: \(user?.uid) signed in")
                self.defaults.set(true, forKey: "UserIsLoggedIn")
                // show the movie Table view
                
                //let movieTableController = UINavigationController(rootViewController: MovieTableViewController())
                //self.present(movieTableController, animated: true, completion: nil)
                
                let customTabController = CustomTabBarController()//UINavigationController(rootViewController: CustomTabBarController())
                //self.present(customTabController, animated: true, completion: nil)
                self.navigationController?.pushViewController(customTabController, animated: true)

                //window?.rootViewController = CustomTabBarController()

                // pushviewController
            }
            
        }
    }
    
    func signupPressed()
    {
        //print("Sign Up Button Pressed!")
        let signUpController = SignUpViewController()
        present(signUpController, animated: true, completion: nil)
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

extension UIView
{
    func createStackView(views: [UIView]) -> UIStackView
    {
        let stackView = UIStackView(arrangedSubviews: views)
        stackView.axis = .vertical
        stackView.distribution = .fillProportionally
        stackView.spacing = 10
        return stackView
    }
}

extension UIButton
{
    public convenience init(title: String, borderColor: UIColor)
    {
        self.init()
        let attributedString = NSMutableAttributedString(attributedString: NSAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor.white]))
        self.setAttributedTitle(attributedString, for: .normal)
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 1
        self.layer.backgroundColor = UIColor(red: 75/255, green: 10/255, blue: 115/255, alpha: 0.35).cgColor
        self.layer.borderColor = borderColor.cgColor
        self.setAnchor(width: 0, height: 40)
    }
}

extension UITextField
{
    public convenience init(title: String, borderColor: UIColor)
    {
        self.init()

        self.borderStyle = .none
        self.layer.cornerRadius = 5
        //self.backgroundColor = UIColor(red: 75/255, green: 75/255, blue: 75/255, alpha: 0.5)
        self.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
        self.borderStyle = UITextBorderStyle.roundedRect // .bezel
        self.layer.borderWidth = 1
        self.layer.borderColor = borderColor.cgColor
        self.textColor = UIColor(white: 1, alpha: 1)
        self.font = UIFont.systemFont(ofSize: 17)
        self.autocorrectionType = .no
        // placeholder
        var placeholder = NSMutableAttributedString()
        placeholder = NSMutableAttributedString(attributedString: NSMutableAttributedString(string: title, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18), .foregroundColor: UIColor(white:1, alpha:0.7)]))
        self.attributedPlaceholder = placeholder
        self.setAnchor(width: 0, height: 40)
        self.setLeftPaddingPoints(15)
    }
    
    func setLeftPaddingPoints(_ space: CGFloat)
    {
        let paddingView = UIView(frame: CGRect(x: 0, y:0, width: space, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

extension UIView
{
    func setAnchor(width: CGFloat, height: CGFloat)
    {
        self.setAnchor(top:nil, left: nil, bottom: nil, right: nil, paddingTop:0, paddingLeft:0, paddingBottom:0, paddingRight:0,  width: width, height: height)
    }
    
    func setAnchor(top: NSLayoutYAxisAnchor?, left: NSLayoutXAxisAnchor?, bottom: NSLayoutYAxisAnchor?, right: NSLayoutXAxisAnchor?, paddingTop: CGFloat, paddingLeft: CGFloat, paddingBottom: CGFloat, paddingRight: CGFloat, width: CGFloat = 0, height: CGFloat = 0)
    {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top
        {
            self.topAnchor.constraint(equalTo: top, constant: paddingTop).isActive = true
        }
        
        if let left = left
        {
            self.leftAnchor.constraint(equalTo: left, constant: paddingLeft).isActive = true
        }
        
        if let bottom = bottom
        {
            self.bottomAnchor.constraint(equalTo: bottom, constant: paddingBottom).isActive = true
        }
        
        if let right = right
        {
            self.rightAnchor.constraint(equalTo: right, constant: paddingRight).isActive = true
        }
        
        if width != 0
        {
            self.widthAnchor.constraint(equalToConstant: width).isActive = true
        }
        
        if height != 0
        {
            self.heightAnchor.constraint(equalToConstant: height).isActive = true
        }
    }
    
    var safeTopAnchor: NSLayoutYAxisAnchor
    {
        if #available(iOS 11.0, *)
        {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeLeftAnchor: NSLayoutXAxisAnchor
    {
        if #available(iOS 11.0, *)
        {
            return safeAreaLayoutGuide.leftAnchor
        }
        return leftAnchor
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor
    {
        if #available(iOS 11.0, *)
        {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
    
    var safeRightAnchor: NSLayoutXAxisAnchor
    {
        if #available(iOS 11.0, *)
        {
            return safeAreaLayoutGuide.rightAnchor
        }
        return rightAnchor
    }
}
