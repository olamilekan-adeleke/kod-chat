import 'package:flutter/material.dart';
import 'package:kodchat/model/conversation_snippet_model.dart';
import 'package:kodchat/model/message_model.dart';
import 'package:kodchat/pages/conversation_page.dart';
import 'package:kodchat/services/get_chat_list.dart';
import 'package:kodchat/services/navigation_service.dart';

class ChatHomePage extends StatefulWidget {
  @override
  _ChatHomePageState createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with AutomaticKeepAliveClientMixin {
  final getChat = GetChatList.instance;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: bodyUi(),
    );
  }

  Widget bodyUi() {
    return StreamBuilder(
      stream: getChat.conversationStream.stream,
      builder: (context, snapshot) {
        print(snapshot.data);
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else {
          List<ConversationSnippetModel> _chatList = snapshot.data;
          return ListView.builder(
            itemCount: _chatList.length,
            itemBuilder: (_, index) {
              ConversationSnippetModel currentChat = _chatList[index];
              return ListTile(
                onTap: () {
                  NavigationService.instance.navigateToPage(
                    MaterialPageRoute(
                      builder: (context) => ConversationPage(
                        conversationDocId: currentChat.docId,
                        receiverId: '',
                        receiverImageUrl: currentChat.otherUser.imageUrl,
                        receiverName: currentChat.otherUser.name,
                      ),
                    ),
                  );
                },
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(100.0),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: NetworkImage(currentChat.otherUser.imageUrl),
                    ),
                  ),
                ),
                title: Text(
                  '${currentChat.otherUser.name}',
                  style: TextStyle(fontWeight: FontWeight.w300, fontSize: 18),
                ),
                subtitle: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.70,
                  child: currentChat.lastMessage.type == MessageType.Text
                      ? Text(
                          '${currentChat.lastMessage.body}',
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 18),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                      : Row(
                          children: [
                            Text(
                              'Attachment: ',
                              style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 18,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
//                            SizedBox(width: 5.0),
                            Icon(Icons.image, size: 18, color: Colors.grey),
                          ],
                        ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      '${currentChat.lastMessage.timestamp.toDate().toString().split(' ')[1].split('.')[0].substring(0, 5)}',
                      style:
                          TextStyle(fontWeight: FontWeight.w300, fontSize: 15),
                    ),
                    !currentChat.lastMessage.isSent
                        ? Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check, size: 15),
                          )
                        : Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.access_time, size: 15),
                          ),
                  ],
                ),
              );
            },
          );
        }
      },
    );
  }
}
