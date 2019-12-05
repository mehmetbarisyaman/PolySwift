//
//  ContentView.swift
//  Deneme12
//
//  Created by Mehmet Baris Yaman on 05.12.19.
//  Copyright © 2019 Baris. All rights reserved.
//

import SwiftUI
import SceneKit
import ModelIO
import ARKit

struct ContentView: View {
    var body: some View {
        ViewControllerWrapper()
    }
}

struct ViewControllerWrapper: UIViewControllerRepresentable {

    typealias UIViewControllerType = ViewController


    func makeUIViewController(context: UIViewControllerRepresentableContext<ViewControllerWrapper>) -> ViewControllerWrapper.UIViewControllerType {
        return ViewController()
    }

    func updateUIViewController(_ uiViewController: ViewControllerWrapper.UIViewControllerType, context: UIViewControllerRepresentableContext<ViewControllerWrapper>) {
        //
    }
}



