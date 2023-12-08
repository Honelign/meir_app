import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:news_app/blocs/theme_bloc.dart';
import 'package:news_app/models/custom_color.dart';
import 'package:news_app/services/app_service.dart';
import 'package:news_app/utils/next_screen.dart';
import 'package:news_app/widgets/full_image.dart';
import 'package:news_app/widgets/iframe_player_widget.dart';
import 'package:news_app/widgets/local_video_player.dart';
import 'package:provider/provider.dart';

  // final String demoText = "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>" + 
  // //'''<iframe width="560" height="315" src="https://www.youtube.com/embed/-WRzl9L4z3g" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>'''+
  // //'''<video controls src="https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4"></video>''' +
  // //'''<iframe src="https://player.vimeo.com/video/226053498?h=a1599a8ee9" width="640" height="360" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>''' +
  // "<p>Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s</p>";

class HtmlBodyWidget extends StatelessWidget {

  final String content;
  final bool isVideoEnabled;
  final bool isimageEnabled;
  final bool isIframeVideoEnabled;
  final double? fontSize;

  
  const HtmlBodyWidget({
    Key? key,
    required this.content, required this.isVideoEnabled, required this.isimageEnabled, required this.isIframeVideoEnabled, this.fontSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Html(
        data: '''$content''',
        onLinkTap: (url, attributes, element) {
          AppService().openLinkWithCustomTab(context, url!);
        },


      /*child: Html(
        data: '''$content''',
        onLinkTap: (url, attributes, element) {
          AppService().openLinkWithCustomTab(context, url!);
        },*/
    /*child: SelectableHtml(
    data: '''$content''',
    onLinkTap: (String? url, RenderContext context1,Map<String, String> attributes, _) {
    AppService().openLinkWithCustomTab(context, url!);
    },*/


/*
        onImageTap: (String? url, RenderContext context1,Map<String, String> attributes, _) {
          nextScreen(context, FullScreenImage(imageUrl: url!));
        },
*/

        style: {
          "body": Style(
            margin: Margins.zero,
            padding: HtmlPaddings.zero,

            //Enable the below line and disble the upper line to disble full width image/video

            //padding: EdgeInsets.all(20),

            fontSize: fontSize == null ? FontSize(18.0) : FontSize(16.0),
            lineHeight: LineHeight(1.7),
            fontFamily: 'Open Sans',
            fontWeight: FontWeight.w400,
            color: context.watch<ThemeBloc>().darkTheme == false
              ? CustomColor().bodyTextColorLight
              : CustomColor().bodyTextColorDark,
          ),
          "figure": Style(margin: Margins.zero, padding: HtmlPaddings.zero),

          //Disable this line to disble full width image/video
          "p,h1,h2,h3,h4,h5,h6": Style(margin: Margins.all(20)),
        },
/*
        customRender: {

          "img": (RenderContext context1, Widget child){
            final String _imageSource = context1.tree.element!.attributes['src'].toString();
            if(isimageEnabled == false) return Container();
            return InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 10,bottom: 10),
                child: CachedNetworkImage(imageUrl: _imageSource)),
              onTap: ()=> nextScreen(context, FullScreenImage(imageUrl: _imageSource)),
            );
          },

          "video": (RenderContext context1, Widget child) {
            final String _videoSource = context1.tree.element!.attributes['src'].toString();
            if(isVideoEnabled == false) return Container();
            return LocalVideoPlayer(videoUrl: _videoSource);
          },

          "iframe": (RenderContext context1, Widget child) {
            final String _videoSource = context1.tree.element!.attributes['src'].toString();
            if(isIframeVideoEnabled == false) return Container();
            if(_videoSource.contains('youtube')){
              return IframePlayerWidget(youtubeVideoUrl: _videoSource);
            }else if(_videoSource.contains('vimeo')){

            }

          },
        },
*/
      ),
    );
  }
}
