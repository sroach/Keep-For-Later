//
//  ShareViewController.swift
//  KeepForLaterShare
//
//  Created by Steve Roach on 7/19/26.
//

import UIKit
import Social
import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import os

class ShareViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    private func setupView() {
        autoreleasepool {
            extractData { [weak self] url, snippet in
                guard let self = self else { return }
                
                let shareView = ShareView(
                    url: url,
                    snippet: snippet,
                    onSave: { title, note in
                        self.saveAndFinish(url: url, snippet: snippet, title: title, note: note)
                    },
                    onCancel: {
                        self.cancel()
                    }
                )
                
                let hostingController = UIHostingController(rootView: shareView)
                self.addChild(hostingController)
                self.view.addSubview(hostingController.view)
                hostingController.view.translatesAutoresizingMaskIntoConstraints = false
                
                NSLayoutConstraint.activate([
                    hostingController.view.topAnchor.constraint(equalTo: self.view.topAnchor),
                    hostingController.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
                    hostingController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                    hostingController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
                ])
                
                hostingController.didMove(toParent: self)
            }
        }
    }

    private func extractData(completion: @escaping (String?, String?) -> Void) {
        guard let item = (extensionContext?.inputItems as? [NSExtensionItem])?.first,
              let providers = item.attachments else {
            completion(nil, nil)
            return
        }
        
        var foundURL: String?
        var foundSnippet: String?
        let group = DispatchGroup()
        
        // 1. Try to find the URL provider first
        if let urlProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.url.identifier) }) {
            group.enter()
            urlProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { (item, error) in
                DispatchQueue.main.async {
                    if let url = item as? URL {
                        foundURL = url.absoluteString
                    } else if let str = item as? String {
                        foundURL = str
                    }
                    group.leave()
                }
            }
        }
        
        // 2. Try to find the Plain Text provider (often the title or snippet)
        // We only load this if we don't have a snippet yet or to find a backup URL
        if let textProvider = providers.first(where: { $0.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) }) {
            group.enter()
            textProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { (item, error) in
                DispatchQueue.main.async {
                    if let text = item as? String {
                        if text.lowercased().hasPrefix("http") {
                            if foundURL == nil {
                                foundURL = text
                            }
                        } else {
                            if foundSnippet == nil {
                                foundSnippet = text
                            }
                        }
                    }
                    group.leave()
                }
            }
        }
        
        // Safety synchronization
        var completed = false
        let finish = {
            if !completed {
                completed = true
                completion(foundURL, foundSnippet)
            }
        }
        
        group.notify(queue: .main) {
            finish()
        }
        
        // Forced timeout after 1.5 seconds to prevent "long delay"
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            finish()
        }
    }

    private func saveAndFinish(url: String?, snippet: String?, title: String?, note: String?) {
        let container = SharedContainer.modelContainer
        let handler = ShareExtensionHandler(modelContext: container.mainContext)
        
        do {
            try handler.saveItem(url: url, snippet: snippet, title: title, note: note)
            extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        } catch {
            Logger.shareExtension.error("Failed to save item from extension: \(error.localizedDescription)")
            // Optionally show an error alert here
            extensionContext?.cancelRequest(withError: error)
        }
    }

    private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(domain: "UserCancelled", code: 0, userInfo: nil))
    }
}
