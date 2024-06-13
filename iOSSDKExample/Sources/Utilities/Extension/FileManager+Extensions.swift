//
// Copyright (c) 2021-2024. NICE Ltd. All rights reserved.
//
// Licensed under the NICE License;
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    https://github.com/nice-devone/nice-cxone-mobile-sample-ios/blob/main/LICENSE
//
// TO THE EXTENT PERMITTED BY APPLICABLE LAW, THE CXONE MOBILE SDK IS PROVIDED ON
// AN “AS IS” BASIS. NICE HEREBY DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS
// OR IMPLIED, INCLUDING (WITHOUT LIMITATION) WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE, NON-INFRINGEMENT, AND TITLE.
//

import UIKit

extension FileManager {
    
    func eraseDocumentsFolder() {
        Log.trace("Removing files from documents folder")
        
        guard let documentsPath = urls(for: .documentDirectory, in: .userDomainMask).first?.relativePath else {
            Log.error(.failed("Unable to get documents path"))
            return
        }
        
        do {
            for fileName in try contentsOfDirectory(atPath: documentsPath) {
                try removeItem(atPath: URL(fileURLWithPath: documentsPath).appendingPathComponent(fileName).path)
            }
        } catch {
            error.logError()
        }
    }
    
    func removeFileInDocuments(named: String) throws {
        Log.trace("Removing file \(named) from documents")
        
        guard let documentsPath = urls(for: .documentDirectory, in: .userDomainMask).first?.relativePath else {
            Log.error(.failed("Unable to get documents path"))
            return
        }
        
        try removeItem(atPath: URL(fileURLWithPath: documentsPath).appendingPathComponent(named).path)
    }
    
    func storeFileDataInDocuments(_ data: Data, named: String) throws {
        Log.trace("Storing file \(named) into documents")
        
        guard let documentsUrl = urls(for: .documentDirectory, in: .userDomainMask).first else {
            Log.error(.failed("Unable to get documents path"))
            return
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(named)
        
        try data.write(to: destinationUrl, options: [.atomic])
    }
}
