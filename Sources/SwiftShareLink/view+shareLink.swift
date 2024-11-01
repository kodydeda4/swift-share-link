import Swift
import SwiftUI
import UIKit
import LinkPresentation
import Foundation

extension View {
  public func shareLink(
    item: Binding<URL?>,
    completionHandler: @escaping (ActivityResult) -> Void = { _ in }
  ) -> some View {
    sheet(
      item: Binding<IdentifiableURL?>(
        get: { item.wrappedValue.flatMap(IdentifiableURL.init) },
        set: { item.wrappedValue = $0?.rawValue }
      ),
      content: { item in
        ActivityView(
          activityItems: [ActivityItem(url: item.rawValue)],
          onComplete: completionHandler
        )
      }
    )
  }
}

public typealias ActivityResult = Result<(activity: UIActivity.ActivityType, items: [Any]?), Error>

// MARK: - Private

private struct IdentifiableURL: Identifiable {
  let id = UUID()
  var rawValue: URL
}

private struct ActivityView: UIViewControllerRepresentable {
  typealias UIViewControllerType = UIActivityViewController
  
  private let activityItems: [Any]
  private let applicationActivities: [UIActivity]?
  private var excludedActivityTypes: [UIActivity.ActivityType] = []
  private var onComplete: (ActivityResult) -> Void = { _ in }
  private var onCancel: () -> Void = {}
  
  init(
    activityItems: [Any],
    applicationActivities: [UIActivity]? = nil,
    onComplete: @escaping (ActivityResult) -> Void = { _ in },
    onCancel: @escaping () -> Void = {}
  ) {
    self.activityItems = activityItems
    self.applicationActivities = applicationActivities
    self.onComplete = onComplete
    self.onCancel = onCancel
  }
  
  func makeUIViewController(context: Context) -> UIViewControllerType {
    .init(activityItems: activityItems, applicationActivities: applicationActivities)
  }
  
  func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
    uiViewController.excludedActivityTypes = excludedActivityTypes
    uiViewController.completionWithItemsHandler = { activity, success, items, error in
      if let error = error {
        self.onComplete(.failure(error))
      } else if let activity = activity, success {
        self.onComplete(.success((activity, items)))
      } else if !success {
        self.onCancel()
      } else {
        assertionFailure()
      }
    }
  }
  
  static func dismantleUIViewController(
    _ uiViewController: UIViewControllerType,
    coordinator: Coordinator
  ) {
    uiViewController.completionWithItemsHandler = nil
  }
  
  func excludeActivityTypes(_ activityTypes: [UIActivity.ActivityType]) -> Self {
    then { $0.excludedActivityTypes = activityTypes }
  }
  
  func onComplete(perform action: @escaping (ActivityResult) -> Void) -> Self {
    then { $0.onComplete = action }
  }

  func onCancel(perform action: @escaping () -> Void) -> Self {
    then { $0.onCancel = action }
  }
}

private final class ActivityItem: UIActivityItemProvider, Identifiable, @unchecked Sendable {
  let id = UUID()
  let url: URL
  
  init(url: URL) {
    self.url = url
    super.init(placeholderItem: url)
  }
  
  override func activityViewControllerLinkMetadata(
    _: UIActivityViewController
  ) -> LPLinkMetadata? {
    let metadata = LPLinkMetadata()
    metadata.url = url
    return metadata
  }
  
  override var item: Any {
    url
  }
}

private extension View {
  func then(_ body: (inout Self) -> Void) -> Self {
    var result = self
    body(&result)
    return result
  }
}
