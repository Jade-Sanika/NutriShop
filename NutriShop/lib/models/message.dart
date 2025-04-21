class Message {
  final String text;
  final bool isUser;
  final bool isMarkdown;

  Message(this.text, this.isUser, {this.isMarkdown = false});
}