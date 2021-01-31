//
//  ContentView.swift
//  apiWebsocket
//
//  Created by Law, Michael on 1/31/21.
//

import SwiftUI
import Foundation

// Copied from
// https://medium.com/better-programming/websockets-in-swift-using-urlsessions-websockettask-bc372c47a7b3
class WebSocket: NSObject, URLSessionWebSocketDelegate {
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        print("Web Socket did connect")
    }
    
    func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        print("Web Socket did disconnect")
    }
}

struct ContentView: View {
    

    
    var body: some View {
        VStack {
            Button("connect") {
                let webSocketDelegate = WebSocket()
                let session = URLSession(configuration: .default, delegate: webSocketDelegate, delegateQueue: OperationQueue())
                let url = URL(string: "wss://[REPLACE_ME].execute-api.[REGION].amazonaws.com/[STAGE]")!
                let webSocketTask = session.webSocketTask(with: url)
                webSocketTask.resume()
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
