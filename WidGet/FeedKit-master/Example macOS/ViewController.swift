//
//  ViewController.swift
//
//  Copyright (c) 2016 - 2018 Nuno Manuel Dias
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.
//

import Cocoa
import FeedKit

let feedURL = URL(string: "http://images.apple.com/main/rss/hotnews/hotnews.rss")!

class ViewController: NSViewController {
    @IBOutlet var feedTableView: NSTableView!
    @IBOutlet var feedItemsTableView: NSTableView!
    @IBOutlet var textView: NSTextView!

    var feed: RSSFeed?

    override func viewDidLoad() {
        super.viewDidLoad()

        let parser = FeedParser(URL: feedURL)

        // Parse asynchronously, not to block the UI.
        parser.parseAsync { [weak self] result in
            guard let self = self else { return }
            switch result {
            case let .success(feed):
                // Grab the parsed feed directly as an optional rss, atom or json feed object
                self.feed = feed.rssFeed

                // Or alternatively...
                //
                // switch feed {
                // case .rss(let feed): break
                // case .atom(let feed): break
                // case .json(let feed): break
                // }

                // Then back to the Main thread to update the UI.
                DispatchQueue.main.async {
                    self.feedItemsTableView.reloadData()
                }

            case let .failure(error):
                print(error)
            }
        }
    }

    // MARK: - Text View Helper

    func updateTextView() {
        let selectedRow = feedItemsTableView.selectedRow
        if selectedRow > -1 {
            let item = feed!.items![selectedRow]
            textView.string = item.description!
        }
    }
}

// MARK: - Table View Delegate

extension ViewController: NSTableViewDelegate {
    func tableView(_ tableView: NSTableView, viewFor _: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: nil) as? NSTableCellView else {
            return nil
        }

        switch tableView {
        case feedTableView:
            switch row {
            case 0: cell.textField?.stringValue = feed?.title ?? "[no title]"
            case 1: cell.textField?.stringValue = feed?.link ?? "[no link]"
            case 2: cell.textField?.stringValue = feed?.description ?? "[no description]"
            default: fatalError()
            }

        case feedItemsTableView:
            cell.textField?.stringValue = feed!.items![row].title ?? "[no title]"

        default: fatalError()
        }

        return cell
    }

    func tableViewSelectionDidChange(_: Notification) {
        updateTextView()
    }
}

// MARK: - Table View Data Source

extension ViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView {
        case feedTableView: return 3
        case feedItemsTableView: return feed?.items?.count ?? 0
        default: fatalError()
        }
    }
}
