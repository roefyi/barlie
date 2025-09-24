import SwiftUI

struct BeerRatingView: View {
    let beer: Beer
    @State private var rating: Double = 0
    @State private var review: String = ""
    @State private var showingReview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Beer Header
                    VStack(spacing: 16) {
                        // Beer Image
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color(.systemGray4), Color(.systemGray5)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(height: 200)
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                        
                        VStack(spacing: 8) {
                            Text(beer.name)
                                .font(.system(size: 28, weight: .bold))
                                .multilineTextAlignment(.center)
                            
                            Text(beer.brewery)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.secondary)
                            
                            Text(beer.styleAndABV)
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Star Rating
                    VStack(spacing: 16) {
                        Text("Rate this beer")
                            .font(.system(size: 20, weight: .semibold))
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button(action: {
                                    withAnimation(.quickSpring) {
                                        HapticFeedback.light()
                                        rating = Double(star)
                                    }
                                }) {
                                    Image(systemName: star <= Int(rating) ? "star.fill" : "star")
                                        .font(.system(size: 40))
                                        .foregroundColor(star <= Int(rating) ? .yellow : .gray)
                                        .scaleEffect(star <= Int(rating) ? 1.1 : 1.0)
                                }
                            }
                        }
                        .animation(.quickSpring, value: rating)
                    }
                    
                    // Review Section
                    if showingReview || !review.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Add a review")
                                .font(.system(size: 18, weight: .semibold))
                            
                            TextEditor(text: $review)
                                .frame(minHeight: 100)
                                .padding(12)
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                                .fadeInScale()
                        }
                        .animation(.smoothSpring, value: showingReview)
                    }
                    
                    // Action Buttons
                    VStack(spacing: 12) {
                        Button(action: {
                            withAnimation(.smoothSpring) {
                                showingReview.toggle()
                                HapticFeedback.medium()
                            }
                        }) {
                            Text(showingReview ? "Hide Review" : "Add Review")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.blue)
                        }
                        
                        if rating > 0 {
                            Button(action: {
                                // Save rating
                                HapticFeedback.success()
                                dismiss()
                            }) {
                                Text("Save Rating")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.primary)
                                    .cornerRadius(12)
                            }
                            .slideInFromBottom()
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(20)
            }
            .navigationTitle("Rate Beer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

extension View {
    func slideInFromBottom() -> some View {
        self.transition(.asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        ))
    }
}

#Preview {
    BeerRatingView(beer: Beer.sampleBeers[0])
}
