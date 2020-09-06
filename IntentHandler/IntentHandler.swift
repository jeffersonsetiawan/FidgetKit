//
//  IntentHandler.swift
//  IntentHandler
//
//  Created by Jefferson Setiawan on 21/08/20.
//

import Intents

class IntentHandler: INExtension, DynamicFidgetSelectionIntentHandling {
    
    func provideFidgetOptionsCollection(for intent: DynamicFidgetSelectionIntent, with completion: @escaping (INObjectCollection<FidgetIntent>?, Error?) -> Void) {
        let collection = INObjectCollection(
            items: [
                FidgetIntent(identifier: "1", display: "Batman"),
                FidgetIntent(identifier: "2", display: "Red Fidget"),
                FidgetIntent(identifier: "3", display: "Blue Fidget"),
            ]
        )
        completion(collection, nil)
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}
