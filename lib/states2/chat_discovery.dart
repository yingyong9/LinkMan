// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

class ChatDiscovery extends StatefulWidget {
  final String docIdFastLink;
  const ChatDiscovery({
    Key? key,
    required this.docIdFastLink,
  }) : super(key: key);

  @override
  State<ChatDiscovery> createState() => _ChatDiscoveryState();
}

class _ChatDiscoveryState extends State<ChatDiscovery> {
  String? docIdFastLink;

  @override
  void initState() {
    super.initState();
    docIdFastLink = widget.docIdFastLink;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
    );
  }
}
