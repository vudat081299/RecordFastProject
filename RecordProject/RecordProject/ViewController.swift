//
//  ViewController.swift
//  RecordProject
//
//  Created by Vũ Quý Đạt  on 10/11/2020.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioRecorderDelegate, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var folder: UITextField!
    @IBOutlet weak var commandLabel: UILabel!
    @IBOutlet weak var completedCommand: UITextField!
    var recordButton: UIButton!
    var label: UILabel!
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    /// Creating UIDocumentInteractionController instance.
    let documentInteractionController = UIDocumentInteractionController()
//    let generator = UINotificationFeedbackGenerator()
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    var result: [String] = []
//    var i = 0
    var defaultIndex =  UserDefaults.standard.integer(forKey: "index")
    var oldCompletedCommand = 0
    func csv(data: String) {
        var result: [[String]] = []
        let rows = data.components(separatedBy: "\n")
        result.append(rows)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        if defaultIndex < 0 || defaultIndex > result.count - 1 {
////            UserDefaults.standard.set(2001, forKey: "index")
//            defaultIndex = 0
//        }
        completedCommand.text = "0"
        oldCompletedCommand = 0
        print(defaultIndex)
        parseCSV()
        folder.text = "" // "file/"
        // Do any additional setup after loading the view.
        recordingSession = AVAudioSession.sharedInstance()

        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        self.loadRecordingUI()
                    } else {
                        // failed to record!
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }

    func loadRecordingUI() {
        commandLabel.text = result[defaultIndex]
        recordButton = UIButton(frame: CGRect(x: self.view.frame.width/2 - 135, y: self.view.frame.height/2 - 50 + 200, width: 270, height: 100))
        recordButton.backgroundColor = .blue
        recordButton.alpha = 0.5
        recordButton.tintColor = .white
        recordButton.setTitle("Tap to Record", for: .normal)
        recordButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .title2)
        recordButton.addTarget(self, action: #selector(recordTapped), for: .touchUpInside)
        
        label = UILabel(frame: CGRect(x: self.view.frame.width/2 - 50, y: self.view.frame.height/2 - 10 + 65 + 200, width: 100, height: 20))
        textField.backgroundColor = .black
        textField.text = "\(defaultIndex + Int(completedCommand.text!)! + 1)"
        view.addSubview(recordButton)
        view.addSubview(label)
    }
    @IBAction func change(_ sender: UITextField) {
        if (sender.text == nil) || (sender.text == "") || Int(sender.text!)! < (Int(completedCommand.text!)! + 1) || Int(sender.text!)! > result.count + Int(completedCommand.text!)! {
            sender.text = "\(Int(completedCommand.text!)! + 1)"
        } else {
        }
        updateDefaultIndexAndCommandLabel()
    }
    @IBAction func changeValue(_ sender: UITextField) {
        if (sender.text == nil) || (sender.text == "") || Int(sender.text!)! < (Int(completedCommand.text!)! + 1) || Int(sender.text!)! > result.count + Int(completedCommand.text!)! {
            sender.text = "\(Int(completedCommand.text!)! + 1)"
        } else {
        }
        updateDefaultIndexAndCommandLabel()
    }
    
    @IBAction func didChooseCompletedCommand(_ sender: UITextField) {
        if (sender.text == nil) || (sender.text == "") || Int(sender.text!)! < 0 {
            sender.text = "0"
        } else {
        }
        textField.text = "\(Int(completedCommand.text!)! + Int(textField.text!)! - oldCompletedCommand)"
        updateDefaultIndexAndCommandLabel()
        
        oldCompletedCommand = Int(completedCommand.text!)!
    }
    
    func updateDefaultIndexAndCommandLabel () {
        defaultIndex = Int(textField.text!)! - (Int(completedCommand.text!)! + 1)
        UserDefaults.standard.set(defaultIndex, forKey: "index")
        print(defaultIndex)
        commandLabel.text = result[defaultIndex]
    }
    @IBAction func changeIndex(_ sender: UITextField) {
    }
    func startRecording() {
        self.view.endEditing(true)
        
//        i += 1
//        print("Running \(i)")
//        switch i {
//        case 1:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.error)
//
//        case 2:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.success)
//
//        case 3:
//            let generator = UINotificationFeedbackGenerator()
//            generator.notificationOccurred(.warning)
//
//        case 4:
//            let generator = UIImpactFeedbackGenerator(style: .light)
//            generator.impactOccurred()
//
//        case 5:
//            let generator = UIImpactFeedbackGenerator(style: .medium)
//            generator.impactOccurred()
//
//        case 6:
//            let generator = UIImpactFeedbackGenerator(style: .heavy)
//            generator.impactOccurred()
//
//        default:
//            let generator = UISelectionFeedbackGenerator()
//            generator.selectionChanged()
//            i = 0
//        }
        print(folder.text!)
        let audioFilename = getDocumentsDirectory().appendingPathComponent("\(String(describing: folder.text!))\(String(describing: Int(textField.text!)!)).wav")

        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 16000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue,
            AVLinearPCMBitDepthKey: 32
        ]

        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()

            recordButton.setTitle("Tap to Stop", for: .normal)
            recordButton.backgroundColor = .red
            label.text = ""
        } catch {
            finishRecording(success: false)
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    @IBAction func hideKeyboardTap(_ sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil

        if success {
            recordButton.setTitle("Tap to Re-record", for: .normal)
            recordButton.backgroundColor = .blue
            textField.text = String(describing: Int(textField.text!)! + 1)
            updateDefaultIndexAndCommandLabel()
        } else {
            recordButton.setTitle("Tap to Record", for: .normal)
            recordButton.backgroundColor = .blue
            // recording failed :(
            label.text = "Failed!"
        }
    }
    /// This function will set all the required properties, and then provide a preview for the document
    func share(url: URL) {
        documentInteractionController.url = url
        documentInteractionController.uti = "public.data, public.content"
        documentInteractionController.name = url.lastPathComponent
        documentInteractionController.presentPreview(animated: true)
    }
    
    /// This function will store your document to some temporary URL and then provide sharing, copying, printing, saving options to the user
    func storeAndShare(withURLString: String) {
        guard let url = URL(string: withURLString) else { return }
        /// START YOUR ACTIVITY INDICATOR HERE
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            let tmpURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(response?.suggestedFilename ?? "fileName.png")
            do {
                try data.write(to: tmpURL)
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                /// STOP YOUR ACTIVITY INDICATOR HERE
                self.share(url: tmpURL)
            }
            }.resume()
    }
    @objc func recordTapped() {
        generator.prepare()
        generator.impactOccurred()
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
    func openCSV(fileName:String, fileType: String)-> String!{
        guard let filepath = Bundle.main.path(forResource: fileName, ofType: fileType)
            else {
                return nil
        }
        do {
            let contents = try String(contentsOfFile: filepath, encoding: .utf8)

            return contents
        } catch {
            print("File Read Error for file \(filepath)")
            return nil
        }
    }

     func parseCSV(){
        let dataString: String! = openCSV(fileName: "command", fileType: "csv")
//        var items: [(String, String, String)] = []
        let lines: [String] = dataString.components(separatedBy: NSCharacterSet.newlines) as [String]

        var values: [String] = []
        for line in lines {
           if line != "" {
               if line.range(of: "\"") != nil {
                   var textToScan:String = line
                   var value:String?
                   var textScanner:Scanner = Scanner(string: textToScan)
                while !textScanner.isAtEnd {
                       if (textScanner.string as NSString).substring(to: 1) == "\"" {


                           textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)

                           value = textScanner.scanUpToString("\"")
                           textScanner.currentIndex = textScanner.string.index(after: textScanner.currentIndex)
                       } else {
                           value = textScanner.scanUpToString(",")
                       }

                        values.append(value! as String)
                    if !textScanner.isAtEnd{
                            let indexPlusOne = textScanner.string.index(after: textScanner.currentIndex)

                        textToScan = String(textScanner.string[indexPlusOne...])
                        } else {
                            textToScan = ""
                        }
                        textScanner = Scanner(string: textToScan)
                   }

                   // For a line without double quotes, we can simply separate the string
                   // by using the delimiter (e.g. comma)
               } else  {
                   values = line.components(separatedBy: ",")
                result.append(contentsOf: values)
               }

               // Put the values into the tuple and add it to the items array
//               let item = (values[0])
//               items.append(item)
            }
        }
    }
}
extension URL {
    var typeIdentifier: String? {
        return (try? resourceValues(forKeys: [.typeIdentifierKey]))?.typeIdentifier
    }
    var localizedName: String? {
        return (try? resourceValues(forKeys: [.localizedNameKey]))?.localizedName
    }
}
