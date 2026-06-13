import UIKit

private let imageCache = NSCache<NSURL, UIImage>()

extension UIImageView {
    func loadImage(from url: URL, placeholder: UIImage? = nil) {
        image = placeholder
        tag = url.hashValue

        if let cached = imageCache.object(forKey: url as NSURL) {
            image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let self,
                  let data,
                  let img = UIImage(data: data) else { return }
            imageCache.setObject(img, forKey: url as NSURL)
            DispatchQueue.main.async {
                if self.tag == url.hashValue {
                    self.image = img
                }
            }
        }.resume()
    }
}
