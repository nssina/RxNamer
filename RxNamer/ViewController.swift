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
    @IBOutlet weak var addNameButton: UIButton!
    
    let disposeBag = DisposeBag()
    var namesArray = BehaviorRelay<[String]>(value: [])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindTextField()
        bindSubmitButton()
        bindAddNameButton()
        
        namesArray.asObservable().subscribe(onNext: { names in
            self.namesLabel.text = names.joined(separator: ", ")
        }).disposed(by: disposeBag)
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
                    self.namesLabel.rx.text.onNext(self.namesArray.value.joined(separator: ", "))
                    self.namesArray.accept(self.namesArray.value + [self.nameEntryTextField.text!])
                    self.nameEntryTextField.rx.text.onNext("")
                    self.helloLabel.rx.text.onNext("Type your name below")
                }
            }).disposed(by: disposeBag)
    }
    
    func bindAddNameButton() {
        addNameButton.rx.tap
            .throttle(RxTimeInterval.milliseconds(500), scheduler: MainScheduler.instance).subscribe(onNext: {
                guard let addNameVC = self.storyboard?.instantiateViewController(identifier: "AddNameVC") as? AddNameVC else { return }
                addNameVC.nameSubject
                    .subscribe(onNext: { name in
                        self.namesArray.accept(self.namesArray.value + [name])
                        addNameVC.dismiss(animated: true, completion: nil)
                    }).disposed(by: self.disposeBag)
                self.present(addNameVC, animated: true, completion: nil)
            }).disposed(by: disposeBag)
    }
}

