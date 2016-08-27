//
//  ViewControllerTextFieldDelegate.swift
//  CreditCardForm
//
//  Created by Bruce McTigue on 8/27/16.
//  Copyright © 2016 tiguer. All rights reserved.
//

import UIKit

protocol TextFieldDelegate {
    func creditCardUpdated(creditCard: CreditCardProtocol)
}

class ViewControllerTextFieldDelegate: NSObject {

    var keyBoardIsOpen: Bool = false
    var creditCard: CreditCardProtocol
    let cardNumberTextField: UITextField!
    let expirationDateTextField: UITextField!
    let cvvTextField: UITextField!
    var cardImageView: UIImageView!
    var cardNumberCheckMark: UIImageView!
    var cardNumberCheckMarkView: UIView!
    var expirationDateCheckMark: UIImageView!
    var expirationDateCheckMarkView: UIView!
    var cvvCheckMark: UIImageView!
    var cvvCheckMarkView: UIView!

    var delegate: TextFieldDelegate?

    init(cardNumberTextField: UITextField, expirationDateTextField: UITextField, cvvTextField: UITextField, creditCard: CreditCardProtocol) {
        self.creditCard = creditCard
        self.cardNumberTextField = cardNumberTextField
        self.expirationDateTextField = expirationDateTextField
        self.cvvTextField = cvvTextField
        super.init()
        self.cardNumberTextField.delegate = self
        self.expirationDateTextField.delegate = self
        self.cvvTextField.delegate = self
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ViewControllerTextFieldDelegate.textDidChange(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
    }
}

extension ViewControllerTextFieldDelegate: UITextFieldDelegate {

    func updateWithViews(cardImageView: UIImageView, cardNumberCheckMark: UIImageView, cardNumberCheckMarkView: UIView, expirationDateCheckMark: UIImageView, expirationDateCheckMarkView: UIView, cvvCheckMark: UIImageView, cvvCheckMarkView: UIView) {
        self.cardImageView = cardImageView
        self.cardNumberCheckMark = cardNumberCheckMark
        self.cardNumberCheckMarkView = cardNumberCheckMarkView
        self.expirationDateCheckMark = expirationDateCheckMark
        self.expirationDateCheckMarkView = expirationDateCheckMarkView
        self.cvvCheckMark = cvvCheckMark
        self.cvvCheckMarkView = cvvCheckMarkView
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text {
            let characterCount = text.characters.count + string.characters.count
            switch(textField.tag) {
            case 0:
                return string.nextCreditCardDigitIsValid(creditCard.type, cardNumberLength:creditCard.cardNumberLength, characterCount: characterCount)
            case 1:
                if text.characters.count <= 2 {
                    expirationDateTextField!.text = text.padExpirationDateMonth()
                }
                return string.nextExpirationDateDigitIsValid(text, characterCount: characterCount)
            case 2:
                return string.nextCVVDigitIsValid(creditCard.cvvLength, characterCount: characterCount)
            default:
                return true
            }
        }
        return true
    }

    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.tag == 2 {
            cardImageView.image = UIImage(named: "Cards_CVV.png")
        }
    }

    func textFieldDidEndEditing(textField: UITextField) {
        if textField.tag == 2 {
            cardImageView.image = UIImage(named: creditCard.logo)
        }
        textField.layoutIfNeeded()
    }

    func textDidChange(notification: NSNotification) {
        let textField = notification.object as! UITextField
        if let text = textField.text {
            switch(textField.tag) {
            case 0:
                creditCard = text.evaluateCardNumber(creditCard, cardImageView: cardImageView, cardNumberCheckMark: cardNumberCheckMark, cardNumberCheckMarkView: cardNumberCheckMarkView)
                creditCard = creditCard.cvv.evaluateCVV(creditCard, cvvTextField: cvvTextField, cvvCheckMark: cvvCheckMark, cvvCheckMarkView: cvvCheckMarkView)
            case 1:
                creditCard = text.evaluateExpiredDate(creditCard, expirationDateTextField: expirationDateTextField, expirationDateCheckMark: expirationDateCheckMark, expirationDateCheckMarkView: expirationDateCheckMarkView)
            case 2:
                creditCard = text.evaluateCVV(creditCard, cvvTextField: cvvTextField, cvvCheckMark: cvvCheckMark, cvvCheckMarkView: cvvCheckMarkView)
            default:
                break
            }
        }
        delegate?.creditCardUpdated(creditCard)
    }

}
