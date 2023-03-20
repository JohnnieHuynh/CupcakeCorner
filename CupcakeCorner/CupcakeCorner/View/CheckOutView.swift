//
//  CheckOutView.swift
//  CupcakeCorner
//
//  Created by Johnny Huynh on 3/19/23.
//

import SwiftUI

struct CheckOutView: View {
    @ObservedObject var order: Order
    
    @State private var confirmationMsg = ""
    @State private var showingConfirmation = false
    
    var body: some View {
        ScrollView {
            VStack {
                AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1614707267537-b85aaf00c4b7?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=987&q=80"),
                           scale: 3) { image in
                    image
                        .resizable()
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 233)
                
                Text("Your total: \(order.cost, format: .currency(code: "USD"))")
                    .font(.title)
                
                Button("Place Order") {
                    Task {
                        await placeOrder()
                    }
                }
                .padding()
            }
            .navigationTitle("Check Out")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Thank you!", isPresented: $showingConfirmation) {
                Button("OK") {}
            } message: {
                Text(confirmationMsg)
            }
        }
    }
    
    func placeOrder() async {
        //Convert data to JSON to send
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("Failed to encode order")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        
        //Set request type to send data to server
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        do {
            //Upload call
            let (data, _) = try await URLSession.shared.upload(for: request, from: encoded)
            
            //Decode the data
            let decodedOrder = try JSONDecoder().decode(Order.self, from: data)
            
            confirmationMsg = "Your order for \(decodedOrder.quantity)x\(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
            showingConfirmation = true
        } catch {
            print("Checkout failed")
        }
    }
}

struct CheckOutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckOutView(order: Order())
    }
}
