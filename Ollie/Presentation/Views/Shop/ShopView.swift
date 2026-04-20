import SwiftUI

struct ShopView: View {
    @StateObject private var vm = ShopViewModel()
    let onClose: () -> Void

    var body: some View {
        ZStack {
            vm.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                header
                categoryTabs
                itemGrid
            }
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
                    .frame(width: 36, height: 36)
                    .background(Color.ollie_subtle, in: Circle())
            }
            Spacer()
            Text("shop")
                .font(.ollieSerif(28))
                .foregroundStyle(Color.ollie_ink)
            Spacer()
            coinBadge
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 12)
    }

    private var coinBadge: some View {
        HStack(spacing: 5) {
            CoinView(size: 18)
            Text("\(vm.coins)")
                .font(.ollieBody(15, weight: .bold))
                .foregroundStyle(Color.ollie_ink)
                .monospacedDigit()
        }
        .padding(.vertical, 5)
        .padding(.leading, 7)
        .padding(.trailing, 11)
        .background(Color.ollie_subtle, in: Capsule())
    }

    // MARK: - Category tabs

    private var categoryTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(ShopCategory.allCases, id: \.self) { cat in
                    Button(action: { vm.selectedCategory = cat }) {
                        Text(LocalizedStringKey(cat.rawValue))
                            .font(.ollieMono(10, weight: .bold))
                            .foregroundStyle(vm.selectedCategory == cat ? Color.ollie_paper : Color.ollie_ink)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 14)
                            .background(
                                vm.selectedCategory == cat ? Color.ollie_ink : Color.ollie_subtle,
                                in: Capsule()
                            )
                    }
                    .animation(.spring(duration: 0.22), value: vm.selectedCategory)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.bottom, 14)
    }

    // MARK: - Item grid

    private var itemGrid: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(vm.currentItems) { item in
                    ShopItemCell(
                        item:         item,
                        purchased:    vm.isPurchased(item),
                        selected:     vm.isSelected(item),
                        canAfford:    vm.canPurchase(item),
                        ollieColor:   vm.ollieColor,
                        bgColor:      vm.backgroundColor,
                        onTap:        { handleTap(item) }
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 50)
        }
    }

    private func handleTap(_ item: ShopItem) {
        if vm.isPurchased(item) {
            item.category == .powerUp ? vm.togglePowerUp(item) : vm.select(item)
        } else {
            vm.purchase(item)
        }
    }
}

// MARK: - Shop Item Cell

private struct ShopItemCell: View {
    let item:       ShopItem
    let purchased:  Bool
    let selected:   Bool
    let canAfford:  Bool
    let ollieColor: Color
    let bgColor:    Color
    let onTap:      () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 10) {
                preview
                info
                badge
            }
            .padding(14)
            .frame(maxWidth: .infinity)
            .background(Color.ollie_paper, in: RoundedRectangle(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(selected ? Color.ollie_coral : Color.clear, lineWidth: 2)
            )
            .shadow(color: Color.ollie_ink.opacity(0.07), radius: 8, x: 0, y: 3)
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var preview: some View {
        switch item.category {
        case .ollieColor:
            OllieCharacterView(size: 60, color: item.colorValue ?? .ollie_ink)
                .frame(height: 68)

        case .background:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.colorValue ?? Color.ollie_cream)
                    .frame(height: 60)
                OllieCharacterView(size: 34, color: ollieColor)
            }
            .frame(height: 60)

        case .lashColor:
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(bgColor)
                    .frame(height: 60)
                MiniLashPreview(color: item.colorValue ?? .ollie_ink)
                    .frame(height: 60)
            }
            .frame(height: 60)

        case .powerUp:
            ZStack {
                Circle()
                    .fill(Color.ollie_ink.opacity(0.06))
                    .frame(width: 60, height: 60)
                Image(systemName: powerUpIcon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(selected ? Color.ollie_coral : Color.ollie_ink)
            }
            .frame(height: 60)
        }
    }

    private var info: some View {
        VStack(spacing: 2) {
            Text(item.name)
                .font(.ollieBody(13, weight: .bold))
                .foregroundStyle(Color.ollie_ink)
            Text(item.description)
                .font(.ollieMono(9))
                .foregroundStyle(Color.ollie_muted)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
    }

    @ViewBuilder
    private var badge: some View {
        if selected {
            Text(item.category == .powerUp ? LocalizedStringKey("ACTIVE") : LocalizedStringKey("EQUIPPED"))
                .font(.ollieMono(9, weight: .bold))
                .foregroundStyle(Color.ollie_paper)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.ollie_coral, in: Capsule())
        } else if purchased {
            Text(item.category == .powerUp ? LocalizedStringKey("ENABLE") : LocalizedStringKey("SELECT"))
                .font(.ollieMono(9, weight: .bold))
                .foregroundStyle(Color.ollie_ink)
                .padding(.vertical, 4)
                .padding(.horizontal, 10)
                .background(Color.ollie_subtle, in: Capsule())
        } else if canAfford {
            HStack(spacing: 3) {
                CoinView(size: 12)
                Text("\(item.cost)")
                    .font(.ollieMono(9, weight: .bold))
                    .foregroundStyle(Color.ollie_ink)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color(red: 0.9, green: 0.75, blue: 0.1).opacity(0.25), in: Capsule())
        } else {
            HStack(spacing: 3) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                Text("\(item.cost)")
                    .font(.ollieMono(9, weight: .bold))
            }
            .foregroundStyle(Color.ollie_muted)
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(Color.ollie_subtle, in: Capsule())
        }
    }

    private var powerUpIcon: String {
        switch item.id {
        case "pw_iron":      return "shield.fill"
        case "pw_rookie":    return "shield.lefthalf.filled"
        case "pw_magnet":    return "scope"
        case "pw_daredevil": return "bolt.fill"
        default:             return "star.fill"
        }
    }
}

// MARK: - Mini Lash Preview

private struct MiniLashPreview: View {
    let color: Color

    var body: some View {
        Canvas { ctx, size in
            let col    = size.width * 0.35
            let w      = size.width * 0.28
            let gapY   = size.height * 0.32
            let gapH   = size.height * 0.36
            let radius = CGSize(width: 6, height: 6)

            let topRect = CGRect(x: col, y: 0, width: w, height: gapY)
            ctx.fill(Path(roundedRect: topRect, cornerSize: radius), with: .color(color))

            let botY    = gapY + gapH
            let botRect = CGRect(x: col, y: botY, width: w, height: size.height - botY)
            ctx.fill(Path(roundedRect: botRect, cornerSize: radius), with: .color(color))
        }
    }
}

#Preview {
    ShopView(onClose: {})
}
