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

    private func getImageURL(_ number: Int) -> String {
        "https://cdn.clien.net/web/api/file/F01/10857985/177492a4904601.jpg"
    }

    private func getMetadataURL(_ number: Int) -> String {
        "https://www.andyibanez.com/fairesepages.github.io/tutorials/async-await/part1/\(number).json"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        Task {
            do {
                let imageDetail = try await downloadImageAndMetadata(imageNumber: 1)
                detailedImages = [imageDetail]
                tableView.reloadData()
            }
            catch {
                print("")
            }
        }
    }

    func downloadImageAndMetadata(imageNumber: Int) async throws -> DetailedImage {
        print("---> willImageDownload")
        let image = try await downloadImage(imageNumber: imageNumber)
        print("---> didImageDownload")
        print("---> willMetadataDownload")
        let metadata = try await downloadMetadata(for: imageNumber)
        print("---> didMetadataDownload")
        return DetailedImage(image: image, metadata: metadata)
    }

//    func downloadImageAndMetadata(imageNumber: Int) async throws -> DetailedImage {
//        print("---> willImageDownload")
//        async let image = downloadImage(imageNumber: imageNumber)
//        print("---> didImageDownload")
//        print("---> willMetadataDownload")
//        async let metadata = downloadMetadata(for: imageNumber)
//        print("---> didMetadataDownload")
//        return try DetailedImage(image: await image, metadata: await metadata)
//    }

    private func downloadImage(imageNumber: Int) async throws -> UIImage {
        try Task.checkCancellation()
        let url = URL(string: getImageURL(imageNumber))!
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let image = UIImage(data: data), (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.badImage
        }
        return image
    }

    func downloadMetadata(for id: Int) async throws -> ImageMetadata {
        try Task.checkCancellation()
        let url = URL(string: getMetadataURL(id))!
        let request = URLRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard (response as? HTTPURLResponse)?.statusCode == 200 else {
            throw ImageDownloadError.invalidMetadata
        }
        return try JSONDecoder().decode(ImageMetadata.self, from: data)
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
