//
//  GridViewController.swift
//  Menu_FYP
//
//  Created by Amir Mughal on 11/11/2018.
//  Copyright © 2018 Bilal Shahid. All rights reserved.
//

import UIKit
import AVFoundation
class GridViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var GridCollection: UICollectionView!
    let reuseIdentifier="GridButton"
    var gridType:String=""
    var subLessonIndex:Int = -1
    var activityIndex:Int = -1
    var QaidaData = Qaida()
    var words = [String]()
    var newWords = [String]()
    var totalPhraseCount:Int = 0
    var callback : ((Bool)->())?
    var verseByVerseSelectionCheck:Bool?
    var lessonIndex = -1
    var surahId: Int = -1
    var userTag = -1
    var selectedUserRepetitions = [10,5,2]
    var dispatchQueueWorkItem: DispatchWorkItem?
    var playPauseButtonSelectionCheck: Bool = false
    var onTapWordPlayCheck = false
    var onTapWordHighlightCheck = false
    var previousSelected : IndexPath?
    var currentSelected : Int?
    var surahChunkNumber: Int = 1
    var audioBuffer: AVAudioPCMBuffer?
    var audioFormat: AVAudioFormat?
    var audioSampleRate: Float = 0
    var audioLengthSeconds: Float = 0
    var audioLengthSamples: AVAudioFramePosition = 0
    var needsFileScheduled = true
    var updater: CADisplayLink?
    var delayInSeconds:Int = 1
    var currentFrame: AVAudioFramePosition {
        guard let lastRenderTime = player.lastRenderTime,
            let playerTime = player.playerTime(forNodeTime: lastRenderTime) else {
                return 0
        }
        
        return playerTime.sampleTime
    }
    var seekFrame: AVAudioFramePosition = 0
    var currentPosition: AVAudioFramePosition = 0
    let pauseImageHeight: Float = 26.0
    let minDb: Float = -80.0
    
    enum TimeConstant {
        static let secsPerMin = 60
        static let secsPerHour = TimeConstant.secsPerMin * 60
    }
    
    //AVAudio Properties
    var engine = AVAudioEngine()
    var player = AVAudioPlayerNode()
    var rateEffect = AVAudioUnitTimePitch()
    
    var audioFile: AVAudioFile? {
        didSet {
            if let audioFile = audioFile {
                audioLengthSamples = audioFile.length
                audioFormat = audioFile.processingFormat
                audioSampleRate = Float(audioFormat?.sampleRate ?? 44100)
                audioLengthSeconds = Float(audioLengthSamples) / audioSampleRate
            }
        }
    }
    
    var audioFileURL: URL? {
        didSet {
            if let audioFileURL = audioFileURL {
                audioFile = try? AVAudioFile(forReading: audioFileURL)
            }
        }
    }
    
    //View Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        QaidaData = getQaidaData()
        words=QaidaData.getwords(index: activityIndex)
        self.navigationController?.navigationBar.barTintColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Play", style: .plain, target: self, action: #selector(playPauseButtonHandler))
        self.setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.isMovingFromParent {
            player.stop()
            updater?.isPaused = true
            playPauseButtonSelectionCheck = false
            disconnectVolumeTap()
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func setup() {
        if(gridType == "subLesson"){
            if(subLessonIndex != -1){
                self.title = "Sub Lesson " + String(subLessonIndex)
                let wordsSize:Int = words.count/3
                print(words.count/3)
                if(subLessonIndex != 3){
                    for i in (wordsSize*(subLessonIndex-1))..<(subLessonIndex*wordsSize){
                        print(i,words[i])
                        newWords.append(words[i])
                    }
                }
                else{
                    for i in (wordsSize*(subLessonIndex-1))..<(words.count){
                        print(i,words[i])
                        newWords.append(words[i])
                    }
                }
            }
        }
        else if(gridType == "practice"){
            newWords=words
            self.title = "Practice"
        }
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSize(width: 60, height: 60)
        
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing=10
        layout.scrollDirection = .vertical
        GridCollection!.collectionViewLayout = layout
        GridCollection?.decelerationRate = UIScrollView.DecelerationRate.fast
        self.additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        currentSelected = 0
        previousSelected = (IndexPath(row: 0, section: 0))
        self.GridCollection.reloadItems(at: [IndexPath(row: currentSelected!, section: 0)])
        initialSetup()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(gridType == "subLesson"){
            if(subLessonIndex == 3){
                totalPhraseCount = words.count - ((words.count/3)*(subLessonIndex-1))
                return totalPhraseCount
            }
            else{
                totalPhraseCount = words.count/3
                return totalPhraseCount
            }
        } else{
            totalPhraseCount = words.count
            return totalPhraseCount
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                      for: indexPath) as! GridViewCell
    
        if currentSelected != nil && currentSelected == indexPath.row
        {
            cell.backgroundColor = #colorLiteral(red: 0.09896145016, green: 0.7481964827, blue: 0.5541328192, alpha: 1)
            cell.layer.borderColor = UIColor.clear.cgColor
            surahChunkNumber = indexPath.row
            cell.GridButton.textColor = .white
        }
        else
        {
            cell.backgroundColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
            cell.GridButton.textColor = .black
            cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        cell.layer.cornerRadius = 10
        cell.layer.borderWidth = 1
        cell.GridButton.text = newWords[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat =  10
        let collectionViewSize = collectionView.frame.size.width - padding
        
        return CGSize(width: collectionViewSize/6, height: collectionViewSize/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onTapWordHighlightCheck = true
        
        if previousSelected != nil{
            if let cell = collectionView.cellForItem(at: previousSelected!) as? GridViewCell{
                cell.backgroundColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
                cell.GridButton.textColor = .black
                cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.layer.borderWidth = 1
                cell.layer.cornerRadius = 10
            }
        }
        player.stop()
        onTapWordPlayCheck = true
        updater?.isPaused = true
        playPauseButtonSelectionCheck = false
        disconnectVolumeTap()
        
        surahChunkNumber = indexPath.row
        initialSetup()
        playPauseButtonHandler()
        
        currentSelected = indexPath.row
        previousSelected = indexPath
        self.GridCollection.reloadItems(at: [indexPath])
    }
    
    func highlightCollectionViewCell(_ CollectionView: UICollectionView, index pSelected: Int)
    {
        if let cell = CollectionView.cellForItem(at: IndexPath(row: pSelected, section: 0)) as? GridViewCell{
            cell.backgroundColor = #colorLiteral(red: 0.9242517352, green: 0.9300937653, blue: 0.9034610391, alpha: 1)
            cell.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.layer.borderWidth = 1
            cell.layer.cornerRadius = 10
            cell.GridButton.textColor = .black
        }
        print (surahChunkNumber)
        currentSelected = surahChunkNumber
        previousSelected = IndexPath(row: surahChunkNumber, section: 0)
        self.GridCollection.reloadItems(at: [IndexPath(row: currentSelected!, section: 0)])
    }
    
    //SoundPlaying Functions

    @objc func playPauseButtonHandler()
    {
        if onTapWordHighlightCheck == true{
            navigationItem.rightBarButtonItem?.title = "Pause"
            onTapWordHighlightCheck = false
            self.highlightCollectionViewCell(self.GridCollection, index: self.surahChunkNumber - 1)
        }
        else
        {
            if playPauseButtonSelectionCheck == false {
                playPauseButtonSelectionCheck = true
                navigationItem.rightBarButtonItem?.title = "Pause"
            }
            else
            {
                playPauseButtonSelectionCheck = false
                navigationItem.rightBarButtonItem?.title = "Play"
            }
        }
        
        if currentPosition >= audioLengthSamples {
            updateUI()
        }
        if self.player.isPlaying {
            self.disconnectVolumeTap()
            self.updater?.isPaused = true
            self.player.pause()
        } else {
            self.updater?.isPaused = false
            self.connectVolumeTap()
            if self.needsFileScheduled {
                self.needsFileScheduled = false
                self.scheduleAudioFile()
            }
            self.player.play()
        }
    }
    
    func initialSetup()
    {
        setupAudio()
        updater = CADisplayLink(target: self, selector: #selector(updateUI))
        updater?.add(to: .current, forMode: .default)
        updater?.isPaused = true
    }

    @objc func updateUI() {
        currentPosition = currentFrame + seekFrame
        currentPosition = max(currentPosition, 0)
        currentPosition = min(currentPosition, audioLengthSamples)
        
        let time = Float(currentPosition) / audioSampleRate
        
        if currentPosition >= audioLengthSamples {
            print("Chunk Finished")
            let chunkTotalTime = time
            player.stop()
            updater?.isPaused = true
            playPauseButtonSelectionCheck = false
            disconnectVolumeTap()
            if(self.surahChunkNumber < totalPhraseCount - 1)
            {
                self.surahChunkNumber += 1
                self.initialSetup()
                if onTapWordPlayCheck == false{
                    dispatchQueueWorkItem = DispatchWorkItem {
                        sleep(UInt32(Int(chunkTotalTime)*self.delayInSeconds))
                        DispatchQueue.main.async {
                            if !self.playPauseButtonSelectionCheck
                            {
                                self.playPauseButtonHandler()
                            }
                        }
                    }
                    DispatchQueue.global().async(execute: dispatchQueueWorkItem!)
                    self.highlightCollectionViewCell(self.GridCollection, index: self.surahChunkNumber - 1)
                }
                else
                {
                    navigationItem.rightBarButtonItem?.title = "Play"
                    onTapWordPlayCheck = false
                    onTapWordHighlightCheck = true
                }
            }
            else
            {
                self.surahChunkNumber = 0
                navigationItem.rightBarButtonItem?.title = "Play"
                self.previousSelected = IndexPath(row: self.totalPhraseCount - 1, section: 0)
                self.highlightCollectionViewCell(self.GridCollection, index: self.previousSelected!.row)
                self.initialSetup()
            }
        }
    }


    func formatted(time: Float) -> String {
        guard !(time.isNaN || time.isInfinite) else {
            return "illegal value"
        }
        var secs = Int(ceil(time))
        var hours = 0
        var mins = 0
        
        if secs > TimeConstant.secsPerHour {
            hours = secs / TimeConstant.secsPerHour
            secs -= hours * TimeConstant.secsPerHour
        }
        
        if secs > TimeConstant.secsPerMin {
            mins = secs / TimeConstant.secsPerMin
            secs -= mins * TimeConstant.secsPerMin
        }
        
        var formattedString = ""
        if hours > 0 {
            formattedString = "\(String(format: "%02d", hours)):"
        }
        formattedString += "\(String(format: "%02d", mins)):\(String(format: "%02d", secs))"
        return formattedString
    }

    func setupAudio() {
        let filename = String(activityIndex+1) + "_" + String(surahChunkNumber)
        audioFileURL = Bundle.main.url(forResource: filename, withExtension: "mp3")
        
        engine.attach(player)
        engine.attach(rateEffect)
        engine.connect(player, to: rateEffect, format: audioFormat)
        engine.connect(rateEffect, to: engine.mainMixerNode, format: audioFormat)
        
        engine.prepare()
        
        do {
            try engine.start()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func scheduleAudioFile() {
        guard let audioFile = audioFile else { return }
        seekFrame = 0
        player.scheduleFile(audioFile, at: nil) { [weak self] in
            self?.needsFileScheduled = true
        }
    }

    func connectVolumeTap() {
        let format = engine.mainMixerNode.outputFormat(forBus: 0)
        engine.mainMixerNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, when in
            
            guard let channelData = buffer.floatChannelData
                else {
                    return
            }
            
            let channelDataValue = channelData.pointee
            let channelDataValueArray = stride(from: 0,
                                               to: Int(buffer.frameLength),
                                               by: buffer.stride).map{ channelDataValue[$0] }
            let channelDataValueArray1 = channelDataValueArray.map{ $0 * $0 }.reduce(0, +)
            let rms = sqrt(channelDataValueArray1 / Float(buffer.frameLength))
            _ = 20 * log10(rms)
        }
    }

    func scaledPower(power: Float) -> Float {
        guard power.isFinite else { return 0.0 }
        
        if power < minDb {
            return 0.0
        } else if power >= 1.0 {
            return 1.0
        } else {
            return (abs(minDb) - abs(power)) / abs(minDb)
        }
    }

    func disconnectVolumeTap() {
        engine.mainMixerNode.removeTap(onBus: 0)
        //volumeMeterHeight.constant = 0
    }

}



