//
//  DateControl.swift
//  Pie Schedule
//
//  Created by Krystian Postek on 28/02/2022.
//

import SwiftUI
import SwiftDate

struct DateControl: View {
    @Binding var activeDate: Date
    
    var body: some View {
        HStack {
            Button {
                activeDate = activeDate - 1.days
            } label: {
                Image(systemName: "chevron.left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
                    .padding(.horizontal, 25.0)
            }
            DatePicker(activeDate.toFormat("EEEE"), selection: $activeDate, displayedComponents: [.date])
                .datePickerStyle(DefaultDatePickerStyle())
            Button {
                activeDate = activeDate + 1.days
            } label: {
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10)
                    .padding(.horizontal, 25.0)
            }
        }
    }
}
