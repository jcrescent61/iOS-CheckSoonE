//
//  ScanViewController.swift
//  iOS-CheckSoonE
//
//  Created by Ellen J on 2023/04/02.
//

import UIKit
import Combine
import Vision
import AVFoundation

final class ScanViewController: UIViewController {

    private var viewModel: ScanViewModelInterface?
    private var cancelable = Set<AnyCancellable>()
    var captureSession = AVCaptureSession()
    
    static func instance(
        _ viewModel: ScanViewModelInterface
    ) -> ScanViewController {
        let viewController = ScanViewController(nibName: nil, bundle: nil)
        viewController.viewModel = viewModel
        return viewController
    }
    
    lazy var detectBarcodeRequest = VNDetectBarcodesRequest { request, error in
        guard error == nil else {
            self.showAlert(
                withTitle: "Barcode error",
                message: error?.localizedDescription ?? "error"
            )
            return
        }
        self.processClassification(request)
    }
    
    // MARK: - Override Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        viewModel?.input.onViewDidLoad()
        checkPermissions()
        setupCameraLiveView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel?.input.onViewDidAppear()
        checkPermissions()
        
        DispatchQueue.global().async { [weak self] in
            self?.captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel?.input.onViewDidDisappear()
        // TODO: Stop Session
        captureSession.stopRunning()
    }
    
    private func bind() {
        viewModel?.output.detailViewPublisher
            .throttle(for: 1, scheduler: RunLoop.main, latest: false)
            .sink { [weak self] model in
                self?.navigationController?.pushViewController(
                    DetailBookInfoViewController(model),
                    animated: true
                )
            }
            .store(in: &cancelable)
        
        viewModel?.output.errorAlertPublisher
            .throttle(for: 1, scheduler: RunLoop.main, latest: false)
            .sink { [weak self] error in
                self?.showAlert(withTitle: "Error", message: error.localizedDescription)
            }
            .store(in: &cancelable)
    }
}

extension ScanViewController {
    // MARK: - Camera
    private func checkPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if !granted {
                    self?.showPermissionsAlert()
                }
            }
        case .denied, .restricted:
            showPermissionsAlert()
        default:
            return
        }
    }
    
    private func setupCameraLiveView() {
        captureSession.sessionPreset = .hd1280x720
        
        let videoDevice = AVCaptureDevice
            .default(.builtInWideAngleCamera, for: .video, position: .back)
        
        guard
            let device = videoDevice,
            let videoDeviceInput = try? AVCaptureDeviceInput(device: device),
            captureSession.canAddInput(videoDeviceInput) else {
            showAlert(
                withTitle: "Cannot Find Camera",
                message: "There seems to be a problem with the camera on your device.")
            return
        }
        
        captureSession.addInput(videoDeviceInput)
        
        let captureOutput = AVCaptureVideoDataOutput()
        captureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
        captureSession.addOutput(captureOutput)
        captureOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        configurePreviewLayer()
        
        DispatchQueue.global().async {
            self.captureSession.startRunning()
        }
    }
    
    // MARK: - Vision
    func processClassification(_ request: VNRequest) {
        guard let barcodes = request.results else { return }
        DispatchQueue.main.async { [self] in
            if captureSession.isRunning {
                view.layer.sublayers?.removeSubrange(1...)
                
                for barcode in barcodes {
                    guard
                        let potentialQRCode = barcode as? VNBarcodeObservation,
                        potentialQRCode.symbology == .ean13,
                        potentialQRCode.confidence > 0.9
                    else { return }
                    viewModel?.input.sendPayloadInfo(
                        potentialQRCode.payloadStringValue
                    )
                }
            }
        }
    }
}

extension ScanViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // TODO: Live Vision
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let imageRequestHandler = VNImageRequestHandler(
            cvPixelBuffer: pixelBuffer,
            orientation: .right)
        
        do {
            try imageRequestHandler.perform([detectBarcodeRequest])
        } catch {
            print(error)
        }
    }
}


extension ScanViewController {
    private func configurePreviewLayer() {
        let cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer.videoGravity = .resizeAspectFill
        cameraPreviewLayer.connection?.videoOrientation = .portrait
        cameraPreviewLayer.frame = view.frame
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    private func showAlert(withTitle title: String, message: String) {
        DispatchQueue.main.async {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alertController, animated: true)
        }
    }
    
    private func showPermissionsAlert() {
        showAlert(
            withTitle: "Camera Permissions",
            message: "Please open Settings and grant permission for this app to use your camera.")
    }
}
