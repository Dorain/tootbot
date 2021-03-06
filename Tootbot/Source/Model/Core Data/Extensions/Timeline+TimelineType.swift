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

enum TimelineType: String {
    case home
    case local
    case federated

    static var all: Set<TimelineType> {
        return [.home, .local, .federated]
    }

    var endpoint: MastodonService {
        switch self {
        case .home:
            return .homeTimeline
        case .local:
            return .publicTimeline(localOnly: true)
        case .federated:
            return .publicTimeline(localOnly: false)
        }
    }
}

extension Timeline {
    var timelineTypeValue: TimelineType? {
        get {
            return timelineType.flatMap { TimelineType(rawValue: $0) }
        }
        set {
            timelineType = newValue?.rawValue
        }
    }
}
