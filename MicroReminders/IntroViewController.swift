//
//  IntroViewController.swift
//  MicroReminders
//
//  Created by Sasha Weiss on 2/26/17.
//  Copyright © 2017 Sasha Weiss. All rights reserved.
//

import Foundation

class IntroViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var codeword: UITextField!
    @IBOutlet weak var submit: UIButton!
    
    @IBAction func submitTapped(_ sender: Any) {
        if let word = codeword.text, word != "" {
            performSegue(withIdentifier: "submitCodeword", sender: self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "submitCodeword" {
            let word = codeword.text!
            UserDefaults.standard.set(word, forKey: "beaconCodeword")
            Beacons.sharedInstance.beaconsFromCodeword()
        }
    }
}
