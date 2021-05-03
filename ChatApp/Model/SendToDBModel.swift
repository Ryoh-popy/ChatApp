//
//  SendToDBModel.swift
//  ChatApp
//
//  Created by Ryoh on 2021/05/01.
//

import Foundation
import FirebaseStorage

protocol SendProfileOKDelegate{
    
    func sendProfileOKDelegate(url:String)
}

class SendToDBModel{
    
    var sendProfileOKDelegate:SendProfileOKDelegate?
    
    init(){
        
    }
    
    // 画像をfirebase Storageに送る
    func sendProfileImageData(data:Data){
        
        // 画像を10分の1に圧縮
        let image = UIImage(data:data)
        let profileImageData = image?.jpegData(compressionQuality: 0.1)
        
        // ユニークなstorageのパスを作り保存先を決める
        
        let imageRef = Storage.storage().reference().child("profileImage").child("\(UUID().uuidString + String(Date().timeIntervalSince1970)).jpg")
        
        
        imageRef.putData(profileImageData!,metadata: nil){ (metaData,error) in
            
            if error != nil{
                print(error.debugDescription)
                return
            }
            
            imageRef.downloadURL{ (url,error) in
                
                if error != nil{
                    print(error.debugDescription)
                    return
                }
                
                UserDefaults.standard.setValue(url?.absoluteString,forKey:"userImage")
                self.sendProfileOKDelegate?.sendProfileOKDelegate(url: url!.absoluteString)
            }
        }
        
        // a
        
    }
    
}
