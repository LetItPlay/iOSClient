protocol TrackInfoDelegate: class {
    func update(track: Track)
}

protocol PlaylistModelDelegate: class {
    func reload(tracks: [TrackViewModel], count: String, length: String)
    func update(track: TrackViewModel, asIndex index: Int)
    func re(name: String)
}

protocol MainPlayerModelDelegate: class {
    func showSpeedSettings()
    func showMoreDialog()
    func player(show: Bool)
}

protocol PlayerModelDelegate: class {
    func update(status: [PlayerControlsStatus : Bool])
    func update(progress: Float, currentTime: String, leftTime: String)
    func update(track: TrackViewModel)
}
