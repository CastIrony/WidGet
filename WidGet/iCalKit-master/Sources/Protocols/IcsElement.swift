import Foundation

// TODO: add documentation
public protocol IcsElement {
    var subComponents: [CalendarComponent] { get set }
    var otherAttrs: [String: String] { get set }

    // TODO: add documentation
    mutating func addAttribute(attr: String, _ value: String)
    // TODO: add documentation
    mutating func append(component: CalendarComponent?)
}

public extension IcsElement {
    mutating func append(component: CalendarComponent?) {
        if let component = component {
            subComponents.append(component)
        }
    }
}
