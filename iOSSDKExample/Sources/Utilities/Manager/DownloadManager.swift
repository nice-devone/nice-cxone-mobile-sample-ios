import Foundation


enum DownloadManager {
    
    static func loadFileSync(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            completion(.success(destinationUrl))
        } else if let dataFromURL = NSData(contentsOf: url) {
            if dataFromURL.write(to: destinationUrl, atomically: true) {
                completion(.success(destinationUrl))
            } else {
                let error = NSError(domain: "Error saving file", code: 1001, userInfo: nil)
                completion(.failure(error))
            }
        } else {
            let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
            completion(.failure(error))
        }
    }
    
    static func loadFileAsync(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let documentsUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            Log.error(CommonError.unableToParse("documentsUrl"))
            return
        }
        
        let destinationUrl = documentsUrl.appendingPathComponent(url.lastPathComponent)
        
        if FileManager().fileExists(atPath: destinationUrl.path) {
            completion(.success(destinationUrl))
        } else {
            let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            let task = session.downloadTask(with: request) { localUrl, response, error in
                if FileManager().fileExists(atPath: destinationUrl.path) {
                    completion(.success(destinationUrl))
                } else if let response = response as? HTTPURLResponse, response.statusCode == 200, let localUrl {
                    do {
                        try FileManager.default.moveItem(at: localUrl, to: destinationUrl)
                        
                        completion(.success(destinationUrl))
                    } catch {
                        completion(.failure(error))
                    }
                } else if let error {
                    completion(.failure(error))
                } else {
                    let error = NSError(domain: "Error downloading file", code: 1002, userInfo: nil)
                    completion(.failure(error))
                }
            }
            
            task.resume()
        }
    }
}
