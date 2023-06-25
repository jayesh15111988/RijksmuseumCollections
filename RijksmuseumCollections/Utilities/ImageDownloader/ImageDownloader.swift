//
//  ImageDownloader.swift
//  RijksmuseumCollections
//
//  Created by Jayesh Kawli on 6/22/23.
//

import UIKit

protocol ImageDownloadable {
    func downloadImage(with imageUrlString: String?,
                       completionHandler: @escaping (UIImage?, Bool, String?) -> Void)
    func clearCache()
}

// Image downloader utility class. We are going to use the singleton instance to be able to download required images and store them into in-memory cache.
final class ImageDownloader: ImageDownloadable {

    static let shared = ImageDownloader()

    private var cachedImages: [String: UIImage]
    private var imagesDownloadTasks: [String: URLSessionDataTask]

    // A serial queue to be able to write the non-thread-safe dictionary
    let serialQueueForImages = DispatchQueue(label: "images.queue", attributes: .concurrent)
    let serialQueueForDataTasks = DispatchQueue(label: "dataTasks.queue", attributes: .concurrent)

    // MARK: Private init
    private init() {
        cachedImages = [:]
        imagesDownloadTasks = [:]
    }

    /**
     Downloads and returns images through the completion closure to the caller
     - Parameter imageUrlString: The remote URL to download images from
     - Parameter completionHandler: A completion handler which returns two parameters. First one is an image which may or may
     not be cached and second one is a bool to indicate whether we returned the cached version or not
     */
    func downloadImage(with imageUrlString: String?,
                       completionHandler: @escaping (UIImage?, Bool, String?) -> Void) {

        guard let imageUrlString = imageUrlString else {
            return
        }

        if let image = getCachedImageFrom(urlString: imageUrlString) {
            completionHandler(image, true, imageUrlString)
        } else {
            guard let url = URL(string: imageUrlString) else {
                return
            }

            if let _ = getDataTaskFrom(urlString: imageUrlString) {
                return
            }

            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in

                guard let data = data else {
                    self.executeClosureOnMainThread(with: completionHandler, image: nil, isCached: false, imageURLString: imageUrlString)
                    return
                }

                if let _ = error {
                    self.executeClosureOnMainThread(with: completionHandler, image: nil, isCached: false, imageURLString: imageUrlString)
                    return
                }

                guard let image = UIImage(data: data) else {
                    self.executeClosureOnMainThread(with: completionHandler, image: nil, isCached: false, imageURLString: imageUrlString)
                    return
                }
                self.serialQueueForImages.sync(flags: .barrier) { [weak self] in
                    self?.cachedImages[imageUrlString] = image
                }

                _ = self.serialQueueForDataTasks.sync(flags: .barrier) { [weak self] in
                    self?.imagesDownloadTasks.removeValue(forKey: imageUrlString)
                }


                self.executeClosureOnMainThread(with: completionHandler, image: image, isCached: false, imageURLString: imageUrlString)
            }
            // We want to control the access to no-thread-safe dictionary in case it's being accessed by multiple threads at once
            self.serialQueueForDataTasks.sync(flags: .barrier) { [weak self] in
                self?.imagesDownloadTasks[imageUrlString] = task
            }

            task.resume()
        }
    }

    /// A method to clear all the cached images in the app
    func clearCache() {
        self.serialQueueForImages.sync(flags: .barrier) { [weak self] in
            self?.cachedImages.removeAll()
        }

        for (_, downloadTask) in imagesDownloadTasks {
            if downloadTask.state == .running {
                downloadTask.cancel()
            }
        }

        serialQueueForDataTasks.sync(flags: .barrier) { [weak self] in
            self?.imagesDownloadTasks.removeAll()
        }
    }

    //MARK: Private methods

    /// A method to force execute the code on main thread
    /// - Parameters:
    ///   - completionHandler: A completion handler closure that gets executed after completin of async operation
    ///   - image: A downloaded image to send back
    ///   - isCached: Boolean flag indicating whether image was cached or not
    ///   - imageURLString: An URL of image location
    private func executeClosureOnMainThread(with completionHandler: @escaping (UIImage?, Bool, String?) -> Void, image: UIImage?, isCached: Bool, imageURLString: String?) {
        DispatchQueue.main.async {
            completionHandler(image, isCached, imageURLString)
        }
    }

    /// A method to get cached image from local storage
    /// - Parameter urlString: An image URL
    /// - Returns: An image if cached, otherwise nil
    private func getCachedImageFrom(urlString: String) -> UIImage? {
        // Reading from the dictionary should happen in the thread-safe manner.
        serialQueueForImages.sync { [weak self] in
            return self?.cachedImages[urlString]
        }
    }

    /// A method to get data task from URL from dictionary that maps URL into URLSessionTask object
    /// - Parameter urlString: An image URL
    /// - Returns: An URLSessionTask if one exists, otherwise nil
    private func getDataTaskFrom(urlString: String) -> URLSessionTask? {

        // Reading from the dictionary should happen in the thread-safe manner.
        serialQueueForDataTasks.sync { [weak self] in
            return self?.imagesDownloadTasks[urlString]
        }
    }
}

extension UIImageView {

    /// An extension method on UIImageView to download image from URL and set it to UIImageView
    /// - Parameters:
    ///   - imageUrlString: An image URL
    ///   - placeholderImage: A placeholder image to show while image download is in progress or image could not be downloaded
    ///   - imageDownloader: An instance of image downloader to download image from URL
    func downloadImage(with imageUrlString: String?,
                       placeholderImage: UIImage?,
                       imageDownloader: ImageDownloadable = ImageDownloader.shared) {
        self.image = placeholderImage

        imageDownloader.downloadImage(with: imageUrlString, completionHandler: { [weak self] (image, isCached, urlString) in
            guard let image else { return }
            self?.image = image
        })
    }
}
