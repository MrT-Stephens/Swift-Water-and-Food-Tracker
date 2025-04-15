import SwiftUI
import WidgetKit

struct SmallWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Today's Progress")
                .font(.caption)
                .foregroundColor(.secondary)
            
            ProgressBar(title: "Water", progress: entry.waterProgress, color: .blue)
            ProgressBar(title: "Food", progress: entry.caloriesProgress, color: .orange)
            ProgressBar(title: "Steps", progress: entry.stepsProgress, color: .green)
        }
        .padding()
    }
}

struct MediumWidgetView: View {
    var entry: SimpleEntry
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Today's Progress")
                    .font(.headline)
                
                ProgressBar(title: "Water", progress: entry.waterProgress, color: .blue)
                ProgressBar(title: "Food", progress: entry.caloriesProgress, color: .orange)
                ProgressBar(title: "Steps", progress: entry.stepsProgress, color: .green)
            }
            
            VStack(alignment: .trailing, spacing: 8) {
                Text("\(Int(entry.waterProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.blue)
                Text("\(Int(entry.caloriesProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("\(Int(entry.stepsProgress * 100))%")
                    .font(.caption)
                    .foregroundColor(.green)
            }
        }
        .padding()
    }
}

struct ProgressBar: View {
    let title: String
    let progress: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 4)
                        .opacity(0.3)
                        .foregroundColor(color)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 4)
                        .foregroundColor(color)
                }
                .cornerRadius(2)
            }
            .frame(height: 4)
        }
    }
} 