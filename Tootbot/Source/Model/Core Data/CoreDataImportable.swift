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

protocol APIImportable {
    associatedtype JSONModel: CoreDataExportable

    associatedtype T: NSManagedObject = Self

    static var primaryKeyPath: String { get }

    static func find(matching model: JSONModel, in context: NSManagedObjectContext) -> T?

    static func upsert(model: JSONModel, in context: NSManagedObjectContext) -> T

    func update(with model: JSONModel)
}

extension APIImportable where Self == T {
    static func find(matching model: JSONModel, in context: NSManagedObjectContext) -> T? {
        let fetchRequest = Self.fetchRequest()
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: Self.primaryKeyPath), rightExpression: NSExpression(forConstantValue: model.primaryKeyValue), modifier: .direct, type: .equalTo)

        do {
            let results = try context.fetch(fetchRequest)
            return results.first as? Self
        } catch {
            print("Core Data fetch error -> \(error)")
            return nil
        }
    }

    static func upsert(model: JSONModel, in context: NSManagedObjectContext) -> T {
        let managedObject: T
        if let existing = self.find(matching: model, in: context) {
            managedObject = existing
        } else {
            managedObject = T(context: context)
        }

        managedObject.update(with: model)
        return managedObject
    }
}