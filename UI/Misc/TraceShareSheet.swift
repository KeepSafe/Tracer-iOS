//
//  TraceShareSheet.swift
//  Tracer
//
//  Created by Rob Phillips on 5/11/18.
//  Copyright © 2018 Keepsafe Inc. All rights reserved.
//

import UIKit

typealias TraceShareSheetSuccess = () -> ()
typealias TraceShareSheetFailure = (_ error: Error) -> ()

struct TraceShareSheet: Viewing {
    static func present(with activityItems: [Any], in controller: UIViewController,
                        success: TraceShareSheetSuccess? = nil, failure: TraceShareSheetFailure? = nil) {
        let shareSheet = UIActivityViewController(activityItems: activityItems, applicationActivities: [])
        var excludeActivities: [UIActivityType] = [.assignToContact, .addToReadingList,
                                                   .postToFacebook, .postToVimeo,
                                                   .postToWeibo, .postToFlickr,
                                                   .postToTwitter, .openInIBooks,
                                                   .postToTencentWeibo]
        if #available(iOS 11.0, *) {
            excludeActivities.append(.markupAsPDF)
        }
        shareSheet.excludedActivityTypes = excludeActivities
        shareSheet.completionWithItemsHandler = { (activityType: UIActivityType?, completed: Bool, returnedItems: [Any]?, activityError: Error?) in
            if completed {
                if let error = activityError {
                    failure?(error)
                    return
                }
                success?()
            }
        }
        controller.present(shareSheet, animated: true, completion: nil)
    }
    
    private init() {}
}
