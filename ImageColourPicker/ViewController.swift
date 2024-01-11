//
//  ViewController.swift
//  ImageColourPicker
//
//  Created by iPHTech 28 on 05/01/24.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIColorPickerViewControllerDelegate {
    
    
    
    //Mark: -IBoutlets
    @IBOutlet weak var backgroundImgView: UIView!
    @IBOutlet weak var imgPickerView: UIImageView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var viewForColorPicker: UIView!
    @IBOutlet weak var hexColorView: UIView!
    @IBOutlet weak var hexCodeView: UIView!
    @IBOutlet weak var hexLbl: UILabel!
    @IBOutlet weak var rgbView: UIView!
    @IBOutlet weak var rgbCodeView: UIView!
    @IBOutlet weak var rgbLbl: UILabel!
    @IBOutlet weak var copyBtnForHex: UIButton!
    @IBOutlet weak var copyForRGB: UIButton!
    @IBOutlet weak var colourPickerBtn: UIButton!
    @IBOutlet weak var selectPhotoLbl: UILabel!
    @IBOutlet weak var displayTextLbl: UILabel!
    
    
    
    //Mark: -Life Cycle Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imgPickerView.isUserInteractionEnabled = true
        imgPickerView.addGestureRecognizer(tapGestureRecognizer)
        
        setUpUI()
    }
    
    
    //Mark: -Action
    @IBAction func pickerBtnAction(_ sender: Any) {
        
        let colorPicker = UIColorPickerViewController()
        colorPicker.delegate = self
        present(colorPicker, animated: true)
        
        
    }
    
    
    @IBAction func hexCodeCopyBtnAction(_ sender: UIButton) {
        
        if let hexCode = hexLbl.text {
            UIPasteboard.general.string = hexCode
            showAlert(message: "Hex code copied to clipboard")
        }
        
    }
    
    
    @IBAction func rgbCodeCopyBtnAction(_ sender: UIButton) {
        
        if let rgbCode = rgbLbl.text {
            UIPasteboard.general.string = rgbCode
            showAlert(message: "RGB code copied to clipboard")
        }
        
    }
    
    //MARK: -setUpUI
    func setUpUI() {
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        colourPickerBtn.isHidden = true
        viewForColorPicker.isHidden = true
        
        viewForColorPicker.layer.cornerRadius = 10
        hexColorView.layer.cornerRadius = 10
        hexCodeView.layer.cornerRadius = 10
        rgbView.layer.cornerRadius = 10
        rgbCodeView.layer.cornerRadius = 10
        
    }
    
    
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "Copied", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    func colorPickerViewControllerDidSelectColor(_ viewController: UIColorPickerViewController) {
        
        let color = viewController.selectedColor
        hexColorView.backgroundColor = color
        
        let hexCode = color.toHexString()
        print("Hex Code: #\(hexCode)")
        
        hexLbl.text = "Hex Code: #\(hexCode)"
        updateRGBValues(color: color)
        
    }
    
    
    func updateRGBValues(color: UIColor) {
        
        let (red, green, blue, _) = color.components
        rgbView.backgroundColor = color
        rgbLbl.text = String(format: "RGB: (%.0f, %.0f, %.0f)", red * 255, green * 255, blue * 255)
        
    }
    
    
    @objc func imageTapped() {
        showImagePicker()
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func displayColorsInPalette(colors: [UIColor]) {
        // Assuming you have a reference to your cells data source
        guard let cells = myCollectionView.visibleCells as? [MyCollectionViewCell] else {
            return
        }
        
        for index in 0...11 {
            cells[index].backgroundColorView.backgroundColor = colors[index*colors.count/12]
        }
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imgPickerView.image = pickedImage
            let colors = extractColors(from: pickedImage)
            displayColorsInPalette(colors: colors)
            colourPickerBtn.isHidden = false
            viewForColorPicker.isHidden = false
            selectPhotoLbl.isHidden = true
            displayTextLbl.isHidden = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func extractColors(from image: UIImage) -> [UIColor] {
        guard let imageRef = image.cgImage else {
            return []
        }
        
        let width = imageRef.width
        let height = imageRef.height
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let rawData = UnsafeMutablePointer<UInt8>.allocate(capacity: height * bytesPerRow)
        
        // Get raw pixel data
        let context = CGContext(data: rawData,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)
        
        context?.draw(imageRef, in: CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        
        var result: [UIColor] = []
        
        // Process raw data and extract colors
        for yy in 0..<height {
            for xx in 0..<width {
                let byteIndex = (bytesPerRow * yy) + xx * bytesPerPixel
                let red   = CGFloat(rawData[byteIndex]) / 255.0
                let green = CGFloat(rawData[byteIndex + 1]) / 255.0
                let blue  = CGFloat(rawData[byteIndex + 2]) / 255.0
                let alpha = CGFloat(rawData[byteIndex + 3]) / 255.0
                
                let acolor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
                result.append(acolor)
                
            }
        }
        hexColorView.backgroundColor = result[0]
        let firstColor = result[0]
        let (hexCode, rgbCode) = getColorCodes(color: firstColor)
        
        hexColorView.backgroundColor = firstColor
        rgbView.backgroundColor = firstColor
        hexLbl.text = "Hex Code: #\(hexCode)"
        rgbLbl.text = "rgb: \(rgbCode)"
        // Now you can use hexCode and rgbCode as needed
        print("Hex Code: #\(hexCode)")
        print("rgb: \(rgbCode)")
        rawData.deallocate()
        return result
    }
    
    
    func getColorCodes(color: UIColor) -> (hexCode: String, rgbCode: String) {
        let hexCode = color.toHexString()
        
        let (red, green, blue, _) = color.components
        let rgbCode = String(format: "RGB: (%.0f, %.0f, %.0f)", red * 255, green * 255, blue * 255)
        
        return (hexCode, rgbCode)
    }
    
    
}


//MARK: -extension
extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! MyCollectionViewCell
        cell.backgroundColorView.layer.cornerRadius = 10
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.frame.width - 320
        let cellHeight: CGFloat = 80
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
extension UIColor {
    func toHexString() -> String {
        guard let components = cgColor.components else {
            return ""
        }
        
        let red = Float(components[0])
        let green = Float(components[1])
        let blue = Float(components[2])
        
        let hexString = String(format: "%02lX%02lX%02lX", lroundf(red * 255), lroundf(green * 255), lroundf(blue * 255))
        return hexString
    }
}
extension UIColor {
    var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        guard let components = cgColor.components else {
            return (0, 0, 0, 1)
        }
        return (components[0], components[1], components[2], components[3])
    }
}
