import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:video_player/video_player.dart';
import 'package:video_provider/video_provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class ContentWidget extends StatefulWidget {
  const ContentWidget({
    Key key,
    @required this.submission,
  }) : super(key: key);

  final Submission submission;

  @override
  _ContentWidgetState createState() => _ContentWidgetState();
}

class _ContentWidgetState extends State<ContentWidget> with AutomaticKeepAliveClientMixin {

  bool _showSpoiler = false;
  bool _loadYouTube = false;
  bool _gifProviderReady = false;
  bool _videoReady = false;
  String _contentType = '';
  VideoPlayerController _controller;
  ChewieController _chewieController;
  YoutubePlayerController _ytController;
  Future<void> _initializeVideoPlayerFuture;

  @override
  void initState() {
    if(widget.submission.url.toString().contains('imgur.com') || widget.submission.url.toString().contains('gfycat.com')) {
      setState(() {
        this._contentType = 'GifProvider';
        this._prepareGifVideo();
      });
    } else  if(widget.submission.url.toString().endsWith('.gif')) {
      setState(() {
        this._contentType = 'Gif';
      });
    } else if(widget.submission.url.toString().contains('youtube.com') || widget.submission.url.toString().contains('youtu.be')) {
      setState(() {
        this._contentType = 'YouTube';
      });
    } else if(widget.submission.isVideo) {
      setState(() {
        this._contentType = 'Video';
        this._prepareVideo();
      });
    } else if(widget.submission.preview.length > 0) {      
      setState(() {
        this._contentType = 'Image';
      });
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  void _prepareGifVideo() async {
    List<Video> checkedUris = VideoProvider.fromUri(
    Uri.parse(widget.submission.url.toString()),
    ).getVideos();
    _controller = VideoPlayerController.network(
      checkedUris[0].uri.toString(),
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      aspectRatio: _controller.value.aspectRatio,
      allowFullScreen: false,
      looping: SettingsService.getKey('content_gif_loop'),
      autoInitialize: SettingsService.getKey('content_gif_preload'),
    );

    _initializeVideoPlayerFuture.then((_) {
      setState(() {
        this._gifProviderReady = true;
      });
      if(SettingsService.getKey('content_gif_autoplay')) 
        this._chewieController.play();
      this._chewieController.setVolume(0);
    });
  }

  void _prepareVideo() {
    _controller = VideoPlayerController.network(
      widget.submission.data['media']['reddit_video']['fallback_url']
    );

    this._initializeVideoPlayerFuture = _controller.initialize();

    this._chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      allowFullScreen: false,
      aspectRatio: widget.submission.data['media']['reddit_video']['width'] / widget.submission.data['media']['reddit_video']['height'],
      looping: SettingsService.getKey('content_video_loop'),
      autoInitialize: SettingsService.getKey('content_videos_preload'),
    );

    this._initializeVideoPlayerFuture.then((_) {
      setState(() {
        this._videoReady = true;
      });
      if(SettingsService.getKey('content_video_autoplay')) 
        this._chewieController.play();
      this._chewieController.setVolume(0);
    });


  }

  @override
  void dispose() {
    if(this._controller != null)
      this._controller.dispose();
    if(this._ytController != null)
      this._ytController.dispose();
    if(this._chewieController != null)
      this._chewieController.dispose();
    super.dispose();
  }

  Widget _getGifProvider() {
    return this._gifProviderReady ? Chewie(
      controller: _chewieController,
    ) : LinearProgressIndicator();
  }

  Widget _getImage() {
    String imageUrl = (widget.submission.preview.length > 0)
        ? widget.submission.preview.elementAt(0).source.url.toString()
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: GestureDetector(
        onTap: !this._showSpoiler ? () {
          setState(() {
            this._showSpoiler = true;
          });
        } : null,
        onLongPress: () {
          if(this._showSpoiler)
            setState(() {
              this._showSpoiler = false;
            });
        },
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          color: widget.submission.spoiler && !this._showSpoiler ? Color.lerp(Colors.black, Colors.redAccent, 0.5) : null,
          alignment: Alignment.center,
          fit: BoxFit.cover,
        ),
      )
    );
  }

  Widget _getGif() {
    return Image.network(widget.submission.url.toString());
  }

  Widget _getYouTube() {
    return this._loadYouTube ? YoutubePlayer(
      context: context,
      videoId: this._getYouTubeId(widget.submission.url.toString()),
      flags: YoutubePlayerFlags(
        autoPlay: SettingsService.getKey('content_youtube_autoplay'),
      ),
      key: Key(this._getYouTubeId(widget.submission.url.toString())),
      onPlayerInitialized: (controller) {
        _ytController = controller;
      },
    ) : Column(
      children: <Widget>[
        GestureDetector(
          child: Image.network(
              widget.submission.preview.length > 0 ? 
              widget.submission.preview[0].source.url.toString()
              : ''
            ),
          onTap: () {
            setState(() {
              this._loadYouTube = true;
            });
          },
        ),
        Text('Tap to load')
      ],
    );
  }

  String _getYouTubeId(String link) {
    link = link.replaceAll('https://', '').replaceAll('https://', '').replaceAll('&feature=youtu.be', '').replaceAll('www.', '');
    RegExp ytId = new RegExp('[a-zA-Z0-9}-]{11}');
    print(ytId.stringMatch(link));
    return ytId.stringMatch(link); 
  }

  Widget _getVideo() {
    return this._videoReady ? Chewie(
      controller: _chewieController)
    : LinearProgressIndicator();
  }
  
  @override
  Widget build(BuildContext context) {

    switch (this._contentType) {
      case 'GifProvider':
        return this._getGifProvider();
        break;
      case 'Image':
        return this._getImage();
        break;
      case 'Gif':
        return this._getGif();
        break;
      case 'YouTube':
        return this._getYouTube();
        break;
      case 'Video':
        return this._getVideo();
        break;
      default:
        return Container(width: 0, height: 0);
    }

  }

}
