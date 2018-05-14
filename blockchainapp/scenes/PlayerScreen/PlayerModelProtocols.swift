protocol TrackInfoDelegate: class {
    func update(track: Track)
}

protocol PlaylistModelDelegate: class {
    func reload(tracks: [TrackViewModel], count: String, length: String)
    func update(dict: [Int: TrackViewModel])
    func re(name: String)
}

protocol MainPlayerModelDelegate: class {
    func showSpeedSettings()
    func showMoreDialog(track: ShareInfo)
    func player(show: Bool)
    func miniplayer(show: Bool, animated: Bool, direction: HideMiniPlayerDirection)
}

protocol PlayerModelDelegate: class {
    func update(status: [PlayerControlsStatus : Bool])
    func update(progress: Float, currentTime: String, leftTime: String)
    func update(track: TrackViewModel)
    func update(speeds: [String])
    func update(currentSpeedIndex: Int)
}
