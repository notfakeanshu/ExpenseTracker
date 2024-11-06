import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pennywise/modals/friend.dart';
import 'package:pennywise/screens/screen4.dart';

class FriendsList extends StatefulWidget {
  const FriendsList({super.key, required this.friends});
  final List<Friend> friends;

  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    Widget content = Center(
      child: Text(
        'No Friends Here!\nClick on the Button below to add Friends',
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          textStyle: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );

    if (widget.friends.isNotEmpty) {
      content = ListView.builder(
        itemCount: widget.friends.length,
        itemBuilder: (ctx, index) {
          Color colorofAmount = Colors.blue;
          if (widget.friends[index].amount > 0) {
            colorofAmount = Colors.green;
          }
          if (widget.friends[index].amount < 0) {
            colorofAmount = Colors.red;
          }

          return InkWell(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Screen4(
                      friend: widget.friends[index],
                      index: index,
                    );
                  },
                ),
              );
              if (result == true) {
                // setState(() {
                //   // Rebuild the widget after returning from Screen4
                //   // You might also trigger a re-fetch of data here if needed
                // });
              }
            },
            child: Column(
              children: [
                ListTile(
                  leading: CircleAvatar(
                    radius: 26,
                    backgroundImage:
                        NetworkImage(widget.friends[index].imageUrl),
                  ),
                  trailing: Text(
                    widget.friends[index].amount.toString(),
                    style: GoogleFonts.lato(
                      textStyle: TextStyle(
                        color: colorofAmount,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  title: Text(
                    widget.friends[index].name,
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          );
        },
      );
    }
    return content;
  }
}
