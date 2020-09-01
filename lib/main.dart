import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

//  to run on linux desktop:
//  from the shell, in the root directory:
//  flutter -d linux create .

Canvas _canvas; //  handy reference
Size _paintSize;

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

    _ticker = createTicker((Duration elapsed) {
      setState(() {});
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
      body: Container(
        color: Colors.white,
        constraints: BoxConstraints.expand(),
        child: CustomPaint(painter: _FishPainter()),
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

    if (_shapes.isEmpty) {
      //  fixme: odd moment to call initialization... but it has to happen after paint size initialization
      for (int i = 0; i < 75; i++) {
        _shapes.add(CircleShape());
      }
    }

    //  clear the pond
    _canvas.drawRect(Rect.fromLTWH(0, 0, paintSize.width, paintSize.height), _blue);

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
    double minDim = min(_paintSize.width, _paintSize.height) * 0.015;
    _r = minDim + _random.nextDouble() * minDim * 2;
    _size = Point(2 * _r, 2 * _r);
    //  reset the location based on the new size
    _location =
        Point(_random.nextDouble() * (_paintSize.width - 2 * _r), _random.nextDouble() * (_paintSize.height - 2 * _r));
    _paint = Paint()
      ..color = Color.fromARGB(
          255, // opaque
          128 + (_random.nextDouble() * 127).toInt(), //
          128 + (_random.nextDouble() * 127).toInt(), //
          64 + (_random.nextDouble() * 191).toInt()
          );
    //  note: with the above coloring, the background color cannot be matched
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

    //  bounce off the boundary
    if (_location.x <= 0) {
      _velocity = Point(-_velocity.x, velocity.y); //  reverse x direction
      _location = Point(_location.x + _velocity.x, _location.y);
    } else if (_location.x + _size.x >= _paintSize.width) {
      _velocity = Point(-_velocity.x, velocity.y); //  reverse x direction
      _location = Point(_location.x - _velocity.x.abs(), _location.y);
    }
    if (_location.y <= 0) {
      _velocity = Point(_velocity.x, -velocity.y); //  reverse y direction
      _location = Point(_location.x, _location.y + _velocity.y);
    } else if (_location.y + _size.y >= _paintSize.height) {
      _velocity = Point(_velocity.x, -velocity.y); //  reverse y direction
      _location = Point(_location.x, _location.y - _velocity.y.abs());
    }

    //  todo: look for other fish, react to their velocity

    //  todo: bounce off other shapes

    // assert truths... not true when window size changes!
    // assert(_location.x >= 0);
    // assert(_location.x <= _paintSize.width - _size.x);
    // assert(_location.y >= 0);
    // assert(_location.y <= _paintSize.height - _size.y);
  }
}

const minimumSpeed = 1.0;
final _random = new Random();

Paint _blue = Paint()..color = Colors.lightBlueAccent;
Paint _black54 = Paint()..color = Colors.black54;
