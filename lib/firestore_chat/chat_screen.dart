import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'call_page.dart';

class ChatScreen extends StatefulWidget {
  final String mentorId;
  final String studentId;
  String studentName;
  String mentorName;

  ChatScreen({
    super.key,
    required this.mentorId,
    required this.studentId,
    required this.studentName,
    required this.mentorName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final user = FirebaseAuth.instance.currentUser;
  String get chatId => "${widget.studentId}_${widget.mentorId}";
  String get callDocId => "${widget.studentId}_${widget.mentorId}";
  bool _hasBookedSession = false;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    checkBookedSession();
    listenForCall();
    fetchMissingNamesIfNeeded();
  }

  Future<void> fetchMissingNamesIfNeeded() async {
    final userRef = FirebaseFirestore.instance.collection('users');

    if (widget.studentName.trim().isEmpty) {
      final studentDoc = await userRef.doc(widget.studentId).get();
      if (studentDoc.exists && studentDoc.data()!.containsKey('fullName')) {
        setState(() {
          widget.studentName = studentDoc['fullName'];
        });
      }
    }

    if (widget.mentorName.trim().isEmpty) {
      final mentorDoc = await userRef.doc(widget.mentorId).get();
      if (mentorDoc.exists && mentorDoc.data()!.containsKey('fullName')) {
        setState(() {
          widget.mentorName = mentorDoc['fullName'];
        });
      }
    }
  }

  Future<void> checkBookedSession() async {
    final sessionSnapshot = await FirebaseFirestore.instance
        .collection('sessions')
        .where('mentorId', isEqualTo: widget.mentorId)
        .where('studentId', isEqualTo: widget.studentId)
        .where('status', isEqualTo: 'confirmed')
        .get();

    setState(() {
      _hasBookedSession = sessionSnapshot.docs.isNotEmpty;
    });
  }

  void listenForCall() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists && mounted) {
        final call = snapshot.data()!;
        final live = call['isLive'] == true;
        final channelName = call['channelName'] ?? 'niga';

        setState(() {
          _isLive = live;
        });

        if (live && user!.uid == widget.studentId) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text("Live Call Started"),
              content: const Text("Your mentor has started the session.\nDo you want to join now?"),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Not Now"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context);
                    await _joinCallAndEndLiveFlag(channelName, 'student');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Join Now"),
                ),
              ],
            ),
          );
        }
      }
    });
  }

  Future<void> _joinCallAndEndLiveFlag(String channelName, String role) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CallPage(channelName: channelName, userRole: role),
      ),
    );

    await FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .update({'isLive': false});
  }

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'text': text.trim(),
      'mentorId': widget.mentorId,
      'studentId': widget.studentId,
      'studentName': widget.studentName,
      'mentorName': widget.mentorName,
      'senderId': user!.uid,
      'isRead': false,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _msgController.clear();
  }

  void markAsRead(QuerySnapshot snapshot) async {
    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['senderId'] != user!.uid && data['isRead'] == false) {
        doc.reference.update({'isRead': true});
      }
    }
  }

  String getDateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final msgDate = DateTime(date.year, date.month, date.day);

    if (msgDate == today) return 'Today';
    if (msgDate == yesterday) return 'Yesterday';
    return DateFormat.yMMMMd().format(date);
  }

  Future<void> _startAgoraCallAsMentor() async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(callDocId)
        .set({
      'mentorId': widget.mentorId,
      'studentId': widget.studentId,
      'channelName': 'niga',
      'isLive': true,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await _joinCallAndEndLiveFlag('niga', 'mentor');
  }

  Future<void> _deleteMessage(DocumentReference ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Message"),
        content: const Text("Are you sure you want to delete this message?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete")),
        ],
      ),
    );
    if (confirm == true) await ref.delete();
  }

  @override
  Widget build(BuildContext context) {
    final isStudent = user!.uid == widget.studentId;
    final chattingWithName = isStudent ? widget.mentorName : widget.studentName;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Text(
              chattingWithName,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            if (_isLive)
              Container(
                margin: const EdgeInsets.only(left: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Live",
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
          ],
        ),
        actions: [
          if (!isStudent)
            IconButton(
              icon: const Icon(Icons.video_call),
              onPressed: _startAgoraCallAsMentor,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                markAsRead(snapshot.data!);

                final messages = snapshot.data!.docs;
                final List<Widget> messageWidgets = [];
                DateTime? lastDate;

                for (final doc in messages) {
                  final msg = doc.data() as Map<String, dynamic>;
                  final timestamp = (msg['timestamp'] as Timestamp?)?.toDate();
                  final isMe = msg['senderId'] == user!.uid;
                  final isRead = msg['isRead'] == true;
                  final timeString = timestamp != null
                      ? TimeOfDay.fromDateTime(timestamp).format(context)
                      : '';

                  if (timestamp != null) {
                    final msgDate = DateTime(timestamp.year, timestamp.month, timestamp.day);
                    if (lastDate == null || msgDate != lastDate) {
                      messageWidgets.add(
                        Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              getDateLabel(timestamp),
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ),
                        ),
                      );
                      lastDate = msgDate;
                    }
                  }

                  messageWidgets.add(
                    GestureDetector(
                      onLongPress: isMe
                          ? () => _deleteMessage(doc.reference)
                          : null,
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isMe ? Colors.deepPurple : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(
                                msg['text'],
                                style: TextStyle(color: isMe ? Colors.white : Colors.black),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    timeString,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isMe ? Colors.white70 : Colors.black54,
                                    ),
                                  ),
                                  if (isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 4),
                                      child: Icon(
                                        isRead ? Icons.done_all : Icons.check,
                                        size: 14,
                                        color: isRead ? Colors.white : Colors.white70,
                                      ),
                                    )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    ...messageWidgets,
                    if (isStudent && _hasBookedSession)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "✅ Session Confirmed",
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),

                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    decoration: const InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => sendMessage(_msgController.text),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
