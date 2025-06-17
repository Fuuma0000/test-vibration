import SwiftUI
import UIKit

struct ContentView: View {
    @State private var isVibrating = false
    @State private var vibrationTimer: Timer?
    @State private var selectedVibrationStyle = 0
    @State private var selectedContinuousVibrationStyle = 1 // 連続振動用の振動パターン
    @State private var vibrationInterval: Double = 1.0
    @State private var customBPM: Double = 60
    @State private var waveformData: [Double] = Array(repeating: 0.0, count: 200) // データポイントを倍に
    @State private var currentWaveIndex: Int = 0
    @State private var animationOffset: Double = 0
    @State private var animationTimer: Timer? // 専用のアニメーションタイマー
    
    let vibrationStyles = ["軽い", "中程度", "強い", "硬い", "柔らかい", "成功", "警告", "エラー"]
    
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
                    
                    // 連続振動用の振動パターン選択
                    VStack(alignment: .leading, spacing: 8) {
                        Text("振動パターン")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Picker("連続振動パターン", selection: $selectedContinuousVibrationStyle) {
                            Text("軽い").tag(0)
                            Text("中程度").tag(1)
                            Text("強い").tag(2)
                            Text("硬い").tag(3)
                            Text("柔らかい").tag(4)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
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
                VStack(spacing: 15) {
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
                        
                        // 電信図風の波形表示
                        VStack(spacing: 10) {
                            Text("心拍波形")
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            ZStack {
                                // 背景グリッド
                                WaveformBackgroundView()
                                
                                // 波形ライン
                                WaveformView(
                                    data: waveformData,
                                    animationOffset: animationOffset,
                                    isHeartPattern: false
                                )
                                .stroke(Color.green, lineWidth: 2)
                                .shadow(color: Color.green.opacity(0.5), radius: 2, x: 0, y: 0) // グロー効果
                                .animation(.easeInOut(duration: 0.05), value: animationOffset) // より短いアニメーション
                            }
                            .cornerRadius(8)
                            .frame(height: 120)
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
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
        .onAppear {
            startSmoothAnimation()
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
        case 3: // 硬い (rigid) - iOS 13.0+
            if #available(iOS 13.0, *) {
                let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
                rigidImpact.impactOccurred()
            } else {
                // iOS 13.0未満では重い振動で代替
                let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
                heavyImpact.impactOccurred()
            }
        case 4: // 柔らかい (soft) - iOS 13.0+
            if #available(iOS 13.0, *) {
                let softImpact = UIImpactFeedbackGenerator(style: .soft)
                softImpact.impactOccurred()
            } else {
                // iOS 13.0未満では軽い振動で代替
                let lightImpact = UIImpactFeedbackGenerator(style: .light)
                lightImpact.impactOccurred()
            }
        case 5: // 成功
            notificationFeedback.notificationOccurred(.success)
        case 6: // 警告
            notificationFeedback.notificationOccurred(.warning)
        case 7: // エラー
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
            triggerVibrationByStyle(selectedContinuousVibrationStyle)
            // 波形にスパイクを追加
            addWaveformSpike(intensity: getIntensityForStyle(selectedContinuousVibrationStyle))
        }
    }
    
    // 連続振動を停止する関数
    func stopContinuousVibration() {
        isVibrating = false
        vibrationTimer?.invalidate()
        vibrationTimer = nil
        animationTimer?.invalidate()
        animationTimer = nil
        // 波形データをリセット
        waveformData = Array(repeating: 0.0, count: 200)
        currentWaveIndex = 0
        animationOffset = 0
    }
    
    // 心拍パターンの振動（実際の心拍のような2段階の振動）
    func startHeartRatePattern() {
        stopContinuousVibration()
        isVibrating = true
        
        let interval = 60.0 / customBPM
        
        vibrationTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
            // 心拍の「ドクン」パターンを再現
            // 選択されたパターンで1回目の振動（ドク）
            triggerVibrationByStyle(selectedContinuousVibrationStyle)
            addWaveformSpike(intensity: getIntensityForStyle(selectedContinuousVibrationStyle))
            
            // 少し遅らせて2回目の振動（ン）- 常に軽い振動
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                let lightImpact = UIImpactFeedbackGenerator(style: .light)
                lightImpact.impactOccurred()
                addWaveformSpike(intensity: 0.3) // 軽い振動のスパイク
            }
        }
    }
    
    // 振動スタイルに応じて振動を実行するヘルパー関数
    func triggerVibrationByStyle(_ style: Int) {
        switch style {
        case 0: // 軽い
            let lightImpact = UIImpactFeedbackGenerator(style: .light)
            lightImpact.impactOccurred()
        case 1: // 中程度
            let mediumImpact = UIImpactFeedbackGenerator(style: .medium)
            mediumImpact.impactOccurred()
        case 2: // 強い
            let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
            heavyImpact.impactOccurred()
        case 3: // 硬い (rigid) - iOS 13.0+
            if #available(iOS 13.0, *) {
                let rigidImpact = UIImpactFeedbackGenerator(style: .rigid)
                rigidImpact.impactOccurred()
            } else {
                let heavyImpact = UIImpactFeedbackGenerator(style: .heavy)
                heavyImpact.impactOccurred()
            }
        case 4: // 柔らかい (soft) - iOS 13.0+
            if #available(iOS 13.0, *) {
                let softImpact = UIImpactFeedbackGenerator(style: .soft)
                softImpact.impactOccurred()
            } else {
                let lightImpact = UIImpactFeedbackGenerator(style: .light)
                lightImpact.impactOccurred()
            }
        default:
            let defaultImpact = UIImpactFeedbackGenerator(style: .medium)
            defaultImpact.impactOccurred()
        }
    }
    
    // 波形データを更新する関数
    func updateWaveform() {
        withAnimation(.easeInOut(duration: 0.05)) {
            animationOffset += 1.0
        }
        if animationOffset > 1000 {
            animationOffset = 0
        }
    }
    
    // スムーズなアニメーションを開始
    func startSmoothAnimation() {
        animationTimer = Timer.scheduledTimer(withTimeInterval: 1.0/60.0, repeats: true) { _ in // 60FPS
            updateWaveform()
            updateWaveformDecay()
        }
    }
    
    // 波形の減衰を更新
    func updateWaveformDecay() {
        for i in 0..<waveformData.count {
            if waveformData[i] > 0 {
                waveformData[i] *= 0.98 // より緩やかな減衰
                if waveformData[i] < 0.02 {
                    waveformData[i] = 0
                }
            }
        }
    }
    
    // 波形にスパイクを追加する関数
    func addWaveformSpike(intensity: Double) {
        // より自然なスパイク形状を作成
        let spikeWidth = 8 // スパイクの幅を増加
        let peakIndex = currentWaveIndex + spikeWidth / 2
        
        // ガウシアン風のスパイクを作成
        for i in 0..<spikeWidth {
            let index = currentWaveIndex + i
            if index < waveformData.count {
                let distance = abs(i - spikeWidth / 2)
                let amplitude = intensity * exp(-Double(distance * distance) / 4.0)
                waveformData[index] = max(waveformData[index], amplitude)
            }
        }
        
        // インデックスを進める
        currentWaveIndex = (currentWaveIndex + spikeWidth + 3) % waveformData.count
    }
    
    // 振動スタイルに応じた強度を取得
    func getIntensityForStyle(_ style: Int) -> Double {
        switch style {
        case 0: return 0.4  // 軽い
        case 1: return 0.7  // 中程度
        case 2: return 1.0  // 強い
        case 3: return 0.9  // 硬い (rigidは強めだが重い程ではない)
        case 4: return 0.5  // 柔らかい (softは軽めだが軽い程ではない)
        default: return 0.7
        }
    }
}

// 波形の背景グリッドを描画するView
struct WaveformBackgroundView: View {
    var body: some View {
        Rectangle()
            .fill(Color.black.opacity(0.8))
            .frame(height: 120)
            .overlay(horizontalGridLines)
            .overlay(verticalGridLines)
    }
    
    private var horizontalGridLines: some View {
        VStack(spacing: 0) {
            ForEach(0..<5) { _ in
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(height: 1)
                Spacer()
            }
        }
    }
    
    private var verticalGridLines: some View {
        HStack(spacing: 0) {
            ForEach(0..<10) { _ in
                Rectangle()
                    .fill(Color.green.opacity(0.3))
                    .frame(width: 1)
                Spacer()
            }
        }
    }
}

// 波形を描画するカスタムShape
struct WaveformView: Shape {
    let data: [Double]
    let animationOffset: Double
    let isHeartPattern: Bool
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let width = rect.width
        let height = rect.height
        let centerY = height / 2
        
        // データポイントが少ない場合の処理
        guard data.count > 1 else {
            path.move(to: CGPoint(x: 0, y: centerY))
            path.addLine(to: CGPoint(x: width, y: centerY))
            return path
        }
        
        // より滑らかな曲線で波形を描画
        let stepX = width / CGFloat(data.count - 1)
        
        // 最初のポイント
        let firstY = centerY - (CGFloat(data[0]) * (height / 2 - 10))
        path.move(to: CGPoint(x: 0, y: firstY))
        
        // スムーズな曲線で接続
        for i in 1..<data.count {
            let x = CGFloat(i) * stepX
            let y = centerY - (CGFloat(data[i]) * (height / 2 - 10))
            
            // 前のポイントとの中間点を計算してスムーズな曲線を描画
            if i < data.count - 1 {
                let nextY = centerY - (CGFloat(data[i + 1]) * (height / 2 - 10))
                let controlPoint1 = CGPoint(x: x - stepX * 0.3, y: y)
                let controlPoint2 = CGPoint(x: x + stepX * 0.3, y: y)
                
                path.addCurve(to: CGPoint(x: x, y: y),
                              control1: controlPoint1,
                              control2: controlPoint2)
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        
        return path
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
