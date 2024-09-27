//
//  CreateSdkObjectView.swift
//  Firebase_iOS
//
//  Created by Robin Kirchner on 29.08.23.
//

import SwiftUI

struct CreateSdkObjectView: View {
    @EnvironmentObject var sdkManager: SDKManager
    
    var body: some View {
        ZStack {
            Text("Created SDK object")
        }
        .onAppear {
            print("CreateSdkObjectView.onAppear")
            sdkManager.createSdkObject()
        }
    }
}

struct CreateSdkObjectView_Previews: PreviewProvider {
    static var previews: some View {
        // Create a preview with a AppsFlyerManager instance
        let sdkManager = SDKManager()
        
        // Wrap the StartView in a NavigationView to match your app's structure
        NavigationView {
            CreateSdkObjectView()
                .environmentObject(sdkManager)
        }
    }
}
