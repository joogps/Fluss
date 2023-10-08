//
//  ContentView.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 07/10/23.
//

import SwiftUI
import AVKit
import UserNotifications
import BackgroundTasks
import Combine
import FluidGradient

#if os(iOS)
import ActivityKit
#endif

struct ContentView: View {
    @AppStorage("liveActivity") var liveActivity = false
    @Environment(\.scenePhase) var scenePhase
    
    @State var updateTask: AnyCancellable?
    @State var updateTasks = Set<AnyCancellable>()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        VideoPlayer(player: Self.video.player)
                            .aspectRatio(1170/778, contentMode: .fit)
                            .disabled(true)
                            .padding(.top, 8)
                            .padding(.bottom, 16)
                            .background(.black)
                        HStack {
                            Text("Para visualizar o nível do rio, adicione um Widget à sua tela de início ou tela de bloqueio.")
                            Spacer()
                        }
                        .multilineTextAlignment(.leading)
                        .padding()
                        .background(.quinary)
                    }
                    .clipShape(.rect(cornerRadius: 12))
                    .onTapGesture {
                        Self.video.player.play()
                    }
                    
                    if #available(iOS 16.1, *) {
                        VStack(alignment: .leading) {
                            Toggle("Exibir Live Activity", isOn: $liveActivity)
                                .tint(.accent)
                            
                            Text("Essa função está em fase experimental, e, portanto, pode não atualizar em tempo real.")
                                .font(.footnote)
                                .multilineTextAlignment(.leading)
                                .foregroundStyle(.secondary)
                                .padding(.top, 2)
                        }
                        .padding()
                        .background(.quinary)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("Fonte dos dados")
                            Spacer()
                        }
                        
                        Text("Os dados exibidos pelo aplicativo provém do portal de monitoramento do [AlertaBlu](https://alertablu.blumenau.sc.gov.br/d/nivel-do-rio).")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                    .padding()
                    .background(.quinary)
                    .clipShape(.rect(cornerRadius: 12))
                    
                    Link(destination: URL(string: "https://instagram.com/joogps")!) {
                        HStack {
                            Text("desenvolvido por joão gabriel")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .foregroundStyle(.white)
                        .buttonStyle(.plain)
                        .padding()
                        .background(.accent)
                        .clipShape(.rect(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationTitle("Fluss")
            .background {
                Color("Background")
                    .overlay(alignment: .bottom) {
                        FluidGradient(blobs: [.accent, .accent, .accent], speed: 0.2)
                            .compositingGroup()
                            .mask(Rectangle().fill(.linearGradient(.init(colors: [.clear, .white.opacity(0.75)]), startPoint: .top, endPoint: .bottom)))
                            .frame(height: 300)
                    }
                    .ignoresSafeArea()
            }
        }
        .preferredColorScheme(.dark)
        .font(.body.bold())
        .onChange(of: liveActivity) { _ in
            if #available(iOS 16.1, *) {
                updateLiveActivity()
            }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                Self.video.player.play()
                if #available(iOS 16.1, *) {
                    updateLiveActivity()
                }
            } else if newPhase == .inactive {
                Self.video.player.pause()
            } else if newPhase == .background {
                Self.video.player.pause()
            }
        }
    }
    
    @available(iOS 16.1, *)
    func updateLiveActivity() {
        #if os(iOS)
        updateTask?.cancel()
        updateTask = Task {
            var leitura: Leitura?
            
            if liveActivity {
                leitura = await API.fetchLeituras()
            }
            
            for activity in Activity<LeituraAttributes>.activities {
                await activity.end(dismissalPolicy: .immediate)
            }
            
            if let leitura {
                let _ = try Activity.request(
                    attributes: LeituraAttributes(),
                    contentState: .init(leitura: leitura)
                )
            }
        }
        .eraseToAnyCancellable()
        
        updateTasks.forEach { $0.cancel() }
        updateTasks.removeAll()
        for i in 0...11 {
            Task {
                let minuteComponent = Calendar.current.component(.minute, from: .now)
                
                let minutes = 60 - minuteComponent + 10
                let hours = i
                
                try await Task.sleep(nanoseconds: UInt64(60_000_000_000*minutes+60_000_000_000*60*hours))
                let leitura = await API.fetchLeituras()
                if let nivel = leitura.nivelAtual {
                    for activity in Activity<LeituraAttributes>.activities {
                        await activity.update(using: .init(leitura: leitura),
                                              alertConfiguration: .init(title: "Atualização do nível do rio", body: "O nível do rio agora está em \(String(format: "%.2f", nivel.nivel))m", sound: .default))
                    }
                }
            }
            .store(in: &updateTasks)
        }
        #endif
    }
    
    static let video: (player: AVPlayer, looper: AVPlayerLooper) = {
        let videoURL = Bundle.main.url(forResource: "Video", withExtension: "mp4")!
        let asset = AVAsset(url: videoURL)
        let item = AVPlayerItem(asset: asset)
        let queuePlayer = AVQueuePlayer(playerItem: item)
        let playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: item)
        
        queuePlayer.play()
        
        return (queuePlayer, playerLooper)
    }()
}

#Preview {
    ContentView()
}
