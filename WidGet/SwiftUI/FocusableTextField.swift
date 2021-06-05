//
//  FocusableTextField.swift
//  WidGet
//
//  Created by Joel Bernstein on 10/12/20.
//

import SwiftUI

struct FocusableTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var isFocused: Bool

    var fieldType: TextFieldEditor.FieldType
    var colorScheme: ColorScheme

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()

        textField.delegate = context.coordinator
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        textField.clearButtonMode = .whileEditing
        textField.font = UIFont.preferredFont(forTextStyle: .body)
        textField.adjustsFontForContentSizeCategory = true
        textField.returnKeyType = .done

        textField.keyboardType = (fieldType == .text) ? .default : .URL
        textField.textContentType = (fieldType == .text) ? .none : .URL
        textField.autocapitalizationType = (fieldType == .text) ? .sentences : .none
        textField.autocorrectionType = (fieldType == .text) ? .default : .no

        textField.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        return textField
    }

    func updateUIView(_ uiView: UITextField, context _: Context) {
        if uiView.text != text {
            uiView.text = text
        }

        uiView.textColor = colorScheme == .light ? UIColor.black : UIColor.white

        DispatchQueue.main.async {
            if isFocused != uiView.isFirstResponder {
                if isFocused {
                    uiView.becomeFirstResponder()
                } else {
                    uiView.resignFirstResponder()
                }
            }
        }
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var focusableTextField: FocusableTextField

        init(_ focusableTextField: FocusableTextField) {
            self.focusableTextField = focusableTextField
        }

        @objc func textFieldDidBeginEditing(_: UITextField) {
            DispatchQueue.main.async {
                self.focusableTextField.isFocused = true
            }
        }

        @objc func textFieldDidEndEditing(_: UITextField) {
            DispatchQueue.main.async {
                self.focusableTextField.isFocused = false
            }
        }

        @objc func textFieldShouldReturn(_: UITextField) -> Bool {
            DispatchQueue.main.async {
                self.focusableTextField.isFocused = false
            }

            return true
        }

        @IBAction func textChanged(_ sender: UITextField) {
            focusableTextField.text = sender.text ?? ""
        }
    }
}
