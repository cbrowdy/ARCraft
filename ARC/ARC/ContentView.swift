//
//  ContentView.swift
//  ARC
//
//  Created by Daniel Ryu on 2/11/23.
//

import SwiftUI

struct ContentView: View{
    var body: some View {
        ARViewContainer()
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        ContentView()
    }
}
