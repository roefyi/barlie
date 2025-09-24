import SwiftUI

struct BeerFilterView: View {
    @Binding var selectedStyle: BeerStyle
    @Binding var isPresented: Bool
    @State private var tempSelectedStyle: BeerStyle
    
    init(selectedStyle: Binding<BeerStyle>, isPresented: Binding<Bool>) {
        self._selectedStyle = selectedStyle
        self._isPresented = isPresented
        self._tempSelectedStyle = State(initialValue: selectedStyle.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    Text("Filter Beers")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    Text("Choose a beer style to filter your search results")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
                
                // Filter Options
                ScrollView {
                    LazyVStack(spacing: 12) {
                        // Popular Styles Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Popular Styles")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                                ForEach(BeerStyle.popularStyles) { style in
                                    FilterStyleButton(
                                        style: style,
                                        isSelected: tempSelectedStyle == style
                                    ) {
                                        tempSelectedStyle = style
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.bottom, 24)
                        
                        // All Styles Section
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Styles")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                                .padding(.horizontal, 20)
                            
                            LazyVStack(spacing: 8) {
                                ForEach(BeerStyle.allStyles.filter { $0 != .all }) { style in
                                    FilterStyleRow(
                                        style: style,
                                        isSelected: tempSelectedStyle == style
                                    ) {
                                        tempSelectedStyle = style
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
            .background(Color.black)
            .navigationBarHidden(true)
            .safeAreaInset(edge: .bottom) {
                // Bottom Action Bar
                HStack(spacing: 16) {
                    Button("Clear") {
                        tempSelectedStyle = .all
                    }
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    Button("Apply Filter") {
                        selectedStyle = tempSelectedStyle
                        isPresented = false
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.primary)
                    .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 16)
                .background(Color.black)
            }
        }
    }
}

struct FilterStyleButton: View {
    let style: BeerStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.primary : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FilterStyleRow: View {
    let style: BeerStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(style.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.primary : Color(.systemGray6))
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    BeerFilterView(
        selectedStyle: .constant(.ipa),
        isPresented: .constant(true)
    )
}
