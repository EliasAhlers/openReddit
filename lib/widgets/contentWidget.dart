import 'package:cached_network_image/cached_network_image.dart';
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
  String _contentType = '';
  VideoPlayerController _controller;
  YoutubePlayerController _ytController;
  Future<void> _initializeVideoPlayerFuture;
  bool _gifProviderReady = false;
  bool _videoReady = false;
  
  @override
  void initState() {
    if(widget.submission.url.toString().contains('imgur') || widget.submission.url.toString().contains('gfycat')) {
      setState(() {
        this._contentType = 'GifProvider';
      });
      this._prepareGifVideo();
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
      });
      this._prepareVideo();
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
    List<Video> checkedUris = await CheckedVideoProvider.fromUri(
    Uri.parse(widget.submission.url.toString()),
    ).getVideos().toList();
    _controller = VideoPlayerController.network(
      checkedUris[0].uri.toString(),
    );

    _initializeVideoPlayerFuture = _controller.initialize();
    _initializeVideoPlayerFuture.then((_) {
      setState(() {
        this._gifProviderReady = true;
      });
      if(SettingsService.getKey('post_gif_loop'))
        _controller.setLooping(true);
      if(SettingsService.getKey('post_gif_autoplay'))
        _controller.play();
    });
  }

  void _prepareVideo() {
    String url = widget.submission.data['media']['reddit_video']['fallback_url'];
    _controller = VideoPlayerController.network(
      url
    );

    this._initializeVideoPlayerFuture = _controller.initialize();
    this._initializeVideoPlayerFuture.then((_) {
      setState(() {
        this._videoReady = true;
      });
      this._controller.play();
      this._controller.setVolume(0);
    });
  }

  @override
  void dispose() {
    if(this._controller != null)
    this._controller.dispose();
    if(this._ytController != null)
    this._ytController.dispose();
    super.dispose();
  }

  Widget _getGifProvider() {
    return this._gifProviderReady ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    ) : LinearProgressIndicator();
  }

  Widget _getImage() {
    String imageUrl = (widget.submission.preview.length > 0)
        ? widget.submission.preview.elementAt(0).source.url.toString()
        : '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        color: widget.submission.spoiler && !this._showSpoiler ? Color.lerp(Colors.black, Colors.redAccent, 0.5) : null,
        alignment: Alignment.center,
        fit: BoxFit.cover,
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
        autoPlay: true,
      ),
      key: Key(this._getYouTubeId(widget.submission.url.toString())),
      onPlayerInitialized: (controller) {
        _ytController = controller;
      },
    ) : Column(
      children: <Widget>[
        GestureDetector(
          child: Image.network(widget.submission.preview[0].source.url.toString()),
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
    return this._videoReady ? AspectRatio(
      aspectRatio: _controller.value.aspectRatio,
      child: VideoPlayer(_controller),
    ) : LinearProgressIndicator();
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
