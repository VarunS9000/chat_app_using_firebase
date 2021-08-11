import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FireBaseFunction extends ChangeNotifier{
   bool blocked=false;
   Widget widget=Container();

  get getBlockedStatus{
    return blocked;
  }

  storedBlockedState() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    return pref.getString('blockedStatus');
  }
   onSendMessage(String content,String id, String peerId , TextEditingController textEditingController, String groupChatId) {

    if (content.trim() != '') {
      textEditingController.clear();

      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId)
          .doc(DateTime.now().millisecondsSinceEpoch.toString());

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
            'content': content,

          },
        );
      });

    }
  }

  onBlockOrUnblock(uid,peerID,array,BuildContext context,blockedStatus) async{
    if(blockedStatus){
      array.remove(peerID);
    }
    else{
      array.add(peerID);
    }

    FirebaseFirestore.instance.collection('users').doc(uid).update({'blocked': array});
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setString('blocked', json.encode(array));
    return array;
  }

  getCurrentBlockedStatus(bool status){
    blocked=status;
    notifyListeners();
  }

  sendRequest(requestArray,peerID,uid){
    requestArray.add(peerID);
    FirebaseFirestore.instance.collection('users').doc(uid).update({'requestSent':requestArray });
  }

  acceptRequest(acceptArray,peerID,uid){
    acceptArray.add(peerID);
    FirebaseFirestore.instance.collection('users').doc(uid).update({'requestAccepted':acceptArray });
  }

  denyRequest(requestArray,peerID,uid){
    requestArray.remove(peerID);
    FirebaseFirestore.instance.collection('users').doc(uid).update({'requestSent':requestArray });
  }

  widgetDecider(requestArray,acceptedArray,uid,BuildContext context,index,uMap,list){
    if(requestArray.contains(uid)){
      return Row(
        children: [
          FlatButton(
              onPressed: (){

              },
              child: Icon(Icons.check)
          ),
          FlatButton(
              onPressed: (){},
              child: Icon(Icons.clear)
          )

        ],
      );
    }

    else if(acceptedArray.contains(uid)){
      return Icon(Icons.check);
    }

    else if(uMap['requestSent'].contains(list[index].get('id'))){
      return Icon(Icons.send);
    }
  }
}