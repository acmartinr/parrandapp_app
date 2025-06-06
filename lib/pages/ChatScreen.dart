import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lexi/Helper/PushNotificationService.dart';
import 'package:lexi/components/MessageText.dart';
import 'package:lexi/utils/notification_singleton.dart';
import 'package:lexi/utils/util.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatScreen extends StatefulWidget {
  final String chatName;
  final String groupId;
  final String userId;
  final String profileImageUrl;

  ChatScreen(this.chatName, this.groupId, this.userId, this.profileImageUrl);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final int timestamp = DateTime.now().millisecondsSinceEpoch;
  String name = "";
  String lastname = "";
  final TextEditingController _messageController = TextEditingController();
  String defaultMyAvatar = '';
  final ScrollController _scrollController = ScrollController();
  bool _showScrollToBottomButton = false;

  @override
  void initState() {
    super.initState();
    NotificationSingleton().setLikedEventsChatActive(true);
    _loadProfile();
    NotificationSingleton().setMessagePageActive(true);
    NotificationSingleton().setCurrentEvent(widget.groupId);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    // offset > 20 (o el umbral que elijas) significa que ya no estás en el fondo.
    if (_scrollController.offset > 20 && !_showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = true;
      });
    } else if (_scrollController.offset <= 20 && _showScrollToBottomButton) {
      setState(() {
        _showScrollToBottomButton = false;
      });
    }
  }

  @override
  void dispose() {
    NotificationSingleton().setLikedEventsChatActive(false);
    NotificationSingleton().setMessagePageActive(false);
    _scrollController.dispose();
    NotificationSingleton().setCurrentEvent("");
    super.dispose();
  }

  void _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    name = (prefs.getString('name') ?? '').trim();
    lastname = (prefs.getString('lastname') ?? '').trim();
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    try {
      _messageController.clear();
      _scrollController.animateTo(
        0.0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      await FirebaseFirestore.instance.collection(widget.groupId).add({
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'sender_id': widget.userId,
        'name': '$name $lastname',
        'img': widget.profileImageUrl,
      });

      final apiService = PushNotificationService(baseUrl: Utils.baseUrl);
      await apiService.sendMessage(
          text, widget.chatName, widget.groupId, widget.userId);
    } catch (e) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to send message. Please try again.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.chatName,
          style: TextStyle(
            color: Color(0xFF1D1B20),
            fontFamily: 'SourceSansProBold',
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/back.png', height: 17),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/fondo.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Usamos un Stack para superponer el botón sobre la columna de mensajes
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection(widget.groupId)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;
                      final totalItems = docs.length + 1;
                      return NotificationListener<ScrollNotification>(
                        onNotification: (notification) {
                          // 2) Comprobar cuánto se desplazó el ListView
                          //    Con reverse:true, pixels=0 → fondo; pixels > 20 → usuario subió un poco.
                          if (notification.metrics.pixels > 20 &&
                              !_showScrollToBottomButton) {
                            setState(() {
                              _showScrollToBottomButton = true;
                            });
                          } else if (notification.metrics.pixels <= 20 &&
                              _showScrollToBottomButton) {
                            setState(() {
                              _showScrollToBottomButton = false;
                            });
                          }
                          return false; // no interfiere con el scroll normal
                        },
                        child: ListView.builder(
                          controller: _scrollController,
                          reverse: true,
                          itemCount: totalItems,
                          itemBuilder: (ctx, i) {
                            if (i == docs.length) {
                              return MessageText(
                                text:
                                    "¡Bienvenido al chat $name! Aquí podrás charlar con las demás personas que les gustó el evento de '" +
                                        widget.chatName +
                                        "'. Pregunta y opina sobre el mismo.",
                                isSentByMe: false,
                                senderName: "Parrandapp",
                                avatarUrl: "ss",
                                time: "23:23",
                                adminMessage: true,
                              );
                            }
                            final message = docs[i];
                            final senderId = message['sender_id'] as String;
                            String avatarUrl;

                            if (senderId == widget.userId) {
                              avatarUrl = widget.profileImageUrl.isNotEmpty
                                  ? '${Utils.baseUrlImage}uploads/${widget.profileImageUrl}?cb=$timestamp'
                                  : defaultMyAvatar;
                            } else {
                              final imgRec = message['img'] ?? '';
                              avatarUrl = imgRec.isNotEmpty
                                  ? '${Utils.baseUrlImage}uploads/$imgRec?cb=$timestamp'
                                  : defaultMyAvatar;
                            }

                            return MessageText(
                              text: message['text'] as String,
                              isSentByMe: senderId == widget.userId,
                              senderName: senderId == widget.userId
                                  ? '$name $lastname'
                                  : (message['name'] as String),
                              avatarUrl: avatarUrl,
                              time: "23:23",
                              adminMessage: false,
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                _buildMessageInput(),
              ],
            ),

            // Si _showScrollToBottomButton es true, mostramos el botón encima del input
            if (_showScrollToBottomButton)
              Positioned(
                bottom: 70, // Ajusta según el alto de tu input
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    // Al pulsarlo, volvemos al fondo y ocultamos el botón
                    _scrollController.animateTo(
                      0.0,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    setState(() {
                      _showScrollToBottomButton = false;
                    });
                  },
                  child: Container(
                    height: 40,
                    width: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey, // verde WhatsApp
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: 'Escribe un mensaje...',
                // Borde por defecto (cuando no está enfocado)
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Color(0xFFADACCA), width: 1.5),
                ),
                // Borde cuando hace foco
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(color: Color(0xFFADACCA), width: 2.0),
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
              ),
            ),
          ),
          SizedBox(width: 8.0),
          IconButton(
            icon: Image.asset('assets/sendbtn.png', height: 30),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
