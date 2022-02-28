//
//  Settings.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 22/02/2022.
//

import SwiftUI
import RealmSwift

struct Settings: View {
    @ObservedResults(ScheduleGroup.self) var groups: Results<ScheduleGroup>
    @Environment(\.realm) private var realm: Realm
    
    var body: some View {
        Form {
            Section(header: Text("Groups")) {
                NavigationLink(destination: SettingsGroupAdd()) {
                    Label("Add group", systemImage: "plus")
                }
                List {
                    ForEach(groups) {
                        Text($0.raw)
                    }
                    .onDelete(perform: deleteHandler)
                }
            }
            
            #if DEBUG
            Section("Developer") {
                Button("Wyczyść UserDefaults") {
                    UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                }
            }
            #endif
            
            Section("About") {
                Text("Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
                Button("Github repo") {
                    UIApplication.shared.open(URL(string: "https://github.com/pjatk21/Pie-Schedule")!)
                }
            }
        }
        .navigationTitle("Settings")
    }
    
    private func deleteHandler(indexSet: IndexSet) {
        if let i = indexSet.first {
            try! realm.write {
                realm.delete(
                    realm.objects(ScheduleGroup.self).where {
                        $0.raw.equals(groups[i].raw)
                    }
                )
            }
        }
    }
}

struct SettingsGroupAdd: View {
    @State private var groupName: String = ""
    @Environment(\.realm) private var realm: Realm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Nazwa grupy", text: $groupName)
            Button {
                let sg = ScheduleGroup()
                sg.raw = groupName
                try! realm.write {
                    realm.add(sg)
                }
                dismiss.callAsFunction()
            } label: {
                Label("Zatwierdź", systemImage: "plus")
            }
            .disabled(!isValid())
        }
        .navigationTitle("Dodaj grupę")
    }
    
    private func isValid() -> Bool {
        return groupName.range(of: "^W", options: .regularExpression) != nil && groupName.range(of: "\\d+[a-z]", options: .regularExpression) != nil
    }
}

/*
struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
*/
