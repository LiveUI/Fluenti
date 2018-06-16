import NIO

/// Controls a Swift NIO pipeline of `[In]` -> `[Out]`.
///
/// One or more `Out` can be enqueued to the handler at a time. When enqueuing output,
/// you must specify an input callback `(In) throws -> (Bool)`. This callback will be used to
/// provide "responses" to your output. When the callback returns `true` (or an error is thrown),
/// the future returned when enqueuing data will be completed.
///
/// This handler is useful for implementing clients. Requests can be enqueued to the handler and one
/// or more responses can be received. This handler works great with client protocols that support pipelining.
///
public final class QueueHandler<In, Out>: ChannelInboundHandler {
    /// See `ChannelInboundHandler.InboundIn`
    public typealias InboundIn = In

    /// See `ChannelInboundHandler.OutboundOut`
    public typealias OutboundOut = Out

    /// Queue of input handlers and promises. Oldest (current) handler and promise are at the end of the array.
    private var inputQueue: [InputContext<InboundIn>]

    /// Queue of output. Oldest objects are at the end of the array (output is dequeued with `popLast()`)
    private var outputQueue: [[OutboundOut]]

    /// This handler's event loop.
    private let eventLoop: EventLoop

    /// A write-ready context waiting.
    private weak var waitingCtx: ChannelHandlerContext?

    /// Handles errors that happen when no input promise is waiting.
    private var errorHandler: (Error) -> ()

    /// Create a new `QueueHandler` on the supplied worker.
    public init(on worker: Worker, onError: @escaping (Error) -> ()) {
        VERBOSE("QueueHandler.init(on: \(worker))")
        self.inputQueue = []
        self.outputQueue = []
        self.eventLoop = worker.eventLoop
        self.errorHandler = onError
    }

    /// Enqueue new output to the handler.
    ///
    /// - parameters:
    ///     - output: An array of output (can be `0`) that you wish to send.
    ///     - onInput: A callback that will accept new input (usually responses to the output you enqueued)
    ///                The callback will continue to be called until you return `true` or an error is thrown.
    /// - returns: A future signal. Will be completed when `onInput` returns `true` or throws an error.
    public func enqueue(_ output: [OutboundOut], onInput: @escaping (InboundIn) throws -> Bool) -> Future<Void> {
        guard eventLoop.inEventLoop else {
            return eventLoop.submit {
                // do nothing
            }.flatMap {
                // perform this on the event loop
                return self.enqueue(output, onInput: onInput)
            }
        }
        
        VERBOSE("QueueHandler.enqueue(\(output.count))")
        outputQueue.insert(output, at: 0)
        let promise = eventLoop.newPromise(Void.self)
        let context = InputContext<InboundIn>(promise: promise, onInput: onInput)
        inputQueue.insert(context, at: 0)
        if let ctx = waitingCtx {
            ctx.eventLoop.execute {
                self.writeOutputIfEnqueued(ctx: ctx)
            }
        }
        return promise.futureResult
    }

    /// Triggers a context write if any output is enqueued.
    private func writeOutputIfEnqueued(ctx: ChannelHandlerContext) {
        VERBOSE("QueueHandler.sendOutput(ctx: \(ctx)) [outputQueue.count=\(outputQueue.count)]")
        while let next = outputQueue.popLast() {
            for output in next {
                ctx.write(wrapOutboundOut(output), promise: nil)
            }
            ctx.flush()
        }
        waitingCtx = ctx
    }

    /// MARK: ChannelInboundHandler conformance

    /// See `ChannelInboundHandler.channelRead(ctx:data:)`
    public func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        VERBOSE("QueueHandler.channelRead(ctx: \(ctx), data: \(data))")
        let input = unwrapInboundIn(data)
        guard let current = inputQueue.last else {
            debugOnly {
                WARNING("[QueueHandler] Read triggered when input queue was empty, ignoring: \(input).")
            }
            return
        }
        do {
            if try current.onInput(input) {
                let popped = inputQueue.popLast()
                assert(popped != nil)
                
                current.promise.succeed()
            }
        } catch {
            let popped = inputQueue.popLast()
            assert(popped != nil)
            
            current.promise.fail(error: error)
        }
    }

    /// See `ChannelInboundHandler.channelActive(ctx:)`
    public func channelActive(ctx: ChannelHandlerContext) {
        VERBOSE("QueueHandler.channelActive(ctx: \(ctx))")
        writeOutputIfEnqueued(ctx: ctx)
    }

    /// See `ChannelInboundHandler.errorCaught(error:)`
    public func errorCaught(ctx: ChannelHandlerContext, error: Error) {
        VERBOSE("QueueHandler.errorCaught(ctx: \(ctx), error: \(error))")
        if let current = inputQueue.last {
            current.promise.fail(error: error)
        } else {
            self.errorHandler(error)
        }
    }
}

/// Contains the `onInput` handler and promise created by enqueuing one or more output to a `QueueHandler`.
fileprivate struct InputContext<In> {
    /// Should be completed when `onInput` returns `true` or an error is thrown.
    var promise: Promise<Void>

    /// All incoming input will be passed to this callback when it is the current context.
    var onInput: (In) throws -> Bool
}
