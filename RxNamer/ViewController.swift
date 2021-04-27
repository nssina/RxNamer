//
//  ViewController.swift
//  RxNamer
//
//  Created by Sina Rabiei on 4/27/21.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    
    @IBOutlet weak var helloLabel: UILabel!
    @IBOutlet weak var nameEntryTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var namesLabel: UILabel!
    
    let disposeBag = DisposeBag()
    var namesArray: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindTextField()
        bindSubmitButton()
    }
    
    func bindTextField() {
        nameEntryTextField.rx.text
            .debounce(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .map {
                if $0 == "" {
                    return "Type your name below"
                } else {
                    return "Hello, \($0!)."
                }
            }
            .bind(to: helloLabel.rx.text)
            .disposed(by: disposeBag)
    }
    
    func bindSubmitButton() {
        submitButton.rx.tap
            .subscribe(onNext: {
                if self.nameEntryTextField.text != "" {
                    self.namesArray.append(self.nameEntryTextField.text!)
                    self.namesLabel.rx.text.onNext(self.namesArray.joined(separator: ", "))
                    self.nameEntryTextField.rx.text.onNext("")
                    self.helloLabel.rx.text.onNext("Type your name below")
                }
            }).disposed(by: disposeBag)
    }
}

