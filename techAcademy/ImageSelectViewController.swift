//
//  ImageViewController.swift
//  techAcademy
//
//  Created by 越川将人 on 2021/09/21.
//

import UIKit
import Vision
import VisionKit
import Alamofire

//var propertyNameInput: Bool = false

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, URLSessionDelegate {
    
    var image: UIImage!
    var requests = [VNRequest]()
    var resultingText = ""
    var activityIndicator: UIActivityIndicatorView!
    var statusCode: Int = 0
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .photoLibrary
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = self
        present(documentCameraViewController, animated: true)
        
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {

        let imageJpgData = self.imageView.image!.jpegData(compressionQuality: 1)
        let textData = self.textView.text.data(using: .utf8)

        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }

        AF.upload(
                multipartFormData: { multipartFormData in
                    multipartFormData.append(imageJpgData!, withName: "upload_img_jpg" , fileName: "test01.jpg", mimeType: "image/jpeg")
                    multipartFormData.append(textData!, withName: "upload_txt" , fileName: "test01.txt", mimeType: "text/plain")
                },
                to: "http://192.168.97.160/test2.php", method: .post
        )
        .response { resp in
            switch resp.result {
                case .success:
                    print("response is:", resp)
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        // 正常終了メッセージ表示実装
                        
                        self.dismiss(animated: true)
                    }
                case let .failure(error):
                    print(error)
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        // 異常終了メッセージ表示実装
                        
                    }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVision()
        cancelButton.isEnabled = false
        
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        
    }
   
    // Setup Vision request as the request can be reused
    private func setupVision() {
        let textRecognitionRequest = VNRecognizeTextRequest { request, _ in
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                print("The observations are of an unexpected type.")
                return
            }
            // 解析結果の文字列を連結する
            let maximumCandidates = 1
            for observation in observations {
                guard let candidate = observation.topCandidates(maximumCandidates).first else { continue }
                self.resultingText += candidate.string + "\n"
            }
        }
        // 文字認識のレベルを設定
        textRecognitionRequest.recognitionLevel = .accurate
        self.requests = [textRecognitionRequest]
    }

    // 文字認識できる言語の取得
    private func getSupportedRecognitionLanguages() {
        let accurate = try! VNRecognizeTextRequest.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequestRevision1)
        print(accurate)
    }
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage

            print("DEBUG_PRINT: image = \(image)")

            // PostViewControllerに画面遷移する
            
            // Dispatch queue to perform Vision requests.
            
            picker.dismiss(animated: true)
            
            let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                                 qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
            textRecognitionWorkQueue.async {
                self.resultingText = ""
                    if let cgImage = image.cgImage {
                        let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                        do {
                            try requestHandler.perform(self.requests)
                        } catch {
                            print(error)
                    }
                }
                DispatchQueue.main.async(execute: {
                    // 文字認識させて反映（未実装）
                    self.textView.text = self.resultingText
                })
            }
            if ( self.textView.text != "" ) {
                cancelButton.isEnabled = true
            }
            imageView.image = image
        }
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            // ImageSelectViewController画面を閉じてタブ画面に戻る
            self.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    
    func processImage(input: CGImage) {
        let request = VNDetectTextRectanglesRequest { (request, error) in
            //ここに結果が表示されます
            if let results = request.results as? [VNTextObservation] {
                print(results)
            }
        }
        //次にリクエストに画像を受け渡します
        let handler = VNImageRequestHandler(cgImage: input, options: [:])
        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try handler.perform([request])
            } catch {
                 print(error)
            }
        }
    }
}

extension ImageSelectViewController: VNDocumentCameraViewControllerDelegate {
    // DocumentCamera で画像の保存に成功したときに呼ばれる
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true)

        // Dispatch queue to perform Vision requests.
        let textRecognitionWorkQueue = DispatchQueue(label: "TextRecognitionQueue",
                                                             qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)
        textRecognitionWorkQueue.async {
            self.resultingText = ""
            for pageIndex in 0 ..< scan.pageCount {
                let image = scan.imageOfPage(at: pageIndex)
                if let cgImage = image.cgImage {
                    let requestHandler = VNImageRequestHandler(cgImage: cgImage, options: [:])

                    do {
                        try requestHandler.perform(self.requests)
                    } catch {
                        print(error)
                    }
                }
            }
            DispatchQueue.main.async(execute: {
                // 文字認識させて反映（未実装）
                self.textView.text = self.resultingText
            })
        }
    }
    
}
