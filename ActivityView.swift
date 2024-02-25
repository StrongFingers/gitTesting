import SwiftUI
import LinkPresentation
import CoreServices

public extension View {

    /// Presents an activity sheet when the associated `ActivityItem` is present
    ///
    /// The system provides several standard services, such as copying items to the pasteboard, posting content to social media sites, sending items via email or SMS, and more. Apps can also define custom services.
    /// 
    /// - Parameters:
    ///   - item: The item to use for this activity
    ///   - onComplete: When the sheet is dismissed, the this will be called with the result
    func activitySheet(_ item: Binding<ActivityItem?>) -> some View {
        background(ActivityView(item: item))
    }

}

private struct ActivityView: UIViewControllerRepresentable {
    var item: Binding<ActivityItem?>

    public init(item: Binding<ActivityItem?>) {
        self.item = item
    }

    func makeUIViewController(context: Context) -> ActivityViewControllerWrapper {
        let activityVC = ActivityViewControllerWrapper(item: item)
        return activityVC
    }

    func updateUIViewController(_ controller: ActivityViewControllerWrapper, context: Context) {
        controller.item = item
        controller.updateState()
    }

}

private final class ActivityViewControllerWrapper: UIViewController {

    var item: Binding<ActivityItem?>
    var activityVC: UIActivityViewController? = nil

    init(item: Binding<ActivityItem?>) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        updateState()
    }

    fileprivate func updateState() {
        if item.wrappedValue != nil {
            if activityVC == nil {
                let controller = UIActivityViewController(activityItems: item.wrappedValue?.items ?? [], applicationActivities: item.wrappedValue?.activities)
                controller.excludedActivityTypes = item.wrappedValue?.excludedTypes
                controller.popoverPresentationController?.permittedArrowDirections = .any
                controller.popoverPresentationController?.sourceView = view
                controller.completionWithItemsHandler = { [weak self] (activityType, success, items, error) in
                    self?.item.wrappedValue = nil
                }
                present(controller, animated: true, completion: nil)
                activityVC = controller
            }
        } else {
            if activityVC != nil {
                activityVC?.dismiss(animated: false)
                activityVC = nil
            }
        }
    }

}
