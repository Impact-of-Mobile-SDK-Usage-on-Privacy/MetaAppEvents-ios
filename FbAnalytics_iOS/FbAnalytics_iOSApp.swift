//
//  FbAnalytics_iOSApp.swift
//  FbAnalytics_iOS
//
//  Created by Robin Kirchner on 05.09.23.
//

import SwiftUI
import AppTrackingTransparency
import AdSupport
import FacebookCore


class SDKManager: ObservableObject {
    @Published var isConfigured = false
    @Published var isCreated = false
    @Published var canShowBanner = false
    @Published var attStatus = ATTrackingManager.trackingAuthorizationStatus
    @Published var idfa = "nil" // not best practice to store the IDFA
    
    var application: UIApplication? = nil
    var launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil

    func retrieveIDFA() -> String {
        // Check whether advertising tracking is enabled
        if #available(iOS 14, *) {
            if ATTrackingManager.trackingAuthorizationStatus != ATTrackingManager.AuthorizationStatus.authorized  {
                idfa = "nil"
                return "nil"
            }
        } else {
            if ASIdentifierManager.shared().isAdvertisingTrackingEnabled == false {
                idfa = "nil"
                return "nil"
            }
        }
        idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    func requestATT() {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                self.attStatus = status
                switch status {
                case .denied:
                    print("ATT status is denied")
                case .notDetermined:
                    print("ATT status is notDetermined")
                case .restricted:
                    print("ATT status is restricted")
                case .authorized:
                    print("ATT status is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
                print("To show this again, the app needs to be uninstalled!")
                self.updateAttStatus()
                print("IDFA:", self.retrieveIDFA())
            }
        }
        
    }
    
    func giveConsent() {
        print("Settings.shared.isAdvertiserTrackingEnabled = true  and Settings.shared.isAutoLogAppEventsEnabled = true")
        Settings.shared.isAdvertiserTrackingEnabled = true // alternatively enable in Info.plist
        Settings.shared.isAutoLogAppEventsEnabled = true
    }
    
    func updateAttStatus() {
        attStatus = ATTrackingManager.trackingAuthorizationStatus
        idfa = retrieveIDFA()
    }
    
    @ViewBuilder
    func statusMessage() -> some View {
        if isConfigured {
            AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("Facebook Analytics is configured")
                }
            )
        } else {
            AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red)
                    Text("Facebook Analytics is not configured")
                }
            )
        }
    }
    
    func idfaMessage() -> AnyView? {
        return AnyView(Text(idfa))
    }
    
    func attStatusMessage() -> AnyView? {
        if #available(iOS 14, *) {
            switch attStatus {
            case .denied:
                return AnyView(
                        HStack {
                        Image(systemName: "xmark.circle")
                            .foregroundColor(.red)
                        Text("ATT is denied")
                        }
                    )
            case .notDetermined:
                return AnyView(
                    HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(.purple)
                    Text("ATT is not determined")
                    }
                )
            case .restricted:
                return AnyView(
                    HStack {
                    Image(systemName: "exclamationmark.circle")
                        .foregroundColor(.yellow)
                    Text("ATT is restricted")
                    }
                )
            case .authorized:
                return AnyView(
                    HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("ATT is authorized")
                    }
                )
            @unknown default:
                return AnyView(
                    HStack {
                    Image(systemName: "checkmark.xmark.circle")
                        .foregroundColor(.red)
                    Text("invalid ATT authorization status")
                    }
                )
            }
        }
    }
    
    func createSdkObject() {
        guard !isCreated else {
            print("Facebook Analytics object is already created. Skipping.")
            return
        }
        print("Facebook Analytics created")
        print(ApplicationDelegate.shared)
        isCreated = true
    }
    
    func configure() {
        guard !isConfigured else {
            print("Facebook Analytics is already configured. Skipping.")
            return
        }
        isConfigured = true
        print("Facebook Analytics.configure()")
        
        ApplicationDelegate.shared.application(
            application!,
            didFinishLaunchingWithOptions: launchOptions
        )
    }
    
    func logBasic() {
        print("Event battledAnOrc logged")
        AppEvents.shared.logEvent(AppEvents.Name("battledAnOrc"))
    }
}

struct NamedView {
    let name: String
    let view: AnyView
}

// MetaAudienceNetwork: Create, Init, Consent, Util
let views: [NamedView] = [
    NamedView(name: "Start", view: AnyView(ContentView())),
    NamedView(name: "Create SDK object", view: AnyView(CreateSdkObjectView())),
    NamedView(name: "Initialize SDK", view: AnyView(InitializeSDKView())),
    NamedView(name: "Inquire Consent", view: AnyView(InquireConsentView())),
    NamedView(name: "Basic Functionality", view: AnyView(BasicFunctionalityView())),
]

var sdkManager = SDKManager() // Create a global instance

@main
struct FbAnalytics_iOSApp: App {
    @UIApplicationDelegateAdaptor(MyAppDelegate.self) var appDelegate
    
    @State private var currentViewIndex = 0
    
    @ViewBuilder
    func debugStatusMessage() -> some View {
        #if DEBUG
            AnyView(
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.orange)
                    Text("running in DEBUG mode.")
                }
            )
        #else
            AnyView(
                HStack {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                    Text("running in release mode.")
                }
            )
        #endif
    }
            
    func advanceViewIndex() -> AnyView {
        if currentViewIndex < views.count - 1 {
            return AnyView(
                Button(action: {
                    currentViewIndex += 1
                }, label: {
                    HStack {
                        Text("Go to \(views[currentViewIndex + 1].name)")
                        Image(systemName: "chevron.right")
                    }
                })
                .padding()
            )
        }
        return AnyView(
            Text("Final View reached.")
                .padding()
        )
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                VStack {
                    VStack {
                        Text("Facebook Analytics iOS")
                            .font(.system(size: 40))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Text("\(views[currentViewIndex].name)")
                            .font(.system(size: 36))
                            .fontWeight(.heavy)
                            .multilineTextAlignment(.center)
                            .padding()
                        Spacer()
      
                        VStack {
                            debugStatusMessage()
                                .padding()
                            sdkManager.statusMessage()
                                .padding()
                            sdkManager.attStatusMessage()
                                .padding()
                            
                        }
                        .onChange(of: sdkManager.isConfigured) { _ in
                            // This will trigger a re-render when sdkManager.isConfigured changes
                        }
                        .padding()
                        
                        // Display the current view
                        views[currentViewIndex].view
                            //.environmentObject(sdkManager)
                        Spacer()
                        // Display "Next View" button
                        advanceViewIndex()
                    }
                    Spacer()
                    VStack {
                        HStack {
                            Image(systemName: "number")
                            sdkManager.idfaMessage()
                        }.font(.system(size: 12))
                    }
                    .frame(height: 75)
                }
                .environmentObject(sdkManager) // pass global sdkManager as environmentObject
            }.onAppear{
                print("sdkManager.updateAttStatus")
                sdkManager.updateAttStatus()
            }
        }
    }
}

class MyAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Access globalSDKManager directly
        
        // instead of configuring FB Analytics on didFinishLaunchingWithOptions, we store the required application and launchOptions objects
        // then we initialize FB when we want
        sdkManager.application = application
        sdkManager.launchOptions = launchOptions
        
        print("Application launched with launchOptions")
        return true
    }
}


