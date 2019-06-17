//
//  EmojiArtDocumentTableViewController.swift
//  EmojiArt
//
//  Created by Stephen Cao on 17/6/19.
//  Copyright © 2019 Stephencao Cao. All rights reserved.
//

import UIKit

class EmojiArtDocumentTableViewController: UITableViewController {

    var emojiArtDocuments = ["one", "two", "three"]
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if splitViewController?.preferredDisplayMode != UISplitViewController.DisplayMode.primaryOverlay{
            splitViewController?.preferredDisplayMode = .primaryOverlay
        }
    }
    
    @IBAction func newEmojiArt(_ sender: Any) {
        emojiArtDocuments += ["Untitled".madeUnique(withRespectTo: emojiArtDocuments)]
        tableView.reloadData()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return emojiArtDocuments.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentCell", for: indexPath)
        cell.textLabel?.text = emojiArtDocuments[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            emojiArtDocuments.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.fade)
        }
    }

}
