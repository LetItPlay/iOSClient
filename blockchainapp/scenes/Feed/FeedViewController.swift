//
//  FeedViewController.swift
//  blockchainapp
//
//  Created by Ivan Gorbulin on 30/08/2017.
//  Copyright © 2017 Ivan Gorbulin. All rights reserved.
//

import UIKit
import SnapKit
import SwipeCellKit
import Crashlytics

enum FeedType {
	case feed, popular
}

class FeedViewController: UIViewController, UISearchBarDelegate {
	
	var viewModel: FeedVMProtocol!
    var emitter: FeedEmitterProtocol!
    
    var previousCell: FeedTableViewCell?
    var alertBlurView: UIVisualEffectView!
    var alertLabel: UILabel!
    
    var didSwipeCell: Bool = false
    
	let tableView = BaseTableView(frame: CGRect.zero, style: .grouped)

	let emptyLabel = EmptyLabel(title: LocalizedStrings.EmptyMessage.noFollows)
    let emptyButton = EmptyButton(title: LocalizedStrings.Button.toChannels)
    
    var tableProvider: TableProvider!
    
    convenience init(viewModel: FeedVMProtocol, emitter: FeedEmitterProtocol) {
        self.init(nibName: nil, bundle: nil)
        self.viewModel = viewModel
        self.viewModel.delegate = self
        
        self.tableProvider = TableProvider.init(tableView: self.tableView, dataProvider: self, cellProvider: self)
        self.tableProvider.cellEvent = { (indexPath, event, data) in
            switch event {
            case "onLike":
                self.emitter.send(event: TrackEvent.trackLiked(index: indexPath.item))
            case "onSelected":
                self.emitter.send(event: TrackEvent.trackSelected(index: indexPath.item))
            case "onChannel":
                self.emitter.send(event: TrackEvent.showChannel(index: indexPath.row))
                break
            case "onOthers":
                self.emitter.send(event: TrackEvent.showOthers(index: indexPath.row))
            default:
                break
            }
        }
        self.emitter = emitter
    }
	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitialize()
        
        self.emitter.send(event: LifeCycleEvent.initialize)
	}
    
    func viewInitialize()
    {
        navigationController?.navigationBar.prefersLargeTitles = false
        self.navigationItem.largeTitleDisplayMode = .automatic
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(onRefreshAction(refreshControl:)), for: .valueChanged)
        
        view.backgroundColor = UIColor.vaWhite
        
        self.view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        tableView.refreshControl = refreshControl
        
        tableView.register(FeedTableViewCell.self, forCellReuseIdentifier: FeedTableViewCell.cellID)
        tableView.backgroundView?.backgroundColor = .clear
        tableView.sectionIndexBackgroundColor = .clear
        
        self.view.backgroundColor = .white
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPress(longPressGestureRecognizer:)))
        tableView.addGestureRecognizer(longPressRecognizer)
        
        tableView.tableFooterView = UIView()
        
        self.view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.center.equalTo(self.view.center)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().inset(16)
        }
        self.view.addSubview(emptyButton)
        emptyButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(self.view)
            make.height.equalTo(32)
            make.top.equalTo(emptyLabel.snp.bottom).inset(-51)
        }
        emptyButton.addTarget(self, action: #selector(showAllChannels), for: .touchUpInside)
        
        self.tableView.refreshControl?.beginRefreshing()
        
        let searchItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(search))
        self.navigationItem.rightBarButtonItem = searchItem
    }
    
    @objc func search() {
        self.emitter.send(event: FeedEvent.showSearch)
    }
    
    @objc func showAllChannels() {
        emitter.send(event: FeedEvent.showAllChannels())
    }

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
        self.emitter.send(event: LifeCycleEvent.appear)
	}
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.emitter.send(event: LifeCycleEvent.disappear)
    }
    
    deinit {
        self.emitter.send(event: LifeCycleEvent.deinitialize)
    }
	
    @objc func onRefreshAction(refreshControl: UIRefreshControl) {
		self.emitter.send(event: TrackEvent.reload)
		DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {[weak self] in self?.tableView.refreshControl?.endRefreshing()})
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

  @objc func longPress(longPressGestureRecognizer: UILongPressGestureRecognizer) {
        
        if longPressGestureRecognizer.state == .began {
            let touchPoint = longPressGestureRecognizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath)
                if self.previousCell != nil,
                   self.previousCell != cell
                {
                    previousCell?.getInfo(toHide: true, animated: true)
                }
                if self.previousCell == cell
                {
                    previousCell = nil
                    (cell as! FeedTableViewCell).getInfo(toHide: true, animated: true)
                }
                else
                {
                    previousCell = cell as? FeedTableViewCell
                    (cell as! FeedTableViewCell).getInfo(toHide: false, animated: true)
                }
            }
        }
    }
    
    func addTrack(toBegining: Bool, for indexPath: IndexPath)
    {
        self.emitter.send(event: TrackEvent.addTrack(index: indexPath.row, toBeginning: toBegining))
		
		let cell = tableView.cellForRow(at: indexPath) as! FeedTableViewCell
		
		UIView.animate(withDuration: 0.3, animations: {
			cell.alertBlurView.alpha = 1
		})
		
		let when = DispatchTime.now() + 1
		DispatchQueue.main.asyncAfter(deadline: when){
			UIView.animate(withDuration: 0.3, animations:{
				cell.alertBlurView.alpha = 0
			})
		}
    }
}

extension FeedViewController: TrackHandlingViewModelDelegate {
    func reload(cells: [CollectionUpdate : [Int]]?) {
        tableView.beginUpdates()
        if let _ = cells, let keys = cells?.keys {
            for key in keys {
                if let indexes = cells?[key]?.map({IndexPath(row: $0, section: 0)}) {
                    switch key {
                    case .insert:
                        tableView.insertRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .delete:
                        tableView.deleteRows(at: indexes, with: UITableViewRowAnimation.none)
                    case .update:
                        if indexes.count != 0 {
                            tableView.reloadRows(at: indexes, with: UITableViewRowAnimation.none)
                        }
                    }
                }
            }
        }
        tableView.endUpdates()
        self.tableView.refreshControl?.endRefreshing()
    }
    
    func reloadAppearence() {
        emptyLabel.isHidden = !self.viewModel.showEmpty
        emptyButton.isHidden = !self.viewModel.showEmpty
    }
    
    func reload() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
    }
}

extension FeedViewController: FeedVMDelegate {
}

extension FeedViewController: TableDataProvider, TableCellProvider {
    
    var numberOfSections: Int {
        return 1
    }
    
    func rowsAt(_ section: Int) -> Int {
        return self.viewModel.data.count
    }
    
    func data(indexPath: IndexPath) -> Any {
        return self.viewModel.data[indexPath.item]
    }
    
    func cellClass(indexPath: IndexPath) -> StandartTableViewCell.Type {
        return FeedTableViewCell.self
    }
    
    func config(cell: StandartTableViewCell) {
        (cell as? SwipeTableViewCell)?.delegate = self
    }
}

extension FeedViewController: SwipeTableViewCellDelegate
{
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        var toBeginning: Bool!
        var image: UIImage!
        
        let myView = UIView(frame: CGRect(x: 0, y: 0, width: 150, height: 305))
        let myLabel = UILabel()
        myLabel.textColor = .white
        myLabel.font = AppFont.Title.big
        myLabel.lineBreakMode = .byWordWrapping
        myLabel.numberOfLines = 0
        
        if orientation == .left
        {
            image = UIImage(named: "illustrationTop")
            toBeginning = true
            
            let imageView = UIImageView(image: image)
            myView.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().inset(10)
                make.centerY.equalToSuperview()
            }
            
            myLabel.text = LocalizedStrings.Button.addTrackToPlaylist.top
            myLabel.textAlignment = .right
            myView.addSubview(myLabel)
            myLabel.snp.makeConstraints { (make) in
                make.right.equalTo(-47)
                make.centerY.equalToSuperview().inset(-10)
            }
        }
        else
        {
            image = UIImage(named: "illustrationBottom")
            toBeginning = false
            
            let imageView = UIImageView(image: image)
            myView.addSubview(imageView)
            imageView.snp.makeConstraints { (make) in
                make.left.equalTo(10)
                make.centerY.equalToSuperview()
            }
            
            myLabel.text = LocalizedStrings.Button.addTrackToPlaylist.bottom
            myLabel.textAlignment = .left
            myView.addSubview(myLabel)
            myLabel.snp.makeConstraints { (make) in
                make.left.equalTo(47)
                make.centerY.equalToSuperview().inset(-10)
            }
        }
        
        let addToPlaylistAction = SwipeAction(style: .default, title: "", handler: { action, indexPath in
            self.addTrack(toBegining: toBeginning, for: indexPath)
        })

        addToPlaylistAction.customView = myView
        addToPlaylistAction.backgroundColor = .clear
        
        addToPlaylistAction.fixCenterForItems = 10
        
        return [addToPlaylistAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        
        self.didSwipeCell = true
        
        let customSwipeStyle = SwipeExpansionStyle(target: .percentage(0.25), additionalTriggers: [.overscroll(50)], elasticOverscroll: false, completionAnimation: .bounce)
        
        var options = SwipeTableOptions()
        options.expansionStyle = customSwipeStyle
        options.transitionStyle = .border
        options.maximumButtonWidth = 300
        options.minimumButtonWidth = 150
        options.backgroundColor = .white
        
        let fromColor = AppColor.Element.redBlur.withAlphaComponent(orientation == .right ? 0.9 : 0).cgColor
        let toColor = AppColor.Element.redBlur.withAlphaComponent(orientation == .right ? 0 : 0.9).cgColor
        
        var frame: CGRect!
		
		let vm = self.viewModel.data[indexPath.item]
		let height =  FeedTableViewCell.height(data: vm, width: tableView.frame.width)
		
        if orientation == .right
        {
            frame = CGRect(x: 0, y: 25, width: 200, height: height-25)
        }
        else
        {
            frame = CGRect(x: -50, y: 25, width: 200, height: height-25)
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [fromColor, toColor]
        gradientLayer.startPoint = CGPoint.init(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 0.5)
        gradientLayer.frame = frame
        gradientLayer.cornerRadius = 10
        
        options.showGradient = gradientLayer
        
        return options
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?, for orientation: SwipeActionsOrientation) {
        self.didSwipeCell = false
    }
}

