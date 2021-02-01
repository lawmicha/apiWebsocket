//
//  ContentView.swift
//  apiWebsocket
//
//  Created by Law, Michael on 1/31/21.
//

import SwiftUI
import Foundation
import AWSCore

// Copied from
// https://medium.com/better-programming/websockets-in-swift-using-urlsessions-websockettask-bc372c47a7b3
class WebSocket: NSObject, URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("Errored")
    }
}

class ContentViewModel: ObservableObject {
    let webSocketDelegate: WebSocket
    let session: URLSession
    var webSocketTask: URLSessionWebSocketTask?
    
    let url = URL(string: "wss://endpint.execute-api.us-west-2.amazonaws.com/production")!
    let identityPool = "us-west-2:1332cbdc-1234-1234-1234-12341234"
    let region = AWSRegionType.USWest2
    
    init() {
        self.webSocketDelegate = WebSocket()
        self.session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
    }
    
    func signRequest() -> URL? {
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: region,
                                                                identityPoolId: identityPool)
        
        let endpoint = AWSEndpoint(region: region, service: .APIGateway, url: url)
        let keyPath = String(url.path.dropFirst())
        let requestHeaders: [String: String] = ["host": endpoint!.hostName]
        let task = AWSSignatureV4Signer
                    .generateQueryStringForSignatureV4(
                        withCredentialProvider: credentialsProvider,
                        httpMethod: .GET,
                        expireDuration: 60,
                        endpoint: endpoint!,
                        keyPath: keyPath,
                        requestHeaders: requestHeaders,
                        requestParameters: .none,
                        signBody: true)
        task.waitUntilFinished()
        if let error = task.error as NSError? {
            print("Error occurred: \(error)")
        }
        if let result = task.result {
            return result as URL
        }
        return nil
    }
    
    func connectWithoutSigning() {
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
    }
    
    func connectWithIAMSigning() {
        if let url = signRequest() {
            webSocketTask = session.webSocketTask(with: url)
            webSocketTask?.resume()
        } else {
            print("Could not sign URL")
        }
        
    }
}
struct ContentView: View {
    let vm = ContentViewModel()
    
    var body: some View {
        VStack {
            Button("connect without signing") {
                vm.connectWithoutSigning()
            }
            Button("connect with signing") {
                vm.connectWithIAMSigning()
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
