// dart pub add xpath_selector
// dart pub add xpath_selector_html_parser
// dart pub add html

// import 'package:html/parser.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

final String htmlString = '''
<html lang="en">
<body>
<div><a href='https://github.com/simonkimi'>author</a></div>
<div class="head">div head</div>
<div class="container">
    <table>
        <tbody>
          <tr>
              <td id="td1" class="first1">1</td>
              <td id="td2" class="first1">2</td>
              <td id="td3" class="first2">3</td>
              <td id="td4" class="first2 form">4</td>
              <td id="td5" class="second1">one</td>
              <td id="td6" class="second1">two</td>
              <td id="td7" class="second2">three</td>
              <td id="td8" class="second2">four</td>
          </tr>
        </tbody>
    </table>
</div>
<div class="end">end</div>
</body>
</html>
''';

void main() {
  // final html1 = parse(htmlString).documentElement!;
  // final html2 = HtmlXPath.node(html1);
  final html = HtmlXPath.html(htmlString);

  // print(html1.queryXPath('//div/a'));
  // print(html2.query('//div/a/@href').attrs);
  print(html.queryXPath('//div/a'));
  print(html.query('//div/a/@href').attrs);
  print(html.query('//tr/td[@class^="fir" and not(text()="4")]'));
  for (final node
      in html.query('//tr/td[@class^="fir" and not(text()="4")]').nodes) {
    print(node.text);
  }
}


// web scraper
// https://chrome.google.com/webstore/detail/web-scraper-free-web-scra/jnhgnonknehpejjnehehllkliplmbmhn

// html -> (json schema) -> json

// root:
//   - root:
//     - { xpath: name: 

//   - nodes
//     [
//       {xpath, name, leafs: [], multi: false},
//     ]
//   - leafs
//     [
//        {xpath: "", name: "", leaf: "", multi: false},
//     ]



// leaf: text, content, href, @attr