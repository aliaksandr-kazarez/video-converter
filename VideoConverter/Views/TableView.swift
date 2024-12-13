//
//  TableRow.swift
//  VideoConverter
//
//  Created by Kazarez, Alex on 12/12/24.
//

import AVFoundation
import SwiftUI

struct TableRow: View {
    let name: String
    let value: String

    var body: some View {
        HStack {
            Text(name)
                .fontWeight(.semibold)
            Spacer()
            Text(value)
        }
        .minimumScaleFactor(0.5)
        .lineLimit(1)
    }
}

struct TableView: View {
    var title: String? = nil
    let data: [(String, String)]

    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            if let title {
                Text(title)
                    .font(.headline)
            }

            ForEach(data, id: \.0) { key, value in
                TableRow(name: key, value: value)
            }
        }
    }
}

#Preview {
    let data = [("Resolution", "1980X600"), ("Key", "Value"), ("Key", "Value")]
    TableView(title: "Title", data: data)
        .panel(background: .ultraThinMaterial)
        .padding(5)
        .background(Color.secondary)

    HStack {
        TableView(title: "Title", data: data)
        TableView(title: "Title", data: data)
        TableView(title: "Title", data: data)
    }
    Spacer()
    TableView(title: "Title", data: data)
}
