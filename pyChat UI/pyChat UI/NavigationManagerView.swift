//
//  NavigationManagerView.swift
//  pyChat UI
//
//  Created by pedro on 9/23/24.
//
import SwiftUI

enum SideBarItem: String, Identifiable, CaseIterable {
    var id: String { rawValue }
    
    case pyChat
    case Leads
    case Reminders
}

struct NavigationManagerView: View {
    @State var sideBarVisibility: NavigationSplitViewVisibility = .doubleColumn
    @State var selectedSideBarItem: SideBarItem = .pyChat
    
    var body: some View{
        NavigationSplitView(columnVisibility: $sideBarVisibility) {
            List(SideBarItem.allCases, selection: $selectedSideBarItem){ item in
                NavigationLink(
                    item.rawValue.localizedCapitalized,
                    value:item
                )
            }
        } detail: {
            switch selectedSideBarItem {
            case .pyChat:
                pyChat()
            case .Leads:
                Leads()
            case .Reminders:
                Reminders()
            }
        }
        
    }
}
