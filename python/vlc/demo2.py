import vlc

Instance = vlc.Instance()
player = Instance.media_player_new()
Media = Instance.media_new('F:/test.mp4')
Media.get_mrl()
player.set_media(Media)
player.play()

