//
//  MedicationCardView.swift
//  DrugLog
//
//  Expandable card showing detailed information for a single medication.
//

import SwiftUI

struct MedicationCardView: View {
    let medication: Medication
    @State private var isExpanded: Bool = false

    var body: some View {
        DisclosureGroup(isExpanded: $isExpanded) {
            VStack(alignment: .leading, spacing: 16) {
                // Pharmacokinetics grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 12),
                    GridItem(.flexible(), spacing: 12),
                ], alignment: .leading, spacing: 12) {
                    DetailRow(
                        label: "Available Doses",
                        value: medication.doses
                            .map { medication.formatDose($0) }
                            .joined(separator: ", ")
                    )
                    DetailRow(
                        label: "Max Daily Dosage",
                        value: medication.maximumDailyDosage
                    )
                    DetailRow(
                        label: "Time Between Doses",
                        value: medication.timeRequiredBetweenDoses
                    )
                    DetailRow(
                        label: "Time to Peak",
                        value: medication.timeToMaxConcentration
                    )
                    DetailRow(
                        label: "Half-Life",
                        value: medication.halfLife
                    )
                    DetailRow(
                        label: "Active Metabolites",
                        value: medication.activeMetabolites
                    )
                    DetailRow(
                        label: "Metabolite Half-Life",
                        value: medication.halfLifeOfActiveMetabolites
                    )
                }

                // Mechanism of Action
                SectionHeader(title: "Mechanism of Action")
                Text(medication.mechanismOfAction)
                    .font(.subheadline)

                // On-Label Indications
                if !medication.indication.onLabel.isEmpty {
                    SectionHeader(title: "On-Label Indications")
                    TagFlowView(
                        tags: medication.indication.onLabel,
                        color: Color.blue
                    )
                }

                // Off-Label Uses
                if !medication.indication.offLabel.isEmpty {
                    SectionHeader(title: "Off-Label Uses")
                    TagFlowView(
                        tags: medication.indication.offLabel,
                        color: Color.orange
                    )
                }

                // Drug Interactions
                if !medication.interactionsWithOtherDrugsOnThisList.isEmpty {
                    SectionHeader(title: "Drug Interactions")
                    ForEach(medication.interactionsWithOtherDrugsOnThisList) { interaction in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(interaction.drug)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.green)
                            Text(interaction.interaction)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                        if interaction.id != medication.interactionsWithOtherDrugsOnThisList.last?.id {
                            Divider()
                        }
                    }
                }

                // Citations
                if !medication.citations.isEmpty {
                    SectionHeader(title: "Citations")
                    ForEach(medication.citations) { citation in
                        HStack(alignment: .top, spacing: 6) {
                            Text(citation.type)
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(3)
                            Text(citation.title)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(medication.genericName)
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(medication.brandNames.joined(separator: ", "))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Helper views

struct DetailRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(.secondary)
                .fontWeight(.semibold)
            Text(value)
                .font(.subheadline)
        }
    }
}

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.subheadline)
            .fontWeight(.bold)
            .padding(.top, 4)
    }
}

struct TagFlowView: View {
    let tags: [String]
    let color: Color

    var body: some View {
        FlowLayout(spacing: 6) {
            ForEach(tags, id: \.self) { tag in
                Text(tag)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(color.opacity(0.12))
                    .foregroundColor(color)
                    .cornerRadius(4)
            }
        }
    }
}

/// A simple flow layout that wraps items to the next line when they exceed the available width.
struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews)
        -> (size: CGSize, positions: [CGPoint])
    {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
            totalWidth = max(totalWidth, currentX - spacing)
        }

        return (
            size: CGSize(width: totalWidth, height: currentY + lineHeight),
            positions: positions
        )
    }
}
