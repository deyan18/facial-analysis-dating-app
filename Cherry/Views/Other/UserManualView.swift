//
//  ManualUsuarioView.swift
//  Cherry
//
//  Created by Deyan on 23/2/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserManualView: View {
    var isSheet: Bool
    var body: some View {
        if(isSheet){
            NavigationView{
                userManualSections
                .padding(.top)
                .navigationTitle("Manual de Usuario")
            }
        }else{
            userManualSections.navigationTitle("Manual de Usuario")
        }
    }
    
    var userManualSections: some View{
        VStack{
            List{
                NavigationLink("Registro", destination: SignUpManualView())
                NavigationLink("Inicio de sesión", destination: SignInManualView())
                NavigationLink("Recuperar contraseña", destination: RecoverPasswordManualView())
                NavigationLink("Lista de recomendaciones", destination: ForYouManualView())
                NavigationLink("Uso de filtros", destination: FiltersManualView())
                NavigationLink("Chatear", destination: ChatsManualView())
                NavigationLink("Personalización del perfil", destination: CustomizeManualView())
                NavigationLink("Cambiar correo y contraseña", destination: ModifyAccountManualView())
                NavigationLink("Cerrar sesión", destination: SignOutManualView())
                NavigationLink("Eliminar cuenta", destination: DeleteAccountManualView())
            }.listStyle(.plain)
        }.padding(.bottom, 40)
        
    }
}


struct SignUpManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Para registrarte debes pulsar sobre el siguiente botón en la pantalla de inicio de sesión:")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    
                    Image("MU:registro")
                        .resizable()
                        .sizeToFit()
                        .frame(width: 300)
                    Spacer()
                }
                Text("A continuación debes proporcionar un correo y una contraseña para crear tu cuenta. La contraseña debe tener un mínimo de 6 caracteres.")
                    .font(.callout)
                    .padding(1)
                
                Text("Tras esto debes rellenar los datos de tu perfil. Recuerda que todos los campos deben estar completos. Una vez completado pulsa sobre el botón Guardar. Espera unos segundos mientras se comprueba si la foto de tu rostro es válida. En el caso de que no lo sea deberás proporcionar una nueva. Si todo los datos son correcto serás llevado a la página de inicio.")
                    .font(.callout)
                    .padding(1)
                Spacer()
            }.padding()
            .navigationTitle("Registro")
        
        }
    }
}

struct CustomizeManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Una vez autenticado navega hasta la sección del perfil utilizando la barra de navegación.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20perfil.png?alt=media&token=69190f83-86c8-4c54-93c7-52b2276ca96b"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                Text("Desde la sección de perfil pulsa sobre el botón de editar colocado en la esquina superior izquierda.")
                    .font(.callout)
                    .padding(1)
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20editar.png?alt=media&token=12730ed9-3df3-42d1-b788-8eeb238ef17a"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }

                Spacer()
                Text("Desde aqui puedes modificar las partes que desees de tu perfil. Para guardar pulsa el botón guardar en la esquina superior derecha.")
                    .font(.callout)
                    .padding(1)
                Spacer()
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fguardar%20perfil.png?alt=media&token=68ad1877-1e3c-477b-92d3-088f7682d32e"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
            }
                
                
            }.padding()
            .navigationTitle("Personalización del perfil")
        
        }
    }


struct SignInManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Para iniciar sesión debes haberte registrado anteriormente. Rellena los campos de correo y contraseña y pulsa sobre el botón de iniciar sesión. Si el botón se encuentra inactivo significa que la contraseña no es válida (esta debe contenter un mínimo de 6 caracteres) o que el correo no es válido.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Finiciar%20sesio%CC%81n.png?alt=media&token=a964ef39-94f0-436c-b39b-fb685671040e"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
               
                
                
            }
                
                
            }.padding()
            .navigationTitle("Inicio de sesión")
    }
}

struct RecoverPasswordManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("En el caso de hayas olvidado tu contraseña debes pulsar sobre el siguiente botón en la pantalla de inicio de sesión.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fhas%20olvidado.png?alt=media&token=a31b74f8-23a7-4ea5-ba6d-17b6ca3fd492"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                Text("Una vez aquí debes introducir tu correo electrónico y pulsar sobre el siguiente botón.")
                    .font(.callout)
                    .padding(1)
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Frecuperar%20contra.png?alt=media&token=6e8a1efd-488a-4912-9e66-e5725ce7ab44"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }

               
            }
                
                
            }.padding()
            .navigationTitle("Recuperar Contraseña")
    }
}

struct ForYouManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("En la vista de Para Ti se muestra una lista con los perfiles recomendados en base a tu preferencias y rasgos faciales. Si deseas recargar la lista y volver a iniciar el proceso de análisis debes pulsar sobre el logo de la aplicación en la esquina superir izquierda.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Frecargar.png?alt=media&token=dc2d01ab-41e9-49b9-83e0-4737b776dc9e"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
               
            }
                
                
            }.padding()
            .navigationTitle("Lista de recomendaciones")
    }
}

struct FiltersManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Puedes personalizar los filtros para los recomendación de perfiles. Para ello pulsa sobre el icono de filtros en la esquina superior deerecha de la pantalla principal.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20filtros.png?alt=media&token=d6157513-b8c5-4075-b727-6036874d180e"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
               
            }
                
                
            }.padding()
            .navigationTitle("Filtros")
    }
}

struct ChatsManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Para acceder a los chats recientes pulsa sobre el siguiente botón en la barra de navegación.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20chat.png?alt=media&token=c424e4f8-bc05-4d5f-bca8-655d0527d8d1"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                
                Text("Desde aqui puedes ver una lista con todos los chats recientes en orden cronológico. Los mensajes sin leer llevan el siguiente indicador a su derecha. Puedes abrir un chat pulsando sobre él.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fchats%20indicador.png?alt=media&token=07819188-7184-493d-b1ee-c20e1fe0f858"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                
                Text("Una vez abiert el chat se muestran todos los mensajes. Desde aquí puedes escribir mensajes haciendo uso de la barra de herramientas inferior.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fenviar%20mensaje.png?alt=media&token=8d441948-69d3-4ee3-914b-1b208f27f6ce"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
               
            }
                
                
            }.padding()
            .navigationTitle("Chats")
    }
}

struct ModifyAccountManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Una vez autenticado navega hasta la sección del perfil utilizando la barra de navegación.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20perfil.png?alt=media&token=69190f83-86c8-4c54-93c7-52b2276ca96b"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                Text("Desde la sección de perfil pulsa sobre el botón de ajustes colocado en la esquina superior derecha.")
                    .font(.callout)
                    .padding(1)
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20ajustes.png?alt=media&token=c5190586-9c34-4be4-baf5-9dca4b1e3ca4"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }

                Spacer()
                Text("Desde aqui puedes modificar tu correo y contraseña. Para guardar pulsa sobre el siguiente botón.")
                    .font(.callout)
                    .padding(1)
                Spacer()
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fguardar%20ajustes.png?alt=media&token=1e8e0b8e-cf29-484e-af91-2a9d5a47fab8"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
            }
                
                
            }.padding()
            .navigationTitle("Cambiar correo y contraseña")
        
        }
    
}

struct SignOutManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Una vez autenticado navega hasta la sección del perfil utilizando la barra de navegación.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20perfil.png?alt=media&token=69190f83-86c8-4c54-93c7-52b2276ca96b"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                Text("Desde la sección de perfil pulsa sobre el botón de ajustes colocado en la esquina superior derecha.")
                    .font(.callout)
                    .padding(1)
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20ajustes.png?alt=media&token=c5190586-9c34-4be4-baf5-9dca4b1e3ca4"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }

                Spacer()
                Text("Desde aqui pulsa sobre el botón de cerrar sesión.")
                    .font(.callout)
                    .padding(1)
                Spacer()
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fcerrar%20sesion.png?alt=media&token=714f0c42-58b6-4fce-8fff-c33ebfc42585"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
            }
                
                
            }.padding()
            .navigationTitle("Cerrar Sesión")
    }
}

struct DeleteAccountManualView: View {
    var body: some View {
        ScrollView{
            VStack(alignment: .leading){
                Text("Una vez autenticado navega hasta la sección del perfil utilizando la barra de navegación.")
                    .font(.callout)
                    .padding(1)
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20perfil.png?alt=media&token=69190f83-86c8-4c54-93c7-52b2276ca96b"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
                Text("Desde la sección de perfil pulsa sobre el botón de ajustes colocado en la esquina superior derecha.")
                    .font(.callout)
                    .padding(1)
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Fabrir%20ajustes.png?alt=media&token=c5190586-9c34-4be4-baf5-9dca4b1e3ca4"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }

                Spacer()
                Text("Desde aqui pulsa sobre el botón de eliminar cuentas.")
                    .font(.callout)
                    .padding(1)
                Spacer()
                
                HStack{
                    Spacer()
                    WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/cherryapp-793a8.appspot.com/o/manual%2Feliminar%20cuenta.png?alt=media&token=3f63b1fb-ccf9-4a13-80b8-d999281082a8"))
                        .resizable()
                        .scaledToFill()

                    Spacer()
                }
            }
                
                
            }.padding()
            .navigationTitle("Eliminar Cuenta")
    }
}
