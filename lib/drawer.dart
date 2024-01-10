import 'package:flutter/material.dart';

class NavBar extends Drawer {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.grey.shade900,
      child: ListView(
        // Remove padding
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text('Oflutter.com'),
            accountEmail: Text('example@gmail.com'),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.network(
                  'https://oflutter.com/wp-content/uploads/2021/02/girl-profile.png',
                  //fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                ),
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: NetworkImage(
                      'https://cdn.shopify.com/s/files/1/0476/5297/articles/Live_Bass_Adjusting_to_Different_Venues_1600x.jpg?v=1620756610',
                  ),
              ),
            ),
          ),
          ListTile(
            leading: Icon(Icons.star,
            color: Colors.white,
            ),
            title: Text('Избранные',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.share,
              color: Colors.white,
            ),
            title: Text('поделиться',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onTap: () => null,
          ),
          //Divider(),
          ListTile(
            leading: Icon(Icons.settings,
              color: Colors.white,
            ),
            title: Text('Настройки',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onTap: () => null,
          ),
          ListTile(
            leading: Icon(Icons.description,
              color: Colors.white,
            ),
            title: Text('Тема',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            onTap: () => null,
          ),
          Divider(),
          ListTile(
            title: Text('Выход',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            leading: Icon(Icons.exit_to_app,
              color: Colors.white,
            ),
            onTap: () => null,
          ),
        ],
      ),
    );
  }
}