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
import ReactiveSwift

enum CacheRequestError: Error {
    case coreData(Error)
}

struct CacheRequest<ManagedObject> where ManagedObject: APIImportable, ManagedObject.T == ManagedObject {
    let managedObjectContext: NSManagedObjectContext
    let fetchRequest: NSFetchRequest<ManagedObject>

    init(managedObjectContext: NSManagedObjectContext, fetchRequest: NSFetchRequest<ManagedObject>) {
        self.managedObjectContext = managedObjectContext
        self.fetchRequest = fetchRequest
    }

    func fetch() -> SignalProducer<[ManagedObject], CacheRequestError> {
        return SignalProducer { observer, disposable in
            let context = self.managedObjectContext
            context.perform {
                do {
                    let results = try context.fetch(self.fetchRequest)
                    observer.send(value: results)
                    observer.sendCompleted()
                } catch {
                    observer.send(error: .coreData(error))
                }
            }
        }
    }
}
