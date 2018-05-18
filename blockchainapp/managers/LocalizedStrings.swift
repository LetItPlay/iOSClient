//
//  LocalizedStrings.swift
//  blockchainapp
//
//  Created by Polina Abrosimova on 17.05.2018.
//  Copyright © 2018 Ivan Gorbulin. All rights reserved.
//

import Foundation

struct LocalizedStrings {
    static let search = NSLocalizedString("search", comment: "search")
    
    struct TabBar {
        static let feed = NSLocalizedString("tab.feed", comment: "feed")
        static let trends = NSLocalizedString("tab.trends", comment: "trends")
        static let playlists = NSLocalizedString("tab.playlists", comment: "playlists")
        static let channels = NSLocalizedString("tab.channels", comment: "channels")
        static let profile = NSLocalizedString("tab.profile", comment: "profile")
    }
    
    struct Others {
        static let share = NSLocalizedString("others.share", comment: "share")
        static let report = NSLocalizedString("others.report", comment: "report")
        static let reportOn = NSLocalizedString("others.report_on", comment: "report on title")
        static let notShow = NSLocalizedString("others.not_show", comment: "not to show channel")
        static let notShowDescription = NSLocalizedString("others.not_show_desctiption", comment: "description of channel not showing")
        static let showHiddenChannels = NSLocalizedString("others.show_hidden_channels", comment: "show hidden channels")
        
        struct Reports {
            static let spam = NSLocalizedString("others.reports.spam", comment: "spam")
            static let adultContent = NSLocalizedString("others.reports.adult_content", comment: "adult content")
            static let cruelContent = NSLocalizedString("others.reports.cruel_content", comment: "cruel content")
        }
    }
    
    struct Playlists {
        static let playlist = NSLocalizedString("playlists.playlist", comment: "playlist")
        static let myPlaylist = NSLocalizedString("playlists.my_playlist", comment: "my playlist")
        static let recommended = NSLocalizedString("playlists.recommended", comment: "recommended")
        static let recommendedTitle = NSLocalizedString("playlists.recommendedTitle", comment: "title of recommended playlist")
        static let recommendedDescription = NSLocalizedString("playlists.recommendedDescription", comment: "description of recommended playlist")
        static let clearAll = NSLocalizedString("playlists.clearAll", comment: "clear all")
        static let currentPlaylist = NSLocalizedString("playlists.current", comment: "current playlist")
    }
    
    struct Channels {
        static let channel = NSLocalizedString("channels.channel", comment: "channel")
        static let categories = NSLocalizedString("channels.categories", comment: "categories")
        static let category = NSLocalizedString("chanenls.category", comment: "category")
        static let hidden = NSLocalizedString("channels.hidden", comment: "hidden channels")
        static let recent = NSLocalizedString("channels.recent", comment: "recent added")
        static let seeAll = NSLocalizedString("channels.seeAll", comment: "see all")
        static let subscibedTitle = NSLocalizedString("channels.subsribedTitle", comment: "subscribed channels")
        static let youSubscribed = NSLocalizedString("channels.you_subscribed", comment: "you are subscribed")
    }
    
    struct TrackSpeed {
        static let message = NSLocalizedString("track_speed.message", comment: "speed of audio")
    }
    
    struct Profile {
        static let camera = NSLocalizedString("profile.camera", comment: "camera")
        static let gallery = NSLocalizedString("profile.gallery", comment: "gallery")
        static let changeLanguage = NSLocalizedString("profile.change_language", comment: "change content language")
        static let selectLanguageTitle = NSLocalizedString("profile.select_lang_title", comment: "select language title")
        static let chooseImage = NSLocalizedString("profile.choose_image", comment: "choose image")
        static let name = NSLocalizedString("profile.name", comment: "name")
        static let likedTracks = NSLocalizedString("profile.liked_tracks", comment: "tracks you've liked")
        static let like = NSLocalizedString("profile.like", comment: "like")
    }
    
    struct Button {
        static let follow = NSLocalizedString("button.follow", comment: "follow")
        static let following = NSLocalizedString("button.following", comment: "following")
        static let show = NSLocalizedString("button.show", comment: "show")
        static let toChannels = NSLocalizedString("button.to_channels", comment: "browse channels list")
        
        struct addTrackToPlaylist {
            static let top = NSLocalizedString("button.add_track_to_playlist.top", comment: "add to the top")
            static let bottom = NSLocalizedString("button.add_track_to_playlist.bottom", comment: "add to the bottom")
        }
    }
    
    struct Player {
        static let playingNow = NSLocalizedString("player.playing_now", comment: "playing now")
    }
    
    struct TimeAgo {
        static let ago = NSLocalizedString("time_ago.ago", comment: "ago")
        static let week = NSLocalizedString("time_ago.w", comment: "week")
        static let weekAgo = NSLocalizedString("time_ago.w_ago", comment: "week ago")
        static let day = NSLocalizedString("time_ago.d", comment: "day")
        static let dayAgo = NSLocalizedString("time_ago.d_ago", comment: "day ago")
        static let hour = NSLocalizedString("time_ago.h", comment: "hour")
        static let hourAgo = NSLocalizedString("time_ago.h_ago", comment: "hour ago")
        static let minute = NSLocalizedString("time_ago.m", comment: "minute")
        static let minuteAgo = NSLocalizedString("time_ago.m_ago", comment: "minute ago")
        static let second = NSLocalizedString("time_ago.s", comment: "second")
        static let secondAgo = NSLocalizedString("time_ago.s_ago", comment: "second ago")
    }
    
    struct EmptyMessage {
        static let noChannels = NSLocalizedString("empty_message.no_channels", comment: "no channels")
        static let noRecommendations = NSLocalizedString("empty_message.no_recommendations", comment: "no recommendations")
        static let noTracks = NSLocalizedString("empty_message.no_tracks", comment: "no tracks")
        static let noFollows = NSLocalizedString("empty_message.noFollows", comment: "no follows")
        static let noDescription = NSLocalizedString("empty_message.no_desc", comment: "no description")
    }
    
    struct AlertMessage {
        static let trackAdded = NSLocalizedString("alert_message.track_added", comment: "track added")
    }
    
    struct SystemMessage {
        static let cancel = NSLocalizedString("system_message.cancel", comment: "cancel")
        static let ok = NSLocalizedString("system_message.ok", comment: "ok")
        static let defaultMessage = NSLocalizedString("system_message.default", comment: "default")
        static let delete = NSLocalizedString("system_message.delete", comment: "delete")
        static let remove = NSLocalizedString("system_message.remove", comment: "remove")
    }
}
