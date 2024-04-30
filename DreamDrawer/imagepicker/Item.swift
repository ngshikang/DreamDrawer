/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct Item: Identifiable {

    let id = UUID()
    let url: URL
    let pos: String

}

extension Item: Equatable {
    static func ==(lhs: Item, rhs: Item) -> Bool {
        return lhs.id == rhs.id
    }
}
