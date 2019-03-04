//
//  PhotoDisplayVC.swift
//  Virtual Tourise
//
//  Created by vasu on 20/01/19.
//  Copyright © 2019 Vasu. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoDisplayVC: UIViewController {

    @IBOutlet weak var mMapView: MKMapView!
    @IBOutlet weak var mCollectionView: UICollectionView!
    @IBOutlet weak var mBtmBtnOutlet: UIButton!
    @IBOutlet weak var mBtnBackgroundView : UIView!
    @IBOutlet weak var mNoDataAvailableView: UIView!
    @IBOutlet weak var mActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mNoDataLbl: UILabel!
    // MARK:- Properties
    var pCoordinate :CLLocationCoordinate2D!
    var dataController:DataController!
    var pPin : Pin!
    
    //MARK:- Local Variables
    private var mDataSource :[PhotoSearchPlaceModel] = []
    private let cell_identifier = "PhotoDisplayCltnCell"
    var fetchedResultsController:NSFetchedResultsController<ImageData>!

    var mSelectedCells = [IndexPath]()
   
    var mImgData = [ImageData]()
    var mImageNames : [String] = []
    var mImageStringDict = [String : ImageData]()
    var mDownloadImageCount  = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerNib()
        fetchImagesFromCoreData()
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
         navigationController?.navigationBar.isHidden = false
        
    }
    
    func configureUI(){
        mCollectionView.delegate = self
        mCollectionView.dataSource = self
        mMapView.delegate = self
        mCollectionView.allowsMultipleSelection = true
    
        let annotation  = MKPointAnnotation()
        annotation.coordinate = pCoordinate
        mMapView.addAnnotation(annotation)
        
        let coordinateRegion = MKCoordinateRegion(center: pCoordinate, span: MKCoordinateSpan(latitudeDelta: 0.5 , longitudeDelta:0.5))
        mMapView.setRegion(coordinateRegion, animated: true)
        
        
        self.mActivityIndicator.isHidden = true
        self.mNoDataAvailableView.isHidden = true
        disableBtn()
        
    }
    
    func disableBtn(){
        
       mBtmBtnOutlet.isEnabled = false
       mBtnBackgroundView.backgroundColor = hexStringToUIColor(hex: "ebebed",alpha: 1)
    }

    func enableBtn(){
        mBtmBtnOutlet.isEnabled = true
        mBtnBackgroundView.backgroundColor = hexStringToUIColor(hex: "449CFF",alpha: 1)
    }
    func registerNib(){
        
        let cellNib = UINib.init(nibName: cell_identifier, bundle: nil)
        mCollectionView.register(cellNib, forCellWithReuseIdentifier: cell_identifier)
    }
    
    func fetchImagesFromCoreData(){
        
        let fetchRequest:NSFetchRequest<ImageData> = ImageData.fetchRequest()
        let predicate = NSPredicate(format: "pin == %@", pPin)
        fetchRequest.predicate = predicate
        
        if let result =  try? dataController.viewContext.fetch(fetchRequest){
            
            mImgData = result
            
        }else{
            print("Error while fetching Pins from CoreData.....")
        }
        
        if self.mImgData.count < 1{
           fetchData()
        }else{
            enableBtn()
            fetchImageName()
            mCollectionView.reloadData()
        }
    }
    
    func fetchImageName(){
        for imgData in mImgData{
            mImageNames.append(imgData.imageName ?? "")
        }
    }
    
    func fetchData(){
        mActivityIndicator.isHidden = false
        mActivityIndicator.startAnimating()
        mNoDataAvailableView.isHidden = false
        
        Engine.seacrhPhotoUsingLatLon(lat: pCoordinate.latitude, lon: pCoordinate.longitude) { (data, error) in

            guard let data = data else{
              print("error while fetching images using locations")
                return
            }
            self.mDataSource = data.photos.photo
            
            if self.mDataSource.count<1{
                DispatchQueue.main.async {
                    self.mActivityIndicator.stopAnimating()
                    self.mActivityIndicator.isHidden = true
                    self.mNoDataAvailableView.isHidden = false
                    self.mNoDataLbl.text = "No Data Available"
                }
            }
            
            else{
                DispatchQueue.main.async {
                    
                    self.mActivityIndicator.stopAnimating()
                    self.mActivityIndicator.isHidden = true
                    self.mNoDataAvailableView.isHidden = true
                    self.configureDataSource()
                }
            }
           print("data has been loaded ......")
        }
    }
    
    func configureDataSource(){
        
        for _ in 0..<mDataSource.count{
            let currentDate = (Date().timeIntervalSince1970 * 1000)
             mImageNames.append("\(currentDate)")
        }
        self.mCollectionView.reloadData()
    }
    
    @IBAction func newCltnBtnClicked(_ sender: Any) {
        
        if mSelectedCells.count > 0{
            
            let indexes  = mSelectedCells.map { (indexpath) in
                 return indexpath.row
            }
            
            
            
            //delete from core data also
            for item in indexes{
                let imageName = mImageNames[item]
                if let imgData   = mImageStringDict[imageName]{
                  dataController.viewContext.delete(imgData)
                }
                else{
                    dataController.viewContext.delete(mImgData[item])
                }
                try? dataController.viewContext.save()
                print("Items deleted ...")
            }
            
            if mDataSource.count > 0{
                mDataSource = mDataSource
                    .enumerated()
                    .filter { !indexes.contains($0.offset) }
                    .map { $0.element }
            }
            else{
                
                mImgData = mImgData
                    .enumerated()
                    .filter { !indexes.contains($0.offset) }
                    .map { $0.element }
                
            }
            

            mCollectionView.performBatchUpdates({
                mCollectionView.deleteItems(at: mSelectedCells)
            }) { (success) in
                print("items deleted")
                if success
                {
                   self.mSelectedCells = []
                }

            }
            mCollectionView.reloadData()
            
        }
        
    }
    
    func getImageName() -> String{
        
        
        
        return ""
    }
    
    func hexStringToUIColor (hex:String,alpha :Float) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }

    
}

extension PhotoDisplayVC : UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cell_identifier, for: indexPath) as! PhotoDisplayCltnCell
        cell.delegate = self
        
        if mSelectedCells.contains(indexPath){
            cell.mSelectedView.isHidden = false
        }else{
            cell.mSelectedView.isHidden = true
        }
        
        if mDataSource.count > 0{
           let obj = mDataSource[indexPath.row]
           cell.configureUIWithData(dataObj: obj,imageName: mImageNames[indexPath.row],index: indexPath.row)
        }
        else{
           cell.configureUIWithData(dataObj: nil,imageName: mImageNames[indexPath.row],index: indexPath.row)
        }

        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mImgData.count > 0{
          return mImgData.count
        }

        return mDataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        return CGSize(width: (UIScreen.main.bounds.size.width)/3-2, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoDisplayCltnCell
        cell.mSelectedView.isHidden = false
        
        if !(mSelectedCells.contains(indexPath)) {
             mSelectedCells.append(indexPath)
             mBtmBtnOutlet.setTitle("Remove Selected Images", for: .normal)
            print("selectedCells - \(mSelectedCells)")
        }
        //cell.removeImgData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoDisplayCltnCell
        cell.mSelectedView.isHidden = true
        //cell.sav()
        if let index = mSelectedCells.index(where: { $0 == indexPath }) {
            mSelectedCells.remove(at: index)
            print("unselectedCells - \(mSelectedCells)")
            
        }
        if mSelectedCells.count == 0{
            mBtmBtnOutlet.setTitle("New Collection", for: .normal)
        }
    }
    
}
extension PhotoDisplayVC : MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
   }
}

extension PhotoDisplayVC : PhotoDisplayCltnCelldelegate{
    func imageSavedSuccessfully(index: Int) {
        saveImagetoCoreData(name: mImageNames[index],index)
    }
    func saveImagetoCoreData(name: String,_ index:Int) {
        let image = ImageData(context: dataController.viewContext)
        image.imageName = name
        image.pin = pPin
        try? dataController.viewContext.save()
        mImageStringDict[name] = image
        mDownloadImageCount = mDownloadImageCount+1
        print("\(mImageStringDict.count)" + " image names " + "\(mImageNames.count)")
        if mDownloadImageCount == mImageNames.count{
            enableBtn()
        }
    }
}
