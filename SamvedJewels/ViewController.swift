//
//  ViewController.swift
//  wkwebview
//
//  Created by Devankkaranwal on 19/11/2023.
//

import UIKit
import WebKit
import Reachability
import Network
import FacebookLogin


class ViewController: UIViewController, WKNavigationDelegate, LoginButtonDelegate {
    
    @IBOutlet weak var webView: WKWebView!
    
    
//    var webView: WKWebView!
    var reachability: Reachability?
    var activityIndicator: UIActivityIndicatorView!
   

    override func loadView() {
        // Create and configure the WKWebView
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView

        // Create and configure the activity indicator
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.color = UIColor(red: 247/255, green: 231/255, blue: 133/255, alpha: 1.0)
        } else {
           
            activityIndicator = UIActivityIndicatorView(style: .large)
                activityIndicator.color = UIColor(red: 247/255, green: 231/255, blue: 133/255, alpha: 1.0)
        }

        // Add the activity indicator as a subview to the main view
        view.addSubview(activityIndicator)

        // Set up constraints to center the activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }


        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Initialize your Facebook login button
        let loginButton = FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = self

       //  Add the login button to your view
        view.addSubview(loginButton)
        loginButton.center = view.center

        // Set the status bar background color
        let app = UIApplication.shared
        let statusBarHeight: CGFloat = app.statusBarFrame.size.height

        let statusbarView = UIView()
        statusbarView.backgroundColor = UIColor(red: 247/255, green: 231/255, blue: 133/255, alpha: 1.0)
        view.addSubview(statusbarView)

        // Set up constraints for the status bar view
        statusbarView.translatesAutoresizingMaskIntoConstraints = false
        statusbarView.heightAnchor.constraint(equalToConstant: statusBarHeight).isActive = true
        statusbarView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
        statusbarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        statusbarView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        // Initialize Reachability
        reachability = try? Reachability()

        // Observe network status changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)

        do {
            // Start monitoring the network
            try reachability?.startNotifier()
        } catch {
            print("Unable to start reachability notifier")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Load the web page when the view is about to appear
        loadWebPage()
    }

//

    
    func loadWebPage() {
        print("Starting web page load")

        // Show the activity indicator before initiating the web page load
        activityIndicator.startAnimating()

        let url = URL(string: "https://www.samvedjewels.com")!
        let request = URLRequest(url: url)

        webView.load(request)
        webView.allowsBackForwardNavigationGestures = true

        // Simulate a delay of 2 seconds (adjust as needed)
        DispatchQueue.main.asyncAfter(deadline: .now() + 55.0) {
            // Stop the activity indicator after the delay
            self.activityIndicator.stopAnimating()
        }
    }




    
       override var preferredStatusBarStyle: UIStatusBarStyle {
           return .lightContent
       }
       
       
    

    
//
 
  
    @objc func reachabilityChanged() {
        if reachability?.connection == .unavailable {
            // Network is unavailable, show alert
            showNetworkUnavailableAlert()
        }
    }
    

    
    func showNetworkUnavailableAlert() {
        let alert = UIAlertController(title: "No Internet Connection", message: "Please check your network settings and try again.", preferredStyle: .alert)
        
        let reloadAction = UIAlertAction(title: "Reload", style: .default) { [weak self] (_) in
            // Clear the cache and reload the web page
            self?.clearCacheAndReload()
        }
        
        alert.addAction(reloadAction)
        present(alert, animated: true, completion: nil)
    }
    
    
    
    
    func clearCacheAndReload() {
        if let websiteURL = webView.url {
            let dataStore = WKWebsiteDataStore.default()
            dataStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
                dataStore.removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), for: records) {
                    // Reload the web page after clearing the cache
                    self.loadWebPage()
                }
            }
        } else {
            // If the web view doesn't have a URL, simply reload the page
            loadWebPage()
        }
    }
    

      deinit {
          // Stop monitoring the network when the view controller is deallocated
          reachability?.stopNotifier()
          NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
      }
   
    
    
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if let nsError = error as NSError?, nsError.domain == NSURLErrorDomain, nsError.code == NSURLErrorNotConnectedToInternet {
            // Handle the error, show an alert, etc.
            showNetworkUnavailableAlert()
        }
    }
    
    
    
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("Web page finished loading")
              DispatchQueue.main.async {
                 self.activityIndicator.stopAnimating()
              }
      }
    
    
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        
        if let url = navigationAction.request.url {
            print("url====================",url)
            
            
            if url.absoluteString.hasPrefix("https://www.facebook.com/samvedjewels/") {
                handleFacebookLoginRedirect(url)
                decisionHandler(.cancel)
                return
            }
            
            
            else if url.absoluteString.hasPrefix("https://twitter.com/i/flow/login?redirect_after_login=%2Fsamvedjewels%2F")

            {
                handleTwitterRedirect(url)
                decisionHandler(.cancel)
                
                return
            }
            
            
            else if url.absoluteString.hasPrefix("https://www.pinterest.com") {
                handlePinterestRedirect(url)
                decisionHandler(.cancel)
                return
            }
            
            
            else if url.absoluteString.hasPrefix("whatsapp://send") {
                handleWhatsAppRedirect(url)
                decisionHandler(.cancel)
                return
            }
            
            
            else if url.absoluteString.hasPrefix("https://www.linkedin.com") {
                // Handle LinkedIn login redirect
                handleLinkedInLoginRedirect(url)
                decisionHandler(.cancel)
                return
            }
            
            else if url.absoluteString.contains("https://www.youtube.com/@samvedjewels") {
                        // Open YouTube URLs in the WKWebView
                        decisionHandler(.allow)
                        return
                    }
            
            
            else if url.absoluteString.hasPrefix("https://www.youtube.com/@samvedjewels") {
                        // Open YouTube URLs in the WKWebView
                handleYoutubeRedirect(url)
                decisionHandler(.cancel)
                        return
                    }
            
     
            
            else if url.absoluteString.contains("https://www.instagram.com/samvedjewels/") {
                        // Open instagram URLs in the WKWebView
                        decisionHandler(.allow)
                        return
                    }
            
            else if url.absoluteString.hasPrefix("https://www.instagram.com/samvedjewels/") {
                        // Open instagram URLs in the WKWebView
//                        decisionHandler(.allow)
                handleInstagramLoginRedirect(url)
                decisionHandler(.cancel)
                        return
                    }
      
            
        }

        decisionHandler(.allow)
    }
    
    // MARK: - LoginButtonDelegate Methods

       func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
           if let error = error {
               // Handle login error
               print("Login error: \(error.localizedDescription)")
           } else if let result = result, result.isCancelled {
               // Handle login cancellation
               print("Login cancelled")
           } else {
               // Handle successful login
               print("Login successful")
           }
       }




       func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
           // Handle logout
           print("User logged out")
       }
    
    
    // MARK: - Facebook Login Methods

    
    func handleFacebookLoginRedirect(_ url: URL) {
        let loginManager = LoginManager()
        loginManager.logIn(permissions: [.publicProfile, .email], viewController: self) { loginResult in
            switch loginResult {
            case .success(granted: _, declined: _, token: _):
                print("Facebook login successful")
                // Handle successful login, e.g., dismiss login view or perform additional actions
            case .failed(let error):
                print("Facebook login failed: \(error)")
            case .cancelled:
                print("Facebook login cancelled")
            }
        }
    }

   //     MARK: - Instagram Login Methods

       func handleInstagramLoginRedirect(_ url: URL) {
           // Extract the access token from the URL
           if let accessToken = extractInstagramAccessToken(from: url) {
               print("Instagram login successful. Access Token: \(accessToken)")
               // Handle successful login, e.g., dismiss login view or perform additional actions
           } else {
               print("Failed to extract Instagram access token.")
           }
       }

       func extractInstagramAccessToken(from url: URL) -> String? {
           // Implement logic to extract the access token from the Instagram redirect URL
           // The structure of the URL depends on your Instagram App settings
           // Parse the URL and extract the necessary parameters
           // Return the extracted access token or nil if not found

           // Example: https://your-redirect-uri.com/#access_token=ACCESS_TOKEN&...
           if let fragment = URLComponents(string: url.absoluteString)?.fragment,
              let accessToken = fragment.components(separatedBy: "=").last {
               return accessToken
           }

           return nil
       }

    // MARK: - WhatsApp Redirect

    func handleWhatsAppRedirect(_ url: URL) {
        // Implement logic to handle the WhatsApp redirect
        // This might involve extracting data from the URL or performing specific actions
        print("WhatsApp redirect URL: \(url)")
    }

    // MARK: - LinkedIn Login Methods

        func handleLinkedInLoginRedirect(_ url: URL) {
            // Extract the authorization code or access token from the URL
            // Implement logic to handle the LinkedIn redirect
            // This might involve exchanging the authorization code for an access token
            print("LinkedIn redirect URL: \(url)")
        }

    // MARK: - Pinterest Redirect (Example)

     func handlePinterestRedirect(_ url: URL) {
         // Implement logic to handle the Pinterest redirect
         // This might involve extracting data from the URL or performing specific actions
         print("Pinterest redirect URL: \(url)")
     }

    // MARK: - Twitter Redirect

        func handleTwitterRedirect(_ url: URL) {
            // Implement logic to handle the Twitter redirect
            // This might involve extracting data from the URL or performing specific actions
            print("Twitter redirect URL: \(url)")
        }
    
    // MARK: - Youtube Redirect

        func handleYoutubeRedirect(_ url: URL) {
            // Implement logic to handle the Twitter redirect
            // This might involve extracting data from the URL or performing specific actions
            print("Youtube redirect URL: \(url)")
        }

    
    
}

