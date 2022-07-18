import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:reminder/helpers/constants.dart';
import 'package:reminder/widgets/add_reminder.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final List<Widget> screens;
  final List<BottomNavigationBarItem> items;
  final Duration itemsDuration;
  final Duration centerItemDuration;
  final Widget centerItem;
  final double centerItemSize;
  final Color? bottomNavigationBarColor;
  final Color centerItemBorderColor;
  final IconThemeData selectedIconTheme;
  final IconThemeData unselectedIconTheme;
  const CustomBottomNavigationBar(
      {this.centerItemSize = 80.00,
      this.bottomNavigationBarColor,
      this.centerItemBorderColor = const Color(0XFF2F66F6),
      this.selectedIconTheme =
          const IconThemeData(color: Color(0XFF2F66F6), size: 30),
      this.unselectedIconTheme =
          const IconThemeData(color: Color(0XFF696F8C), size: 30),
      this.itemsDuration = const Duration(milliseconds: 300),
      this.centerItemDuration = const Duration(milliseconds: 300),
      required this.items,
      required this.screens,
      required this.centerItem,
      Key? key})
      :
        // assert(items.length == 4 && screens.length == 5, 'screens should be 5 and items should be 4'),
        super(key: key);

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final PageController _pagecontroller = PageController(initialPage: 0);
  int _selectedPage = 0;
  int _lastpage = 0;
  bool centerItemSelected = false;
  final List<AnimationController> animationControllers = [];
  final List<Animation<Offset>> animations = [];
  final List<Widget> _pages = [];
  final List<BottomNavigationBarItem> items = [];
  late AnimationController rotationController;

  double? latitude;
  double? longitude;

  Future<void> _getCurrentUserLocation() async {
    final locData = await Location().getLocation();
    setState(() {
      latitude = locData.latitude;
      longitude = locData.longitude;
    });
  }

  @override
  void initState() {
    super.initState();
    rotationController = AnimationController(
      vsync: this,
      duration: widget.centerItemDuration,
      upperBound: 0.5,
    );
    prepareInitialData();
    _getCurrentUserLocation();
  }

  @override
  void dispose() {
    super.dispose();
    rotationController.dispose();
    for (var element in animationControllers) {
      element.dispose();
    }
  }

  void prepareInitialData() {
    for (BottomNavigationBarItem element in widget.items) {
      if (widget.items.indexOf(element) == 0) {
        animationControllers.add(AnimationController(
          duration: widget.itemsDuration,
          vsync: this,
        ));
        animations.add(
          Tween<Offset>(
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, -0.25),
          ).animate(
            CurvedAnimation(
              parent: animationControllers.last,
              curve: Curves.linear,
            ),
          ),
        );
        items.add(
          BottomNavigationBarItem(
              icon: element.icon,
              activeIcon: SlideTransition(
                position: animations.last,
                child: element.activeIcon,
              ),
              label: element.label),
        );
        animationControllers.add(
          AnimationController(
            duration: widget.itemsDuration,
            vsync: this,
          ),
        );
        animations.add(
          Tween<Offset>(
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, -0.25),
          ).animate(
            CurvedAnimation(
              parent: animationControllers.last,
              curve: Curves.linear,
            ),
          ),
        );

        items.add(
          BottomNavigationBarItem(
            label: '',
            icon: const Icon(
              Icons.circle,
              size: 0,
              color: Colors.transparent,
            ),
            activeIcon: SlideTransition(
              position: animations.last,
              child: const Icon(
                Icons.circle,
                size: 0,
                color: Colors.transparent,
              ),
            ),
          ),
        );
      } else {
        animationControllers.add(AnimationController(
          duration: widget.itemsDuration,
          vsync: this,
        ));
        animations.add(
          Tween<Offset>(
            begin: const Offset(0.0, 0.0),
            end: const Offset(0.0, -0.25),
          ).animate(
            CurvedAnimation(
              parent: animationControllers.last,
              curve: Curves.linear,
            ),
          ),
        );
        items.add(
          BottomNavigationBarItem(
            label: element.label,
            icon: element.icon,
            activeIcon: SlideTransition(
              position: animations.last,
              child: element.activeIcon,
            ),
          ),
        );
      }
    }
    animationControllers[0].forward(from: 0.0);
  }

  void _selectPage(int index) {
    _lastpage = _selectedPage;
    if (index != 1 && index != _selectedPage) {
      if (index != _lastpage) {
        animationControllers[_lastpage].reverse(from: 1.0);
      }
      animationControllers[index].forward(from: 0.0);
      setState(() {
        centerItemSelected = false;
        _selectedPage = index;
        _pagecontroller.jumpToPage(index);
      });
    }
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: RotationTransition(
        turns: Tween(begin: 0.0, end: 1.0).animate(rotationController),
        child: SizedBox(
          height: widget.centerItemSize,
          width: widget.centerItemSize,
          child: FloatingActionButton(
            focusColor: Colors.transparent,
            highlightElevation: 0,
            hoverColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            onPressed: () {
              // if (!centerItemSelected) {
              centerItemSelected = true;
              //   _selectedPage = 1;
              setState(() {
                if (rotationController.isCompleted ||
                    rotationController.isDismissed) {
                  rotationController.forward(from: 0.0).whenComplete(() {
                    setState(() {
                      centerItemSelected = false;
                    });
                    showModalBottomSheet(
                        isDismissible: false,
                        enableDrag: false,
                        isScrollControlled: true,
                        context: context,
                        builder: (context) => AddReminder(
                            latitude: latitude ?? 0,
                            longitude: longitude ?? 0));
                  });
                  // Navigator.of(context).push(MaterialPageRoute(builder: (c) =>  const AddReminder())));
                }
                // _pagecontroller.jumpToPage(1);
              });

              // }
            },
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                      color: centerItemSelected
                          ? widget.centerItemBorderColor
                          : Colors.white,
                      width: 4),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: widget.centerItem),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      backgroundColor: Colors.transparent,
      bottomNavigationBar: SizedBox(
        height: 80,
        child: BottomAppBar(
          child: BottomNavigationBar(
              selectedItemColor: darkColor,
              type: BottomNavigationBarType.fixed,
              elevation: 0.0,
              showUnselectedLabels: false,
              showSelectedLabels: true,
              currentIndex: _selectedPage,
              onTap: _selectPage,
              selectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.red),
              backgroundColor: widget.bottomNavigationBarColor,
              selectedIconTheme: widget.selectedIconTheme,
              unselectedIconTheme: widget.unselectedIconTheme,
              items: items),
        ),
      ),
      body: PageView(
        controller: _pagecontroller,
        physics: const NeverScrollableScrollPhysics(),
        children: widget.screens,
      ),
    );
  }
}
