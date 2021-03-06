//
//  RenderTemplate.swift
//  SiriIntents
//
//  Created by Robert Trencheny on 2/19/19.
//  Copyright © 2019 Robbie Trencheny. All rights reserved.
//

import Foundation
import UIKit
import Shared
import Intents

class RenderTemplateIntentHandler: NSObject, RenderTemplateIntentHandling {
    func resolveTemplate(for intent: RenderTemplateIntent,
                         with completion: @escaping (INStringResolutionResult) -> Void) {
        if let templateStr = intent.template {
            completion(.success(with: templateStr))
            return
        }
        completion(.confirmationRequired(with: intent.template))
    }

    func confirm(intent: RenderTemplateIntent, completion: @escaping (RenderTemplateIntentResponse) -> Void) {
        HomeAssistantAPI.authenticatedAPIPromise.catch { (error) in
            Current.Log.error("Can't get a authenticated API \(error)")
            completion(RenderTemplateIntentResponse(code: .failureConnectivity, userActivity: nil))
            return
        }

        completion(RenderTemplateIntentResponse(code: .ready, userActivity: nil))
    }

    func handle(intent: RenderTemplateIntent, completion: @escaping (RenderTemplateIntentResponse) -> Void) {
        guard let api = HomeAssistantAPI.authenticatedAPI() else {
            completion(RenderTemplateIntentResponse(code: .failureConnectivity, userActivity: nil))
            return
        }

        guard let templateStr = intent.template else {
            Current.Log.error("Unable to unwrap intent.template")
            let resp = RenderTemplateIntentResponse(code: .failure, userActivity: nil)
            resp.error = "Unable to unwrap intent.template"
            completion(resp)
            return
        }

        Current.Log.verbose("Rendering template \(templateStr)")

        api.RenderTemplate(templateStr: templateStr).done { rendered in
            Current.Log.verbose("Successfully renderedTemplate")

            let resp = RenderTemplateIntentResponse(code: .success, userActivity: nil)
            resp.renderedTemplate = rendered

            completion(resp)
        }.catch { error in
            Current.Log.error("Error when rendering template in shortcut \(error)")
            let resp = RenderTemplateIntentResponse(code: .failure, userActivity: nil)
            resp.error = "Error during api.RenderTemplate: \(error.localizedDescription)"
            completion(resp)
        }
    }
}
