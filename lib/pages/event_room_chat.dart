import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lexi/pages/ChatScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class EventRoomChat extends StatefulWidget {
  final String userProfileId;

  EventRoomChat(this.userProfileId);

  @override
  _EventRoomChatState createState() => _EventRoomChatState();
}

class _EventRoomChatState extends State<EventRoomChat> {
  List<Map<String, String>> chats = [
    {
      "image": "https://images.ctfassets.net/denf86kkcx7r/57uYN7JlyDtQ91KvRldrm9/0a0656983993f5e09c4daa0a4fd8f5e6/comment-punir-son-chat-91?fm=webp&w=913",
      "name": "Chat de Eventos",
      "description": "Conversaciones sobre eventos interesantes."
    },
    {
      "image": "https://images.ctfassets.net/denf86kkcx7r/57uYN7JlyDtQ91KvRldrm9/0a0656983993f5e09c4daa0a4fd8f5e6/comment-punir-son-chat-91?fm=webp&w=913",
      "name": "Música y Festivales",
      "description": "Discusión sobre los últimos festivales."
    },
    {
      "image": "https://images.ctfassets.net/denf86kkcx7r/57uYN7JlyDtQ91KvRldrm9/0a0656983993f5e09c4daa0a4fd8f5e6/comment-punir-son-chat-91?fm=webp&w=913",
      "name": "Deportes",
      "description": "Charlas sobre eventos deportivos en vivo."
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chatrooms'),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(chats[index]["image"]!),
            ),
            title: Text(chats[index]["name"]!),
            subtitle: Text(chats[index]["description"]!),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(chats[index]["name"]!,"","",""),
                ),
              );
            },
          );
        },
      ),
    );
  }
}