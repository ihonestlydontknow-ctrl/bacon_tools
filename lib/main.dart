main.dart
Bacon Tools Source Code — Final Production Build Configuration
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
void main() {
runApp(const BaconToolsApp());
}
class BaconToolsApp extends StatelessWidget {
const BaconToolsApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
debugShowCheckedModeBanner: false,
theme: ThemeData.dark().copyWith(
primaryColor: Colors.deepPurple,
scaffoldBackgroundColor: const Color(0xFF0F0F12),
),
home: const MainFlowScreen(),
);
}
}
class MainFlowScreen extends StatefulWidget {
const MainFlowScreen({super.key});
@override
State<MainFlowScreen> createState() => _MainFlowScreenState();
}
class _MainFlowScreenState extends State<MainFlowScreen> with SingleTickerProviderStateMixin
{
int _currentStep = 0; // 0 = Splash, 1 = Instructions, 2 = Connection, 3 = Hub
String _activeTab = 'Mods';
bool _isConnected = false;
bool _isBoundaryOff = false;
String _activeModName = 'None';
// Real Network Socket for ADB connection
Socket? _adbSocket;
late AnimationController _fadeController;
late Animation<double> _fadeInAnimation;
final TextEditingController _ipController = TextEditingController(text: "192.168.1.");
final TextEditingController _portController = TextEditingController(text: "5555");
final TextEditingController _pairingController = TextEditingController();
1
@override
void initState() {
super.initState();
_playSoundPlaceholder();
_fadeController = AnimationController(
vsync: this,
duration: const Duration(milliseconds: 1500),
);
_fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
);
_fadeController.forward().then((_) {
Future.delayed(const Duration(seconds: 1), () {
setState(() { _currentStep = 1; });
});
});
void _playSoundPlaceholder() {
debugPrint("Startup sound triggered!");
}
}
@override
void dispose() {
_fadeController.dispose();
_adbSocket?.close();
super.dispose();
}
// --- THE REAL ADB ENGINE ---
Future<void> _connectToVRHeadset() async {
String ip = _ipController.text.trim();
int port = int.tryParse(_portController.text.trim()) ?? 5555;
try {
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Connecting to $ip:$port...')),
);
_adbSocket = await Socket.connect(ip, port, timeout: const Duration(seconds: 5));
setState(() {
_isConnected = true;
_currentStep = 3;
});
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Connection Failed: Make sure Wireless Debugging is ON
in VR.')),
);
}
}
2
// Executes actual shell scripts on the Quest OS
void _executeRealADBScript(String shellCommand) {
if (_adbSocket == null) return;
try {
_adbSocket!.write(shellCommand + "
");
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text('Sent: $shellCommand')),
);
} catch (e) {
ScaffoldMessenger.of(context).showSnackBar(
const SnackBar(content: Text('Failed to transmit script.')),
);
}
}
// Reusable single function to force mod switches safely
void triggerSingleMod(String modName, String scriptPayload) {
if (_activeModName != 'None') {
_executeRealADBScript('setprop debug.oculus.headlock 0');
}
setState(() {
_activeModName = modName;
});
_executeRealADBScript(scriptPayload);
}
@override
Widget build(BuildContext context) {
if (_currentStep == 0) {
return Scaffold(
body: Center(
child: FadeTransition(
opacity: _fadeInAnimation,
child: const Text(
'Bacon Tools',
color: Colors.deepPurpleAccent),
),
style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 2,
),
),
);
}
if (_currentStep == 1) {
return Scaffold(
body: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.center,
crossAxisAlignment: CrossAxisAlignment.stretch,
3
children: [
const Text(
'Setup Required',
style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color:
Colors.white),
textAlign: TextAlign.center,
),
const SizedBox(height: 24),
const Card(
color: Color(0xFF1E1E24),
child: Padding(
padding: EdgeInsets.all(20.0),
child: Text(
'Please enable developer mode and turn on wireless debugging inside your
VR Headset settings before continuing.',
style: TextStyle(fontSize: 16, height: 1.5, color: Colors.white70),
textAlign: TextAlign.center,
),
),
),
const SizedBox(height: 40),
ElevatedButton(
onPressed: () => setState(() => _currentStep = 2),
style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple, padding:
const EdgeInsets.symmetric(vertical: 16)),
child: const Text('Next', style: TextStyle(fontSize: 16, fontWeight:
FontWeight.bold)),
)
],
),
),
);
}
if (_currentStep == 2) {
return Scaffold(
appBar: AppBar(title: const Text('Connect Headset'), backgroundColor:
Colors.transparent, elevation: 0),
body: Padding(
padding: const EdgeInsets.all(24.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
TextField(
controller: _ipController,
decoration: const InputDecoration(labelText: 'IP Address', border:
OutlineInputBorder()),
keyboardType: TextInputType.number,
),
const SizedBox(height: 16),
Row(
children: [
Expanded(
child: TextField(
controller: _portController,
4
decoration: const InputDecoration(labelText: 'Port', border:
OutlineInputBorder()),
keyboardType: TextInputType.number,
),
),
const SizedBox(width: 16),
Expanded(
child: TextField(
controller: _pairingController,
decoration: const InputDecoration(labelText: 'Pairing Code
(Optional)', border: OutlineInputBorder()),
keyboardType: TextInputType.number,
),
),
],
),
const SizedBox(height: 32),
ElevatedButton(
onPressed: _connectToVRHeadset,
style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding:
const EdgeInsets.symmetric(vertical: 16)),
child: const Text('Connect Wirelessly', style: TextStyle(fontSize: 16,
fontWeight: FontWeight.bold)),
),
],
),
),
);
}
return Scaffold(
appBar: AppBar(
automaticallyImplyLeading: false,
backgroundColor: Colors.transparent,
elevation: 0,
actions: const [
Padding(
padding: EdgeInsets.only(right: 20.0, top: 16.0),
child: Text(
'Bacon Tools',
style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color:
Colors.deepPurpleAccent),
),
)
],
),
body: Row(
children: [
NavigationRail(
selectedIndex: _activeTab == 'Mods' ? 0 : (_activeTab == 'Settings' ? 1 : 2),
onDestinationSelected: (int index) {
setState(() {
if (index == 0) _activeTab = 'Mods';
if (index == 1) _activeTab = 'Settings';
if (index == 2) _activeTab = 'Credits';
5
});
},
labelType: NavigationRailLabelType.all,
destinations: const [
NavigationRailDestination(icon: Icon(Icons.extension), label: Text('Mods')),
NavigationRailDestination(icon: Icon(Icons.settings), label:
Text('Settings')),
NavigationRailDestination(icon: Icon(Icons.info), label: Text('Credits')),
],
),
const VerticalDivider(thickness: 1, width: 1),
Expanded(
child: Padding(
padding: const EdgeInsets.all(16.0),
child: _buildHubContent(),
),
)
],
),
);
}
Widget _buildHubContent() {
if (_activeTab == 'Settings') {
return Padding(
padding: const EdgeInsets.symmetric(vertical: 12.0),
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
const Text(
'System Configurations',
style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color:
Colors.deepPurpleAccent)
),
const SizedBox(height: 20),
Container(
decoration: BoxDecoration(
color: const Color(0xFF1E1E24),
borderRadius: BorderRadius.circular(12),
),
child: ListTile(
title: const Text(
'Turn Off Boundary',
style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color:
Colors.white)
),
subtitle: const Text(
'Completely disables the VR Guardian mesh walls',
style: TextStyle(fontSize: 12, color: Colors.white54)
),
trailing: Switch(
value: _isBoundaryOff,
activeColor: Colors.green,
activeTrackColor: Colors.green.withOpacity(0.4),
inactiveThumbColor: Colors.white,
6
inactiveTrackColor: Colors.white24,
onChanged: (bool newValue) {
setState(() {
_isBoundaryOff = newValue;
});
if (_isBoundaryOff) {
_executeRealADBScript('setprop debug.oculus.guardian_pause 1');
} else {
_executeRealADBScript('setprop debug.oculus.guardian_pause 0');
}
},
),
),
),
],
),
);
}
if (_activeTab == 'Credits') {
return const Column(
crossAxisAlignment: CrossAxisAlignment.start,
mainAxisAlignment: MainAxisAlignment.center,
children: [
Text('Project Credits', style: TextStyle(fontSize: 22, fontWeight:
FontWeight.bold, color: Colors.deepPurpleAccent)),
SizedBox(height: 16),
Text('• RacoonVR - adb scripts', style: TextStyle(fontSize: 16, height: 1.8)),
Text('• Bacon Mods - developed the app', style: TextStyle(fontSize: 16, height:
1.8)),
],
);
}
// --- LIVE SAFE ADB SCRIPT STRINGS ---
final String flyScript = "setprop debug.oculus.headlock 1; i=1; while [ \$i -lt 125 ];
do setprop debug.oculus.headlock.translation.z -\$(awk -v i=\$i 'BEGIN {print i * 0.5}');
i=\$((\$i + 1)); done; setprop debug.oculus.headlock.translation.z 1; setprop
debug.oculus.headlock 3333";
final String longArmsScript = "setprop debug.oculus.heai=1; while [ \$i -lt 125 ]; do
setprop debug.oculus.headlock.translation.z -\$(awk -v i=\$i 'BEGIN {print i * 0.5}'); i=\$
((\$i + 1)); done; setprop debug.oculus.headlock.translation.z 1; setprop
debug.oculus.headlock 3";
final String teleportScript = "debug.oculus.hea; i=1; while [ \$i -lt 5 ]; do setprop
debug.oculus.headlock.translation.z -\$(awk -v i=\$i 'BEGIN {print i * 0.55}'); i=\$((\$i +
1)); done; setprop debug.oculus.headlock.translation.z 9999999; setprop
debug.oculus.headlock 0";
final String flyUpScript = "echo '=== HIGH Y-BOOST (TALL MODE) ==='; setprop
debug.oculus.headlock 1; STEPS=140; MAX_Y=12.5; S=0.012; i=1; while [ \$i -le \$STEPS ]; do
p=\$(awk \"BEGIN{printf \\\"%.3f\\\",\$i/\$STEPS}\"); e=\$(awk \"BEGIN{printf \\\"%.3f\\\",
1-(1-\$p)*(1-\$p)}\"); height=\$(awk \"BEGIN{printf \\\"%.2f\",\$e*\$MAX_Y}\"); setprop
debug.oculus.headlock.translation.y \"\$height\"; sleep \$S; i=\$((\$i+1)); done; echo
'Maximum height reached!'; echo 'Reset: adb shell setprop debug.oculus.headlock 0'";
final String pullScript = "setprop debug.oculus.headlock 1; i=1; while [ \$i -lt 10 ];
do setprop debug.oculus.headlock.translation.z -\$(awk -v i=\$i 'BEGIN {print i * 0.55}');
7
i=\$((\$i + 1)); done; setprop debug.oculus.headlock.translation.z 0; setprop
debug.oculus.headlock 0000";
{
return RawKeyboardListener(
focusNode: FocusNode()..requestFocus(),
onKey: (RawKeyEvent event) {
if (event is RawKeyDownEvent) {
final String keyLabel = event.data.logicalKey.keyLabel.toLowerCase();
if (keyLabel.contains('button r1') || keyLabel.contains('gamepad right trigger'))
if (_activeModName == 'Fly') triggerSingleMod('Fly', flyScript);
if (_activeModName == 'Fly Up') triggerSingleMod('Fly Up', flyUpScript);
if (_activeModName == 'Pull Mod') triggerSingleMod('Pull Mod', pullScript);
}
}
},
child: SingleChildScrollView(
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Container(
padding: const EdgeInsets.all(12),
decoration: BoxDecoration(color: Colors.white10, borderRadius:
BorderRadius.circular(8)),
child: Text(
'Active Status: \${_activeModName.toUpperCase()}',
style: const TextStyle(fontWeight: FontWeight.bold, color:
Colors.deepPurpleAccent),
textAlign: TextAlign.center,
),
),
const SizedBox(height: 16),
CustomScriptButton(
title: _activeModName == 'Fly' ? '[ ACTIVE ] Fly' : 'Fly',
color: _activeModName == 'Fly' ? Colors.green.shade800 : Colors.green,
onPressed: () => triggerSingleMod('Fly', flyScript),
),
const SizedBox(height: 12),
CustomScriptButton(
title: _activeModName == 'Long Arms' ? '[ ACTIVE ] Long Arms' : 'Long Arms',
color: _activeModName == 'Long Arms' ? Colors.blue.shade900 :
Colors.blueAccent,
onPressed: () => triggerSingleMod('Long Arms', longArmsScript),
),
const SizedBox(height: 12),
CustomScriptButton(
title: _activeModName == 'Teleport' ? '[ ACTIVE ] Teleport' : 'Teleport',
color: _activeModName == 'Teleport' ? Colors.purple.shade900 : Colors.purple,
onPressed: () => triggerSingleMod('Teleport', teleportScript),
),
const SizedBox(height: 12),
8
CustomScriptButton(
title: _activeModName == 'Fly Up' ? '[ ACTIVE ] Fly Up' : 'Fly Up',
color: _activeModName == 'Fly Up' ? Colors.orange.shade900 : Colors.orange,
onPressed: () => triggerSingleMod('Fly Up', flyUpScript),
),
const SizedBox(height: 12),
CustomScriptButton(
title: _activeModName == 'Pull Mod' ? '[ ACTIVE ] Pull Mod' : 'Pull Mod',
color: _activeModName == 'Pull Mod' ? Colors.red.shade900 : Colors.redAccent,
onPressed: () => triggerSingleMod('Pull Mod', pullScript),
),
const SizedBox(height: 24),
ElevatedButton(
onPressed: () {
setState(() { _activeModName = 'None'; });
_executeRealADBScript('setprop debug.oculus.headlock 0');
},
style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800,
padding: const EdgeInsets.symmetric(vertical: 14)),
child: const Text('Reset / Clear All Mods', style: TextStyle(color:
Colors.white70, fontWeight: FontWeight.bold)),
),
],
),
),
);
}
}
class CustomScriptButton extends StatelessWidget {
final String title;
final Color color;
final VoidCallback onPressed;
const CustomScriptButton({
super.key,
required this.title,
required this.color,
required this.onPressed
});
@override
Widget build(BuildContext context) {
return ElevatedButton(
onPressed: onPressed,
style: ElevatedButton.styleFrom(
backgroundColor: color,
padding: const EdgeInsets.symmetric(vertical: 18),
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
),
color: Colors.white)),
child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
9
);
}
}
10