import UIKit


class BaseViewController: UIViewController {
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
        
        guard motion == .motionShake else {
            return
        }
        
        let shareLogs = UIAlertAction(title: "Share Logs", style: .default) { _ in
            do {
                self.present(try Log.getLogShareDialog(), animated: true)
            } catch {
                error.logError()
            }
        }
        let removeLogs = UIAlertAction(title: "Remove Logs", style: .destructive) { _ in
            do {
                try Log.removeLogs()
            } catch {
                error.logError()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        UIAlertController.show(.actionSheet, title: "Options", message: nil, actions: [shareLogs, removeLogs, cancelAction])
    }
}
