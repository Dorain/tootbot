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
import Foundation

extension Mention: APIImportable {
    typealias JSONModel = API.Mention

    static func predicate(matching model: API.Mention) -> NSPredicate {
        return NSPredicate(format: "%K == %@", #keyPath(userID), model.accountID as NSNumber)
    }

    func update(with model: API.Mention) {
        accountName = model.accountName
        profileURL = model.profileURL
        userID = Int64(model.accountID)
        username = model.username
    }
}
