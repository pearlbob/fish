import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

int _paintCounter = 0; //  debug
Canvas _canvas; //  handy reference
Size _paintSize = Size(800, 600);

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'A Fishy App',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'A Fishy App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 25; i++) _shapes.add(CircleShape());

    _ticker = createTicker((Duration elapsed) {
      setState(() {
        _paintCounter++;
      });
    });
    _ticker.start();
  }

  void _doPlusButton() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(10),
              child: Container(
                color: Colors.white,
                width: _paintSize.width,
                height: _paintSize.height,
                child: CustomPaint(painter: _FishPainter()),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _doPlusButton,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  Ticker _ticker;
}

class _FishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size paintSize) {
    _canvas = canvas;
    _paintSize = paintSize;

    //  clear the pond
    _canvas.drawRect(Rect.fromLTWH(0, 0, paintSize.width, paintSize.height), _blue);

    //  debug counter
    // TextPainter(
    //   text: TextSpan(
    //     text: _paintCounter.toString(),
    //     style: TextStyle(
    //       fontFamily: 'Bravura',
    //       color: Colors.black54,
    //       fontSize: 20,
    //     ),
    //   ),
    //   textDirection: TextDirection.ltr,
    // )
    //   ..layout(
    //     minWidth: 0,
    //     maxWidth: 200,
    //   )
    //   ..paint(_canvas, Offset(10, 10));

    //  increment and paint the shapes
    for (Shape shape in _shapes) {
      shape.tick();
      shape.paint();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; //  always repaint
  }
}

List<Shape> _shapes = [];

class CircleShape extends Shape {
  CircleShape() {
    _r = 10.0 + _random.nextDouble() * 20.0;
    _size = Point(2 * _r, 2 * _r);
    //  reset the location based on the new size
    _location =
        Point(_random.nextDouble() * (_paintSize.width - 2 * _r), _random.nextDouble() * (_paintSize.height - 2 * _r));
    _paint = Paint()
      ..color = Color.fromARGB(
          255, // opaque
          (_random.nextDouble() * 255).toInt(), //
          (_random.nextDouble() * 255).toInt(), //
          (_random.nextDouble() * 255).toInt()
          // fixme: worry about random color that matches the background too well!
          );
  }

  @override
  void paint() {
    //  circle centered on upper left to bounce properly from rectangular upper left limits
    _canvas.drawCircle(Offset(_location.x + _r, _location.y + _r), _r, _paint);
  }

  double _r;
  Paint _paint;
}

class Shape {
  Point get velocity => _velocity;
  Point _velocity = Point(
      minimumSpeed + _random.nextDouble() * 3.0, //  some non-zero velocity
      minimumSpeed + _random.nextDouble() * 3.0 //  some non-zero velocity
      );

  Point get location => _location;
  Point _location = Point(_random.nextDouble() * _paintSize.width, _random.nextDouble() * _paintSize.height);

  Point get size => _size;
  Point _size = Point(15.0, 5.0); //  default size only

  void paint() {
    //  default paint, intended to be overwritten
    _canvas.drawRect(Rect.fromLTWH(_location.x, _location.y, 20.0, 5.0), _black54);
  }

  void tick() {
    _location = Point(_location.x + _velocity.x, _location.y + _velocity.y);

    //  bounce off the paint boundary
    if (_location.x <= 0) {
      _velocity = Point(-_velocity.x, velocity.y); //  reverse x direction
      _location = Point(_location.x + _velocity.x, _location.y);
    } else if (_location.x + _size.x >= _paintSize.width) {
      _velocity = Point(-_velocity.x, velocity.y); //  reverse x direction
      _location = Point(_location.x + _velocity.x, _location.y);
    }
    if (_location.y <= 0) {
      _velocity = Point(_velocity.x, -velocity.y); //  reverse y direction
      _location = Point(_location.x, _location.y + _velocity.y);
    } else if (_location.y + _size.y >= _paintSize.height) {
      _velocity = Point(_velocity.x, -velocity.y); //  reverse y direction
      _location = Point(_location.x, _location.y + _velocity.y);
    }

    //  todo: bounce off other shapes

    //  assert truths
    assert(_velocity.x <= -minimumSpeed || _velocity.x >= minimumSpeed);  //  temporary
    assert(_velocity.y <= -minimumSpeed || _velocity.y >= minimumSpeed);  //  temporary
    assert(_location.x >= 0);
    assert(_location.x <= _paintSize.width - _size.x);
    assert(_location.y >= 0);
    assert(_location.y <= _paintSize.height - _size.y);
  }
}

const minimumSpeed = 1.0;
final _random = new Random();

Paint _blue = Paint()..color = Colors.lightBlueAccent;
Paint _black54 = Paint()..color = Colors.black54;
Paint _orange = Paint()..color = Colors.orange;
