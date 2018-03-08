//
//  HardWiredRequest.swift
//  Siesta
//
//  Created by Paul on 2018/3/7.
//  Copyright © 2018 Bust Out Solutions. All rights reserved.
//

extension Resource
    {
    /**
      Returns a request that immedately fails, without ever touching the network.
      Useful for creating your own custom requests that perform pre-request validation.
     */
    public static func failedRequest(_ error: RequestError) -> Request
        {
        return hardWiredRequest(returning: .failure(error))
        }

    /**
      Returns a request that immediately and always returns the given response, without ever touching the network
      or applying the transformer pipeline.
     */
    public static func hardWiredRequest(returning response: Response) -> Request
        {
        return HardWiredRequest(returning: response)
        }
    }

/// For requests that failed before they even made it to the network layer
private final class HardWiredRequest: Request
    {
    private let hardWiredResponse: ResponseInfo

    let isStarted = true
    let isCompleted = true
    let progress: Double = 1

    init(returning response: Response)
        { self.hardWiredResponse = ResponseInfo(response: response) }

    func onCompletion(_ callback: @escaping (ResponseInfo) -> Void) -> Request
        {
        // HardWiredRequest is immutable and thus threadsafe. However, this call would not be safe if this were a
        // NetworkRequest, and callers can’t assume the request is hard-wired, so we validate main thread anyway.

        DispatchQueue.mainThreadPrecondition()

        // Callback should run immediately, but not synchronously

        DispatchQueue.main.async
            { callback(self.hardWiredResponse) }

        return self
        }

    func onProgress(_ callback: @escaping (Double) -> Void) -> Request
        {
        DispatchQueue.mainThreadPrecondition()

        DispatchQueue.main.async
            { callback(1) }  // That’s my secret, Captain: I’m always complete.

        return self
        }

    func start() -> Request
        { return self }

    func cancel()
        { DispatchQueue.mainThreadPrecondition() }

    func repeated() -> Request
        { return self }
    }


