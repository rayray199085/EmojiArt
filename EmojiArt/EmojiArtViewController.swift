//
//  EmojiArtViewController.swift
//  EmojiArt
//
//  Created by Stephen Cao on 17/6/19.
//  Copyright © 2019 Stephencao Cao. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController {
    
    private var font: UIFont {
        return UIFontMetrics(forTextStyle: UIFont.TextStyle.body).scaledFont(for: UIFont.preferredFont(forTextStyle: .body).withSize(64.0))
    }
    var emojis = "👩🏻‍🏭🍙👢🎲🤜👘🦑😃👠😙🇺🇸🦈".map( { String($0)} )
    
    @IBOutlet weak var scrollViewConsWidth: NSLayoutConstraint!
    
    
    @IBOutlet weak var collectionView: UICollectionView!{
        didSet{
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.dragDelegate = self
            collectionView.dropDelegate = self
        }
    }
    
    @IBOutlet weak var scrollViewConsHeight: NSLayoutConstraint!
    var imageFetcher: ImageFetcher?
    @IBOutlet weak var dropZone: UIView!{
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
        }
    }
    var emojiArtView = EmojiArtView()
    
    @IBOutlet weak var scrollView: UIScrollView!{
        didSet{
            scrollView.minimumZoomScale = 0.1
            scrollView.maximumZoomScale = 5.0
            scrollView.delegate = self
            scrollView.addSubview(emojiArtView)
        }
    }
    
    var emojiBackgroundImage: UIImage?{
        get{
            return emojiArtView.backgroundImage
        }
        set{
            scrollView.zoomScale = 1.0
            emojiArtView.backgroundImage = newValue
            let size = newValue?.size ?? CGSize.zero
            emojiArtView.frame = CGRect(origin: CGPoint.zero, size: size)
            scrollView.contentSize = size
            scrollViewConsWidth?.constant = size.width
            scrollViewConsHeight?.constant = size.height
            if let dropZone = dropZone, size.width > 0, size.height > 0{
                scrollView.zoomScale = max(dropZone.bounds.size.width / size.width, dropZone.bounds.height / size.height)
            }
        }
    }
    private func dragItemsAtIndexPath(indexPath: IndexPath)->[UIDragItem]{
        if let attributedString = (collectionView.cellForItem(at: indexPath) as? EmojiCollectionViewCell)?.emojiLabel?.attributedText{
            let dragItem = UIDragItem(itemProvider: NSItemProvider(object: attributedString))
            dragItem.localObject = attributedString
            return [dragItem]
        }else{
            return []
        }
    }
}
extension EmojiArtViewController: UIDropInteractionDelegate{
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
    }
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        return UIDropProposal(operation: UIDropOperation.copy)
    }
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        imageFetcher = ImageFetcher { (url, image) in
            DispatchQueue.main.async(execute: {
                self.emojiBackgroundImage = image
            })
        }
        session.loadObjects(ofClass: NSURL.self) { (urls) in
            if let url = urls.first as? URL{
                self.imageFetcher?.fetch(url)
            }
        }
        session.loadObjects(ofClass: UIImage.self) { (images) in
            if let image = images.first as? UIImage{
                self.imageFetcher?.backup = image
            }
        }
    }
}

extension EmojiArtViewController: UIScrollViewDelegate{
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return emojiArtView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scrollViewConsWidth.constant = scrollView.contentSize.width
        scrollViewConsHeight.constant = scrollView.contentSize.height
    }
}
extension EmojiArtViewController:UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojis.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EmojiCell", for: indexPath) as! EmojiCollectionViewCell
        cell.emojiLabel.attributedText = NSAttributedString(string: emojis[indexPath.item], attributes: [NSAttributedString.Key.font : font])
        return cell
    }
}
extension EmojiArtViewController: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        session.localContext = collectionView
        return dragItemsAtIndexPath(indexPath: indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, itemsForAddingTo session: UIDragSession, at indexPath: IndexPath, point: CGPoint) -> [UIDragItem] {
        return dragItemsAtIndexPath(indexPath: indexPath)
    }
}
extension EmojiArtViewController: UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: NSAttributedString.self)
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        let isSelf = (session.localDragSession?.localContext as? UICollectionView) == collectionView
        return UICollectionViewDropProposal(operation: isSelf ? .move : .copy, intent: UICollectionViewDropProposal.Intent.insertAtDestinationIndexPath)
    }
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        let destionationIndexPath = coordinator.destinationIndexPath ?? IndexPath(item: 0, section: 0)
        for item in coordinator.items {
            if let sourceIndexPath = item.sourceIndexPath {
                if let attributeString = item.dragItem.localObject as? NSAttributedString {
                    collectionView.performBatchUpdates({
                        collectionView.deleteItems(at: [sourceIndexPath])
                        collectionView.insertItems(at: [destionationIndexPath])
                        emojis.remove(at: sourceIndexPath.item)
                        emojis.insert(attributeString.string, at: destionationIndexPath.item)
                    }) { (Bool) in
                        
                    }
                    coordinator.drop(item.dragItem, toItemAt: destionationIndexPath)
                }
            } else {
                let placeholderContext = coordinator.drop(item.dragItem, to: UICollectionViewDropPlaceholder(insertionIndexPath: destionationIndexPath, reuseIdentifier: "PlaceholderCell"))
                item.dragItem.itemProvider.loadObject(ofClass: NSAttributedString.self) { (provider, error) in
                    DispatchQueue.main.async {
                        if let attributeString = provider as? NSAttributedString {
                            placeholderContext.commitInsertion(dataSourceUpdates: { (insertionIndexPath) in
                                self.emojis.insert(attributeString.string, at: insertionIndexPath.item)
                            })
                        } else {
                            placeholderContext.deletePlaceholder()
                        }
                    }
                }
            }
        }
        
    }
    
    
}
