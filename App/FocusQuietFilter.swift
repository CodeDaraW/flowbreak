import AppIntents

/// Configure this filter under Do Not Disturb once. The system supplies false on deactivation.
struct FocusQuietFilter: SetFocusFilterIntent {
    static var title: LocalizedStringResource { "focus.filter.title" }
    static var description: IntentDescription { "focus.filter.description" }

    @Parameter(title: "focus.filter.parameter", default: false)
    var quiet: Bool

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "focus.filter.title")
    }

    static func suggestedFocusFilters(for context: FocusFilterSuggestionContext) async -> [FocusQuietFilter] {
        let filter = FocusQuietFilter()
        filter.quiet = true
        return [filter]
    }

    func perform() async throws -> some IntentResult {
        // Current filter is the authoritative value; the running app samples it without shared storage.
        .result()
    }
}
