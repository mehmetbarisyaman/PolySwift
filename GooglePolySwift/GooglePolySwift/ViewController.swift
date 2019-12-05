//
//  ViewController.swift
//  Deneme12
//
//  Created by Mehmet Baris Yaman on 05.12.19.
//  Copyright © 2019 Baris. All rights reserved.
//

import Foundation
import ARKit
import SceneKit
import ModelIO
import UIKit
import SceneKit.ModelIO

class ViewController: UIViewController, ARSCNViewDelegate, URLSessionDownloadDelegate {
    
    private var polyApiKey = "[YOUR_API_KEY]"
    private var polyBaseGetAssetUrl = "https://poly.googleapis.com/v1/assets"
    private var polyAssetId = "[ANY_OBJECT_EXTENSION]"
    private var fileURLsToDownload = [] as Array
    private var objPathURL: URL?
    private var mtlPathURL: URL?
    var arscn = ARSCNView()
    
    func getObjectFromPoly() {
        fileURLsToDownload = [AnyHashable]()
        let polyURLWithKey = "\(polyBaseGetAssetUrl)/\(polyAssetId)?key=\(polyApiKey)"
        let polyURL = URL(string: polyURLWithKey)
        var data: Data?
        var json: [AnyHashable: Any]?
        do {
            if let polyURL = polyURL {
                data = try Data(contentsOf: polyURL)
            }
            if let data = data {
                json = try JSONSerialization.jsonObject(with: data, options: []) as? [AnyHashable: Any]
            }
        } catch {
        }
        //var formats = json?.map { $0.formats } as? [AnyHashable]
        let formats = json?["formats"] as? [AnyHashable]
        let format = formats?[0] as? [AnyHashable: Any]
        let root = format?["root"] as? [AnyHashable: Any]
        let resources = format?["resources"] as? [AnyHashable]
        let resource = resources?[0] as? [AnyHashable: Any]
        if let value = root?["url"] {
            fileURLsToDownload.append(value)
        }
        if let value = resource?["url"] {
            fileURLsToDownload.append(value)
        }
    }
    
    func downloadFiles() {
        // Async download files.
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: OperationQueue.main)
        for fileURL in fileURLsToDownload {
            let url = URL(string: fileURL as? String ?? "")
            var downloadTask: URLSessionTask?
            if let url = url {
                downloadTask = session.downloadTask(with: url)
            }
            downloadTask?.resume()
        }
    }
    
    func loadobjectstoScene() {
        let mdlAsset = MDLAsset(url: objPathURL ?? URL.init(fileURLWithPath: ""))
        mdlAsset.loadTextures()
        let node = SCNNode(mdlObject: mdlAsset.object(at: 0))
        node.scale = SCNVector3Make(0.15, 0.15, 0.15)
        node.position = SCNVector3Make(0, -0.2, -0.8)

        let rotate = SCNAction.repeatForever(SCNAction.rotate(by: .pi, around: SCNVector3Make(0, 1, 0), duration: 3))
        node.runAction(rotate)
        arscn.scene.rootNode.addChildNode(node)
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let finalPath = URL(fileURLWithPath: documentsPath).appendingPathComponent(downloadTask.originalRequest?.url?.lastPathComponent ?? "")
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: finalPath.path) {
            do {
                try fileManager.removeItem(atPath: finalPath.path)
            } catch {
                print("ERROR IN REMOVING ITEM!!!")
            }
        }

        let finalPathURL = URL(fileURLWithPath: finalPath.path)
        do {
           try fileManager.moveItem(at: location, to: finalPathURL)
        } catch {
            print("ERROR IN MOVING ITEM!!!")
        }
        if finalPathURL.lastPathComponent.contains("obj") {
            objPathURL = finalPathURL
        } else if finalPathURL.lastPathComponent.contains("mtl") {
            mtlPathURL = finalPathURL
        }
        self.loadobjectstoScene()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arscn.frame = self.view.bounds
        arscn.delegate = self
        arscn.automaticallyUpdatesLighting = true
        arscn.autoenablesDefaultLighting = true
        getObjectFromPoly()
        downloadFiles()
        self.view.addSubview(arscn)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let configuration = ARWorldTrackingConfiguration()
        self.arscn.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.arscn.session.pause()
    }
}
