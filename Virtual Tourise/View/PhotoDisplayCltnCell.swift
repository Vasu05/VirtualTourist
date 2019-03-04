//  PhotoDisplayCltnCell.swift
//  Virtual Tourise
//
//  Created by vasu on 21/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import UIKit

protocol PhotoDisplayCltnCelldelegate :class {
    func imageSavedSuccessfully(index : Int)
}

class PhotoDisplayCltnCell: UICollectionViewCell {

    @IBOutlet weak var mPhotoView: UIImageView!
    @IBOutlet weak var mAcitivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mSelectedView: UIView!
    weak var delegate : PhotoDisplayCltnCelldelegate?
    var cellIndex = -1
    
    var dataController:DataController!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        mSelectedView.isHidden = true
        self.mAcitivityIndicator.isHidden = true
        // Initialization code
    }
    
    func configureUIWithData(dataObj:PhotoSearchPlaceModel?,imageName:String = "",index:Int = -1){
       
        mAcitivityIndicator.startAnimating()
        cellIndex = index
        
        if let img = loadImageFromDocumentDirectory(nameOfImage: imageName){
            mPhotoView.image = img
        }
        else if let obj = dataObj  {
            self.mAcitivityIndicator.isHidden = false
            Engine.getPhotoUsing(dataObj: obj) { (data, error) in
                
                self.mAcitivityIndicator.stopAnimating()
                self.mAcitivityIndicator.isHidden = true
                guard let data = data else {
                    return
                }
                let imageData = UIImage(data: data)
                self.mPhotoView.image = imageData
                
                self.saveImageToDocumentDirectory(image: imageData!, imageName: imageName)
                
            }
        }
    }

    func saveImageToDocumentDirectory(image: UIImage,imageName:String ) {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        let fileURL = documentsDirectory.appendingPathComponent(imageName)
        
        if let data = image.jpegData(compressionQuality: 1),!FileManager.default.fileExists(atPath: fileURL.path){
            do {
                try data.write(to: fileURL)
                self.delegate?.imageSavedSuccessfully(index: cellIndex)
                print("file saved \(imageName)")
            } catch {
                print("error saving file:", error)
            }
            
        }
        
    }
    
    func loadImageFromDocumentDirectory(nameOfImage : String) -> UIImage? {
        let nsDocumentDirectory = FileManager.SearchPathDirectory.documentDirectory
        let nsUserDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(nsDocumentDirectory, nsUserDomainMask, true)
        if let dirPath = paths.first{
            let imageURL = URL(fileURLWithPath: dirPath).appendingPathComponent(nameOfImage)
            let image    = UIImage(contentsOfFile: imageURL.path)
            return image
        }
        return nil
    }
    
    

    
}
