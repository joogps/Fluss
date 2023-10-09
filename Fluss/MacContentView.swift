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
            
            Link(destination: URL(string: "https://instagram.com/joogps")!) {
                HStack {
                    Text("desenvolvido por joão gabriel")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundStyle(.white)
                .padding()
                .background(.accent)
                .clipShape(.rect(cornerRadius: 8))
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
        .buttonStyle(.plain)
        .padding(16)
        .background(Color("Background").ignoresSafeArea())
        .preferredColorScheme(.dark)
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
