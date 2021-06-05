//
//  ViewController.swift
//  Example
//
//  Created by Nabil on 05/10/17.
//  Copyright © 2017 Nabil. All rights reserved.
//

import SwiftSoup
import UIKit

class ViewController: UIViewController {
    typealias Item = (text: String, html: String)

    @IBOutlet var tableView: UITableView!
    @IBOutlet var urlTextField: UITextField!
    @IBOutlet var cssTextField: UITextField!

    // current document
    var document = Document("")
    // item founds
    var items: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "SwiftSoup Example"

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension

        urlTextField.text = "http://www.facebook.com"
        cssTextField.text = "div"

        // start first request
        downloadHTML()
    }

    // Download HTML
    func downloadHTML() {
        // url string to URL
        guard let url = URL(string: urlTextField.text ?? "") else {
            // an error occurred
            UIAlertController.showAlert("Error: \(urlTextField.text ?? "") doesn't seem to be a valid URL", self)
            return
        }

        do {
            // content of url
            let html = try String(contentsOf: url)
            // parse it into a Document
            document = try SwiftSoup.parse(html)
            // parse css query
            parse()
        } catch {
            // an error occurred
            UIAlertController.showAlert("Error: \(error)", self)
        }
    }

    // Parse CSS selector
    func parse() {
        do {
            // empty old items
            items = []
            // firn css selector
            let elements: Elements = try document.select(cssTextField.text ?? "")
            // transform it into a local object (Item)
            for element in elements {
                let text = try element.text()
                let html = try element.outerHtml()
                items.append(Item(text: text, html: html))
            }

        } catch {
            UIAlertController.showAlert("Error: \(error)", self)
        }

        tableView.reloadData()
    }

    @IBAction func chooseQuery(_: Any) {
        guard let viewController = storyboard?.instantiateViewController(
            withIdentifier: "QueryViewController") as? QueryViewController
        else {
            return
        }
        viewController.completionHandler = { [weak self] resilt in
            self?.navigationController?.popViewController(animated: true)
            self?.cssTextField.text = resilt.example
            self?.parse()
        }
        show(viewController, sender: self)
    }
}

extension ViewController: UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    public func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
            cell?.textLabel?.numberOfLines = 2
            cell?.detailTextLabel?.numberOfLines = 6

            cell?.textLabel?.textColor = UIColor(red: 1.0 / 255, green: 174.0 / 255, blue: 66.0 / 255, alpha: 1)
            cell?.detailTextLabel?.textColor = UIColor(red: 55.0 / 255, green: 67.0 / 255, blue: 55.0 / 255, alpha: 1)

            cell?.backgroundColor = UIColor(red: 245.0 / 255, green: 245.0 / 255, blue: 245.0 / 255, alpha: 1)
        }

        cell?.textLabel?.text = items[indexPath.row].text
        cell?.detailTextLabel?.text = items[indexPath.row].html

        let color1 = UIColor(red: 245.0 / 255, green: 245.0 / 255, blue: 245.0 / 255, alpha: 1)
        let color2 = UIColor(red: 240.0 / 255, green: 240.0 / 255, blue: 240.0 / 255, alpha: 1)
        cell?.backgroundColor = (indexPath.row % 2) == 0 ? color1 : color2

        return cell!
    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == urlTextField {
            downloadHTML()
        }

        if textField == cssTextField {
            parse()
        }
    }
}

public extension UIAlertController {
    static func showAlert(_ message: String, _ controller: UIViewController) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        controller.present(alert, animated: true, completion: nil)
    }
}
