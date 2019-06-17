//
//  EmojiArtView.swift
//  EmojiArt
//
//  Created by Stephen Cao on 17/6/19.
//  Copyright © 2019 Stephencao Cao. All rights reserved.
//

import UIKit

class EmojiArtView: UIView {
    var backgroundImage: UIImage?{
        didSet{
            setNeedsDisplay()
        }
    }
    override func draw(_ rect: CGRect) {
        backgroundImage?.draw(in: rect)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup(){
        addInteraction(UIDropInteraction(delegate: self))
    }
    private func addLabel(with attributedString: NSAttributedString, centerdAt point: CGPoint){
        let label = UILabel()
        label.backgroundColor = .clear
        label.attributedText = attributedString
        label.sizeToFit()
        label.center = point
        addEmojiArtGestureRecognizers(to: label)
        addSubview(label)
    }
}
extension EmojiArtView: UIDropInteractionDelegate{
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: NSAttributedString.self) { (providers) in
            let dropPoint = session.location(in: self)
            for attributedString in providers as? [NSAttributedString] ?? []{
                self.addLabel(with: attributedString, centerdAt: dropPoint)
            }
        }
    }
}
