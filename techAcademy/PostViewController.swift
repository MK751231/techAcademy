//
//  PostViewController.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/09/21.
//

import UIKit
import Vision
import VisionKit

class PostViewController: UIViewController {
    var image: UIImage!

    @IBOutlet weak var imageView: UIImageView!

    @IBAction func handlePostButton(_ sender: Any) {
        var alertTextField: UITextField?

        let alert = UIAlertController(
            title: "新規保存",
            message: "件名を入力してください",
            preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(
            configurationHandler: {(textField: UITextField!) in
                alertTextField = textField
                // textField.text = self.textLabel.text
                // textField.placeholder = "Mike"
                // textField.isSecureTextEntry = true
        })
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: UIAlertAction.Style.cancel,
                handler: nil))
        alert.addAction(
            UIAlertAction(
                title: "OK",
                style: UIAlertAction.Style.default) { _ in
                    if let text = alertTextField?.text {
                        // self.textLabel.text = text
                        let myImage = self.imageView.convertToImage() // 全レイヤーを一つの画像に合成する。
                        UIImageWriteToSavedPhotosAlbum(myImage!,self,
                            #selector(self.didFinishSavingImage(_:didFinishSavingWithError:contextInfo:)),nil)
                        }
                    })
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // self.dismiss(animated: true, completion: nil)
        // ImageSelectViewController まで戻る
        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.imageView.image = image

        // imageのOrientationを正しくするExtensionを使って前処理
        image = UIImage.fixedOrientation(for: image)
        
        // imageViewのframe sizeを可変にする
        let scale = self.view.bounds.width/image.size.width
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.frame = CGRect(
            x: imageView.frame.minX,
            y: imageView.frame.minY,
            width: self.view.bounds.width,
            height: scale * image.size.height)
        
        let cgImage = image.cgImage!
        processImage(input1: image, input2: cgImage)
        let myImage = self.imageView.convertToImage()
        self.imageView.image = myImage

    }
    
    func processImage(input1: UIImage, input2: CGImage) {
        let request = VNDetectTextRectanglesRequest { (request, error) in
            //We have the result here
            if let results = request.results as? [VNTextObservation] {
                for result in results {
                    DispatchQueue.main.async {
                        self.drawBoundingBox(forResult: result)
                    }
                }
            }
        }
        //Now pass the image to the request
        let handler = VNImageRequestHandler(cgImage: input2, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                 print(error)
            }
        }
    }
    
    func drawBoundingBox(forResult: VNTextObservation) {
        let outline = CALayer()
        // バウンディングボックスの座標はパーセンテージとして与えられます。実際の画面の座標に変換する必要があります
        let x = forResult.topLeft.x * imageView.frame.width
        let y = (1 - forResult.topLeft.y) * imageView.frame.height
        // 横幅と高さは「boundingBox」から取得できます
        let width = forResult.boundingBox.width * imageView.frame.width
        let height = forResult.boundingBox.height * imageView.frame.height
        print("\(Int(x)),\(Int(y)),\(Int(width)),\(Int(height))")
        
        outline.frame = CGRect(x: x, y: y, width: width, height: height)
        outline.borderColor = UIColor.green.cgColor
        outline.borderWidth = 1
        imageView.layer.addSublayer(outline)
    }

    @objc func didFinishSavingImage(_ image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutableRawPointer) {
       
       // 結果によって出すアラートを変更する
       var title = "保存完了"
       var message = "カメラロールに保存しました"
       let ok = "OK"
       
       if error != nil {
           title = "エラー"
           message = "保存に失敗しました"
       }
       
       let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
       alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in
           
       }))
       self.present(alertController, animated: true, completion: nil)
    }
    
}

extension UIView {
    func convertToImage() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
extension UIImage {

    static func fixedOrientation(for image: UIImage) -> UIImage? {
        
        guard image.imageOrientation != .up else {
            return image
        }
        
        let size = image.size
        
        let imageOrientation = image.imageOrientation
        
        var transform: CGAffineTransform = .identity

        switch image.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        guard var cgImage = image.cgImage else {
            return nil
        }
        
        autoreleasepool {
            var context: CGContext?
            
            guard let colorSpace = cgImage.colorSpace, let _context = CGContext(data: nil, width: Int(image.size.width), height: Int(image.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                return
            }
            context = _context
            
            context?.concatenate(transform)

            var drawRect: CGRect = .zero
            switch imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                drawRect.size = CGSize(width: size.height, height: size.width)
            default:
                drawRect.size = CGSize(width: size.width, height: size.height)
            }

            context?.draw(cgImage, in: drawRect)
            
            guard let newCGImage = context?.makeImage() else {
                return
            }
            cgImage = newCGImage
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1, orientation: .up)
        return uiImage
    }
}
