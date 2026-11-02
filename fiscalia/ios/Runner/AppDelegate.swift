import Flutter
import UIKit
import Vision

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(
      forPlugin: "FiscaliaOcrPlugin"
    ) {
      FiscaliaOcrPlugin.register(with: registrar)
    }
  }
}

final class FiscaliaOcrPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "fr.fiscalia/ocr",
      binaryMessenger: registrar.messenger()
    )
    let instance = FiscaliaOcrPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "recognizeText" else {
      result(FlutterMethodNotImplemented)
      return
    }

    guard
      let arguments = call.arguments as? [String: Any],
      let filePath = arguments["filePath"] as? String,
      !filePath.isEmpty
    else {
      result(
        FlutterError(
          code: "invalid-arguments",
          message: "Le chemin du fichier image est requis.",
          details: nil
        )
      )
      return
    }

    recognizeText(atPath: filePath, result: result)
  }

  private func recognizeText(atPath path: String, result: @escaping FlutterResult) {
    let imageUrl = URL(fileURLWithPath: path)
    let request = VNRecognizeTextRequest { request, error in
      if let error {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "ocr-failed",
              message: "La reconnaissance de texte iOS a echoue.",
              details: error.localizedDescription
            )
          )
        }
        return
      }

      let observations = request.results as? [VNRecognizedTextObservation] ?? []
      let texte = observations.compactMap { observation in
        observation.topCandidates(1).first?.string
      }.joined(separator: "\n")

      DispatchQueue.main.async {
        result(texte)
      }
    }

    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true
    request.recognitionLanguages = ["fr-FR", "en-US"]

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        let handler = VNImageRequestHandler(url: imageUrl, options: [:])
        try handler.perform([request])
      } catch {
        DispatchQueue.main.async {
          result(
            FlutterError(
              code: "ocr-handler-failed",
              message: "Impossible de preparer l'analyse OCR iOS.",
              details: error.localizedDescription
            )
          )
        }
      }
    }
  }
}
