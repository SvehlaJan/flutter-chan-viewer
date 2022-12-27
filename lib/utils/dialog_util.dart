import 'package:flutter/material.dart';
import 'package:flutter_chan_viewer/models/ui/thread_item.dart';

class DialogUtil {
  static void showCustomCollectionPickerDialog(
    BuildContext context,
    List<ThreadItem> threads,
    TextEditingController? textController,
    Function onCreateNewCollectionClicked,
    Function onAddPostToCollectionClicked,
  ) {
    List<Widget> items = threads
        .map((thread) => ListTile(
              title: Text(thread.subtitle!),
              onTap: () {
                onAddPostToCollectionClicked(context, thread.subtitle);
                Navigator.of(context).pop();
              },
            ))
        .toList();
    items.add(ListTile(
      title: TextField(
        controller: textController,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(hintText: "New collection"),
      ),
      trailing: IconButton(
        icon: Icon(Icons.add),
        onPressed: () {
          String name = textController!.text;
          if (name.isNotEmpty) {
            textController.clear();
            onCreateNewCollectionClicked(context, name);
            Navigator.of(context).pop();
          }
        },
      ),
    ));

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: Text("Add post to collection"),
            children: items,
          );
        });
  }
}
