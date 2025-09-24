
import Foundation
import CoreNFC

class NFCDelegateHandler: NSObject, NFCNDEFReaderSessionDelegate {
    let onTagScanned: (String) -> Void
    let onTimeout: () -> Void
    private var session: NFCNDEFReaderSession?
    private var timeoutTask: DispatchWorkItem?

    init(onTagScanned: @escaping (String) -> Void, onTimeout: @escaping () -> Void) {
        self.onTagScanned = onTagScanned
        self.onTimeout = onTimeout
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        timeoutTask?.cancel()
        print("❌ NFC Session invalidated: \(error.localizedDescription)")
    }
    
    

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        timeoutTask?.cancel()
        for message in messages {
            for record in message.records {
                var payloadData = record.payload
                if payloadData.count > 3 {
                    payloadData.removeFirst(3)
                }

                if let tagID = String(data: payloadData, encoding: .utf8) {
                    print("📦 Scanned tag ID: \(tagID)")
                    onTagScanned(tagID)
                    session.invalidate()
                    return
                }
            }
        }
    }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        // Save reference
        self.session = session

        // Schedule timeout task
        let task = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            session.invalidate()
            self.onTimeout()
        }
        self.timeoutTask = task
        DispatchQueue.main.asyncAfter(deadline: .now() + 15, execute: task)
    }
}
