import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kodchat/model/message_model.dart';
import 'package:kodchat/provider/auth_provider.dart';
import 'package:kodchat/services/get_chat_conversation.dart';
import 'package:kodchat/services/media_servivce.dart';
import 'package:timeago/timeago.dart' as timeago;

class ConversationPage extends StatefulWidget {
  final String conversationDocId;
  final String receiverId;
  final String receiverImageUrl;
  final String receiverName;

  ConversationPage({
    this.conversationDocId,
    this.receiverId,
    this.receiverImageUrl,
    this.receiverName,
  });

  @override
  _ConversationPageState createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
  final messageInstance = SendMessageMethod.instance;
  TextEditingController inputController = TextEditingController();
  ScrollController controller = ScrollController();
  final formKey = GlobalKey<FormState>();
  bool isFirstTime;
  String conversationId;

  Future<void> sendMessage() async {
    String message = inputController.text.trim();

    if (message.length != 0) {
      String senderId = AuthProvider.instance.user.uid;
      MessageModel _message = MessageModel(
        body: message,
        type: MessageType.Text,
        senderId: senderId,
        timestamp: Timestamp.now(),
      );

      if (isFirstTime) {
        formKey.currentState.reset();
        inputController.text = '';

        await SendMessageMethod().sendMessageToFirstTime(
          message: _message,
          docID: widget.conversationDocId ?? conversationId,
          receiverId: widget.receiverId,
        );
      } else {
        formKey.currentState.reset();
        inputController.text = '';

        await SendMessageMethod().sendMessage(
          message: _message,
          docID: widget.conversationDocId ?? conversationId,
        );
      }

      controller.animateTo(
        controller.position.minScrollExtent,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color.fromRGBO(31, 31, 33, 1.0),
        title: Text(this.widget.receiverName),
      ),
      body: widget.conversationDocId == null
          ? FutureBuilder(
              future: SendMessageMethod().getConversationId(widget.receiverId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                } else {
                  conversationId = snapshot.data;
                  return bodyUi();
                }
              },
            )
          : bodyUi(),
    );
  }

  Widget bodyUi() {
    return Container(
      height: MediaQuery.of(context).size.height - kTextTabBarHeight,
      child: Stack(
        children: [
          ListView(
            children: [
              messageStreamUi(),
              messageField(),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ValueListenableBuilder<Map<String, Map>>(
              valueListenable: messageInstance.sendingValue,
              builder: (_, Map data, child) {
                print(data);
                print(data);

                if (!data
                    .containsKey(widget.conversationDocId ?? conversationId)) {
                  return Container();
                } else {
                  Map _data = data[widget.conversationDocId ?? conversationId];

                  if (_data['value'] == null) {
                    return Container();
                  } else {
                    return sendingImageIndicator(
                      _data['value'],
                      _data['total'],
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget messageStreamUi() {
    return StreamBuilder(
      stream:
          GetChatConversation(id: widget.conversationDocId ?? conversationId)
              .conversationStream
              .stream,
      builder: (_, snapshot) {
        if (!snapshot.hasData) {
          return Expanded(child: Center(child: CircularProgressIndicator()));
        } else {
          List<MessageModel> _messageList = snapshot.data;

          if (_messageList.isEmpty) {
            isFirstTime = true;
            return Align(
              alignment: Alignment.center,
              child: emptyConversationUi(),
            );
          }

          isFirstTime = false;
          return messageList(_messageList);
        }
      },
    );
  }

  Widget messageList(List<MessageModel> messageList) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
//      height:
      width: MediaQuery.of(context).size.width,
      child: ListView.builder(
        reverse: true,
        physics: BouncingScrollPhysics(),
        controller: controller,
        itemCount: messageList.length,
        itemBuilder: (_, index) {
          MessageModel currentMessage = messageList[index];
          bool isOwner =
              currentMessage.senderId == AuthProvider.instance.user.uid;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment:
                isOwner ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              !isOwner ? receiverImageUi() : Container(),
              currentMessage.type == MessageType.Text
                  ? textBubble(
                      isOwner,
                      currentMessage.body,
                      currentMessage.timestamp,
                      currentMessage.isSent,
                    )
                  : imageBubble(
                      isOwner,
                      currentMessage.body,
                      currentMessage.timestamp,
                      currentMessage.isSent,
                    ),
            ],
          );
        },
      ),
    );
  }

  Widget textBubble(bool isOwn, String message, Timestamp time, bool sent) {
    List<Color> colorsList = isOwn
        ? [Colors.blue, Colors.blue[700]]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.symmetric(vertical: 5.0),
      height: MediaQuery.of(context).size.height * 0.10 +
          (message.length / 20 * 5.0),
      width: MediaQuery.of(context).size.width * 0.75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        gradient: LinearGradient(
          colors: colorsList,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          Row(
            children: [
              Text(
                '${timeago.format(time.toDate())} At ${time.toDate().toString().split(' ')[1].split('.')[0].substring(0, 5)}',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
              !sent
                  ? Icon(Icons.check, size: 15)
                  : Icon(Icons.access_time, size: 15),
            ],
          ),
        ],
      ),
    );
  }

  Widget imageBubble(bool isOwn, String imageUrl, Timestamp time, bool sent) {
    List<Color> colorsList = isOwn
        ? [Colors.blue, Colors.blue[700]]
        : [Color.fromRGBO(69, 69, 69, 1), Color.fromRGBO(43, 43, 43, 1)];

    return Container(
      height: MediaQuery.of(context).size.height * 0.50,
      width: MediaQuery.of(context).size.height * 0.40,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      margin: EdgeInsets.symmetric(vertical: 5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        gradient: LinearGradient(
          colors: colorsList,
          stops: [0.30, 0.70],
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.40,
            width: MediaQuery.of(context).size.height * 0.40,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (_, child, progress) {
                  if (progress == null) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return Center(
                    child: CircularProgressIndicator(
                      value: progress.totalSize != null
                          ? progress.downloaded / progress.totalSize
                          : null,
                    ),
                  );
                },
              ),
            ),
          ),
          Row(
            children: [
              Text(
                '${timeago.format(time.toDate())} At ${time.toDate().toString().split(' ')[1].split('.')[0].substring(0, 5)}',
                style: TextStyle(color: Colors.white),
              ),
              Spacer(),
              !sent
                  ? Icon(Icons.check, size: 15)
                  : Icon(Icons.access_time, size: 15),
            ],
          ),
        ],
      ),
    );
  }

  Widget emptyConversationUi() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.80,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Icon(
              Icons.textsms,
              size: 80,
              color: Colors.grey[700],
            ),
          ),
          Center(
            child: Text(
              'There Seems To Be No Conversation Here\n Be The Frist To Start A Conversation',
              style: TextStyle(
                fontWeight: FontWeight.w300,
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget receiverImageUi() {
    return Container(
      margin: EdgeInsets.all(5.0),
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.height * 0.05,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(500.0),
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(widget.receiverImageUrl),
        ),
      ),
    );
  }

  Widget messageField() {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.04,
        vertical: 10.0,
      ),
      height: MediaQuery.of(context).size.height * 0.08,
      decoration: BoxDecoration(
        color: Color.fromRGBO(43, 43, 43, 1.0),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Form(
        key: formKey,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            messageTextField(),
            sendMessageButton(),
            imageMessageButton(),
          ],
        ),
      ),
    );
  }

  Widget messageTextField() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.55,
      child: TextFormField(
        controller: inputController,
        cursorColor: Colors.white,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Type Message...',
        ),
        autocorrect: false,
      ),
    );
  }

  Widget sendMessageButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      width: MediaQuery.of(context).size.width * 0.05,
      child: IconButton(
        icon: Icon(Icons.send, color: Colors.white),
        onPressed: () async {
          await sendMessage();
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }

  Widget imageMessageButton() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.1,
      child: ValueListenableBuilder<Map<String, Map>>(
        child: FloatingActionButton(
          onPressed: () {},
          backgroundColor: Colors.grey,
          child: Icon(Icons.camera_enhance),
        ),
        valueListenable: messageInstance.sendingValue,
        builder: (_, Map data, child) {
          print(data);
          print(data);

          if (!data.containsKey(widget.conversationDocId ?? conversationId)) {
            return FloatingActionButton(
              onPressed: () async {
                File image = await MediaService.instance.getImageFromGallery();

                if (image != null) {
                  messageInstance.uploadImage(
                    docId: widget.conversationDocId ?? conversationId,
                    image: image,
                  );
                }
              },
              child: Icon(Icons.camera_enhance),
            );
          } else {
            Map _data = data[widget.conversationDocId ?? conversationId];

            if (_data['value'] == null) {
              return FloatingActionButton(
                onPressed: () async {
                  File image =
                      await MediaService.instance.getImageFromGallery();

                  if (image != null) {
                    messageInstance.uploadImage(
                      docId: widget.conversationDocId ?? conversationId,
                      image: image,
                    );
                  }
                },
                child: Icon(Icons.camera_enhance),
              );
            } else {
              return child;
            }
          }
        },
      ),
    );
  }

  Widget sendingImageIndicator(int value, int total) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.05,
      margin: EdgeInsets.symmetric(
        horizontal: MediaQuery.of(context).size.width * 0.15,
        vertical: MediaQuery.of(context).size.height * 0.01,
      ),
      padding: EdgeInsets.symmetric(),
      child: Stack(
        children: [
          LinearProgressIndicator(
            backgroundColor: Colors.grey,
            minHeight: MediaQuery.of(context).size.height * 0.05,
            value: value.toDouble() / total,
          ),
          Align(
            alignment: Alignment.center,
            child:
                Text('Sending Image... ${((value / total) * 100).round()} %'),
          ),
        ],
      ),
    );
  }
}
