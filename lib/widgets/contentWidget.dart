import 'dart:async';
import 'dart:convert';

import 'package:chewie/chewie.dart';
import 'package:connectivity/connectivity.dart';
import 'package:draw/draw.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:openReddit/services/infoService.dart';
import 'package:openReddit/services/settingsService.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';
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
  String _gifUrl = '';
  double _aspectRatio = 1;
  VideoPlayerController _controller;
  ChewieController _chewieController;
  YoutubePlayerController _ytController;

  @override
  void initState() {
    print(widget.submission.url);
    if(
      (widget.submission.url.toString().contains('imgur.com') || widget.submission.url.toString().contains('gfycat.com')) && 
      !widget.submission.url.toString().contains('.jpg') && !widget.submission.url.toString().contains('.png') 
    ) {
      setState(() {
        this._prepareGifVideo();
        this._contentType = 'GifProvider';
      });
    } else  if(widget.submission.url.toString().endsWith('.gif') || widget.submission.url.toString().endsWith('.gifv')) {
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
    } else if(widget.submission.url.toString().endsWith('.jpg') || widget.submission.url.toString().endsWith('.png') || widget.submission.preview.length > 0) {      
      setState(() {
        this._contentType = 'Image';
      });
    }
    super.initState();
  }

  @override
  bool get wantKeepAlive => false;

  void _prepareGifVideo() async {

    if(widget.submission.url.host.contains('imgur')) {
      _gifUrl = widget.submission.url.toString().replaceAll('.gifv', '.mp4').replaceAll('.gif', '.mp4');
      print('https://api.imgur.com/3/image/' + widget.submission.url.path.replaceAll('/', '').replaceAll('.gifv', '').replaceAll('.gif', ''));
      Map<String, dynamic> data = json.decode((await get('https://api.imgur.com/3/image/' + widget.submission.url.path.replaceAll('/', '').replaceAll('.gifv', '').replaceAll('.gif', ''))).body);
      try {
        _aspectRatio = data['data']['width'] / data['data']['height'];
      } catch (e) {
        _aspectRatio = 1;
      }
    } else if(widget.submission.url.host.contains('gfycat')) {
      Map<String, dynamic> data = json.decode((await get('https://api.gfycat.com/v1/gfycats/' + widget.submission.url.path.split('-')[0])).body);
      _gifUrl = data['gfyItem']['mp4Url'];
      try {
        _aspectRatio = data['gfyItem']['width'] / data['gfyItem']['height'];
      } catch (e) {
        _aspectRatio = 1;
      }
    }

    _controller = VideoPlayerController.network(
      _gifUrl
    )..initialize().then((_) {
      if(mounted)
        setState(() {
          this._gifProviderReady = true;
        });
        _controller.setLooping(true);
        _controller.play();
    });

    // this._chewieController = ChewieController(
    //   videoPlayerController: _controller,
    //   autoPlay: true,
    //   allowFullScreen: false,
    //   showControls: true,
    //   aspectRatio: aspectRatio,
    //   looping: SettingsService.getKey('content_gifs_loop'),
    //   autoInitialize: SettingsService.getKey('content_gifs_preload'),
    // );
  }

  void _prepareVideo() {
    _controller = VideoPlayerController.network(
      widget.submission.data['media']['reddit_video']['fallback_url']
    );

    this._chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      allowFullScreen: false,
      aspectRatio: widget.submission.data['media']['reddit_video']['width'] / widget.submission.data['media']['reddit_video']['height'],
      looping: SettingsService.getKey('content_videos_loop'),
      autoInitialize: SettingsService.getKey('content_videos_preload'),
    );
    setState(() {
      this._videoReady = true;
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

  Widget _getGifProviderWidget() {
    if(
      SettingsService.getKey('content_gifs_load') == 'Always' ||
      (SettingsService.getKey('content_gifs_load') == 'WiFi' && InfoService.connectivity == ConnectivityResult.wifi)
    ) {
      return this._gifProviderReady && _controller.value.initialized ?
      // Chewie(controller: _chewieController)
      AspectRatio(
        aspectRatio: _controller.value.aspectRatio,
        child: VideoPlayer(_controller),
      )
      : LinearProgressIndicator();
    } else {
      return Container(
        child: Center(
          child: 
            SettingsService.getKey('content_gifs_load') == 'WiFi' ?
            Text('You only enabled gifs while beeing connected to WiFi') :
            Text('You disabled gifs in the settings'),
        ),
      );
    }   
  }

  Widget _getImageWidget() {
    String imageUrl = '';

    if(widget.submission.url.toString().endsWith('.jpg') || widget.submission.url.toString().endsWith('.png')) {
      imageUrl = widget.submission.url.toString();
    } else {
      imageUrl = widget.submission.preview.last.source.url.toString();
    }

    if(
      SettingsService.getKey('content_images_load') == 'Always' ||
      (SettingsService.getKey('content_images_load') == 'WiFi' && InfoService.connectivity == ConnectivityResult.wifi)
    ) {
      return GestureDetector(
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
        child: 
        ExtendedImage.network(
          imageUrl,
          cache: true,
          retries: 3,
        )
        // FadeInImage.memoryNetwork(
        //   placeholder: kTransparentImage,
        //   image: imageUrl,
        // ),
      );
    } else {
      return Container(
        child: Center(
          child: 
            SettingsService.getKey('content_images_load') == 'WiFi' ?
            Text('You only enabled images while beeing connected to WiFi') :
            Text('You disabled images in the settings'),
        ),
      );
    }   
  }

  Widget _getGifWidget() {
    if(
      SettingsService.getKey('content_gifs_load') == 'Always' ||
      (SettingsService.getKey('content_gifs_load') == 'WiFi' && InfoService.connectivity == ConnectivityResult.wifi)
    ) {
      return Image.network(
        widget.submission.url.toString().replaceAll('.gifv', '.gifv'),
      );
    } else {
      return Container(
        child: Center(
          child: 
            SettingsService.getKey('content_gifs_load') == 'WiFi' ?
            Text('You only enabled gifs while beeing connected to WiFi') :
            Text('You disabled gifs in the settings'),
        ),
      );
    }  
  }

  Widget _getYouTubeWidget() {
    if(
      SettingsService.getKey('content_youtube_load') == 'Always' ||
      (SettingsService.getKey('content_youtube_load') == 'WiFi' && InfoService.connectivity == ConnectivityResult.wifi)
    ) {
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
    } else {
      return Container(
        child: Center(
          child: 
            SettingsService.getKey('content_youtube_load') == 'WiFi' ?
            Text('You only enabled Youtube videos while beeing connected to WiFi') :
            Text('You disabled Youtube videos in the settings'),
        ),
      );
    }
  }

  String _getYouTubeId(String link) {
    link = link.replaceAll('https://', '').replaceAll('https://', '').replaceAll('&feature=youtu.be', '').replaceAll('www.', '');
    RegExp ytId = new RegExp('[a-zA-Z0-9}-]{11}');
    return ytId.stringMatch(link); 
  }

  Widget _getVideoWidget() {
    if(
      SettingsService.getKey('content_videos_load') == 'Always' ||
      (SettingsService.getKey('content_videos_load') == 'WiFi' && InfoService.connectivity == ConnectivityResult.wifi)
    ) {
    return this._videoReady ? Chewie(
      controller: _chewieController)
    : LinearProgressIndicator();
    } else {
      return Container(
        child: Center(
          child: 
            SettingsService.getKey('content_videos_load') == 'WiFi' ?
            Text('You only enabled videos while beeing connected to WiFi') :
            Text('You disabled videos in the settings'),
        ),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);

    Widget content;

    switch (this._contentType) {
      case 'GifProvider':
        content = this._getGifProviderWidget();
        break;
      case 'Image':
        content = this._getImageWidget();
        break;
      case 'Gif':
        content = this._getGifWidget();
        break;
      case 'YouTube':
        content = this._getYouTubeWidget();
        break;
      case 'Video':
        content = this._getVideoWidget();
        break;
      default:
        return Container(width: 0, height: 0);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: content,
    );

  }

}
