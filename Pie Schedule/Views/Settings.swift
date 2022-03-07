//
//  Settings.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 22/02/2022.
//

import SwiftUI
import RealmSwift
import WidgetKit

struct BuildInfo: Codable {
    let branch: String
    let commit: String
}

struct Settings: View {
    @ObservedResults(ScheduleGroup.self) var groups: Results<ScheduleGroup>
    @Environment(\.realm) private var realm: Realm
    @AppStorage("pref.autoskip") private var skipToNextDate = true
    @AppStorage("pref.fetchSize") private var fetchSize = 7
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Groups")) {
                    NavigationLink(destination: SettingsGroupAdd()) {
                        Label("Add group", systemImage: "plus")
                    }
                    List {
                        ForEach(generateMissingGroupsWarnings(), id: \.self) {
                            Text("⚠️" + $0)
                        }
                        ForEach(groups) {
                            Text($0.name)
                        }
                        .onDelete(perform: deleteHandler)
                    }
                }
                
                Section("General preferences") {
                    List {
                        Toggle("Skip to next classes", isOn: $skipToNextDate)
                        HStack {
                            Text("Number of automaticly fetch days")
                            Spacer()
                            TextField("7", value: $fetchSize, formatter: NumberFormatter())
                                .textFieldStyle(.roundedBorder)
                                .keyboardType(.numberPad)
                                .frame(width: 30)
                        }
                        
                    }
                }
                
                #if DEBUG
                Section("Developer") {
                    Button("Clear UserDefaults") {
                        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
                    }
                    Button("Reload widget timeline") {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
                #endif
                
                Section("About") {
                    Text("Version: \(Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String)")
                    Text("Git: \(build.branch) \(build.commit)")
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
                        $0.name.equals(groups[i].name)
                    }
                )
            }
        }
    }
    
    private enum GroupTypes: String {
        case c, l, w
    }
    
    private func generateMissingGroupsWarnings() -> [String] {
        var groupCats = Set<GroupTypes>()
        
        for group in realm.objects(ScheduleGroup.self) {
            if group.name.range(of: "c$", options: .regularExpression) != nil {
                groupCats.insert(.c)
            } else if group.name.range(of: "l$", options: .regularExpression) != nil {
                groupCats.insert(.l)
            } else if group.name.range(of: "w$", options: .regularExpression) != nil {
                groupCats.insert(.w)
            }
        }
        
        var warnings = Array<String>()
        if !groupCats.contains(.c) {
            warnings.append(String(localized: "Missing exc. group!"))
        }
        if !groupCats.contains(.l) {
            warnings.append(String(localized: "Missing lang. group!"))
        }
        if !groupCats.contains(.w) {
            warnings.append(String(localized: "Missing lect. group!"))
        }
        return warnings
    }
    
    let build: BuildInfo = {
        if let buildInfoUrl = Bundle.main.url(forResource: "buildinfo", withExtension: "json") {
            if let data = try? Data(contentsOf: buildInfoUrl) {
                do {
                    print(String(data: data, encoding: .utf8)!)
                    return try JSONDecoder().decode(BuildInfo.self, from: data)
                } catch {
                    print(error)
                    return nil
                }
                
            }
        }
        
        return nil
    }() ?? BuildInfo(branch: "unknown", commit: "unknown")
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
                sg.name = groupName
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
            .buttonStyle(.automatic)
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
                .environment(\.realmConfiguration, .previewConfig)
                .navigationBarTitleDisplayMode(.inline)
        }
        
        NavigationView {
            SettingsGroupAdd()
                .environment(\.realmConfiguration, .previewConfig)
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
