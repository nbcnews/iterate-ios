//
//  Iterate.swift
//  Iterate
//
//  Created by Michael Singleton on 12/20/19.
//  Copyright © 2020 Pickaxe LLC. (DBA Iterate). All rights reserved.
//

import Foundation

/// The Iterate class is the primary class of the SDK, the main entry point is the shared singleton property
public class Iterate {
    // MARK: Properties
    
    /// The shared singleton instance is the primary entrypoint into the Iterate iOS SDK.
    /// Unless you have uncommon needs you should use this singleton to call methods
    /// on the Iterate class.
    public static let shared = Iterate()
    
    /// Query parameter used to set the preview mode
    public static let PreviewParameter = "iterate_preview"
    
    // Current version number, will be updated on each release
    static let Version = "0.1.1"
    
    /// URL Scheme of the app, used for previewing surveys
    lazy var urlScheme = URLScheme()
    
    /// API Client, which will be initialized when the API key is
    var api: APIClient?
    
    /// Optional API host override to use when creating the API client
    var apiHost: String?
    
    /// The id of the survey being previewed
    var previewingSurveyId: String?
    
    /// Storage engine for storing user data like their API key and user attributes
    var storage: StorageEngine
    
    /// Container manages the overlay window
    let container = ContainerWindowDelegate()
    
    // Get the bundle by identifier or by url (needed when packaging in cocoapods)
    var bundle: Bundle? {
        let containerBundle = Bundle(for: ContainerWindowDelegate.self)
        if let bundleUrl = containerBundle.url(forResource: "Iterate", withExtension: "bundle") {
            return Bundle(url: bundleUrl)
        } else {
            return Bundle(identifier: "com.iteratehq.Iterate")
        }
    }
    
    // MARK: API Keys

    /// You Iterate API Key, you can get this from your settings page
    var companyApiKey: String? {
        didSet {
            updateApiKey()
        }
    }
    
    /// The API key for a user, this is returned by the server the first time a request is made by a new user
    var userApiKey: String? {
        get {
            if cachedUserApiKey == nil {
                cachedUserApiKey = storage.get(key: StorageKeys.UserApiKey) as? String
            }
            
            return cachedUserApiKey
        }
        set(newUserApiKey) {
            cachedUserApiKey = newUserApiKey
            storage.set(key: StorageKeys.UserApiKey, value: newUserApiKey)
            
            updateApiKey()
        }
    }
    
    /// Cached copy of the user API key that was loaded from UserDefaults
    private var cachedUserApiKey: String?
    
    
    // MARK: User Properties
    
    var userProperties: UserProperties? {
        get {
            if cachedUserProperties == nil {
                if let data = storage.get(key: StorageKeys.UserProperties) as? Data,
                    let properties = try? JSONDecoder().decode(UserProperties.self, from: data) {
                    cachedUserProperties = properties
                }
            }
            
            return cachedUserProperties
        }
        set (newUserProperties) {
            if let newUserProperties = newUserProperties,
                let encodedNewUserProperties = try? JSONEncoder().encode(newUserProperties) {
                cachedUserProperties = newUserProperties
                
                storage.set(key: StorageKeys.UserProperties, value: encodedNewUserProperties)
            }
        }
    }
    
    /// Cached copy of the user properties that was loaded from UserDefaults
    private var cachedUserProperties: UserProperties?
    
    var responseProperties: ResponseProperties?
    
    // MARK: Init
    
    /// Initializer
    /// - Parameter storage: Storage engine to use
    init(storage: StorageEngine = Storage.shared) {
        self.storage = storage
    }
    
    // MARK: Methods
    
    /// Helper method used when calling the embed endpoint which is responsible for updating the user API key
    /// if a new one is returned
    /// - Parameters:
    ///   - context: Embed context data
    ///   - complete: Callback returning the response and error from the embed endpoint
    func embedRequest(context: EmbedContext, complete: @escaping (EmbedResponse?, Error?) -> Void) {
        api?.embed(context: context, complete: { (response, error) in
            // Update the user API key if one was returned
            if let token = response?.auth?.token {
                self.userApiKey = token
            }
            
            complete(response, error)
        })
    }
    
    /// Update the API client to use the latest API key. We prefer to use the user API key and fall back to the company key
    func updateApiKey() {
        if let apiKey = userApiKey ?? companyApiKey {
            api = APIClient(apiKey: apiKey, apiHost: apiHost ?? DefaultAPIHost)
        }
    }
}
