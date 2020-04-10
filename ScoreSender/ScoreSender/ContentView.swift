//
//  ContentView.swift
//  ScoreSender
//
//  Created by Brice Redmond on 4/7/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct ContentView: View {
 
    @State var people: [Person] = [
        .init(firstName: "Steve",
              lastName: "Jobs", image: #imageLiteral(resourceName: "jobs"), ranking: 1, score: 1250),
        .init(firstName: "Tim", lastName: "Cook", image: #imageLiteral(resourceName: "cook"), ranking: 2, score: 1024),
        .init(firstName: "Jony", lastName: "Ive", image: #imageLiteral(resourceName: "ive"), ranking: 3, score: 900)
    ]
    
    @State var isPresentingAddModal = false
    @State var isPresentingSettingsModal = false
    
   var body: some View {
        NavigationView {
            List(people) { person in
                PersonRow(person: person, didOpenGames: { p in
                    print("Opening games!")
                })
            }.navigationBarTitle("Rankings")
                .navigationBarItems(
                    leading: Button(action: {
                        self.isPresentingSettingsModal.toggle()
                    }, label: {
                        Text("Settings")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .background(Color.gray)
                        .cornerRadius(4)
                    }).sheet(isPresented: $isPresentingSettingsModal, content: {
                        SettingsForm(isPresented: self.$isPresentingSettingsModal)
                    }),
                    
                    trailing: Button(action: {
                        self.isPresentingAddModal.toggle()

                }, label: {
                    Text("Add Game")
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .background(Color.green)
                    .cornerRadius(4)
                }))
                .sheet(isPresented: $isPresentingAddModal, content: {
                    GameForm(isPresented: self.$isPresentingAddModal, didAddGame: { g in
                        print(g)
                    })
                })
        }
    }
}

struct SettingsForm: View {
    @Binding var isPresented: Bool
    
    @State var selectedImage = UIImage()
    @State var isShowingImagePicker = false
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Spacer()
                Button(action: {
                       self.isPresented = false
                   }, label: {
                       Text("Back")
                       .fontWeight(.bold)
                       .foregroundColor(.white)
                       .padding(.vertical, 8)
                       .padding(.horizontal, 12)
                       .background(Color.green)
                       .cornerRadius(4)
                })
                .background(Color.green)
                .cornerRadius(4)
            }
            
            Text("Settings")
                .fontWeight(.heavy)
                .font(.system(size: 32))
            HStack {
               Spacer()
                Image(uiImage: self.selectedImage)
               .resizable()
               .scaledToFill()
               .frame(width: 80, height: 80)
               .overlay(
                   RoundedRectangle(cornerRadius: 80)
                       .strokeBorder(style: StrokeStyle(lineWidth: 2))
                       .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)))
               .cornerRadius(80)
               Spacer()
           }
           
           Button(action: {
               self.isShowingImagePicker.toggle()
           }, label: {
               HStack {
                   Spacer()
                   Text("Select Your Photo")
                       .fontWeight(.bold)
                       .padding(.all, 8)
                       .background(Color.blue)
                       .foregroundColor(.white)
                       .cornerRadius(4)
                   Spacer()
               }
           }).sheet(isPresented: $isShowingImagePicker, content: {
                HybridImagePickerController(imageFromPicker: self.$selectedImage)
            })
           
           Spacer()
        }.padding(.all, 20)
    }
}

struct HybridImagePickerController: UIViewControllerRepresentable {

    @Binding var imageFromPicker: UIImage

    func makeUIViewController(context: UIViewControllerRepresentableContext<HybridImagePickerController>) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func makeCoordinator() -> HybridImagePickerController.Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

        var parent: HybridImagePickerController

        init(_ parent: HybridImagePickerController) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            let selectedImage = info[.originalImage] as! UIImage
            parent.imageFromPicker = selectedImage
            picker.dismiss(animated: true)
        }

    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<HybridImagePickerController>) {

    }

}

struct GameForm: View {
    
    @Binding var isPresented: Bool
    
    var didAddGame: (Game) -> ()
    
    @State var p1: String = ""
    @State var p2: String = ""
    @State var p3: String = ""
    @State var p4: String = ""
    @State var score1: String = ""
    @State var score2: String = ""
    
    var width: CGFloat = 80
    
    var body: some View {
        VStack (alignment: .leading, spacing: 16) {
            Text("Add Game")
                .fontWeight(.heavy)
                .font(.system(size: 32))
            
            HStack {
                Spacer()
                Image("bicycle_die")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .overlay(
                    RoundedRectangle(cornerRadius: 80)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)))
                .cornerRadius(80)
                Spacer()
            }
            
            HStack (spacing: 16) {
                Text("Player 1")
                    .frame(width: width, alignment: .leading)
                TextField("Player 1", text: $p1)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            HStack (spacing: 16) {
                Text("Player 2")
                    .frame(width: width, alignment: .leading)
                TextField("Player 2", text: $p2)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
            
            HStack(spacing: 16) {
                Text("Score")
                    .frame(width: width, alignment: .leading)
                TextField("Score 1", text: $score1)
                    .frame(alignment: .center)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                Text("-")
                    .frame(width: 30, alignment: .center)
                
                TextField("Score 2", text: $score2)
                    .frame(alignment: .center)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
                
            }
            
            HStack (spacing: 16) {
                Text("Player 3")
                    .frame(width: width, alignment: .leading)
                TextField("Player 3", text: $p3)
                    .padding(.all, 12)
                    .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .strokeBorder(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
            }
           
           HStack (spacing: 16) {
               Text("Player 4")
                   .frame(width: width, alignment: .leading)
               TextField("Player 4", text: $p4)
                   .padding(.all, 12)
                   .overlay(
                   RoundedRectangle(cornerRadius: 4)
                       .strokeBorder(style: StrokeStyle(lineWidth: 1))
                       .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 0.2)))
           }
            
            Button(action: {
                if let game = checkValidGame(l: [self.p1, self.p2, self.p3, self.p4, self.score1, self.score2]) {
                    //set game here
                    
                    self.didAddGame(game)
                    self.isPresented = false
                }
            }, label: {
                HStack {
                    Spacer()
                    Text("Add")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
            })
            .background(Color.green)
            .cornerRadius(4)
            
            Button(action: {
                self.isPresented = false
            }, label: {
                HStack {
                    Spacer()
                    Text("Cancel")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                    
                    Spacer()
                }
            })
            .background(Color.red)
            .cornerRadius(4)
            
            Spacer()
            
        }.padding(.all, 20)
        
    }
}



struct PersonRow: View {
    
    var person: Person
    var didOpenGames: (Person) -> ()
    
    var body: some View {
        HStack {
            Text(
                String(person.ranking))
                .font(.system(size: 20))
            Image(uiImage: person.image)
                .resizable()
                .scaledToFill()
                .frame(width: 60, height: 60)
                .overlay(
                    RoundedRectangle(cornerRadius: 60)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color.black))
                .cornerRadius(60)
            
            VStack (alignment: .leading) {
                Text("\(person.firstName) \(person.lastName)")
                    .fontWeight(.bold)
                Text(String(person.score))
                    .fontWeight(.light)
            }.layoutPriority(1)
            
            Spacer()
            
            Button(action: {
                self.didOpenGames(self.person)
            }, label: {
                Text("See Games")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.all, 12)
                    .background(Color.blue)
                    .cornerRadius(3)
            })
            
        }.padding(.vertical, 8)
    }
}
