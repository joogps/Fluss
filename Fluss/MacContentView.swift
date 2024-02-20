//
//  MacContentView.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

#if os(macOS)
import SwiftUI
import WidgetKit

struct MacContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Image("Example")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                HStack {
                    Text("Para visualizar o nível do rio, adicione um Widget ao seu Desktop ou central de notificações.")
                    Spacer()
                }
                .multilineTextAlignment(.leading)
                .padding()
                .background(.quinary)
            }
            .clipShape(.rect(cornerRadius: 8))
            
            VStack(alignment: .leading) {
                HStack {
                    Text("Fonte dos dados")
                    Spacer()
                }
                
                Text("Os dados exibidos pelo aplicativo provém do portal de monitoramento do [AlertaBlu](https://alertablu.blumenau.sc.gov.br/d/nivel-do-rio).")
                    .tint(.accent)
                    .font(.footnote)
                    .multilineTextAlignment(.leading)
                    .foregroundStyle(.secondary)
                    .padding(.top, 2)
            }
            .padding()
            .background(.quinary)
            .clipShape(.rect(cornerRadius: 8))
            
            Link(destination: URL(string: "https://brasil.un.org/pt-br/175180-o-que-são-mudanças-climáticas")!) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Mudanças climáticas")
                        
                        Text("Clique para saber mais sobre as mudanças climáticas e o aquecimento global.")
                            .font(.footnote)
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(Color.accent
                    .overlay(Color(white: 0.1).blendMode(.luminosity))
                    .opacity(0.65))
                .background(.quinary)
                .clipShape(.rect(cornerRadius: 12))
            }
            
            Link(destination: URL(string: "https://joogps.com")!) {
                HStack {
                    Text("desenvolvido por joão gabriel")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(.accent)
                .clipShape(.rect(cornerRadius: 12))
            }
            
            Button(action: {
                NSApp.terminate(nil)
            }) {
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: "power")
                    Text("Encerrar Fluss")
                    Spacer()
                }
                .foregroundStyle(.accent)
                .padding()
                .background(.white)
                .clipShape(.rect(cornerRadius: 8))
            }
            
        }
        .buttonStyle(ElasticButtonStyle())
        .padding(16)
        .background(Color("Background").ignoresSafeArea())
        .colorScheme(.dark)
        .font(.body.bold())
        .onAppear {
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
}

#Preview {
    MacContentView()
}
#endif
