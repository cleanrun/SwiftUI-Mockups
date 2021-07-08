//
//  ContentView.swift
//  SwiftUI-Mockups
//
//  Created by cleanmac on 08/07/21.
//

import SwiftUI

struct TwitterParallaxView: View {
    
    @State private var offset: CGFloat = 0
    
    // MARK: Dark/Light mode support
    @Environment(\.colorScheme) var colorScheme
    
    @State private var currentTab = "Tweets"
    
    @Namespace var animation // For smooth sliding tab animation
    
    @State var tabBarOffset: CGFloat = 0
    @State var titleOffset: CGFloat = 0
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                // MARK: Header View
                GeometryReader { proxy -> AnyView in
                    let minY = proxy.frame(in: .global).minY
                    
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    
                    return AnyView(
                        ZStack {
                            Image("banner")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: getRect().width, height: minY > 0 ? 180 + minY : 180, alignment: .center)
                                .cornerRadius(0)
                            
                            BlurView()
                                .opacity(blurViewOpacity())
                            
                            VStack(spacing: 5) {
                                Text("Profile")
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("7777 Tweets")
                                    .foregroundColor(.white)
                            }.offset(y: 120)
                            .offset(y: titleOffset > 100 ? 0 : -getTitleOffset())
                            .opacity(titleOffset < 100 ? 1 : 0)
                            
                        }.clipped()
                        .frame(height: minY > 0 ? 180 + minY : nil)
                        .offset(y: minY > 0 ? -minY : -minY < 80 ? 0 : -minY - 80)
                    )
                }.frame(height: 180)
                .zIndex(1)
                
                // MARK: Profile data view
                VStack {
                    HStack {
                        Image("displaypicture")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 75, height: 75)
                            .clipShape(Circle())
                            .padding(8)
                            .background(colorScheme == .dark ? Color.black : Color.white)
                            .clipShape(Circle())
                            .offset(y: offset < 0 && -offset < 80 ? getOffset() - 20 : -20 )
                            .scaleEffect(getScale())
                        
                        Spacer()
                        
                        Button(action: {}) {
                            Text("Edit Profile")
                                .foregroundColor(.blue)
                                .padding(.vertical, 10)
                                .padding(.horizontal)
                                .background(
                                    Capsule()
                                        .stroke(Color.blue, lineWidth: 1.5)
                                    
                                )
                        }
                    }.padding(.top, -25)
                    .padding(.bottom, -10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Profile")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("@twitterprofile")
                            .foregroundColor(.gray)
                        
                        Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.")
                        
                        HStack(spacing: 5) {
                            Text("13")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                            
                            Text("Followers")
                                .foregroundColor(.gray)
                            
                            Text("680")
                                .foregroundColor(.primary)
                                .fontWeight(.semibold)
                                .padding(.leading, 10)
                            
                            Text("Following")
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 8)
                        
                    }.overlay(
                        GeometryReader { proxy -> Color in
                            let minY = proxy.frame(in: .global).minY
                            
                            DispatchQueue.main.async {
                                self.titleOffset = minY
                            }
                            
                            return Color.clear
                        }.frame(width: 0, height: 0)
                        
                        , alignment: .top
                    )
                    
                    // MARK: Segmented control
                    VStack(spacing: 0) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 0) {
                                TabButton(title: "Tweets", currentTab: $currentTab, animation: animation)

                                TabButton(title: "Tweets & Replies", currentTab: $currentTab, animation: animation)

                                TabButton(title: "Media", currentTab: $currentTab, animation: animation)

                                TabButton(title: "Likes", currentTab: $currentTab, animation: animation)
                            }
                        }

                        Divider()
                    }.padding(.top, 30)
                    .background(colorScheme == .dark ? Color.black : Color.white)
                    .offset(y: tabBarOffset < 90 ? -tabBarOffset + 90 : 0)
                    .overlay(
                        GeometryReader { reader -> Color in
                            let minY = reader.frame(in: .global).minY
                            
                            DispatchQueue.main.async {
                                self.tabBarOffset = minY
                            }
                            
                            return Color.blue
                        }.frame(width: 0, height: 0)
                        , alignment: .top
                    )
                    .zIndex(1)
                    
                    // MARK: Tweets
                    VStack(spacing: 18) {
                        ForEach(1...20, id: \.self) { _ in
                            TweetCell()
                        }
                    }.padding(.top)
                    .zIndex(0)
                }.padding(.horizontal)
                .zIndex(-offset > 80 ? 0 : 1)
                
                
            }
        }.ignoresSafeArea(.all, edges: .top)
    }
    
    // MARK: Profile shrinking effect
    private func getOffset() -> CGFloat {
        let progress = (-offset / 80) * 20
        return progress <= 20 ? progress : 20
    }
    
    private func getScale() -> CGFloat {
        let progress = -offset / 80
        let scale = 1.8 - (progress < 1.0 ? progress : 1)
        // We're scalling view to 0.8 times (1.8 - 1.0 = 0.8)
        return scale < 1 ? scale : 1
    }
    
    private func blurViewOpacity() -> Double {
        let progress = -(offset + 80) / 150
        return Double(-offset > 80 ? progress : 0)
    }
    
    private func getTitleOffset() -> CGFloat {
        let progress = 20 / titleOffset
        let offset = 60 * (progress > 0 && progress <= 1 ? progress : 1)
        return offset
    }
    
}

#if DEBUG
struct TwitterParallaxView_Previews: PreviewProvider {
    static var previews: some View {
        TwitterParallaxView()
    }
}
#endif

struct TabButton: View {
    var title: String
    @Binding var currentTab: String
    var animation: Namespace.ID
    
    var body: some View {
        Button(action: {
            withAnimation {
                currentTab = title
            }
        }) {
            LazyVStack(spacing: 12) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundColor(currentTab == title ? .blue : .gray)
                    .padding(.horizontal)
                
                if currentTab == title {
                    Capsule()
                        .fill(Color.blue)
                        .frame(height: 1.2)
                        .matchedGeometryEffect(id: "TAB", in: animation)
                } else {
                    Capsule()
                        .fill(Color.clear)
                        .frame(height: 1.2)
                }
            }
        }
    }
}

struct TweetCell: View {
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image("displaypicture")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 55, height: 55)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 10) {
                (
                    Text("Profile  ")
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    +
                    
                    Text("@twitterprofile")
                        .foregroundColor(.gray)
                )
                
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.")
                
                Divider()
            }
        }
    }
}

extension View {
    func getRect() -> CGRect { // Getting the screen size
        UIScreen.main.bounds
    }
}


