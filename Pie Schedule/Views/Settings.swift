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
            Section(header: Text("Grupy")) {
                NavigationLink(destination: SettingsGroupAdd()) {
                    Label("Dodaj grupę", systemImage: "plus")
                }
                List {
                    ForEach(groups) {
                        Text($0.raw)
                    }
                    .onDelete(perform: deleteHandler)
                }
            }
        }
        .navigationTitle("Ustawienia")
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
        }
        .navigationTitle("Dodaj grupę")
    }
}

/*
struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings()
    }
}
*/
