//
// Copyright (C) 2017 Tootbot Contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published
// by the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

import CoreData
import Freddy
import ReactiveSwift
import Result
import Moya

enum DataFetcherCachePolicy {
    /// Load from the Core Data cache without making a network request
    case cacheOnly

    /// Ignoring cached data, makes a network request and returns resulting data
    case networkOnly

    /// Reads from cache and loads from network simultaneously.
    /// Provides cached results as 'value' event before network returns (two 'value' events).
    /// If network returns first, cached values are not returne (one 'value' event).
    case cacheThenNetwork

    static var `default`: DataFetcherCachePolicy {
        return .cacheThenNetwork
    }
}

enum DataFetcherError: Swift.Error {
    case moya(MoyaError)
    case network(NetworkRequestError)
    case cache(CacheRequestError)
    case importer(DataImporterError)
}

struct DataFetcher<ManagedObject> where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    struct JSONModelRequest: NetworkRequestProtocol  {
        typealias Output = JSONCollection<ManagedObject.JSONModel>

        private let requestFunction: () -> SignalProducer<Response, MoyaError>
        private let parseFunction: (Response) -> Result<Output, NetworkRequestError>

        init<R>(_ request: R) where R: NetworkRequestProtocol, R.Output == Output {
            self.requestFunction = request.request
            self.parseFunction = request.parse
        }

        func request() -> SignalProducer<Response, MoyaError> {
            return requestFunction()
        }

        func parse(response: Response) -> Result<Output, NetworkRequestError> {
            return parseFunction(response)
        }
    }

    let cacheRequest: CacheRequest<ManagedObject>
    let dataImporter: DataImporter<ManagedObject>
    let networkRequest: JSONModelRequest

    init<Request>(networkRequest: Request, cacheRequest: CacheRequest<ManagedObject>, dataImporter: DataImporter<ManagedObject>)
        where Request: NetworkRequestProtocol, Request.Output == JSONCollection<ManagedObject.JSONModel>
    {
        self.cacheRequest = cacheRequest
        self.dataImporter = dataImporter
        self.networkRequest = JSONModelRequest(networkRequest)
    }

    func fetch(cachePolicy: DataFetcherCachePolicy = .default) -> SignalProducer<[ManagedObject], DataFetcherError> {
        switch cachePolicy {
        case .cacheOnly:
            return cacheRequest.fetch().mapError(DataFetcherError.cache)
        case .networkOnly:
            return networkRequest.request()
                .mapError(DataFetcherError.moya)
                .attemptMap { response in
                    self.networkRequest.parse(response: response)
                        .mapError(DataFetcherError.network)
                }
                .flatMap(.latest) { models in
                    self.dataImporter.importModels(collection: models)
                        .mapError(DataFetcherError.importer)
                }
                .then(fetch(cachePolicy: .cacheOnly))
        case .cacheThenNetwork:
            let local = fetch(cachePolicy: .cacheOnly)
            let remote = fetch(cachePolicy: .networkOnly)
            return local.take(untilReplacement: remote)
        }
    }
}
