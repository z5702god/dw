import SwiftUI

struct MapFilterView: View {
    @Binding var selectedRating: MealRating?

    private let filters: [(MealRating?, String)] = [
        (nil, "全部"),
        (.recommended, "推薦"),
        (.ok, "普通"),
        (.bad, "踩雷"),
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(filters, id: \.1) { rating, title in
                Button {
                    withAnimation(.spring(duration: 0.25)) {
                        selectedRating = (selectedRating == rating) ? nil : rating
                    }
                } label: {
                    Text(title)
                        .font(.footnote.weight(.medium))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background {
                            if selectedRating == rating {
                                Capsule().fill(.appPrimary)
                            } else {
                                Capsule().fill(.ultraThinMaterial)
                            }
                        }
                        .foregroundStyle(selectedRating == rating ? .white : .primary)
                }
                .frame(minHeight: 44)
                .contentShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
    }
}
