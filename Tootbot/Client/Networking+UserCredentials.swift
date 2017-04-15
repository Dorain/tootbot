//
// Copyright (C) 2017 Alexsander Akers and Tootbot Contributors
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

import Foundation

extension Networking {
    func token(for account: UserAccount) -> String? {
        return keychain.password(forService: account.instanceURI, account: account.username)
    }

    @discardableResult
    func setToken(_ token: String, for account: UserAccount) -> Bool {
        return keychain.setPassword(token, forService: account.instanceURI, account: account.username)
    }

    @discardableResult
    func deleteToken(for account: UserAccount) -> Bool {
        return keychain.deletePassword(forService: account.instanceURI, account: account.username)
    }
}