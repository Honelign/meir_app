import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

class DynamicLinkProvider {

  Future<String> createLink(String articleId) async {
    final String url = "https://meireliyahu.ace?article_id=$articleId";
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      link: Uri.parse(url),
      uriPrefix: "https://meireliyahu.page.link",
      androidParameters: AndroidParameters(packageName: 'meireliyahu.ace'),
      iosParameters: IOSParameters(bundleId: 'meireliyahu.ace', minimumVersion: "0", appStoreId: '1625080404'),
    );

    final FirebaseDynamicLinks link = FirebaseDynamicLinks.instance;
    final refLink = await link.buildShortLink(parameters);

    return refLink.shortUrl.toString();
  }
}
