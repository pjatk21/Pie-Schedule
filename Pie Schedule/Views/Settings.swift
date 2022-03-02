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
        VStack {
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
                Text("Made with ❤️ by Chris")
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
    @State private var availableGroups: [String] = []
    @Environment(\.realm) private var realm: Realm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            TextField("Group name", text: $groupName)
            Button {
                let sg = ScheduleGroup()
                sg.raw = groupName
                try! realm.write {
                    realm.add(sg)
                }
                dismiss.callAsFunction()
            } label: {
                Label("Add", systemImage: "plus")
            }
            .disabled(!isValid())
            Section {
                NavigationLink(destination: SettingsGroupSearchablePicker(selectedGroup: $groupName, searchQuery: "", filteredGroups: availableGroups, availableGroups: availableGroups)) {
                    Label("Select group", systemImage: "person.3.fill")
                }
            }
        }
        .navigationTitle("Add group")
        .task {
            availableGroups = try! await AltapiManager().getAvailableGroups().groupsAvailable
        }
    }
    
    private func isValid() -> Bool {
        return groupName.range(of: "^W", options: .regularExpression) != nil && groupName.range(of: "\\d+[a-z]", options: .regularExpression) != nil
    }
}

struct SettingsGroupSearchablePicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedGroup: String
    @State var searchQuery: String
    @State var filteredGroups: [String]
    let availableGroups: [String]
    
    var body: some View {
        List(filteredGroups, id: \.self) { groupName in
            Button(groupName) {
                selectedGroup = groupName
                dismiss.callAsFunction()
            }
            .buttonStyle(.plain)
        }
        .searchable(text: $searchQuery)
        .navigationTitle("Select group")
        .onChange(of: searchQuery) { _ in
            filteredGroups = filterGroups()
        }
    }
    
    private func filterGroups() -> [String] {
        searchQuery.isEmpty ? availableGroups.sorted() : availableGroups.filter {
            $0.contains(searchQuery)
        }.sorted()
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            Settings()
                .environment(\.realm, .previews)
                .navigationBarTitleDisplayMode(.inline)
        }
        NavigationView {
            SettingsGroupAdd()
                .environment(\.realm, .previews)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
