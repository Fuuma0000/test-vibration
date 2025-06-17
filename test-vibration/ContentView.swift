import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isVibrating = false
    @State private var vibrationTimer: Timer?
    @State private var selectedVibrationStyle = 0
    @State private var vibrationInterval: Double = 1.0
    @State private var customBPM: Double = 60
    
    let vibrationStyles = ["軽い", "中程度", "強い", "成功", "警告", "エラー"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // タイトル
                Text("振動テストアプリ")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 単発振動セクション
                VStack(alignment: .leading, spacing: 15) {
                    Text("単発振動テスト")
                        .font(.headline)
                    
                    Picker("振動の強さ", selection: $selectedVibrationStyle) {
                        ForEach(0..<vibrationStyles.count, id: \.self) { index in
                            Text(vibrationStyles[index]).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    Button(action: {
                        triggerSingleVibration()
                    }) {
                        Text("振動させる")
                            .font(.title2)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // 連続振動セクション
                VStack(alignment: .leading, spacing: 15) {
                    Text("連続振動テスト（心拍シミュレーション）")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("BPM (心拍数): \(Int(customBPM))")
                            .font(.subheadline)
                        
                        Slider(value: $customBPM, in: 40...180, step: 1) {
                            Text("BPM")
                        }
                        .accentColor(.red)
                        
                        Text("間隔: \(String(format: "%.2f", 60.0/customBPM))秒")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    HStack(spacing: 15) {
                        Button(action: {
                            if isVibrating {
                                stopContinuousVibration()
                            } else {
                                startContinuousVibration()
                            }
                        }) {
                            Text(isVibrating ? "停止" : "開始")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(isVibrating ? Color.red : Color.green)
                                .cornerRadius(10)
                        }
                        
                        Button(action: {
                            startHeartRatePattern()
                        }) {
                            Text("心拍パターン")
                                .font(.title2)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                
                // ステータス表示
                VStack {
                    if isVibrating {
                        HStack {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 10, height: 10)
                                .scaleEffect(isVibrating ? 1.5 : 1.0)
                                .animation(.easeInOut(duration: 0.5).repeatForever(), value: isVibrating)
                            
                            Text("振動中...")
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                    } else {
                        Text("待機中")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationBarHidden(true)
        }
        .onDisappear {
            stopContinuousVibration()
        }
    }
    
    // 単発振動を実行する関数
    func triggerSingleVibration() {
        let notificationFeedback = UINotificationFeedbackGenerator()
        
        switch selectedVibrationStyle {
        case 0: // 軽い
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.impactOccurred()
        case 1: // 中程度
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        case 2: // 強い
            let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
            heavyImpact.impactOccurred()
        case 3: // 成功
            notificationFeedback.notificationOccurred(.success)
        case 4: // 警告
            notificationFeedback.notificationOccurred(.warning)
        case 5: // エラー
            notificationFeedback.notificationOccurred(.error)
        default:
            let defaultImpact = UIImpactFeedbackGenerator(style: .medium)
            defaultImpact.impactOccurred()
        }
    }
    
    // 連続振動を開始する関数
    func startContinuousVibration() {
        guard !isVibrating else { return }
        
        isVibrating = true
        vibrationInterval = 60.0 / customBPM // BPMから間隔を計算
        
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: vibrationInterval, repeats: true) { _ in
            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
            impactFeedback.impactOccurred()
        }
    }
    
    // 連続振動を停止する関数
    func stopContinuousVibration() {
        isVibrating = false
        vibrationTimer?.invalidate()
        vibrationTimer = nil
    }
    
    // 心拍パターンの振動（実際の心拍のような2段階の振動）
    func startHeartRatePattern() {
        stopContinuousVibration()
        isVibrating = true
        
        let interval = 60.0 / customBPM
        
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            // 心拍の「ドクン」パターンを再現
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            
            // 1回目の振動（ドク）
            impactFeedback.impactOccurred()
            
            // 少し遅らせて2回目の振動（ン）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let lightImpact = UIImpactFeedbackGenerator(style: .light)
                lightImpact.impactOccurred()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
