//
//  GameView.swift
//  Candy Crush
//
//  Created by Dwayne Reinaldy on 5/6/22.
//

import Combine
import SwiftUI

let defaultTimeRemaining: CGFloat = 30
let lineWidth: CGFloat = 5
let radius: CGFloat = 70
struct GameView: View {
    typealias ViewModel = GameViewModel
    @StateObject private var viewModel: ViewModel
    @State private var squares = [Int: CGRect]()
    @State private var selectedIndex: Int? = nil
    @State private var selectionOpacity = 0.5
    @State private var canMove = true
    @State private var score : Int = 0
    @State private var isActive = false
    @State private var toggleAlert = false
    @State private var toggleWin = false
    @State private var timeRemaining: CGFloat = defaultTimeRemaining
    @State private var streakMulti: Int = 0
    @State private var barWidth: CGFloat = 70
    @State private var barHeight: CGFloat = 10
    @State private var color1 = Color(#colorLiteral(red: 1, green: 0.497258985, blue: 0, alpha: 1))
    @State private var color2 = Color(#colorLiteral(red: 1, green: 0.01224201724, blue: 0, alpha: 1))

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private enum Space: Hashable {
        case board
    }
    init() {
        _viewModel = .init(wrappedValue: .init())
    }

    var body: some View {
        NavigationView{
            ZStack(alignment: .topLeading) {
                ZStack {
                    VStack(spacing: 2)  {
                        ForEach(0..<GameViewModel.Constant.boardWidth, id: \.self) { y in
                            HStack(spacing: 2) {
                                ForEach(0..<GameViewModel.Constant.boardWidth, id: \.self) { x in
                                    let index = x + y * GameViewModel.Constant.boardWidth
                                    let background = #colorLiteral(red: 0.5632492164, green: 0.707854137, blue: 1, alpha: 1)
                                    GeometryReader { proxy in
                                        RoundedRectangle(cornerRadius: proxy.size.width*0.1)
                                            .aspectRatio(1, contentMode: .fit)
                                            .preference(
                                                key: SquaresPreferenceKey.self,
                                                value: [index: proxy.frame(in: .named(Space.board))]
                                            )
                                            .foregroundColor(Color(background))
                                    }
                                    .onTapGesture { Task { await handleTap(at: index);streakMulti=1 } }
                                }
                            }
                        }
                    }
                }
                    .aspectRatio(1, contentMode: .fit)
                    .padding()
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar{
                        ToolbarItem(placement: .principal){
                            VStack{
                                Text("Candy Crush")
                                    .font(.system(size: 24))
                                    .padding(5)
                            }
                        }
                        ToolbarItem(placement: .navigationBarTrailing){
                            ZStack{
                                Circle()
                                    .stroke(Color.gray.opacity(0.2),style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                                Circle()
                                    .trim(from: 0, to: 1-((defaultTimeRemaining-timeRemaining)/defaultTimeRemaining))
                                    .stroke(
                                        timeRemaining > 3 ? Color.blue : Color.red,
                                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                                    .frame(width: 50, height: 50)
                                    .padding(5)
                                    .rotationEffect(.degrees(-90))
                                    .animation(.easeInOut(duration: 1),value:1)
                                    .onReceive(timer){ _ in
                                        if timeRemaining != 0 && toggleAlert == false{
                                            timeRemaining -= 1
                                            if score>=1000{
                                                toggleWin.toggle()
                                                playSound(sound: "ans", type: "mp3")
                                            }
                                        }
                                        else{
                                            toggleAlert.toggle()
                                        }
                                    }
                                Text("\(Int(timeRemaining))")
                            }
                            .padding(5)
                            .alert(isPresented: $toggleAlert){
                                Alert(title: Text("You Lose"), message: Text("Play Again?"), dismissButton: .default(Text("Yes"),action:{
                                    timeRemaining = defaultTimeRemaining;score = 0;viewModel.newBoard();toggleAlert=false
                                }))
                            }
                            
                        }
                        ToolbarItem(placement: .navigationBarLeading){
                            VStack{
                                Text("Score : \(score)")
                                let multiplier = barWidth / 1000
                                ZStack(alignment: .leading){
                                    RoundedRectangle(cornerRadius: barHeight,style: .continuous)
                                        .frame(width:barWidth, height: barHeight)
                                        .foregroundColor(Color.black.opacity(0.1))
                                    
                                    RoundedRectangle(cornerRadius: barHeight,style: .continuous)
                                        .frame(width:CGFloat(score) * multiplier, height: barHeight)
                                        .background(
                                            LinearGradient(gradient: Gradient(colors: [color1,color2]), startPoint: .leading, endPoint: .trailing)
                                                .clipShape(RoundedRectangle(cornerRadius: 5,style: .continuous))
                                        )
                                        .foregroundColor(.clear)
                                }
                            }
                            .alert(isPresented: $toggleWin){
                                Alert(title: Text("You Win"), message: Text("Play Again?"), dismissButton: .default(Text("Yes"),action:{
                                    timeRemaining = defaultTimeRemaining;score = 0;viewModel.newBoard();toggleAlert=false
                                }))
                            }
                        }

                        ToolbarItem(placement: .bottomBar){
                            Button{
                                viewModel.newBoard()
                                timeRemaining = defaultTimeRemaining
                                score = 0
                                toggleAlert = false
                            }label:{
                                Text("Restart")
                                    .font(.largeTitle)
                            }
                        }
                    }
                if let selectedIndex = selectedIndex, let rect = squares[selectedIndex] {
                    RoundedRectangle(cornerRadius: rect.width*0.1)
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: rect.size.width)
                        .offset(x: rect.minX, y: rect.minY)
                        .foregroundColor(Color.purple)
                        .opacity(selectionOpacity)
                        .onAppear { selectionOpacity = 1.0 }
                        .onDisappear { selectionOpacity = 0.5 }
                        .animation(Animation.easeInOut(duration: 1).repeatForever(), value: selectionOpacity)
                        .allowsHitTesting(false)
                }
                ForEach(viewModel.cells) { cell in
                    let square = squares[cell.position] ?? .init(origin: .zero, size: .zero)
                    let rect = square.insetBy(dx: square.size.width * 0.1, dy: square.size.height * 0.1)
                    Image(ViewModel.Constant.cellContents[cell.content])
                        .resizable()
                        .foregroundColor(Color(ViewModel.Constant.colors[cell.content]))
                        .frame(width: rect.size.width, height: rect.size.height)
                        .scaleEffect(cell.isMatched ? 1e-6 : 1, anchor: .center)
                        .offset(x: rect.minX, y: rect.minY)
                        .transition(.move(edge: .top))
                        .shadow(radius: 2)
                        .allowsHitTesting(false)
                }
            }
                .background(Color(.blue)).ignoresSafeArea()
                .coordinateSpace(name: Space.board)
                .onPreferenceChange(SquaresPreferenceKey.self) { squares = $0 }
        }
        
    }
    private func handleTap(at index: Int) async {
        let cell = viewModel.cells[index]
        guard selectedIndex != cell.position else { return selectedIndex = nil }
        guard let selectedIndex = selectedIndex else { return selectedIndex = cell.position }
        guard canMove, ViewModel.isAdjacent(selectedIndex, to: cell.position) else { return }
        self.selectedIndex = nil
        canMove = false
        defer { canMove = true }
        await animate(with: .easeInOut(duration:0.5)) {
            viewModel.exchange(selectedIndex, with: cell.position)
        }
        guard viewModel.hasMatches else {
            return await animate(with: .easeInOut(duration:0.5)) {
                playSound(sound: "wrong", type: "mp3")
                viewModel.exchange(selectedIndex, with: cell.position)
            }
        }
        while viewModel.hasMatches {
            playSound(sound: "correct", type: "mp3")
            score = score + 10 * streakMulti
            streakMulti += 1
            timeRemaining = defaultTimeRemaining
            await animate(with: .linear(duration:0.25)) {
                viewModel.removeMatches()
            }
            while(viewModel.canCollapse) {
                await animate(with: .linear(duration:0.15)) {
                    viewModel.collapse()
                }
            }
        }
    }
}

