import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatacter/models/message.dart';
import 'package:chatacter/functions/format_date.dart';
import 'package:chatacter/styles/app_colors.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatefulWidget {
  final Message message;
  final String currentUser;
  final bool isImage;

  const MessageItem(
      {super.key,
      required this.message,
      required this.currentUser,
      required this.isImage});

  @override
  State<MessageItem> createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {
  @override
  Widget build(BuildContext context) {
    return widget.isImage
        ? Container(
            child: Row(
              mainAxisAlignment: widget.message.sender == widget.currentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment:
                      widget.message.sender == widget.currentUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.all(4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:
                              "https://cloud.appwrite.io/v1/storage/buckets/662faabe001a20bb87c6/files/${widget.message.message}/view?project=662e8e5c002f2d77a17c&mode=admin",
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 3),
                          child: Text(
                            formatDate(widget.message.timestamp),
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.outline),
                          ),
                        ),
                        widget.message.sender == widget.currentUser
                            ? widget.message.isSeenByReceiver
                                ? Icon(
                                    Icons.check_circle,
                                    size: 16,
                                    color: AppColors.primary,
                                  )
                                : Icon(
                                    Icons.check_circle_outline,
                                    size: 16,
                                    color: AppColors.primary,
                                  )
                            : SizedBox()
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        : Container(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: widget.message.sender == widget.currentUser
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment:
                        widget.message.sender == widget.currentUser
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.all(10),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.75),
                            decoration: BoxDecoration(
                                color:
                                    widget.message.sender == widget.currentUser
                                        ? AppColors.primary
                                        : AppColors.secondary,
                                borderRadius: BorderRadius.only(
                                    bottomLeft: widget.message.sender ==
                                            widget.currentUser
                                        ? Radius.circular(20)
                                        : Radius.circular(2),
                                    bottomRight: widget.message.sender ==
                                            widget.currentUser
                                        ? Radius.circular(2)
                                        : Radius.circular(20),
                                    topLeft: Radius.circular(20),
                                    topRight: Radius.circular(20))),
                            child: Text(
                              widget.message.message,
                              style: TextStyle(
                                  color: widget.message.sender ==
                                          widget.currentUser
                                      ? AppColors.black
                                      : AppColors.black),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 3),
                            child: Text(
                              formatDate(widget.message.timestamp),
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.outline),
                            ),
                          ),
                          widget.message.sender == widget.currentUser
                              ? widget.message.isSeenByReceiver
                                  ? Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppColors.primary,
                                    )
                                  : Icon(
                                      Icons.check_circle_outline,
                                      size: 16,
                                      color: AppColors.notSeen,
                                    )
                              : SizedBox()
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          );
  }
}
