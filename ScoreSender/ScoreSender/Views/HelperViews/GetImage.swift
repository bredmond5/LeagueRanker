//
//  GetImage.swift
//  ScoreSender
//
//  Created by Brice Redmond on 8/17/20.
//  Copyright © 2020 Brice Redmond. All rights reserved.
//

import SwiftUI

struct GetImage: View {
    
    enum SheetType {
      case imagePick
      case imageCrop
      case share
    }
   
    @State var currentSheet: SheetType = .imagePick
    
    let initialImage: UIImage
    let resizePercentage: CGFloat
    let imageViewSize: CGFloat

    @State var image: UIImage?
    
    @State var isShowingImagePicker = false

    var userChoseImage: (UIImage) -> ()
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(uiImage: self.image ?? initialImage)
                .resizable()
                .scaledToFill()
               .frame(width: imageViewSize, height: imageViewSize)
                .overlay(
                    RoundedRectangle(cornerRadius: imageViewSize)
                        .strokeBorder(style: StrokeStyle(lineWidth: 2))
                        .foregroundColor(Color(.sRGB, red: 0.1, green: 0.1, blue: 0.1, opacity: 1)))
                .cornerRadius(imageViewSize)
                Spacer()
            }
            
            Button(action: {
                 self.currentSheet = .imagePick
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
            }).sheet(isPresented: $isShowingImagePicker) {
             if (self.currentSheet == .imagePick) {
                 ImagePickerView(croppingStyle: .circular, sourceType: .photoLibrary, onCanceled: {
                    
                 }) { (image) in
                     guard let image = image else {
                         return
                     }
                     
                     self.image = image
                     DispatchQueue.main.async {
                         self.currentSheet = .imageCrop
                         self.isShowingImagePicker = true
                     }
                 }
             } else if (self.currentSheet == .imageCrop) {
                 ImageCropView(croppingStyle: .circular, originalImage: self.image!, onCanceled: {
                     // on cancel
                 }) { (image, cropRect, angle) in
                     // on success
                    let thumb1 = image.resized(withPercentage: self.resizePercentage)
                    self.image = thumb1
                    self.userChoseImage(thumb1 ?? image)
                 }
               }
             }
        }
    }
}
