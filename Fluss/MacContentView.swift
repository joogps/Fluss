//
//  MacContentView.swift
//  Fluss
//
//  Created by João Gabriel Pozzobon dos Santos on 08/10/23.
//

#if os(macOS)
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 8) {
            VStack(spacing: 0) {
                Image("Example")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                HStack {
                    VStack(alignment: .leading) {
                        Text("Para visualizar a situação da enchente, adicione um Widget ao seu Desktop ou central de notificações.")
                        Text("Para alterar a região, realize um clique secundário. Então, selecione \"Editar \"Fluss\"\" e selecione a região.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .padding(.top, 2)
                    }
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
                
                Text("Os dados exibidos para as regiões de Blumenau e Porto Alegre, provêm, respectivemente, do portal de monitoramento do [AlertaBlu](https://alertablu.blumenau.sc.gov.br/d/nivel-do-rio) e do [SNIRH](https://www.snirh.gov.br).")
                    .tint(.accentColor)
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
        .padding(.vertical, 36)
        .background(Color("Background").ignoresSafeArea())
        .colorScheme(.dark)
        .font(.body.bold())
    }
}

#Preview {
    ContentView()
}
#endif
