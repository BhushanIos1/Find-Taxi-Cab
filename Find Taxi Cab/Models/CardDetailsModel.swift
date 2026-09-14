//
//  CardDetailsModel.swift
//  Find Taxi Cab
//
//  Created by Claude on 11/09/26.
//

import Foundation

/// `POST /get_card_details` with `{custid}`.
///
/// Android decodes this as `Call<CardDetails>` — the card object sits at the top
/// level of the response, not nested under a `data` key.
struct CardDetails: Decodable, Equatable {

    let card: String?
    let month: String?
    let year: String?

    /// Android's model stops at the three fields above, so its Edit Credit Card
    /// form always opens blank. We prefill instead, which means reading the
    /// holder name back too — accepted under every spelling the API uses for it
    /// elsewhere (`edit_card_detaile` and `register_user` both send
    /// `card_holder_name`), and simply absent when the backend doesn't return it.
    let cardHolderName: String?

    /// Android treats a missing card as "no payment details on file" and blocks
    /// the payment dialog from opening at all.
    var isUsable: Bool {
        !(card ?? "").isEmpty
    }

    private struct AnyKey: CodingKey {

        let stringValue: String
        var intValue: Int? { nil }

        init?(stringValue: String) { self.stringValue = stringValue }
        init?(intValue: Int) { nil }
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: AnyKey.self)

        /// The backend is inconsistent about quoting numbers, so a bare `2027`
        /// has to read the same as `"2027"` — a throw here would take the whole
        /// card down with it.
        func text(_ names: String...) -> String? {

            for name in names {

                guard let key = AnyKey(stringValue: name) else { continue }

                if let value = try? container.decodeIfPresent(String.self, forKey: key),
                   !value.isEmpty {
                    return value
                }

                if let value = try? container.decodeIfPresent(Int.self, forKey: key) {
                    return String(value)
                }
            }

            return nil
        }

        card = text("card", "card_number")
        month = text("month", "card_month")
        year = text("year", "card_year")
        // `get_card_details` answers with "cardholder"; `edit_card_detaile` and
        // `register_user` are *written* with "card_holder_name". The read and
        // write spellings genuinely differ, so both are accepted here.
        cardHolderName = text("cardholder", "card_holder_name", "cardholder_name", "holder_name", "card_name", "name")
    }

    init(
        card: String?,
        month: String?,
        year: String?,
        cardHolderName: String? = nil
    ) {
        self.card = card
        self.month = month
        self.year = year
        self.cardHolderName = cardHolderName
    }
}
