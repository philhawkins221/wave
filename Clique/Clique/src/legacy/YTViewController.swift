//
//  YTViewController.swift
//  Clique
//
//  Created by Phil Hawkins on 3/30/16.
//  Copyright © 2016 Phil Hawkins. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class YTViewController: UIViewController, WKNavigationDelegate {

    let webview = WKWebView()
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var selectbutton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        selectbutton.enabled = false
        webview.navigationDelegate = self
        webview.frame = square.frame
        webview.configuration.allowsInlineMediaPlayback = true
        webview.allowsBackForwardNavigationGestures = true
        if #available(iOS 9.0, *) {
            webview.allowsLinkPreview = true
        }
        view.addSubview(webview)
        
        fetch()
    }
    
    func fetch() {
        func plus(string: String) -> String {
            var result = ""
            
            for c in string.characters {
                if c == " " {
                    result += "+"
                } else {
                    result.append(c)
                }
            }
            
            result = result.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) ?? ""
            return result
        }
        
        webview.loadRequest(NSURLRequest(URL: NSURL(string: "https://www.youtube.com/results?search_query=" + plus(searchsong.lowercaseString) + "+" + plus(searchartist.lowercaseString))!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - WebView Stack
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        print("loaded: " + webview.URL!.absoluteString)
        if webview.URL!.absoluteString.containsString("search_query") {
            selectbutton.enabled = false
        } else if webview.URL!.absoluteString.containsString("watch") {
            selectbutton.enabled = true
        }
    }
    
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        print("loaded: " + webview.URL!.absoluteString)
        if webview.URL!.absoluteString.containsString("search_query") {
            selectbutton.enabled = false
        } else if webview.URL!.absoluteString.containsString("watch") {
            selectbutton.enabled = true
        }
        
        decisionHandler(.Allow)
        webview.reloadFromOrigin()
    }
    
    @IBAction func goBack(sender: AnyObject) {
        webview.goBack()
    }
    
    @IBAction func goForward(sender: AnyObject) {
        webview.goForward()
    }
    
    @IBAction func selectVideo(sender: AnyObject) {
        var newytid = webview.URL!.absoluteString
        newytid = newytid[newytid.characters.count - 11..<newytid.characters.count]
        
        let add = UIAlertController(title: "Add Song", message: "Add this song to clique?", preferredStyle: .Alert)
        add.addAction(UIAlertAction(title: "Nevermind", style: .Cancel, handler: {action in }))
        add.addAction(UIAlertAction(title: "Add", style: .Default, handler: {action in
            var parameters = [String : AnyObject]()
            parameters = [
                "name": searchsong,
                "artist": searchartist,
                "mpid": "",
                "ytid": newytid,
                "spid": "",
                "amid": "",
                "scid": "",
                "votes": 0,
                "played": false,
                "radio": false
            ]
            
            Alamofire.request(.PUT, "http://clique2016.herokuapp.com/playlists/" + currentclique.id + "/addSong", parameters: parameters as [String : AnyObject], encoding: .JSON)
        }))
        
        self.presentViewController(add, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
