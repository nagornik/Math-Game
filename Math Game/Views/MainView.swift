//
//  MainView.swift
//  Math Game
//
//  Created by Anton Nagornyi on 29.08.2022.
//

import SwiftUI

struct MainView: View {
    
    @EnvironmentObject var logic: ViewModel
    @EnvironmentObject var database: DatabaseService
    
    @State var drag = CGFloat.zero
    
    var body: some View {
        
        ZStack {
            
            Color("back")
                    .ignoresSafeArea()
            Color("accent")
                    .rotationEffect(Angle(degrees: 45))
                    .blur(radius: 20)
                    .ignoresSafeArea()
            
            VStack {
                TopButtons()
                
                switch logic.selectedScreen {
                    case .start:
                        StartView()
                            .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity), removal: .move(edge: .trailing).combined(with: .opacity)))
                    case .game:
                        GameView()
                            .transition(.asymmetric(insertion: .move(edge: .trailing).combined(with: .opacity), removal: .move(edge: .leading).combined(with: .opacity)))
                    case .settings:
                        SettingsView()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    case .topResults:
                        TopResultsView(drag: $drag)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                    case .login:
                        LoginView()
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
            }
            
            if logic.isLoading {
                ZStack {
                    Color.black
                        .opacity(0.3)
                    ProgressView()
                }
                .transition(.opacity)
                .ignoresSafeArea()
            }

        }
        .animation(.spring().speed(0.5), value: logic.selectedScreen)
        .animation(.spring().speed(0.5), value: logic.isAnswered)
        .animation(.spring().speed(0.5), value: logic.isLoading)
        .animation(.spring().speed(0.5), value: logic.choiceArray)
        .onAppear {
            database.downloadAndUpdateScore(allTopScores: logic.allTopScores) { data in
                if data != nil {
                    logic.allTopScores = data!
                } else {
                    logic.allTopScores = logic.getAllTopScoresFromLocal() ?? [String : Int]()
                }
            }
        }
        .gesture(
            DragGesture(minimumDistance: logic.selectedScreen == .topResults ? 10 : 10000)
                .onChanged({ value in
                    drag = value.translation.width
                })
                .onEnded({ value in
                    
                    guard value.translation.width > 100 || value.translation.width < -100 else {
                        withAnimation(.spring()) {
                            drag = .zero
                        }
                        return
                    }
                    
                    if value.translation.width > 100 {
                        withAnimation(.spring()) {
                            drag = screen.width * 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            drag = -screen.width * 1
                            withAnimation(nil) {
                                previousTopDifficulty()
                            }
                        }
                    } else if value.translation.width < -100 {
                        withAnimation(.spring()) {
                            drag = -screen.width * 1
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                            drag = screen.width * 1
                            withAnimation(nil) {
                                nextTopDifficulty()
                            }
                        }
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        withAnimation(.spring()) {
                            drag = .zero
                        }
                    }
                })
        )
        
    }
    
    func nextTopDifficulty() {
        if logic.difficultyForTopScore == .veryEasy {
            logic.difficultyForTopScore = .easy
        } else if logic.difficultyForTopScore == .easy {
            logic.difficultyForTopScore = .medium
        } else if logic.difficultyForTopScore == .medium {
            logic.difficultyForTopScore = .hard
        } else if logic.difficultyForTopScore == .hard {
            logic.difficultyForTopScore = .ultraHard
        }
    }
    
    func previousTopDifficulty() {
        if logic.difficultyForTopScore == .ultraHard {
            logic.difficultyForTopScore = .hard
        } else if logic.difficultyForTopScore == .hard {
            logic.difficultyForTopScore = .medium
        } else if logic.difficultyForTopScore == .medium {
            logic.difficultyForTopScore = .easy
        } else if logic.difficultyForTopScore == .easy {
            logic.difficultyForTopScore = .veryEasy
        }
    }
    
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
            .environmentObject(ViewModel())
            .environmentObject(DatabaseService())
            .preferredColorScheme(.dark)
    }
}
