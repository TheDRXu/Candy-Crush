//
//  Sound.swift
//  Candy Crush
//
//  Created by Dwayne Reinaldy on 5/9/22.
//

import AVFoundation

var audioPlayer: AVAudioPlayer?

func playbackgroundSound(sound: String, type: String){
    if let bundle = Bundle.main.path(forResource: sound, ofType: type) {
                let backgroundMusic = NSURL(fileURLWithPath: bundle)
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf:backgroundMusic as URL)
                    guard let audioPlayer = audioPlayer else { return }
                    audioPlayer.numberOfLoops = -1
                    audioPlayer.prepareToPlay()
                    audioPlayer.play()
                } catch {
                    print(error)
                }
            }
    
}

func playSound(sound: String, type: String){
    if let path = Bundle.main.path(forResource: sound, ofType: type){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: path))
            audioPlayer?.play()
        }
        catch{
            print("ERROR")
        }
    }
    
}

