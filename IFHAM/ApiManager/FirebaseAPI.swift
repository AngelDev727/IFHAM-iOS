//
//  FirebaseAPI.swift
//  IFHAM
//
//  Created by AngelDev on 5/29/20.
//  Copyright © 2020 AngelDev. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

public class FirebaseAPI {
    class func isConnected(completion: @escaping (_ state: Bool) -> ()) {
    
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        
        connectedRef.observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool, connected {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
}
