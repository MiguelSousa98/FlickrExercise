//
//  ViewController.swift
//  MobileExercise
//
//  Created by formacao on 05/07/2021.
//

import UIKit

struct APIResponse: Codable{
    let photos: Photos
}

struct Photos: Codable{
    let pages: Int
    let total: Int
    let photo: [Photo]
}

struct Photo: Codable{
    let id: String
    let server: String
    let secret: String
    let title: String
    
    var photoURL: String {
        "https://live.staticflickr.com/\(server)/\(id)_\(secret)_q.jpg"
    }
    
}

class ViewController: UIViewController, UICollectionViewDataSource {

    let urlBase = "https://api.flickr.com/services/rest/?api_key=7bdb03d29144dbbabc9c71fd173ac356&tags=bird&format=json&nojsoncallback=1&method=flickr.photos.search&page="
    
    var nextPage = 1  
    
    private var collectionView: UICollectionView?
    
    var photo: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2,
                        height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        view.addSubview(collectionView)
        self.collectionView = collectionView
        fetchPhotos()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.bounds
    }
    
    func fetchPhotos(){

        let urlString = "\(urlBase)\(nextPage)"
        guard let url = URL(string: urlString)else{
            return
        }
        let task = URLSession.shared.dataTask(with: url){[weak self] data, _, error in
            guard let data = data, error == nil else{
                return
            }
            do{
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.photo = jsonResult.photos.photo
                    self?.collectionView?.reloadData()
                    
                }
            }catch{
                print(error)
            }
        }
        task.resume()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photo.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result = photo[indexPath.row].photoURL
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath
        )  as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: result)
        return cell
    }
}
