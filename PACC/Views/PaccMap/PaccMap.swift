//
//  PaccMap.swift
//  PACC
//
//  Created by RSS on 5/27/18.
//  Copyright © 2018 HTK. All rights reserved.
//

import UIKit
import GoogleMaps

class PaccMap: UIView {

    @IBOutlet weak var mapView: GMSMapView!
    
    let businessType = ["Dispensary", "Grower/processor", "Physician", "Attorney", "Contractors", "Electricians", "Grow room design ", "Security", "Payroll", "Marketing", "Real estate", "Storefront", "Media/photography/videography"]
    var currentFilter: String = "Dispensary"
    var currentMarkers: [PaccMarker] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadNibName()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadNibName()
    }
    
    func loadNibName() {
        let view = Bundle.main.loadNibNamed("PaccMap", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        view.backgroundColor = self.backgroundColor
        self.addSubview(view)
        
        // Set mapview delegate
        mapView.delegate = self        
        
    }
    
    func setMapStyle() {
        // Customize google map
        if let path = Bundle.main.path(forResource: "GoogleMapStyle", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
                let jsonSTR = String(data: data, encoding: String.Encoding.utf8)
                self.mapView.mapStyle = try GMSMapStyle(jsonString: jsonSTR!)
            } catch let error {
                print(error.localizedDescription)
            }
        } else {
            print("Invalid filename/path.")
        }
    }
    
    func showBusinessesOnMap(_ businesses: [User]?) {
        if self.currentMarkers.count > 0 {
            for marker in self.currentMarkers {
                marker.map = nil
            }
        }
        self.currentMarkers.removeAll()
        if businesses != nil && businesses!.count > 0 {
            for business in businesses! {
                let businessMarker = PaccMarker()
                if(business.lat != nil) {
                     businessMarker.position = CLLocationCoordinate2D(latitude: business.lat!, longitude: business.long!)
                }
                businessMarker.icon = #imageLiteral(resourceName: "map_active_location")
                businessMarker.map = self.mapView
                businessMarker.appearAnimation = GMSMarkerAnimation.pop
                businessMarker.business = business
                self.currentMarkers.append(businessMarker)
            }
        }
        if self.currentMarkers.count > 0 && self.currentMarkers[0].business!.lat! != 0 {
            let camera = GMSCameraPosition.camera(withLatitude: self.currentMarkers[0].business!.lat!, longitude: self.currentMarkers[0].business!.long!, zoom: 6.0 )
            self.mapView.camera = camera
        }else {
            if User.sharedInstance.lat != nil && User.sharedInstance.lat != 0 {
//                let camera = GMSCameraPosition.camera(withLatitude: User.sharedInstance.lat!, longitude: User.sharedInstance.long!, zoom: 6.0 )
//                self.mapView.camera = camera
                
                let camera = GMSCameraPosition.camera(withLatitude: 40.855640, longitude: -77.760468, zoom: 6.0 )
                self.mapView.camera = camera
            }else {
                let camera = GMSCameraPosition.camera(withLatitude: 40.855640, longitude: -77.760468, zoom: 6.0 )
                self.mapView.camera = camera
            }
        }
    }
    
    func showBusinessesOnMap(_ businessType: String) {
        let vc = self.findViewController() as! ExploreViewController
        vc.showHUD()
        
        API.sharedInstance.get_existing_businesses { (businesses) in
            vc.hideHUD()
            if self.currentMarkers.count > 0 {
                for marker in self.currentMarkers {
                    marker.map = nil
                }
            }
            self.currentMarkers.removeAll()
            if businesses != nil && businesses!.count > 0 {
                for business in businesses! {
                    if business.business_type == businessType {
                        let businessMarker = PaccMarker()
                        businessMarker.position = CLLocationCoordinate2D(latitude: business.lat!, longitude: business.long!)
                        businessMarker.icon = #imageLiteral(resourceName: "map_active_location")
                        businessMarker.map = self.mapView
                        businessMarker.appearAnimation = GMSMarkerAnimation.pop
                        businessMarker.business = business
                        self.currentMarkers.append(businessMarker)
                    }
                }
            }
            if self.currentMarkers.count > 0 && self.currentMarkers[0].business!.lat! != 0 {
                let camera = GMSCameraPosition.camera(withLatitude: self.currentMarkers[0].business!.lat!, longitude: self.currentMarkers[0].business!.long!, zoom: 15.0 )
                self.mapView.camera = camera
            }else {
                if User.sharedInstance.lat != 0 && User.sharedInstance.lat != 0 {
//                    let camera = GMSCameraPosition.camera(withLatitude: User.sharedInstance.lat!, longitude: User.sharedInstance.long!, zoom: 6.0 )
//                    self.mapView.camera = camera
                    
                    let camera = GMSCameraPosition.camera(withLatitude: 40.855640, longitude: -77.760468, zoom: 6.0 )
                    self.mapView.camera = camera
                }else {
                    let camera = GMSCameraPosition.camera(withLatitude: 40.855640, longitude: -77.760468, zoom: 6.0 )
                    self.mapView.camera = camera
                }
            }
        }
    }
    
    
    func showBusinessesOnMap(_ businessType: String, _ businessName: String) {
        let vc = self.findViewController() as! ExploreViewController
        var currentLong: Double = -77.760468
        var currentLat: Double = 40.855640
        vc.showHUD()
        
        API.sharedInstance.get_existing_businesses { (businesses) in
            vc.hideHUD()
            if self.currentMarkers.count > 0 {
                for marker in self.currentMarkers {
                    marker.map = nil
                }
            }
            self.currentMarkers.removeAll()
            if businesses != nil && businesses!.count > 0 {
                for business in businesses! {
                    if business.business_type == businessType {
                        
                        if business.name == businessName{
                            currentLong =  business.long!
                            currentLat = business.lat!
                        }
                        let businessMarker = PaccMarker()
                        businessMarker.position = CLLocationCoordinate2D(latitude: business.lat!, longitude: business.long!)
                        businessMarker.icon = #imageLiteral(resourceName: "map_active_location")
                        businessMarker.map = self.mapView
                        businessMarker.appearAnimation = GMSMarkerAnimation.pop
                        businessMarker.business = business
                        self.currentMarkers.append(businessMarker)
                    }
                }
            }
            if self.currentMarkers.count > 0 && currentLat != 0 {
                let camera = GMSCameraPosition.camera(withLatitude: currentLat, longitude: currentLong, zoom: 6.0 )
                self.mapView.camera = camera
            }else {
                let camera = GMSCameraPosition.camera(withLatitude: 40.855640, longitude: -77.760468, zoom: 6.0 )
                self.mapView.camera = camera
            }
        }
    }
}

extension PaccMap: GMSMapViewDelegate{
    /* handles Info Window tap */
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        print("didTapInfoWindowOf")
    }
    
    /* handles Info Window long press */
    func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
        print("didLongPressInfoWindowOf")
    }
    
    /* set a custom Info Window */
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 70))
        view.alpha = 0.0
        let currentMarker: PaccMarker = marker as! PaccMarker
        if self.findViewController() is ExploreViewController {
            let vc = self.findViewController() as! ExploreViewController
            vc.businessInfo?.alpha = 1.0
            if currentMarker.business?.profileimg != nil && currentMarker.business?.profileimg != "" {
                vc.businessInfo?.profile.loadImageWithoutIndicator(urlString: currentMarker.business!.profileimg!)
            }
            vc.businessInfo?.user = currentMarker.business
            vc.businessInfo?.name.text = currentMarker.business?.name
            vc.businessInfo?.type.text = currentMarker.business?.business_type
        }else {
            let vc = self.findViewController() as! HomeViewController
            let mapBusinessInfo = BusinessInfo()
            mapBusinessInfo.alpha = 1.0
            if currentMarker.business?.profileimg != nil && currentMarker.business?.profileimg != "" {
               mapBusinessInfo.profile.loadImageWithoutIndicator(urlString: currentMarker.business!.profileimg!)
            }
            mapBusinessInfo.user = currentMarker.business
            mapBusinessInfo.name.text = currentMarker.business?.name
            mapBusinessInfo.type.text = currentMarker.business?.business_type
          
            vc.gotoExplore()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
               NotificationCenter.default.post(name: .mapBusinessInfoSendNotification, object: nil, userInfo: ["BusinessInfo" : mapBusinessInfo])
           }
        }
        
        
        return view
    }
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        
    }
}

extension Notification.Name {
    static let mapBusinessInfoSendNotification = Notification.Name("MapBusinessInfoSendNotification")
}
