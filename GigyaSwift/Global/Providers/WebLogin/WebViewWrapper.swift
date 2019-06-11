//
//  WebViewWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import WebKit

class WebLoginWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String?

    var webViewController: WebViewController?

    private var config: GigyaConfig?

    private let providerType: GigyaSocielProviders

    private var navigationController: UINavigationController?

    private var completionHandler: ((_ jsonData: [String: Any]?, _ error: String?) -> Void)? = nil

    required override init() {
        self.providerType = .google
    }

    init(config: GigyaConfig, providerType: GigyaSocielProviders) {
        self.providerType = providerType
        self.config = config
        self.webViewController = WebViewController()

        super.init()

        webViewConfig()
    }

    func webViewConfig() {
        guard let url = getUrl() else { return }

        webViewController?.setDelegate(delegate: self)

        webViewController?.loadUrl(url: url)

        webViewController?.userDidCancel = { [weak self] in
            self?.completionHandler?(nil, "sign in cancelled")
        }

    }

    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        completionHandler = completion
        
        navigationController = UINavigationController(rootViewController: webViewController!)

        if let navigationController = navigationController {
            viewController?.show(navigationController, sender: nil)
        }
    }

    func getUrl() -> URL? {
        var urlString = "https://socialize.\(config?.apiDomain ?? "")/socialize.login?"
        urlString.append("redirect_uri=gsapi://login_result&")
        urlString.append("response_type=token&")
        urlString.append("client_id=\(config?.apiKey ?? "")&")
        urlString.append("gmid=\(config?.gmid ?? "")&")
        urlString.append("ucid=\(config?.ucid ?? "")&")
        urlString.append("x_secret_type=oauth1&")
        urlString.append("x_endPoint=socialize.login&")
        urlString.append("x_sdk=\(InternalConfig.General.version)&")
        urlString.append("x_provider=\(providerType.rawValue)")

        guard let url = URL(string: urlString) else {
            GigyaLogger.log(with: WebLoginWrapper.self, message: "Cna't make URL")
            return nil
        }

        return url
    }
}

extension WebLoginWrapper: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if navigationAction.navigationType == .other {
            if let url = navigationAction.request.url {
                GigyaLogger.log(with: providerType.rawValue, message: "Log redirect url: \(url)")
                if
                    let status = url["status"],
                    status == "ok",
                    let accessToken = url["access_token"],
                    let tokenSecret = url["x_access_token_secret"] {
                    let json = ["status": status, "accessToken": accessToken, "tokenSecret": tokenSecret]
                        completionHandler?(json, nil)

                        // dismiss viewController
                        navigationController?.dismiss(animated: true, completion: nil)
                } else if let status = url["status"], status != "ok" {
                    completionHandler?(nil, "Failed to login")
                }
            }
        }
        decisionHandler(.allow)
    }
}
