//
//  ViewController.swift
//  Concurrency
//
//  Created by Heejae Kim on 2022/01/21.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var tableView: UITableView!

    private var detailedImages: [DetailedImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        downloadImageAndMetadata(imageNumber: 1) { [weak self] detailedImage, error in
            guard let detailedImage = detailedImage else { return }
            self?.detailedImages.append(detailedImage)
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }

    private func downloadImageAndMetadata(
        imageNumber: Int,
        completionHandler: @escaping (DetailedImage?, Error?) -> Void
    ) {
        let imageUrl = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).png")!
        let imageTask = URLSession.shared.dataTask(with: imageUrl) { data, response, error in
            guard let data = data, let image = UIImage(data: data), (response as? HTTPURLResponse)?.statusCode == 200 else {
                completionHandler(nil, ImageDownloadError.badImage)
                return
            }
            let metadataUrl = URL(string: "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(imageNumber).json")!
            let metadataTask = URLSession.shared.dataTask(with: metadataUrl) { data, response, error in
                guard let data = data, let metadata = try? JSONDecoder().decode(ImageMetadata.self, from: data),  (response as? HTTPURLResponse)?.statusCode == 200 else {
                    completionHandler(nil, ImageDownloadError.invalidMetadata)
                    return
                }
                let detailedImage = DetailedImage(image: image, metadata: metadata)
                completionHandler(detailedImage, nil)
            }
            metadataTask.resume()
        }
        imageTask.resume()
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detailedImages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") else { return UITableViewCell()
        }
        cell.imageView?.image = detailedImages[indexPath.row].image
        return cell
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        200
    }
}
