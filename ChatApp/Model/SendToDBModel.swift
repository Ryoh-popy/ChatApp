//
//  SendToDBModel.swift
//  ChatApp
//
//  Created by Ryoh on 2021/05/01.
//

import Foundation
import FirebaseStorage

class SendToDBModel{
    
    init(){
        
    }
    
    // 画像をfirebase Storageに送る
    func sendProfileImageData(data:Data){
        
        // 画像を10分の1に圧縮
        let image = UIImage(data:data)
        let profileImage = image?.jpegData(compressionQuality: 0.1)
        
        // ユニークなstorageのパスを決める
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        
        
        imageRef.putData(Data(profileImage!),metadata: nil){ (metaData,error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            imageRef.downloadURL{ (url,error) in
                
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                
                UserDefaults.standard.setValue(url?.absoluteURL,forKey:"userImage")
                
            }
            
        }
        
        // a
        
    }
    
}
