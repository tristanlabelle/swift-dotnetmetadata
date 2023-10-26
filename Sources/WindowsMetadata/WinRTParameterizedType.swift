// https://learn.microsoft.com/en-us/uwp/winrt-cref/winrt-type-system
// > WinRT supports parameterization of interfaces and delegates.
// > However, in this release WinRT does not support definition of parameterized types by 3rd parties.
// > Only the parameterized types included in the system in the Windows.* namespace are supported.
public enum WinRTParameterizedType: Hashable {
    case asyncActionProgressHandler
    case asyncActionWithProgressCompletedHandler
    case asyncOperationCompletedHandler
    case asyncOperationProgressHandler
    case asyncOperationWithProgressCompletedHandler
    case eventHandler
    case iasyncActionWithProgress
    case iasyncOperation
    case iasyncOperationWithProgress
    case ireference
    case ireferenceArray
    case typedEventHandler

    case collections_iiterable
    case collections_iiterator
    case collections_ikeyValuePair
    case collections_imap
    case collections_imapChangedEventArgs
    case collections_imapView
    case collections_iobservableMap
    case collections_iobservableVector
    case collections_ivector
    case collections_ivectorView
    case collections_mapChangedEventHandler
    case collections_vectorChangedEventHandler
}

extension WinRTParameterizedType {
    public var namespace: String { data.namespace }
    public var nameWithoutAritySuffix: String { data.name }
    public var nameWithAritySuffix: String { "\(data.name)`\(data.arity)" }
    public var arity: Int { data.arity }

    public static func from(namespace: String, name: String) -> WinRTParameterizedType? {
        if namespace == "Windows.Foundation" {
            switch name {
                case "IAsyncActionProgressHandler`1": return .asyncActionProgressHandler
                case "IAsyncActionWithProgressCompletedHandler`1": return .asyncActionWithProgressCompletedHandler
                case "IAsyncOperationCompletedHandler`1": return .asyncOperationCompletedHandler
                case "IAsyncOperationProgressHandler`2": return .asyncOperationProgressHandler
                case "IAsyncOperationWithProgressCompletedHandler`2": return .asyncOperationWithProgressCompletedHandler
                case "IEventHandler`1": return .eventHandler
                case "IAsyncActionWithProgress`1": return .iasyncActionWithProgress
                case "IAsyncOperation`1": return .iasyncOperation
                case "IAsyncOperationWithProgress`2": return .iasyncOperationWithProgress
                case "IReference`1": return .ireference
                case "IReferenceArray`1": return .ireferenceArray
                case "ITypedEventHandler`2": return .typedEventHandler
                default: return nil
            }
        }
        else if namespace == "Windows.Foundation.Collections" {
            switch name {
                case "IIterable`1": return .collections_iiterable
                case "IIterator`1": return .collections_iiterator
                case "IKeyValuePair`2": return .collections_ikeyValuePair
                case "IMap`2": return .collections_imap
                case "IMapChangedEventArgs`1": return .collections_imapChangedEventArgs
                case "IMapView`2": return .collections_imapView
                case "IObservableMap`2": return .collections_iobservableMap
                case "IObservableVector`1": return .collections_iobservableVector
                case "IVector`1": return .collections_ivector
                case "IVectorView`1": return .collections_ivectorView
                case "IMapChangedEventHandler`2": return .collections_mapChangedEventHandler
                case "IVectorChangedEventHandler`1": return .collections_vectorChangedEventHandler
                default: return nil
            }
        }
        else {
            return nil
        }
    }

    private var data: (namespace: String, name: String, arity: Int) {
        switch self {
            case .asyncActionProgressHandler: return ("Windows.Foundation", "IAsyncActionProgressHandler", 1)
            case .asyncActionWithProgressCompletedHandler: return ("Windows.Foundation", "IAsyncActionWithProgressCompletedHandler", 1)
            case .asyncOperationCompletedHandler: return ("Windows.Foundation", "IAsyncOperationCompletedHandler", 1)
            case .asyncOperationProgressHandler: return ("Windows.Foundation", "IAsyncOperationProgressHandler", 2)
            case .asyncOperationWithProgressCompletedHandler: return ("Windows.Foundation", "IAsyncOperationWithProgressCompletedHandler", 2)
            case .eventHandler: return ("Windows.Foundation", "IEventHandler", 1)
            case .iasyncActionWithProgress: return ("Windows.Foundation", "IAsyncActionWithProgress", 1)
            case .iasyncOperation: return ("Windows.Foundation", "IAsyncOperation", 1)
            case .iasyncOperationWithProgress: return ("Windows.Foundation", "IAsyncOperationWithProgress", 2)
            case .ireference: return ("Windows.Foundation", "IReference", 1)
            case .ireferenceArray: return ("Windows.Foundation", "IReferenceArray", 1)
            case .typedEventHandler: return ("Windows.Foundation", "ITypedEventHandler", 2)

            case .collections_iiterable: return ("Windows.Foundation.Collections", "IIterable", 1)
            case .collections_iiterator: return ("Windows.Foundation.Collections", "IIterator", 1)
            case .collections_ikeyValuePair: return ("Windows.Foundation.Collections", "IKeyValuePair", 2)
            case .collections_imap: return ("Windows.Foundation.Collections", "IMap", 2)
            case .collections_imapChangedEventArgs: return ("Windows.Foundation.Collections", "IMapChangedEventArgs", 1)
            case .collections_imapView: return ("Windows.Foundation.Collections", "IMapView", 2)
            case .collections_iobservableMap: return ("Windows.Foundation.Collections", "IObservableMap", 2)
            case .collections_iobservableVector: return ("Windows.Foundation.Collections", "IObservableVector", 1)
            case .collections_ivector: return ("Windows.Foundation.Collections", "IVector", 1)
            case .collections_ivectorView: return ("Windows.Foundation.Collections", "IVectorView", 1)
            case .collections_mapChangedEventHandler: return ("Windows.Foundation.Collections", "IMapChangedEventHandler", 2)
            case .collections_vectorChangedEventHandler: return ("Windows.Foundation.Collections", "IVectorChangedEventHandler", 1)
        }
    }
}